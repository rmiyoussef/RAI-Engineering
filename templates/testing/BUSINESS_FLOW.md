# BUSINESS FLOW TEST TEMPLATE

> **Use:** Template for testing chained business flows (multi-step processes).
> **Example:** Onboarding flow — create employee → get UUID → create contract → assign role.
> **Location:** `templates/testing/BUSINESS_FLOW.md`

---

## Flow Spec

```yaml
flow_name: {Feature Name} Flow
description: Full walkthrough of the {feature} business process
steps:
  - 1: {Step 1 action}
  - 2: {Step 2 action}
  - 3: {Step 3 action}
roles_required: [admin, manager, user]
data_persistence: true|false   # Does data carry between steps?
```

## Flow Steps Map

| Step | API Endpoint | Method | Input | Output Used Next |
|------|-------------|--------|-------|------------------|
| 1 | `/api/v1/{resource}` | POST | `{ payload }` | `{id}` |
| 2 | `/api/v1/{resource}/{id}/{action}` | POST | `{id}` | `{uuid}` |
| 3 | `/api/v1/{resource2}` | POST | `{uuid}` | `{contractId}` |
| 4 | `/api/v1/{resource2}/{id}/finalize` | POST | `{contractId}` | status |

## Full Flow Test

```php
<?php

namespace Tests\Feature\Flows;

use Tests\TestCase;
use App\Models\{User, Employee, Contract};
use Illuminate\Foundation\Testing\RefreshDatabase;

class {Feature}FlowTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private array $flowState = [];

    protected function setUp(): void
    {
        parent::setUp();
        $this->admin = User::factory()->admin()->create([
            'email' => 'admin.{feature}@example.com',
            'name' => 'Admin {Feature}',
        ]);
    }

    // ── Happy path — full flow ─────────────────────────────────────

    /** @test */
    public function it_completes_full_onboarding_flow_successfully(): void
    {
        // Step 1: Create resource
        $step1 = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/{resource}', [
                'name' => 'John Onboard',
                'email' => 'john.onboard@example.com',
                'role' => 'employee',
            ]);
        $step1->assertStatus(201);
        $resourceId = $step1->json('data.id');
        $this->flowState['resourceId'] = $resourceId;

        // Step 2: Get UUID from resource
        $step2 = $this->actingAs($this->admin, 'sanctum')
            ->getJson("/api/v1/{resource}/{$resourceId}/generate-uuid");
        $step2->assertStatus(200);
        $uuid = $step2->json('data.uuid');
        $this->flowState['uuid'] = $uuid;
        $this->assertNotNull($uuid);

        // Step 3: Create contract using UUID
        $step3 = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/contracts', [
                'employee_uuid' => $uuid,
                'type' => 'full_time',
                'salary' => 75000.00,
                'start_date' => now()->addDays(7)->toDateString(),
            ]);
        $step3->assertStatus(201);
        $contractId = $step3->json('data.id');
        $this->flowState['contractId'] = $contractId;

        // Step 4: Finalize contract
        $step4 = $this->actingAs($this->admin, 'sanctum')
            ->postJson("/api/v1/contracts/{$contractId}/finalize");
        $step4->assertStatus(200);
        $this->assertEquals('active', $step4->json('data.status'));

        // Verify final state in database
        $this->assertDatabaseHas('contracts', [
            'id' => $contractId,
            'status' => 'active',
        ]);
    }

    // ── Flow interruption — each step fails independently ──────────

    /** @test */
    public function it_returns_422_when_step1_data_is_invalid(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/{resource}', []);

        $response->assertStatus(422);
    }

    /** @test */
    public function it_returns_404_when_step2_resource_not_found(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson('/api/v1/{resource}/999999/generate-uuid');

        $response->assertStatus(404);
    }

    /** @test */
    public function it_returns_422_when_step3_uses_invalid_uuid(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/contracts', [
                'employee_uuid' => 'not-a-valid-uuid',
                'type' => 'full_time',
                'salary' => 75000.00,
            ]);

        $response->assertStatus(422);
    }

    // ── Auth at each step ─────────────────────────────────────────

    /** @test */
    public function it_blocks_unauthenticated_user_at_every_step(): void
    {
        $steps = [
            ['POST', '/api/v1/{resource}', ['name' => 'Test']],
            ['GET', '/api/v1/{resource}/1/generate-uuid'],
            ['POST', '/api/v1/contracts', ['employee_uuid' => 'fake', 'type' => 'full_time']],
        ];

        foreach ($steps as [$method, $url, $data]) {
            $response = $method === 'GET'
                ? $this->getJson($url)
                : $this->postJson($url, $data ?? []);

            $response->assertStatus(401,
                "Step {$method} {$url} should return 401 when unauthenticated"
            );
        }
    }

    // ── Role-based step access ────────────────────────────────────

    /** @test */
    public function it_prevents_unauthorized_role_from_completing_flow(): void
    {
        $user = User::factory()->create([
            'email' => 'basic.user@example.com',
            'role' => 'viewer',
        ]);

        // Step 1 — should fail if viewer can't create resources
        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/{resource}', [
                'name' => 'Unauthorized User',
                'email' => 'unauth@example.com',
            ]);

        // If viewer cannot create, expect 403
        if ($response->status() === 403) {
            $response->assertJson(['error' => ['code' => 'FORBIDDEN']]);
            return; // Flow stops here — no further steps possible
        }

        // If viewer CAN create, test next step instead
        $resourceId = $response->json('data.id');
        $step2 = $this->actingAs($user, 'sanctum')
            ->getJson("/api/v1/{resource}/{$resourceId}/generate-uuid");
        $step2->assertStatus(403);
    }

    // ── Partial flow — step 1 succeeds, step 2 fails ──────────────

    /** @test */
    public function it_handles_step2_failure_after_step1_success(): void
    {
        // Step 1: Create resource
        $resource = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/v1/{resource}', [
                'name' => 'Partial Flow User',
                'email' => 'partial@example.com',
            ]);
        $resource->assertStatus(201);
        $resourceId = $resource->json('data.id');

        // Step 2: Try with wrong payload
        $step2 = $this->actingAs($this->admin, 'sanctum')
            ->postJson("/api/v1/{resource}/{$resourceId}/custom-action", [
                'invalid_field' => 'bad data',
            ]);
        $step2->assertStatus(422);
    }

    // ── Database verification after full flow ─────────────────────

    /** @test */
    public function it_creates_correct_database_records_after_full_flow(): void
    {
        // Run steps 1-4 (or call a helper that runs the flow)
        $this->it_completes_full_onboarding_flow_successfully();

        // Assert database state
        $this->assertDatabaseHas('employees', [
            'email' => 'john.onboard@example.com',
        ]);

        $this->assertDatabaseHas('contracts', [
            'type' => 'full_time',
            'salary' => 75000.00,
        ]);

        // Verify relationships
        $employee = \App\Models\Employee::where('email', 'john.onboard@example.com')->first();
        $this->assertNotNull($employee->contract);
        $this->assertEquals('active', $employee->contract->status);
    }
}
```

