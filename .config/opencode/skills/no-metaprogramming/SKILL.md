---
name: no-metaprogramming
description: Avoid metaprogramming unless it falls into explicitly permitted exceptions.
---

# No Metaprogramming

Metaprogramming makes code harder to trace, breaks IDE support, and increases
the learning curve for collaborators. Do not use metaprogramming unless the
situation clearly falls into one of the permitted exceptions below.

## Definition

"Metaprogramming" here means any technique that generates, modifies, or
introspects code structure at compile time or runtime beyond what the language
requires for normal operation. Examples include:

- Dynamically creating classes, methods, or functions
- Intercepting attribute/method access to synthesize behavior
  (`__getattr__`, `method_missing`, `Proxy`)
- Dynamic method dispatch via names passed as strings or symbols
  (`send`, `public_send`, `getattr()`)
- Building custom macros (proc macros, template metaprogramming)
- Runtime monkey-patching or reopening classes
- Advanced type-level computation that obscures intent

## Permitted Exceptions

Metaprogramming is acceptable **only** in these cases:

### 1. Framework or Library Foundation Code

When you are building a framework or library **itself** and the design
fundamentally requires automatic discovery, registration, or extension of
user-defined constructs (e.g., plugin systems, ORM internals, DI containers).

This does **not** apply to application code that merely uses a framework.

### 2. Established Language or Library Idioms

When the language standard library or a widely-adopted library provides a
metaprogramming facility that is the conventional way to achieve the goal.

| Language   | Permitted                                                     |
|------------|---------------------------------------------------------------|
| Python     | `@dataclass`, `@property`, `abc.ABC`, `typing.Protocol`      |
| Ruby       | `attr_accessor`, `attr_reader`, `Struct.new`                  |
| TypeScript | Decorators prescribed by the framework (e.g., NestJS, Angular)|
| Rust       | `#[derive(...)]`, standard derive macros, `serde` attributes  |

### Conditions for Using an Exception

Even when an exception applies, you **must**:

1. Add a comment explaining **why** metaprogramming is necessary and why a
   straightforward approach is insufficient
2. Confine the metaprogramming to the smallest possible scope
3. Ensure that the behavior is easily discoverable (no silent, implicit effects)

## Avoid These Patterns

### Python

Bad -- dynamically generating methods obscures the class interface:

```python
class Config:
    _fields = ["host", "port", "debug"]
    _defaults = {"host": "localhost", "port": 8080, "debug": False}

    def __getattr__(self, name):
        if name in self._fields:
            return self._defaults.get(name)
        raise AttributeError(name)
```

Good -- explicit attributes are visible to readers and tooling:

```python
@dataclass
class Config:
    host: str = "localhost"
    port: int = 8080
    debug: bool = False
```

### Ruby

Bad -- `method_missing` hides the available interface:

```ruby
class Settings
  def method_missing(name, *args)
    if KNOWN_KEYS.include?(name)
      @store[name]
    else
      super
    end
  end
end
```

Bad -- `send`/`public_send` with a dynamic method name defeats static analysis:

```ruby
class Executor
  def run(action, *args)
    public_send(action, *args)
  end

  def create(name) = puts "create #{name}"
  def delete(name) = puts "delete #{name}"
end
```

Good -- explicit dispatch makes every call site searchable:

```ruby
class Executor
  def run(action, *args)
    case action
    when :create then create(*args)
    when :delete then delete(*args)
    else raise ArgumentError, "Unknown action: #{action}"
    end
  end

  def create(name) = puts "create #{name}"
  def delete(name) = puts "delete #{name}"
end
```

Good -- explicit methods are grep-able and documented by the source:

```ruby
Settings = Struct.new(:host, :port, :debug, keyword_init: true)
```

### TypeScript

Bad -- `Proxy` to synthesize config properties bypasses the type system:

```typescript
function createConfig(defaults: Record<string, unknown>) {
  return new Proxy(defaults, {
    get(target, prop: string) {
      if (prop in target) return target[prop];
      throw new Error(`Unknown config key: ${prop}`);
    },
  });
}

const config = createConfig({ host: "localhost", port: 8080, debug: false });
config.host; // type is `unknown`, no autocomplete
```

Good -- a plain class with explicit properties:

```typescript
class Config {
  constructor(
    readonly host: string = "localhost",
    readonly port: number = 8080,
    readonly debug: boolean = false,
  ) {}
}
```

### Rust

Bad -- a custom proc macro for something a plain `impl` can handle:

```rust
// my_macro/src/lib.rs
#[proc_macro_derive(Getters)]
pub fn derive_getters(input: TokenStream) -> TokenStream {
    // 50 lines of syn/quote to generate getter methods ...
}
```

Good -- derive standard traits; write methods by hand when the struct is small:

```rust
#[derive(Debug, Clone, PartialEq)]
struct Config {
    host: String,
    port: u16,
    debug: bool,
}

impl Config {
    fn host(&self) -> &str { &self.host }
    fn port(&self) -> u16 { self.port }
    fn is_debug(&self) -> bool { self.debug }
}
```

## Decision Checklist

Before reaching for metaprogramming, answer every question with "yes":

1. Does this fall under a permitted exception?
2. Have you confirmed that no simpler alternative exists (explicit code, generics,
   traits/interfaces)?
3. Will IDE navigation, auto-complete, and static analysis still work?
4. Can a new team member understand this without reading the metaprogramming
   internals?

If any answer is "no", do not use metaprogramming.
