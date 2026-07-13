# CODE QUALITY TEST TEMPLATE

> **Use:** Template for clean code audits, naming conventions, SOLID principles.
> **Location:** `templates/testing/CODE_QUALITY.md`

---

## Code Quality Spec

```yaml
target: {Class or namespace}
check_types:
  - naming
  - solid
  - duplication
  - complexity
  - documentation
framework: laravel|symfony|react|vue|generic
```

## Test Scenarios

### Naming Convention Check

```php
<?php

namespace Tests\Unit\CodeQuality;

use Tests\TestCase;
use Illuminate\Support\Facades\File;

class {Module}NamingTest extends TestCase
{
    private string $targetPath;

    protected function setUp(): void
    {
        parent::setUp();
        $this->targetPath = app_path('Services/{Module}');
    }

    /** @test */
    public function classes_follow_naming_conventions(): void
    {
        $classes = File::allFiles($this->targetPath);
        $violations = [];

        foreach ($classes as $file) {
            $className = $file->getFilenameWithoutExtension();

            // PascalCase check
            if (!preg_match('/^[A-Z][a-zA-Z0-9]+$/', $className)) {
                $violations[] = "{$className}: not PascalCase";
            }

            // Controller suffix for controllers
            if (str_contains($file->getPathname(), 'Controllers')
                && !str_ends_with($className, 'Controller')) {
                $violations[] = "{$className}: Controller should end with 'Controller'";
            }

            // Service suffix for services
            if (str_contains($file->getPathname(), 'Services')
                && !str_ends_with($className, 'Service')) {
                $violations[] = "{$className}: Service should end with 'Service'";
            }
        }

        $this->assertEmpty($violations,
            "Naming violations found:\n" . implode("\n", $violations)
        );
    }

    /** @test */
    public function methods_follow_naming_conventions(): void
    {
        $violations = $this->getMethodViolations($this->targetPath);

        $this->assertEmpty($violations,
            "Method naming violations:\n" . implode("\n", $violations)
        );
    }

    /** @test */
    public function variables_are_descriptive(): void
    {
        $files = File::allFiles($this->targetPath);
        $violations = [];

        foreach ($files as $file) {
            $content = file_get_contents($file->getPathname());

            // Check for single-letter variables (except loop counters)
            preg_match_all('/\$([a-z])\s*=/', $content, $matches);
            foreach ($matches[1] as $var) {
                if (!in_array($var, ['i', 'j', 'k'])) {
                    $violations[] = "{$file->getFilename()}: single-letter var \${$var}";
                }
            }
        }

        $this->assertEmpty($violations,
            "Variable naming violations:\n" . implode("\n", $violations)
        );
    }

    private function getMethodViolations(string $path): array
    {
        $violations = [];
        $files = File::allFiles($path);

        foreach ($files as $file) {
            $tokens = token_get_all(file_get_contents($file->getPathname()));

            foreach ($tokens as $i => $token) {
                if (!is_array($token)) continue;
                if ($token[0] === T_FUNCTION) {
                    // Find the function name
                    for ($j = $i + 1; $j < count($tokens); $j++) {
                        if (!is_array($tokens[$j])) continue;
                        if ($tokens[$j][0] === T_STRING) {
                            $methodName = $tokens[$j][1];
                            if (!preg_match('/^[a-z][a-zA-Z0-9]+$/', $methodName)
                                && !str_starts_with($methodName, '__')) {
                                $violations[] = "{$file->getFilename()}: {$methodName} not camelCase";
                            }
                            break;
                        }
                    }
                }
            }
        }

        return $violations;
    }
}
```

### SOLID Principle Check