## Partial Flow Tests

Test each step independently — don't always chain them:

```php
/** @test */
public function it_handles_step2_without_step1_data(): void
{
    // Test what happens when step 2 endpoint is hit without prior context
    $response = $this->actingAs($this->admin, 'sanctum')
        ->getJson('/api/v1/{resource}/0/generate-uuid');

    $response->assertStatus(404);
}
```

## Coverage Checklist

```
☐ Full flow — all steps complete successfully
☐ Full flow — database state verified after flow
☐ Partial — step 1 fails (validation)
☐ Partial — step 2 fails (not found)
☐ Partial — step 3 fails (invalid data from step 2)
☐ Auth — every step blocks unauthenticated
☐ Auth — every step blocks unauthorized role
☐ Auth — different roles get different step access
☐ Rollback — earlier steps rolled back if later step fails
☐ Duplicate — full flow cannot be re-run (idempotent)
☐ Edge — flow with min/max data values
☐ Edge — flow with special characters in inputs
```

## Output Schema

```json
{
  "flow": "{Feature}",
  "steps": 4,
  "testFile": "tests/Feature/Flows/{Feature}FlowTest.php",
  "scenariosCovered": 8,
  "scenariosTotal": 12,
  "passed": 8,
  "failed": 0,
  "flowSpecific": {
    "fullFlowPassed": true,
    "partialFlowHandled": true,
    "rollbackConfirmed": true
  },
  "notes": "Full onboarding flow verified end-to-end"
}
```
