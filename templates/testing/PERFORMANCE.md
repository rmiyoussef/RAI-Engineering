# PERFORMANCE TEST TEMPLATE

> **Use:** Template for response-time benchmarks, load tests, and query performance.
> **Location:** `templates/testing/PERFORMANCE.md`

---

## Performance Spec

```yaml
test_type: response_time|query_speed|load_test|concurrent
endpoint_or_query: {path or query}
expected_p95_ms: 500
expected_p99_ms: 1000
concurrent_users: 50
duration_seconds: 10
```

## Response Time Benchmarks

```php
<?php

namespace Tests\Performance;

use Tests\TestCase;
use App\Models\ModelA;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;

class {Feature}PerformanceTest extends TestCase
{
    use RefreshDatabase;

    private const MAX_ACCEPTABLE_MS = 500;
    private const P95_ACCEPTABLE_MS = 300;

    /** @test */
    public function list_endpoint_responds_within_time_budget(): void
    {
        ModelA::factory()->count(100)->create();

        $start = microtime(true);
        $response = $this->actingAs($this->admin(), 'sanctum')
            ->getJson($this->baseUrl);
        $duration = (microtime(true) - $start) * 1000;

        $response->assertStatus(200);
        $this->assertLessThan(
            self::MAX_ACCEPTABLE_MS,
            $duration,
            "List endpoint took {$duration}ms (max: " . self::MAX_ACCEPTABLE_MS . "ms)"
        );
    }

    /** @test】
    public function list_endpoint_performance_is_stable_over_multiple_calls(): void
    {
        ModelA::factory()->count(100)->create();
        $durations = [];

        for ($i = 0; $i < 5; $i++) {
            $start = microtime(true);
            $this->actingAs($this->admin(), 'sanctum')
                ->getJson($this->baseUrl);
            $durations[] = (microtime(true) - $start) * 1000;
        }

        $avg = array_sum($durations) / count($durations);
        $this->assertLessThan(
            self::P95_ACCEPTABLE_MS,
            $avg,
            "Average response time {$avg}ms exceeds limit"
        );
    }

    /** @test */
    public function query_under_test_data_is_complete(): void
    {
        $duration = $this->benchmarkQuery(function () {
            return ModelA::with('relation')
                ->active()
                ->paginate(20);
        });

        $this->assertLessThan(
            self::MAX_ACCEPTABLE_MS,
            $duration,
            "Query took {$duration}ms"
        );
    }

    // Helpers
    private function benchmarkQuery(callable $query): float
    {
        DB::enableQueryLog();
        $start = microtime(true);
        $query();
        $duration = (microtime(true) - $start) * 1000;
        DB::disableQueryLog();
        return $duration;
    }

    private function admin()
    {
        return \App\Models\User::factory()->admin()->create();
    }
}
```

## Query Load Test

```php
/** @test */
public function query_executes_efficiently_under_data_volume(): void
{
    // Seed realistic data volume
    ModelA::factory()->count(500)->create();
    ModelB::factory()->count(2000)->create();

    DB::enableQueryLog();

    $results = ModelA::withSum('related', 'amount')
        ->active()
        ->paginate(20);

    $queries = count(DB::getQueryLog());

    $this->assertLessThanOrEqual(3, $queries,
        "Expected ≤3 queries for paginated load, got {$queries}"
    );
    $this->assertCount(20, $results->items());
}
```

## Response Size Test

```php
/** @test */
public function list_response_size_is_within_limits(): void
{
    ModelA::factory()->count(50)->create();

    $response = $this->actingAs($this->admin(), 'sanctum')
        ->getJson($this->baseUrl);

    $responseSize = strlen($response->content());
    $this->assertLessThan(
        1024 * 100, // 100KB max
        $responseSize,
        "Response size {$responseSize} bytes exceeds 100KB limit"
    );
}
```

## Coverage Checklist

```
☐ Response time — single call under limit
☐ Response time — average over 5 calls under P95 limit
☐ Response time — cold start vs warm cache
☐ Query load — with realistic data volume
☐ Query load — with pagination
☐ Concurrent — no deadlocks under parallel requests
☐ Response size — payload within limits
☐ Slow query detection — queries over 100ms flagged
```

## Output Schema

```json
{
  "feature": "{Feature}",
  "testFile": "tests/Performance/{Feature}PerformanceTest.php",
  "results": {
    "avgResponseMs": 120,
    "p95ResponseMs": 280,
    "maxResponseMs": 450,
    "queriesCount": 2,
    "responseSizeKB": 45
  },
  "thresholds": {
    "maxMs": 500,
    "p95Ms": 300,
    "maxQueryCount": 3,
    "maxSizeKB": 100
  },
  "passed": true,
  "warnings": [],
  "notes": "Performance within acceptable thresholds"
}
```
