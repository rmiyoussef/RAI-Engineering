# Controller Template

> **Location:** `.brain/templates/controller.md`
> **Use:** Template for creating a thin Controller (HTTP layer only).

---

## Purpose

Controllers are **thin**. They only:
- Parse HTTP input (request data)
- Call the appropriate Service method
- Return an HTTP response

Controllers do NOT contain:
- ❌ Business logic
- ❌ Direct database queries
- ❌ Complex validation (use Form Requests)
- ❌ Business rule decisions

## Structure

```
app/Http/Controllers/Api/V1/
├── {Resource}Controller.php
```

## Controller Signature

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\{Domain}\{StoreRequest};
use App\Http\Requests\{Domain}\{UpdateRequest};
use App\Http\Resources\{Domain}\{Resource};
use App\Http\Resources\{Domain}\{ResourceCollection};
use App\Services\{Domain}\{Domain}Service;
use Illuminate\Http\JsonResponse;

class {Resource}Controller extends Controller
{
    public function __construct(
        private readonly {Domain}Service $service,
    ) {}

    /**
     * Display a listing of the resource.
     */
    public function index(): ResourceCollection
    {
        $models = $this->service->list(request()->all());
        return new ResourceCollection($models);
    }

    /**
     * Store a newly created resource.
     */
    public function store(StoreRequest $request): JsonResponse
    {
        $model = $this->service->create($request->validated());
        return response()->json([
            'data' => new Resource($model),
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(int|string $id): Resource
    {
        $model = $this->service->findOrFail($id);
        return new Resource($model);
    }

    /**
     * Update the specified resource.
     */
    public function update(UpdateRequest $request, int|string $id): Resource
    {
        $model = $this->service->update($id, $request->validated());
        return new Resource($model);
    }

    /**
     * Remove the specified resource.
     */
    public function destroy(int|string $id): JsonResponse
    {
        $this->service->delete($id);
        return response()->json(null, 204);
    }

    // ── Custom Actions ────────────────────────────────────────────

    /**
     * Custom action on a resource.
     * Route: POST /api/v1/{resource}/{id}/{action}
     */
    public function customAction(CustomRequest $request, int|string $id): JsonResponse
    {
        $result = $this->service->performAction($id, $request->validated());
        return response()->json(['data' => $result]);
    }
}
```

## Action Method Naming

| HTTP Method | Controller Method | Route Name |
|-------------|------------------|------------|
| GET (list) | `index()` | `api.v1.{resource}.index` |
| POST | `store()` | `api.v1.{resource}.store` |
| GET (single) | `show()` | `api.v1.{resource}.show` |
| PUT/PATCH | `update()` | `api.v1.{resource}.update` |
| DELETE | `destroy()` | `api.v1.{resource}.destroy` |
| POST (custom) | `{action}()` | `api.v1.{resource}.{action}` |

## Rules

1. **≤ 30 lines per method** — if longer, extract to service
2. **≤ 5 methods per controller** — if more, split into sub-controllers
3. **No `dd()`, `dump()`** — ever in committed code
4. **No inline validation** — use Form Request classes
5. **No direct DB calls** — delegate to service
6. **Return consistent responses** — use API Resource classes
7. **Inject services via constructor** — no `app()->make()`
