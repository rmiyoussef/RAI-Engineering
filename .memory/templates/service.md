# Service Class Template

> **Location:** `.memory/templates/service.md`
> **Use:** Template for creating a new Service class (business logic layer).

---

## Purpose

Services contain **business logic**. They are:
- Stateless — no properties, no constructor state
- Testable — inject dependencies, mock externals
- Single responsibility — one service = one domain concern

## Structure

```
app/Services/{Domain}/
├── {Domain}Service.php          ← Main service
├── {Domain}ServiceInterface.php ← Contract/interface
└── Concerns/
    ├── Handles{Action}.php      ← Trait for complex actions
    └── Handles{Other}.php
```

## Naming Rules

| Pattern | Example | When |
|---------|---------|------|
| `{Domain}Service` | `UserService` | Standard domain service |
| `{Action}Service` | `SendInvitationService` | Single-action service |
| `{Domain}Manager` | `OrderManager` | Orchestrates multiple services |

## Service Signature

```php
<?php

namespace App\Services\{Domain};

use App\Models\{Model};
use App\Repositories\{Domain}\{Model}Repository;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class {Domain}Service
{
    /**
     * @param {Model}Repository $repository
     */
    public function __construct(
        private readonly {Model}Repository $repository,
    ) {
        //
    }

    // ── CRUD ──────────────────────────────────────────────────────

    public function list(array $filters = []): LengthAwarePaginator
    {
        return $this->repository->paginate($filters);
    }

    public function create(array $data): {Model}
    {
        return DB::transaction(function () use ($data) {
            $model = $this->repository->create($data);
            // ... side effects (events, notifications, logs)
            Log::info('{Model} created', ['id' => $model->id]);
            return $model;
        });
    }

    public function update(int|string $id, array $data): {Model}
    {
        return DB::transaction(function () use ($id, $data) {
            $model = $this->repository->findOrFail($id);
            $this->repository->update($model, $data);
            Log::info('{Model} updated', ['id' => $model->id]);
            return $model->fresh();
        });
    }

    public function delete(int|string $id): void
    {
        DB::transaction(function () use ($id) {
            $model = $this->repository->findOrFail($id);
            $this->repository->delete($model);
            Log::info('{Model} deleted', ['id' => $id]);
        });
    }

    // ── Business Logic ────────────────────────────────────────────

    public function performBusinessAction(int|string $id, array $params): {Model}
    {
        // 1. Validate business rules
        // 2. Execute domain logic
        // 3. Persist changes
        // 4. Dispatch events
        // 5. Return result
    }
}
```

## Rules

1. **Services call repositories**, not Eloquent directly (except simple reads)
2. **Services are stateless** — no properties holding request data
3. **Transactions for writes** — `DB::transaction()` for every mutation
4. **Logging** — log every create/update/delete with context
5. **Events** — dispatch domain events after state changes
6. **Validation is the Controller's job** — services receive already-validated data
7. **Returns models or DTOs** — never returns raw arrays or JSON
8. **Throws domain exceptions** — `throw new {Domain}Exception('message')`
9. **Testable** — inject repository mock in tests, assert methods called
