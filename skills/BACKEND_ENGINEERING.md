# Backend Engineering Skill

> Deep patterns for backend code quality, database optimization, API security, and testing with realistic mock data.
> Loaded by the BACKEND QA agent.

---

## 1. Clean Code Patterns

### SOLID in Practice

**Single Responsibility — the symptom check**
Ask: "If I need to change this class, how many reasons could I have?"
- Reason 1: Business logic changed → one class
- Reason 2: Storage format changed → different class
- Reason 3: Notification method changed → different class
- If one class triggers multiple reasons, split it.

**Dependency Injection, not Dependency Location**
```php
// ❌ Bad — hidden dependency
class OrderController {
    public function ship($id) {
        $order = Order::findOrFail($id);
        Mail::send(new ShippedMail($order));  // static facade, untestable
    }
}

// ✅ Good — explicit dependency
class OrderController {
    public function __construct(
        private OrderService $orderService,
        private Mailer $mailer
    ) {}

    public function ship($id) {
        $order = $this->orderService->findOrFail($id);
        $this->mailer->send(new ShippedMail($order));
    }
}
```

### Error Handling Patterns

**Fail fast, fail specific**
```php
// ❌ Bad — generic exception swallows context
throw new \Exception('User not found');

// ✅ Good — specific exception carries context
throw new UserNotFoundException($userId);
```

**Never return error strings. Throw exceptions.**
```php
// ❌ Bad
return ['error' => 'User not found', 'code' => 404];

// ✅ Good
throw new UserNotFoundException($userId);
// Catch at a single boundary (controller middleware or handler)
```

**Log at the right level**
| Level | When |
|-------|------|
| `debug` | Development-only, verbose |
| `info` | Normal operations (user registered, email sent) |
| `warning` | Something unexpected but handled (rate limit hit, retry) |
| `error` | Something failed but system continues (payment failed) |
| `critical` | System is degraded or stopping (database down) |

### Code Organization

**Controllers: Thin, stateless, one method per action**
```php
// ❌ Bad — fat controller
class UserController {
    public function store(Request $r) {
        // validation, business logic, email, response — all here
    }
}

// ✅ Good — thin controller delegates to service
class UserController {
    public function __construct(private UserService $service) {}

    public function store(StoreUserRequest $request): JsonResponse {
        $user = $this->service->create($request->validated());
        return response()->json($user, 201);
    }
}
```

**Services: One responsibility, stateless, testable**
```php
class RegistrationService {
    public function __construct(
        private UserRepository $users,
        private Mailer $mailer,
        private Logger $logger
    ) {}

    public function register(array $data): User {
        $user = $this->users->create($data);
        $this->mailer->send(new WelcomeMail($user));
        $this->logger->info('User registered', ['id' => $user->id]);
        return $user;
    }
}
```

---

## 2. Query Optimization Patterns

### N+1 Detection

**The pattern:**
```php
// ❌ N+1 — 1 query for posts + N queries for comments
$posts = Post::all();
foreach ($posts as $post) {
    $post->comments;  // N queries
}

// ✅ Fixed — 2 queries total
$posts = Post::with('comments')->get();
```

**How to detect:**
- Any relationship accessed inside a loop = N+1 candidate
- Any lazy-loaded relationship outside the scope where it was eager-loaded
- Check for `$model->relation` inside `foreach`, `map`, `filter`, `each`

### Eager Loading Strategies

**Default eager load for frequently used relationships:**
```php
class Post extends Model {
    protected $with = ['author:id,name'];  // Only in specific models
}
```

**Select only needed columns on relationships:**
```php
// ✅ Good — don't load all columns on related models
Post::with('author:id,name,email')->get();
```

**Nested eager loading:**
```php
Post::with(['comments' => fn($q) => $q->latest(), 'comments.user:id,name'])->get();
```

### Indexing Rules

**Index every:**
- `WHERE` column
- `JOIN` column (foreign keys)
- `ORDER BY` column
- `GROUP BY` column

