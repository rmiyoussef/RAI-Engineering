# DATABASE QUERY TEST TEMPLATE

> **Use:** Template for testing database queries, N+1 detection, index usage, and migrations.
> **Location:** `templates/testing/DATABASE_QUERY.md`

---

## Query Spec

```yaml
query_type: SELECT|INSERT|UPDATE|DELETE|JOIN|AGGREGATE
model: ModelName
relationships: [relation1, relation2]
indexes_used: [column1, column2]
expects_nplus_one: false
critical: true|false
```

## Test Scenarios

```php
<?php

namespace Tests\Unit\Queries;

use Tests\TestCase;
use App\Models\{ModelA, ModelB};
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;

class {Model}QueryTest extends TestCase
{
    use RefreshDatabase;

    // ── Query Correctness ─────────────────────────────────────────

    /** @test */
    public function it_returns_correct_active_records(): void
    {
        ModelA::factory()->active()->count(3)->create();
        ModelA::factory()->inactive()->count(2)->create();

        $results = ModelA::active()->get();

        $this->assertCount(3, $results);
        $results->each(fn($r) => $this->assertTrue($r->is_active));
    }

    /** @test */
    public function it_returns_correct_filtered_results(): void
    {
        ModelA::factory()->count(5)->create(['status' => 'pending']);
        ModelA::factory()->count(3)->create(['status' => 'approved']);

        $results = ModelA::where('status', 'approved')->get();

        $this->assertCount(3, $results);
    }

    // ── Relationship Loading (N+1 Detection) ──────────────────────

    /** @test */
    public function it_does_not_have_nplus_one_when_loading_relations(): void
    {
        $models = ModelA::factory()->count(5)
            ->has(ModelB::factory()->count(2))
            ->create();

        DB::enableQueryLog();

        $results = ModelA::with('relatedModels')->get();
        $queries = count(DB::getQueryLog());

        // 1 query for models + 1 query for relations = 2 total
        $this->assertLessThanOrEqual(3, $queries,
            "Expected ≤3 queries, got {$queries}. Possible N+1 issue."
        );
    }

    // ── Eager Loading vs Lazy Loading ─────────────────────────────

    /** @test */
    public function it_correctly_eager_loads_nested_relations(): void
    {
        $model = ModelA::factory()
            ->has(ModelB::factory()->has(ModelC::factory()))
            ->create();

        DB::enableQueryLog();

        $result = ModelA::with('relationB.relationC')->find($model->id);
        $queries = count(DB::getQueryLog());

        // Should be 3 queries max: parent + relationB + relationC
        $this->assertLessThanOrEqual(3, $queries,
            "Nested eager loading should use ≤3 queries, got {$queries}"
        );
        $this->assertNotNull($result->relationB->first()->relationC);
    }

    // ── Scopes ────────────────────────────────────────────────────

    /** @test */
    public function it_applies_query_scopes_correctly(): void
    {
        ModelA::factory()->count(3)->create(['status' => 'active']);
        ModelA::factory()->count(2)->create(['status' => 'archived']);

        $activeScope = ModelA::active()->get();
        $this->assertCount(3, $activeScope);
        $activeScope->each(fn($m) => $this->assertEquals('active', $m->status));
    }

    // ── Aggregations ──────────────────────────────────────────────

    /** @test */
    public function it_aggregates_data_correctly(): void
    {
        ModelA::factory()->count(5)->create(['amount' => 100]);
        ModelA::factory()->count(3)->create(['amount' => 200]);

        $total = ModelA::sum('amount');
        $this->assertEquals(1100, $total);

        $average = ModelA::average('amount');
        $this->assertEquals(137.5, $average);
    }
}
```

## Migration Test

```php
/** @test */
public function migration_can_be_rolled_back(): void
{
    // Run the migration up
    $this->artisan('migrate');

    // Assert table exists
    $this->assertTrue(Schema::hasTable('{table_name}'));

    // Rollback
    $this->artisan('migrate:rollback', ['--step' => 1]);

    // Assert table gone
    $this->assertFalse(Schema::hasTable('{table_name}'));

    // Re-run
    $this->artisan('migrate');
    $this->assertTrue(Schema::hasTable('{table_name}'));
}

/** @test */
public function migration_has_correct_columns(): void
{
    $this->artisan('migrate');

    $columns = Schema::getColumnListing('{table_name}');
    $expected = ['id', 'name', 'created_at', 'updated_at'];

    foreach ($expected as $column) {
        $this->assertContains($column, $columns,
            "Column '{$column}' missing from {table_name} table"
        );
    }
}

/** @test */
public function foreign_keys_are_indexed(): void
{
    $this->artisan('migrate');

    $indexes = DB::select("SHOW INDEX FROM {table_name}");
    $indexedColumns = array_column($indexes, 'Column_name');

    $this->assertContains('user_id', $indexedColumns,
        "Foreign key column 'user_id' is not indexed"
    );
}
```

## Coverage Checklist

```
☐ Query correctness — returns right rows
☐ Query correctness — returns right columns
☐ Filtering — WHERE clauses work
☐ Filtering — scope methods return correct subset
☐ Relationships — no N+1 (verify query count)
☐ Relationships — eager vs lazy loading behavior
☐ Aggregations — sum, avg, count, min, max
☐ Ordering — ORDER BY works correctly
☐ Pagination — limit/offset or cursor
☐ Migrations — up and down are reversible
☐ Migrations — columns are correct types
☐ Migrations — foreign keys are indexed
☐ Constraints — unique constraint violation returns error
☐ Constraints — foreign key cascade deletes work
```

## Output Schema

```json
{
  "model": "ModelName",
  "testFile": "tests/Unit/Queries/{Model}QueryTest.php",
  "queriesAnalyzed": 8,
  "nplusOneDetected": false,
  "missingIndexesFound": 0,
  "migrationSafe": true,
  "notes": "All queries optimized. No N+1 detected."
}
```
