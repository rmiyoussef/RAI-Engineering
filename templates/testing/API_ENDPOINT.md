# API ENDPOINT TEST TEMPLATE

> **Use:** Template for testing a single API endpoint (all scenarios).
> **Location:** `templates/testing/API_ENDPOINT.md`

---

## Endpoint Summary

```yaml
# ── Method & Path ────────────────────────────────────────────────
method: GET|POST|PUT|PATCH|DELETE
path: /api/v1/{resource}
version: v1

# ── Parameters ───────────────────────────────────────────────────
params:
  path:
    - name: id
      type: int|uuid|string
      required: true|false
      example: 1|550e8400-e29b-41d4-a716-446655440000
  query:
    - name: page
      type: int
      default: 1
      example: 2
    - name: per_page
      type: int
      default: 20
      example: 10
    - name: filters
      type: string
      example: status:active
  body (payload):
    - name: name
      type: string
      required: true
      min_length: 2
      max_length: 255
      example: "John Doe"
    - name: email
      type: email
      required: true
      example: "john.doe@example.com"
    - name: role
      type: enum
      values: [admin, manager, user]
      default: user
      example: admin

# ── Headers ──────────────────────────────────────────────────────
headers:
  required:
    - name: Authorization
      value: "Bearer {token}"
      description: Sanctum/JWT auth token
    - name: Accept
      value: application/json
  optional:
    - name: X-Request-Id
      value: string
      description: Idempotency key for retry safety
    - name: Idempotency-Key
      value: uuid
      description: Prevents duplicate processing

# ── Auth & Roles ─────────────────────────────────────────────────
auth:
  type: sanctum|jwt|oauth|session|api_key|none
  required: true|false
roles:
  read: [admin, manager, user]
  write: [admin, manager]
  delete: [admin]
guest_access: false|read_only

# ── Rate Limiting ────────────────────────────────────────────────
rate_limits:
  - tier: authenticated
    limit: 60
    period: 1 minute
  - tier: guest
    limit: 10
    period: 1 minute

# ── Idempotency ──────────────────────────────────────────────────
idempotent: true|false
idempotency_key_required: true|false
idempotency_window_hours: 24

# ── Validation Rules ─────────────────────────────────────────────
validation:
  - field: email
    rules:
      - required
      - email format
      - max:255
      - unique in users table
      - lowercase enforced
  - field: password
    rules:
      - required
      - min:8
      - max:128
      - regex: must have uppercase, lowercase, number, special char
  - field: role
    rules:
      - required
      - in: admin, manager, user
  - field: age
    rules:
      - integer
      - min:18
      - max:120

# ── Expected Response ────────────────────────────────────────────
response:
  success:
    status_code: 200|201|204
    body:
      data:
        id: "uuid|int"
        name: "string"
        email: "string"
        role: "string"
        created_at: "2026-07-13T00:00:00Z"
      meta:
        current_page: 1
        per_page: 20
        total: 150
        last_page: 8
  validation_error:
    status_code: 422
    body:
      error:
        code: "VALIDATION_ERROR"
        message: "The given data was invalid."
        details:
          field_name: ["The field name is required."]
  auth_error:
    status_code: 401
    body:
      error:
        code: "UNAUTHENTICATED"
        message: "Unauthenticated."
  forbidden_error:
    status_code: 403
    body:
      error:
        code: "FORBIDDEN"
        message: "Forbidden."
  not_found_error:
    status_code: 404
    body:
      error:
        code: "NOT_FOUND"
        message: "Resource not found."

# ── Security Considerations ──────────────────────────────────────
security:
  - sql_injection_protected: true
  - xss_protected: true
  - csrf_protected: true
  - rate_limited: true|false
  - data_encrypted_in_transit: true
  - sensitive_fields_filtered: [password, token, credit_card]
  - mass_assignment_protected: true
  - authorization_checked_per_action: true
  - own_data_only: false|user can only access own data

# ── Database ─────────────────────────────────────────────────────
database:
  tables:
    - users
    - profiles
  joins:
    - users LEFT JOIN profiles ON users.id = profiles.user_id
  indexes_used:
    - users.email (unique)
    - users.role
    - profiles.user_id
  query_count_expected: 2
  nplus_one_risk: false
  eager_loads: [profile, roles]

# ── Performance Targets ──────────────────────────────────────────
performance:
  response_time_ms:
    p50: < 150
    p95: < 300
    p99: < 500
    max: 1000
  payload_size_kb:
    list: < 100
    detail: < 50
  concurrent_users: 50
  queries_per_request: <= 3
  cache_strategy: "redis | null"

# ── Clean Code ───────────────────────────────────────────────────
clean_code:
  controller_lines: 45
  service_lines_if_any: 120
  validation_separate: true|false
  uses_resource_transformer: true|false
  has_query_scopes: true|false
  exceptions_handled: true|false
  logging_included: true|false
  single_responsibility: true|false

# ── Optimization Suggestions (if any) ────────────────────────────
optimizations:
  - "Add composite index on (status, created_at) for list queries"
  - "Eager load profile to avoid N+1"
  - "Cache role listing for 5 minutes — rarely changes"
  - "Use cursor pagination for large datasets"


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