```php
/** @test */
public function class_responsibility_is_single(): void
{
    $files = File::allFiles($this->targetPath);
    $largeClasses = [];

    foreach ($files as $file) {
        $content = file_get_contents($file->getPathname());

        // Count methods as proxy for single responsibility
        preg_match_all('/function\s+[a-zA-Z]/', $content, $methods);
        $methodCount = count($methods[0]);

        if ($methodCount > 15) {
            $largeClasses[] = "{$file->getFilename()}: {$methodCount} methods (consider splitting)";
        }

        // Check for too many dependencies
        preg_match_all('/new\s+([A-Z][a-zA-Z]+)/', $content, $deps);
        $uniqueDeps = array_unique($deps[1]);
        if (count($uniqueDeps) > 8) {
            $largeClasses[] = "{$file->getFilename()}: {$methodCount} direct dependencies";
        }
    }

    $this->assertEmpty($largeClasses,
        "Single Responsibility violations:\n" . implode("\n", $largeClasses)
    );
}

/** @test */
public function mock_dependencies_are_used_instead_of_concrete(): void
{
    $files = File::allFiles($this->targetPath . '/Services');

    foreach ($files as $file) {
        $content = file_get_contents($file->getPathname());

        if (str_contains($content, '__construct(')) {
            preg_match_all('/\b(\w+)Interface\b/', $content, $interfaceDeps);
            preg_match_all('/\b(\w+)Repository\b/', $content, $repoDeps);

            // Services should depend on interfaces, not concretions
            $this->assertNotEmpty($interfaceDeps[0] + $repoDeps[0],
                "{$file->getFilename()}: Constructor should use interfaces, not concrete classes"
            );
        }
    }
}

/** @test */
public function long_methods_are_flagged(): void
{
    $files = File::allFiles($this->targetPath);
    $longMethods = [];

    foreach ($files as $file) {
        $content = file_get_contents($file->getPathname());
        $lines = explode("\n", $content);

        $currentMethod = '';
        $methodStart = 0;

        foreach ($lines as $lineNum => $line) {
            if (preg_match('/function\s+([a-zA-Z_]+)/', $line, $m)) {
                $currentMethod = $m[1];
                $methodStart = $lineNum;
            }
            if ($currentMethod && preg_match('/^\}\s*$/', trim($line))) {
                $length = $lineNum - $methodStart;
                if ($length > 30) {
                    $longMethods[] = "{$file->getFilename()}:{$methodStart} {$currentMethod} is {$length} lines";
                }
                $currentMethod = '';
            }
        }
    }

    $this->assertEmpty($longMethods,
        "Long method violations:\n" . implode("\n", $longMethods)
    );
}
```

### Documentation Check

```php
/** @test */
public function public_methods_have_docblocks(): void
{
    $files = File::allFiles($this->targetPath);
    $missing = [];

    foreach ($files as $file) {
        $content = file_get_contents($file->getPathname());
        $tokens = token_get_all($content);

        foreach ($tokens as $i => $token) {
            if (!is_array($token)) continue;

            // Find public/protected functions
            if (in_array($token[0], [T_PUBLIC, T_PROTECTED])) {
                // Look ahead for 'function'
                for ($j = $i + 1; $j < min($i + 5, count($tokens)); $j++) {
                    if (!is_array($tokens[$j])) continue;
                    if ($tokens[$j][0] === T_FUNCTION) {
                        // Check if there's a docblock before
                        $hasDocblock = false;
                        for ($k = $i - 1; $k >= max(0, $i - 5); $k--) {
                            if (!is_array($tokens[$k])) continue;
                            if ($tokens[$k][0] === T_DOC_COMMENT) {
                                $hasDocblock = true;
                                break;
                            }
                        }
                        if (!$hasDocblock) {
                            $funcName = $tokens[$j + 2][1] ?? 'unknown';
                            if ($funcName !== '__construct') {
                                $missing[] = "{$file->getFilename()}: {$funcName} missing docblock";
                            }
                        }
                        break;
                    }
                }
            }
        }
    }

    $this->assertEmpty($missing,
        "Missing docblocks:\n" . implode("\n", $missing)
    );
}
```

## Coverage Checklist

```
☐ Naming — classes are PascalCase
☐ Naming — methods are camelCase
☐ Naming — variables are descriptive (no single-letter)
☐ SOLID — single responsibility (method count per class)
☐ SOLID — dependency inversion (interface injection)
☐ SOLID — open/closed (switch statements flagged)
☐ Complexity — methods under 30 lines
☐ Complexity — cyclomatic complexity under 10
☐ Duplication — no duplicated code blocks
☐ Documentation — public methods have docblocks
☐ Documentation — complex logic has inline comments
```

## Output Schema

```json
{
  "module": "{Module}",
  "testFile": "tests/Unit/CodeQuality/{Module}NamingTest.php",
  "results": {
    "namingViolations": 0,
    "solidViolations": 1,
    "longMethods": 0,
    "missingDocblocks": 2,
    "duplicationBlocks": 0
  },
  "passed": true,
  "warnings": [
    "ReviewController has 18 methods — consider splitting"
  ],
  "notes": "Code quality acceptable. Minor naming issues fixed."
}
```