**Composite index column order — put high-selectivity columns first:**
```sql
-- Good: status has low cardinality (3 values), created_at has high cardinality
INDEX idx_status_created_at (status, created_at)

-- Bad: created_at first means the index is less useful for status queries
INDEX idx_created_at_status (created_at, status)
```

**Covering indexes:**
```sql
-- If you always query these two columns together
SELECT id, email FROM users WHERE status = 'active';
-- Index covers the query entirely (no table access)
INDEX idx_status_id_email (status, id, email)
```

### Query Volume Rules

- **< 10 queries per page load:** Green
- **10-50 queries per page load:** Yellow, investigate
- **> 50 queries per page load:** Red, must optimize
- **API endpoints should use < 5 queries total for 95% of requests**

### Cursor vs Offset Pagination

```php
// ❌ Offset — slow on large datasets (must scan skipped rows)
$users = User::orderBy('id')->skip(10000)->take(20)->get();

// ✅ Cursor — fast on any dataset size (WHERE id > last_seen)
$users = User::orderBy('id')->where('id', '>', $cursor)->take(20)->get();
```

Use cursor pagination for:
- Infinite scroll
- Large datasets (> 10k rows)
- Real-time feeds

Use offset pagination only for:
- Page-number navigation (classic paginator)
- Small datasets
- Admin panels

---

## 3. Security Patterns

### Input Validation

**Whitelist, don't blacklist:**
```php
// ❌ Bad — blacklist approach
$sort = str_replace(['drop', 'delete', 'union'], '', $request->sort);

// ✅ Good — whitelist approach
$allowedSorts = ['name', 'email', 'created_at'];
$sort = in_array($request->sort, $allowedSorts) ? $request->sort : 'name';
```

**Validation at the boundary (Form Requests in Laravel):**
```php
class StoreUserRequest extends FormRequest {
    public function rules(): array {
        return [
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:12|regex:/[A-Z]/|regex:/[0-9]/|regex:/[!@#$%^&*]/',
            'role' => 'required|in:admin,editor,viewer',
        ];
    }
}
```

### Authentication Hardening

**Rate limit login:**
```php
// 5 attempts per minute per email + IP
RateLimiter::for('login', fn($job) => $job
    ->by($request->input('email') . '|' . $request->ip())
    ->max(5)
    ->decay(60)
);
```

**Use dedicated authentication rate limits for each endpoint type:**
- Login: 5/min per IP+email
- Registration: 3/hour per IP
- Password reset: 3/hour per email
- API keys: 1000/min per key (standard), custom per tier

### Authorization Patterns

**Always verify ownership, not just role:**
```php
// ❌ Bad — checks role but not ownership
if ($user->role !== 'admin') abort(403);

// ✅ Good — checks ownership
public function update(Post $post, Request $request): JsonResponse {
    $this->authorize('update', $post);  // PostPolicy checks ownership
    // ...
}
```

**Use policies, not closures in routes:**
```php
// ✅ Good — centralized policy
class PostPolicy {
    public function update(User $user, Post $post): bool {
        return $user->id === $post->user_id || $user->isAdmin();
    }
}
```

### Data Exposure Prevention

**API Resources for output control:**
```php
// ✅ Good — explicit output shape
class UserResource extends JsonResource {
    public function toArray($request): array {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,  // intentional
            'role' => $this->role,
            'createdAt' => $this->created_at,
        ];
    }
}
```

**Never return models directly:**
```php
// ❌ Bad — exposes all model attributes, including hidden ones that might be missed
return response()->json($user);

// ✅ Good — resource controls exactly what is exposed
return new UserResource($user);
```

---

## 4. Testing with Mock Data

### Realistic Factory Patterns

```php
// ❌ Bad — fake data that doesn't reflect reality
User::factory()->create(['email' => 'test@test.com']);

// ✅ Good — realistic mock data
User::factory()->create([
    'email' => 'john.acme@example.com',
    'role' => 'admin',
    'email_verified_at' => now(),
]);
```

### Relationship Factories

```php
// ✅ Good — creates related models with proper data
$user = User::factory()
    ->has(Post::factory()->count(3)
        ->has(Comment::factory()->count(5))
    )
    ->create();

// Now test: user has 3 posts, each with 5 comments
```

