# Full CRUD Template

> **Location:** `.memory/templates/crud.md`
> **Use:** Complete CRUD generation — model, migration, controller, service, routes, tests.

---

## CRUD Checklist

```
☐ Migration — create table with all columns + indexes + foreign keys
☐ Model — fillable, casts, relationships, scopes
☐ Repository — Eloquent query methods
☐ Service — business logic with transaction support
☐ Controller — thin HTTP layer (index, store, show, update, destroy)
☐ Form Requests — StoreRequest + UpdateRequest with validation rules
☐ API Resource — single + collection transformer
☐ Routes — apiResource with custom actions
☐ Tests — Feature test with all 15+ scenarios
```

---

## 1. Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('{table_name}', function (Blueprint $table) {
            $table->id();
            $table->uuid()->unique();                          // Public ID
            $table->foreignId('user_id')->constrained()->index(); // FK + index
            $table->string('name', 255);
            $table->string('email')->unique();
            $table->string('status')->default('pending');
            $table->text('description')->nullable();
            $table->decimal('amount', 10, 2)->nullable();
            $table->json('metadata')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->softDeletes();                              // Soft delete
            $table->timestamps();

            // Composite indexes
            $table->index(['status', 'created_at']);
            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('{table_name}');
    }
};
```

## 2. Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class {Model} extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name', 'email', 'status', 'description',
        'amount', 'metadata', 'published_at',
    ];

    protected $casts = [
        'metadata' => 'array',
        'amount' => 'decimal:2',
        'published_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function (self $model) {
            $model->uuid = (string) Str::uuid();
        });
    }

    // ── Relationships ───────────────────────────────────────────

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // ── Scopes ───────────────────────────────────────────────────

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', 'active');
    }

    public function scopePending(Builder $query): Builder
    {
        return $query->where('status', 'pending');
    }

    public function scopeForUser(Builder $query, int $userId): Builder
    {
        return $query->where('user_id', $userId);
    }
}
```

## 3. Factory

```php
<?php

namespace Database\Factories;

use App\Models\{Model};
use Illuminate\Database\Eloquent\Factories\Factory;

class {Model}Factory extends Factory
{
    protected $model = {Model}::class;

    public function definition(): array
    {
        return [
            'name' => fake()->company(),
            'email' => fake()->unique()->companyEmail(),
            'status' => 'pending',
            'description' => fake()->sentence(),
            'amount' => fake()->randomFloat(2, 100, 10000),
            'metadata' => ['source' => 'manual', 'priority' => 'normal'],
            'published_at' => null,
            'user_id' => {Model}::factory(),
        ];
    }

    public function active(): static
    {
        return $this->state(['status' => 'active', 'published_at' => now()]);
    }

    public function inactive(): static
    {
        return $this->state(['status' => 'inactive']);
    }
}
```

## 4. Service

See [service template](service.md) for full service pattern.

## 5. Controller

See [controller template](controller.md) for full controller pattern.

## 6. Form Requests

```php
// Store{Model}Request.php
class Store{Model}Request extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', {Model}::class);
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:{table_name},email'],
            'status' => ['required', 'in:pending,active,inactive'],
            'amount' => ['nullable', 'numeric', 'min:0', 'max:999999.99'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'A name is required.',
            'email.unique' => 'This email is already in use.',
        ];
    }
}
```

## 7. Routes

```php
Route::apiResource('{resource}', {Model}Controller::class)->parameters([
    '{resource}' => 'id',
]);

// Custom action routes
Route::prefix('{resource}/{id}')->group(function () {
    Route::post('publish', [{Model}Controller::class, 'publish']);
    Route::post('archive', [{Model}Controller::class, 'archive']);
});
```

## 8. Tests

See `templates/testing/API_ENDPOINT.md` for full 15+ test scenarios.

## CRUD Timeline

| Step | File | Depends On |
|------|------|------------|
| 1 | Migration | — |
| 2 | Model | Migration |
| 3 | Factory | Model |
| 4 | Repository | Model |
| 5 | Service | Repository |
| 6 | Form Requests | Model (validation rules) |
| 7 | Controller | Service + Form Requests |
| 8 | API Resource | Model |
| 9 | Routes | Controller |
| 10 | Tests | All of the above |

## Git Commit Pattern

```
feat: add {Model} CRUD — migration, model, service, controller, tests

- Migration for {table_name} with indexes + soft deletes
- Model with relationships, scopes, UUID generation
- Factory with realistic test data
- Service with create/update/delete with transactions
- Controller with index/store/show/update/destroy
- Form requests with validation rules
- API Resource + Collection transformers
- Routes as apiResource
- Feature tests with 15+ scenarios
```
