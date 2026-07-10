# Database Rules

> Rules for database design, migrations, queries, and performance.

---

## R1 — Every Table Has a Primary Key

Usually an auto-incrementing `id` column or a UUID. No tables without a primary key.

```
Schema::create('users', function (Blueprint $table) {
    $table->id();  // auto-increment primary key
    // or
    $table->uuid('id')->primary();
});
```

## R2 — Every Foreign Key Is Indexed

Foreign key columns must have indexes. Most frameworks add these automatically, but verify:

```
$table->foreignId('user_id')->constrained()->index();
//                                                    ^^^^^^^
```

If you add a foreign key manually, add the index:

```
$table->unsignedBigInteger('user_id');
$table->foreign('user_id')->references('id')->on('users');
$table->index('user_id');
```

## R3 — Every WHERE/JOIN/ORDER BY Column Is Indexed

If you filter, join, or sort by a column, it should be indexed:

```
❌ SELECT * FROM users WHERE status = 'active' ORDER BY created_at;
   -- no index on status or created_at

✅ CREATE INDEX idx_users_status_created_at ON users (status, created_at);
```

Composite indexes: put high-selectivity columns first.

## R4 — Migrations Are Irreversible Without a Down

Every migration must have a `down` method that reverses it:

```
public function up(): void {
    Schema::create('failed_jobs', function (Blueprint $table) {
        $table->id();
    });
}

public function down(): void {
    Schema::dropIfExists('failed_jobs');
}
```

Never write a migration that can't be rolled back.

## R5 — Never Change Existing Migrations

Once a migration is committed, never modify it:

- **Wrong:** Edit a migration that's already been run
- **Right:** Create a new migration to make changes

This ensures that a fresh `migrate:fresh` produces the same schema as incremental migrations.

## R6 — Use Constraints, Not Application Logic

Database constraints are more reliable than application-level checks:

```
❌ // Application-level check (race condition possible)
if (!User::where('email', $email)->exists()) {
    User::create(['email' => $email]);
}

✅ // Database-level unique constraint
$table->string('email')->unique();

// Still validate in the app for user feedback, but the DB enforces it
```

Use: `UNIQUE`, `NOT NULL`, `CHECK`, `FOREIGN KEY` constraints.

## R7 — Avoid N+1 Queries

Detect N+1 by looking for queries inside loops:

```
❌ $posts = Post::all();
    foreach ($posts as $post) {
        echo $post->author->name;  // N queries
    }

✅ $posts = Post::with('author')->get();
    foreach ($posts as $post) {
        echo $post->author->name;  // 2 queries total
    }
```

Always eager-load relationships that will be accessed in a loop.

## R8 — Select Only Needed Columns

Don't use `SELECT *` in production queries:

```
❌ $users = DB::table('users')->get();  // selects ALL columns
✅ $users = DB::table('users')->select('id', 'name', 'email')->get();
```

In ORMs, be explicit about what you need:

```
✅ User::select('id', 'name', 'email')->get();
✅ Post::with('author:id,name')->get();
```

## R9 — Paginate Large Result Sets

Never return all rows for tables that could grow beyond 100 rows:

```
❌ $users = User::all();  // could be 100k users
✅ $users = User::paginate(20);
```

For infinite scroll or large datasets, use cursor pagination:

```
✅ $users = User::cursorPaginate(20);  // fast on large datasets
```

## R10 — Use Chunking for Batch Operations

Process large datasets in chunks to avoid memory exhaustion:

```
❌ User::all()->each(function ($user) {  // loads all users into memory
        // process
    });

✅ User::chunkById(100, function ($users) {  // 100 at a time
✅     foreach ($users as $user) {
✅         // process
✅     }
✅ });
```

## R11 — Timestamps on Every Table

Every table should have `created_at` and `updated_at`:

```
$table->timestamps();  // created_at, updated_at
```

If the table is immutable (logs, audit trails), only `created_at`:

```
$table->timestamp('created_at')->nullable();
```

## R12 — Soft Deletes for Critical Data

Use soft deletes for data that shouldn't be permanently lost:

```
$table->softDeletes();  // deleted_at column
```

Data suitable for soft deletes:
- Users, orders, invoices, products
- Any data with financial or legal significance

Data NOT suitable for soft deletes:
- Logs, sessions, cache, temporary data
- Data where null conflicts cause complexity

## R13 — Use the Correct Column Types

| Data | Type | Example |
|------|------|---------|
| True/false | `boolean` | `$table->boolean('is_active')` |
| Money | `decimal(10,2)` | `$table->decimal('price', 10, 2)` |
| Large text | `text` | `$table->text('description')` |
| JSON | `json` | `$table->json('metadata')` |
| Enum-like | `string` with constraint | `$table->string('status')->default('pending')` |
| Counters | `integer` or `bigInteger` | `$table->bigInteger('view_count')->default(0)` |
| Dates | `date`, `datetime`, `timestamp` | `$table->timestamp('published_at')->nullable()` |

Don't use `string` for booleans, `integer` for flags, or `text` for short strings.
