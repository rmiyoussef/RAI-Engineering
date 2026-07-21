# Naming Conventions Rules

> Consistent naming across any codebase. Names should reveal intent.

---

## R1 — Classes Are Nouns

Classes represent things. They should be nouns describing their responsibility:

```
❌ UserHelper, StringUtil, DatabaseManager (too generic)
✅ UserService, EmailFormatter, ConnectionPool (describes what it is)
```

Controller naming: resource name + Controller

```
UserController.php
OrderController.php
ProductCategoryController.php
```

## R2 — Methods Are Verbs

Methods represent actions. They should be verbs describing what they do:

```
❌ $user->email();          // is this getting or setting?
✅ $user->getEmail();
✅ $user->setEmail($email);

❌ $user->posts();          // could be a property or method
✅ $user->getRecentPosts();
✅ $user->loadPosts();
```

Boolean methods use `is`, `has`, `can`, `should`:

```
✅ $user->isAdmin()
✅ $order->hasItems()
✅ $request->isValid()
✅ $user->canEdit($post)
```

## R3 — Variables Describe What They Hold

Variable names should say what the data is, not its type:

```
❌ $data, $items, $result, $info, $temp
✅ $users, $orders, $validationResult, $errorMessage

❌ foreach ($items as $item) {        // what is item?
✅ foreach ($users as $user) {
✅ foreach ($posts as $post) {
```

One-letter variables are only allowed in:
- Loop counters: `$i`, `$j`, `$k`
- Closures: `fn($x) => $x * 2`

## R4 — Boolean Variables Use Positive Names

```
❌ $notValid, $noError, $unavailable
✅ $isValid, $hasError, $isAvailable
```

Avoid double negatives: `if (!$notInvalid)` is unreadable.

## R5 — File Names Match Class Names

One class per file. File name = class name + extension:

```
✅ User.php          → class User
✅ UserService.php   → class UserService
❌ helpers.php       → helper functions (use class or namespace)
❌ functions.php     → what functions?
```

## R6 — Test Names Describe Behavior

Test names should describe what's being tested and what should happen:

```
❌ testUser()
❌ testRegistration()
✅ test_it_registers_a_new_user()
✅ test_it_rejects_duplicate_email()
✅ test_it_returns_404_when_user_not_found()
```

Pattern: `test_it_[expected_behavior]_when_[condition]()`

## R7 — Constants and Enums

Constants are UPPER_SNAKE_CASE:

```
MAX_RETRY_ATTEMPTS
DEFAULT_PAGE_SIZE
STATUS_ACTIVE
```

Enum cases are PascalCase (PHP 8.1+) or UPPER_SNAKE_CASE (legacy):

```
enum UserRole: string {
    case Admin = 'admin';
    case Editor = 'editor';
    case Viewer = 'viewer';
}
```

## R8 — Abbreviations and Acronyms

- Spell out abbreviations unless universally known:
  - `$userId` ✅ not `$uid`
  - `$databaseConnection` ✅ not `$dbConn`
  - `$htmlContent` ✅ not `$hCnt`
  - `$url` ✅ (universally known)
  - `$apiKey` ✅ (universally known)

## R9 — Consistency Over Preference

The most important rule: **be consistent with the existing codebase.**

- If the project uses `camelCase` for variables, don't use `snake_case`
- If the project uses `UserService`, don't create `user_service_helper`
- If existing tests use `test_it_does_x`, don't use `testX`

When in doubt, match the surrounding code. Renaming an entire codebase to satisfy naming rules is a separate refactoring task, not part of feature work.
