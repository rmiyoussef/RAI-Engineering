# 🗄️ Database Migration Test

> **Mode:** Database Migration
> **Purpose:** Verify migration safety, up/down idempotency, index integrity, and rollback correctness
> **Use when:** Creating or modifying any database migration

---

## Migration Metadata

| Field | Value |
|-------|-------|
| **Migration file** | `database/migrations/XXXX_XX_XX_XXXXXX_create_<table>_table.php` |
| **Table** | `<table_name>` |
| **Action** | `create table | add column | modify column | drop column | add index | drop index | add foreign key` |
| **Framework** | Laravel / Rails / Django / Prisma / Raw SQL |
| **Environment** | `testing` (separate DB from dev/prod) |

---

## Test Scenarios

### 1. ✅ Up Migration — Creates Schema Correctly

```php
/** @test */
public function migration_creates_expected_table()
{
    // Refresh migration from scratch
    Artisan::call('migrate:fresh', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);

    // Assert table exists
    $this->assertTrue(Schema::hasTable('<table>'));

    // Assert all expected columns exist with correct types
    $columns = Schema::getColumnListing('<table>');
    $this->assertContains('id', $columns);
    $this->assertContains('created_at', $columns);
    $this->assertContains('updated_at', $columns);
    // ... assert each column your migration creates

    // Assert column types
    $this->assertEquals('string', Schema::getColumnType('<table>', 'email'));
    $this->assertEquals('bigint', Schema::getColumnType('<table>', 'user_id'));
}
```

### 2. ⬇️ Down Migration — Rolls Back Cleanly

```php
/** @test */
public function migration_rolls_back_cleanly()
{
    // Run up
    Artisan::call('migrate', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);
    $this->assertTrue(Schema::hasTable('<table>'));

    // Rollback
    Artisan::call('migrate:rollback', ['--step' => 1]);

    // Assert table is gone (or column reverted if alter)
    $this->assertFalse(Schema::hasTable('<table>'));
    // For column modifications:
    // $this->assertFalse(Schema::hasColumn('<table>', '<new_column>'));
}
```

### 3. 🔁 Up/Down Idempotency — Run Twice, Same Result

```php
/** @test */
public function migration_up_down_cycle_is_idempotent()
{
    // Cycle 1
    Artisan::call('migrate', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);
    Artisan::call('migrate:rollback', ['--step' => 1]);
    $this->assertFalse(Schema::hasTable('<table>'));

    // Cycle 2 — should work identically
    Artisan::call('migrate', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);
    Artisan::call('migrate:rollback', ['--step' => 1]);
    $this->assertFalse(Schema::hasTable('<table>'));
}
```

### 4. 📊 Index Integrity — Verify All Indexes

```php
/** @test */
public function migration_creates_expected_indexes()
{
    Artisan::call('migrate:fresh', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);

    $indexes = DB::select("SHOW INDEX FROM `<table>`");
    $indexNames = array_column($indexes, 'Key_name');

    $this->assertContains('<table>_<column>_index', $indexNames);
    // Assert primary, unique, foreign, composite indexes
}
```

### 5. 🔗 Foreign Key Enforcement

```php
/** @test */
public function foreign_key_enforces_referential_integrity()
{
    // Given a parent record exists
    $parent = ParentModel::factory()->create();

    // When creating child with valid FK — should succeed
    $child = ChildModel::factory()->create(['parent_id' => $parent->id]);
    $this->assertNotNull($child);

    // When creating child with invalid FK — should fail
    $this->expectException(\Illuminate\Database\QueryException::class);
    ChildModel::factory()->create(['parent_id' => 99999]);
}
```

### 6. ⚡ Nullable / Default Handling

```php
/** @test */
public function nullable_columns_accept_null()
{
    Artisan::call('migrate:fresh', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);

    // Insert record with all nullable columns as null
    $record = Model::factory()->create([
        '<nullable_column>' => null,
    ]);

    $this->assertDatabaseHas('<table>', [
        'id' => $record->id,
        '<nullable_column>' => null,
    ]);
}

/** @test */
public function default_values_are_applied()
{
    Artisan::call('migrate:fresh', ['--path' => 'database/migrations/XXXX_XX_XX_XXXXXX_...']);

    // Insert record without specifying default column
    $record = Model::factory()->create([
        '<default_column>' => null, // let default apply
    ]);

    $this->assertEquals('<expected_default>', $record->fresh()-><default_column>);
}
```

### 7. 🔄 Data Migration Safety (for data migrations)

```php
/** @test */
public function data_migration_transforms_correctly()
{
    // Given existing data in old format
    $old = OldModel::factory()->create(['old_field' => 'old_value']);

    // Run data migration
    Artisan::call('migrate');

    // Assert data was transformed
    $this->assertDatabaseHas('<new_table>', [
        'id' => $old->id,
        'new_field' => 'transformed_value',
    ]);
}

/** @test */
public function data_migration_is_idempotent()
{
    // Run data migration twice
    Artisan::call('migrate');
    Artisan::call('migrate');

    // Assert no duplicate records
    $this->assertEquals(1, NewModel::count());
}
```

---

## Schema Verification Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Table created/dropped correctly | ☐ | |
| All columns present with correct types | ☐ | |
| Nullable/required constraints set | ☐ | |
| Default values applied | ☐ | |
| Primary key exists | ☐ | |
| Foreign keys reference correct tables/columns | ☐ | |
| Indexes created (query-planned) | ☐ | |
| Composite indexes in correct order | ☐ | |
| No duplicate indexes | ☐ | |
| `onDelete` / `onUpdate` set on FKs | ☐ | |
| Rollback reverses all changes | ☐ | |
| Idempotent (up/down/up/down) | ☐ | |
| Timestamps handled (nullable/required) | ☐ | |
| Soft deletes column exists if needed | ☐ | |

---

## Run Command

```bash
# Test specific migration
php artisan test --filter MigrationTest

# Or run migration tests group
php artisan test --group=migration
```

---

## Template Variables

| Variable | Description |
|----------|-------------|
| `<table>` | Primary table name |
| `<column>` | Column being modified |
| `<new_column>` | Column being added |
| `<default_column>` | Column with default value |
| `<nullable_column>` | Column that should accept null |
| `<expected_default>` | Expected default value string |
| `<parent_id>` | Foreign key column name |
| `<table>_<column>_index` | Expected index name convention |