### Edge Case Data

```php
it('handles user with maximum posts', function () {
    $user = User::factory()->create();
    Post::factory()->count(100)->for($user)->create();
    // Test pagination handles 100 posts
});

it('returns empty result when user has no posts', function () {
    $user = User::factory()->create();  // no posts
    $response = $this->getJson("/api/users/{$user->id}/posts");
    $response->assertJsonCount(0, 'data');
});

it('handles duplicate email registration', function () {
    $email = 'existing@example.com';
    User::factory()->create(['email' => $email]);
    $response = $this->postJson('/api/register', [
        'email' => $email,
        'password' => 'ValidP@ss1',
    ]);
    $response->assertStatus(422);
    $response->assertJsonValidationErrors('email');
});
```

### Mock Services Correctly

```php
// ✅ Good — mock external services, test your logic
$mailer = $this->createMock(Mailer::class);
$mailer->expects($this->once())
    ->method('send')
    ->with($this->isInstanceOf(WelcomeMail::class));

$service = new RegistrationService(
    new UserRepository(),
    $mailer,
    $this->createMock(Logger::class)
);

$user = $service->register(['email' => 'new@example.com', 'password' => 'ValidP@ss1']);
$this->assertNotNull($user->id);
```

### Test Coverage Checklist for Any Backend Change

- [ ] Happy path — the most common flow works
- [ ] Validation failure — invalid input returns proper errors
- [ ] Authorization failure — unauthorized user gets 403
- [ ] Not found — missing resource returns 404
- [ ] Duplicate — creating duplicate unique fields returns 422
- [ ] Empty state — zero results returns properly
- [ ] Boundary — max length, max count, pagination edge
- [ ] Authentication — unauthenticated requests return 401
- [ ] Database error — what happens when the DB is down (if feasible)

---

## 5. API Design Patterns

### RESTful URL Convention

```
GET    /api/resources          → index()    — list (paginated)
POST   /api/resources          → store()    — create
GET    /api/resources/{id}     → show()     — single
PUT    /api/resources/{id}     → update()   — full update
PATCH  /api/resources/{id}     → update()   — partial update
DELETE /api/resources/{id}     → destroy()  — delete
```

### Response Consistency

```php
// ✅ Good — consistent response envelope
public function index(): JsonResponse {
    return response()->json([
        'data' => UserResource::collection($users),
        'meta' => [
            'current_page' => $users->currentPage(),
            'per_page' => $users->perPage(),
            'total' => $users->total(),
        ],
    ]);
}

public function store(StoreUserRequest $request): JsonResponse {
    $user = $this->service->create($request->validated());
    return response()->json([
        'data' => new UserResource($user),
        'message' => 'User created successfully.',
    ], 201);
}
```

### Error Response Format

```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "The given data was invalid.",
        "details": {
            "email": ["The email field is required."]
        }
    }
}
```

**HTTP status codes:**
| Code | When |
|------|------|
| 200 | Success (GET, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad request (malformed payload) |
| 401 | Unauthenticated |
| 403 | Forbidden (authenticated but not allowed) |
| 404 | Not found |
| 422 | Validation error |
| 429 | Rate limited |
| 500 | Server error |

---

## 6. Performance Patterns

### Caching Strategy

```php
// Cache expensive queries
$users = Cache::remember('active_users', 3600, fn() =>
    User::with('profile')->where('active', true)->get()
);

// Cache invalidation on mutation
User::created(fn() => Cache::forget('active_users'));
```

### Batch Operations

```php
// ❌ Bad — N queries for N items
foreach ($userIds as $id) {
    User::where('id', $id)->update(['status' => 'inactive']);
}

// ✅ Good — 1 query
User::whereIn('id', $userIds)->update(['status' => 'inactive']);
```

### Chunk for Large Datasets

```php
// ✅ Good — processes in batches of 100
User::chunkById(100, function ($users) {
    foreach ($users as $user) {
        // process
    }
});
```
