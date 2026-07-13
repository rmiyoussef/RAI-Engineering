# API ENDPOINT TEST TEMPLATE

> **Use:** Template for testing a single API endpoint (all scenarios).
> **Location:** `templates/testing/API_ENDPOINT.md`

---

## Endpoint Spec

```yaml
method: GET|POST|PUT|PATCH|DELETE
path: /api/v1/{resource}
auth: required|optional|none
roles: [admin, manager, user]
rate_limit: true|false
idempotent: true|false
```

## Test Scenarios

Each endpoint gets **ALL** of the following scenarios:

```php
<?php

namespace Tests\Feature\Api\V1;

use Tests\TestCase;
use App\Models\{Resource, User};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;

class ResourceTest extends TestCase
{
    use RefreshDatabase;

    private string $baseUrl = '/api/v1/{resource}';
    private ?User $admin = null;
    private ?User $user = null;

    protected function setUp(): void
    {
        parent::setUp();
        $this->admin = User::factory()->admin()->create([
            'email' => 'admin.{resource}@example.com',
            'name' => 'Admin Resource',
        ]);
        $this->user = User::factory()->create([
            'email' => 'user.{resource}@example.com',
            'name' => 'Normal User',
        ]);
    }

    // ── Happy Path ────────────────────────────────────────────────

    /** @test */
    public function it_can_list_resources(): void
    {
        Resource::factory()->count(3)->create();

        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson($this->baseUrl);

        $response->assertStatus(200)
            ->assertJsonStructure(['data', 'meta']);
    }

    /** @test */
    public function it_can_create_a_resource(): void
    {
        $payload = Resource::factory()->definition();

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson($this->baseUrl, $payload);

        $response->assertStatus(201)
            ->assertJsonStructure(['data' => ['id']]);
    }

    /** @test */
    public function it_can_show_a_resource(): void
    {
        $resource = Resource::factory()->create();

        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson("{$this->baseUrl}/{$resource->id}");

        $response->assertStatus(200)
            ->assertJson(['data' => ['id' => $resource->id]]);
    }

    /** @test */
    public function it_can_update_a_resource(): void
    {
        $resource = Resource::factory()->create();
        $newData = ['name' => 'Updated Resource Name'];

        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("{$this->baseUrl}/{$resource->id}", $newData);

        $response->assertStatus(200);
        $this->assertDatabaseHas('resources', ['name' => 'Updated Resource Name']);
    }

    /** @test */
    public function it_can_delete_a_resource(): void
    {
        $resource = Resource::factory()->create();

        $response = $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("{$this->baseUrl}/{$resource->id}");

        $response->assertStatus(204);
        $this->assertDatabaseMissing('resources', ['id' => $resource->id]);
    }

    // ── Validation ────────────────────────────────────────────────

    /** @test */
    public function it_returns_422_for_invalid_data(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson($this->baseUrl, []);

        $response->assertStatus(422)
            ->assertJsonStructure(['error' => ['code', 'message', 'details']])
            ->assertJson(['error' => ['code' => 'VALIDATION_ERROR']]);
    }

    /** @test */
    public function it_returns_422_for_missing_required_fields(): void
    {
        $payload = Resource::factory()->definition();
        unset($payload['required_field']);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson($this->baseUrl, $payload);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['required_field']);
    }

    // ── Auth ──────────────────────────────────────────────────────

    /** @test */
    public function it_returns_401_when_unauthenticated(): void
    {
        $response = $this->getJson($this->baseUrl);

        $response->assertStatus(401);
    }

    /** @test */
    public function it_returns_401_when_token_is_invalid(): void
    {
        $response = $this->withHeaders(['Authorization' => 'Bearer invalid-token'])
            ->getJson($this->baseUrl);

        $response->assertStatus(401);
    }

    // ── Authorization ─────────────────────────────────────────────

    /** @test */
    public function it_returns_403_for_unauthorized_role(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson($this->baseUrl, Resource::factory()->definition());

        // If this endpoint requires admin role
        if (method_exists($this, 'requiresAdminRole') && $this->requiresAdminRole()) {
            $response->assertStatus(403)
                ->assertJson(['error' => ['code' => 'FORBIDDEN']]);
        } else {
            $response->assertStatus(201);
        }
    }

    // ── Not Found ─────────────────────────────────────────────────

    /** @test */
    public function it_returns_404_when_resource_not_found(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson("{$this->baseUrl}/999999");

        $response->assertStatus(404)
            ->assertJson(['error' => ['code' => 'NOT_FOUND']]);
    }

    /** @test */
    public function it_returns_404_for_update_on_nonexistent_resource(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->putJson("{$this->baseUrl}/999999", ['name' => 'Nope']);

        $response->assertStatus(404);
    }

    /** @test */
    public function it_returns_404_for_delete_on_nonexistent_resource(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->deleteJson("{$this->baseUrl}/999999");

        $response->assertStatus(404);
    }

    // ── Edge Cases ────────────────────────────────────────────────

    /** @test */
    public function it_returns_empty_list_when_no_resources(): void
    {
        $response = $this->actingAs($this->admin, 'sanctum')
            ->getJson($this->baseUrl);

        $response->assertStatus(200)
            ->assertJson(['data' => []])
            ->assertJson(['meta' => ['total' => 0]]);
    }

    /** @test */
    public function it_paginates_results_correctly(): void
    {
        Resource::factory()->count(25)->create();

        $page1 = $this->actingAs($this->admin, 'sanctum')
            ->getJson("{$this->baseUrl}?page=1&per_page=10");
        $page1->assertStatus(200)
            ->assertJsonCount(10, 'data')
            ->assertJson(['meta' => ['current_page' => 1, 'total' => 25]]);

        $page2 = $this->actingAs($this->admin, 'sanctum')
            ->getJson("{$this->baseUrl}?page=2&per_page=10");
        $page2->assertStatus(200)
            ->assertJsonCount(10, 'data')
            ->assertJson(['meta' => ['current_page' => 2]]);
    }

    /** @test */
    public function it_handles_max_length_inputs(): void
    {
        $payload = Resource::factory()->definition();
        $payload['name'] = str_repeat('A', 255);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson($this->baseUrl, $payload);

        // Should either succeed (255 is valid) or return 422 (if shorter limit)
        $this->assertContains($response->status(), [201, 422]);
    }

    // ── Idempotency (if applicable) ───────────────────────────────

    /** @test */
    public function it_handles_duplicate_submission_gracefully(): void
    {
        $resource = Resource::factory()->create();
        $payload = Resource::factory()->definition();
        $payload['unique_field'] = $resource->unique_field;

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson($this->baseUrl, $payload);

        $response->assertStatus(409)
            ->assertJson(['error' => ['code' => 'CONFLICT']]);
    }
}
```

## Coverage Checklist

```
☐ Happy Path — list
☐ Happy Path — create
☐ Happy Path — show
☐ Happy Path — update
☐ Happy Path — delete
☐ Validation — empty payload (422)
☐ Validation — missing required fields (422)
☐ Validation — invalid data types (422)
☐ Auth — no token (401)
☐ Auth — invalid token (401)
☐ Auth — expired token (401)
☐ Authorization — wrong role (403)
☐ Not Found — nonexistent ID (404)
☐ Not Found — deleted resource (404)
☐ Edge — empty collection (200, [])
☐ Edge — pagination (per_page, page)
☐ Edge — max length inputs
☐ Edge — special characters / SQL injection attempt
☐ Idempotency — duplicate unique field (409)
☐ Soft Delete — deleted resource not in list
```

## Output Schema

```json
{
  "endpoint": "{method} {path}",
  "testFile": "tests/Feature/Api/V1/{Resource}Test.php",
  "scenariosCovered": 15,
  "scenariosTotal": 20,
  "passed": 15,
  "failed": 0,
  "skipped": 5,
  "notes": "5 edge cases skipped due to framework defaults",
  "securityIssues": []
}
```
