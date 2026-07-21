# API Resource Template

> **Location:** `.brain/templates/resource.md`
> **Use:** Template for creating an API Resource/Transformer.

---

## Purpose

API Resources control **what data is returned** in API responses. They:
- Transform models to JSON
- Hide sensitive fields (passwords, internal IDs)
- Include related resources
- Keep response format consistent

## Structure

```
app/Http/Resources/{Domain}/
├── {Model}Resource.php          ← Single model transformer
├── {Model}Collection.php        ← Collection transformer
```

## Single Resource

```php
<?php

namespace App\Http\Resources\{Domain};

use App\Http\Resources\UserResource;
use App\Models\{Model};
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin {Model} */
class {Model}Resource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,                    // Use UUID, not DB ID
            'name' => $this->name,
            'email' => $this->email,
            'status' => $this->status,
            'role' => $this->role,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),

            // Conditionally include relationships
            $this->mergeWhen(
                $this->relationLoaded('profile'),
                ['profile' => new ProfileResource($this->whenLoaded('profile'))]
            ),

            // Include count when loaded
            $this->mergeWhen(
                $this->relationLoaded('posts'),
                ['posts_count' => $this->posts_count ?? $this->posts->count()]
            ),
        ];
    }

    /**
     * Customize the response for an API response.
     */
    public function withResponse(Request $request, JsonResponse $response): void
    {
        $response->header('X-Resource-Version', '1.0');
    }
}
```

## Collection Resource

```php
<?php

namespace App\Http\Resources\{Domain};

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;

class {Model}Collection extends ResourceCollection
{
    public $collects = {Model}Resource::class;

    /**
     * Transform the resource collection into an array.
     */
    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection,
            'meta' => [
                'current_page' => $this->resource->currentPage(),
                'per_page' => $this->resource->perPage(),
                'total' => $this->resource->total(),
                'last_page' => $this->resource->lastPage(),
            ],
        ];
    }
}
```

## Fields to NEVER Include

- ❌ `password` / `password_hash`
- ❌ `remember_token`
- ❌ `api_token`
- ❌ `internal_id` / auto-increment ID
- ❌ `deleted_at` (unless explicitly requested)
- ❌ `pivot` data (unless needed)
- ❌ `email_verified_at` (unless relevant to feature)

## Rules

1. **Use UUIDs** as public IDs, never auto-increment DB IDs
2. **ISO 8601 dates** — `$this->created_at?->toISOString()`
3. **Eager load before accessing relations** — `$this->whenLoaded()`
4. **Omit null fields** — unless they have meaning (e.g., `deleted_at`)
5. **Use `$this->mergeWhen()`** for conditional inclusions
6. **One resource per model** — don't create multiple variants
7. **Collection always has `meta`** — pagination info
