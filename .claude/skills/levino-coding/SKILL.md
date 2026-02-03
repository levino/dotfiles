---
name: levino-coding
description: Levin Keller's coding style preferences. Always apply when writing, reviewing, or refactoring code - functional programming, no classes, no async/await, TDD, Vitest, no comments.
user-invocable: false
---

# Levino Coding

Levin Keller's (levino) coding style and opinions.

IMPORTANT: Generated code must never contain comments or JSDoc. This skill file uses comments only to teach the pattern to the AI.

<language>
- TypeScript always, strict mode
- type vs interface: follow official TypeScript best practices
</language>

<tooling>
- Testing: Vitest
- Package manager: npm
- Formatting and linting: Biome
</tooling>

<libraries>
- Effect (https://effect.website/) is the default for any non-trivial logic
  - Use pipe/flow for all transformations
  - Use Schema for input validation
  - Use Effect.try for wrapping side effects
  - Use Effect.tryPromise for wrapping async side effects
  - Use Either for simple synchronous branching without side effects
- Effect replaces: Ramda, fp-ts, lodash, manual validation
</libraries>

<functional-programming>
- Everything is composition: data in, data out
- Use `pipe` to compose transformations, `flow` for point-free function composition
- Expression bodies (no curly braces) over function bodies wherever possible
- No intermediate variables - inline or extract to a named function instead
  - Bad: `const x = getA(); const y = transform(x); return format(y);`
  - Good: `pipe(getA(), transform, format)`
- No mutation - use map/reduce/filter, never loops with mutation
</functional-programming>

<effect-pattern>
This is the core pattern. Every function that does something non-trivial should follow this structure.

1. Define a Schema for input validation
2. Write small, single-purpose transform functions
3. Compose them in a pipe (happy path only)
4. Handle errors at the call site, not inside the pipe
5. Effect.runPromise stays at the outermost edge

```typescript
// 1. Schema validates input - replaces all manual if/else checking
const RequestBody = Schema.Struct({ token: Schema.NonEmptyString })

// 2. Small function: wraps side effects in Effect.try so errors land in the error channel
const tokenToResult = (token: string) =>
  Effect.try(() => {
    const service = new ExternalService(CONFIG)
    service.save(token)
    return service.getResult()
  })

// 3. Small function: pure data transformation, no Effect needed
const formatResult = (result: string) =>
  new Response("OK", { status: 200, headers: { "X-Result": result } })

// 4. Happy path pipe: reads top to bottom, each step transforms the data
//    Errors from Schema or Effect.try automatically short-circuit (railway oriented programming, see https://fsharpforfunandprofit.com/rop/)
const handleRequest = (context: APIContext) =>
  pipe(
    context,
    Struct.get("request"),            // APIContext → Request
    Schema.decodeUnknown(RequestBody), // Request → Effect<{ token }, ParseError>
    Effect.map(Struct.get("token")),  // → Effect<string>
    Effect.flatMap(tokenToResult),    // → Effect<string, UnknownException>
    Effect.map(formatResult),         // → Effect<Response>
  )

// 5. Error handler: separate from happy path, at the call site
const handleError = () =>
  Effect.succeed(new Response("Invalid request", { status: 400 }))

// 6. Exported handler: glues happy path + error handling, runs the Effect
export const POST: APIRoute = (context) =>
  Effect.runPromise(
    pipe(handleRequest(context), Effect.catchAll(handleError)),
  )
```
</effect-pattern>

<async>
- Never use async/await
- For promises: use .then() chains or wrap in Effect.tryPromise
- async/await encourages intermediate variables that are hard to name
- With Effect, async is just another Effect in the pipe - no special syntax needed
</async>

<error-handling>
- Never return encoded errors like { success: true, data } or { error: ... }
- Use Effect's error channel (the "left" side) for expected errors
- Effect.try / Effect.tryPromise capture exceptions into the error channel
- Effect.catchAll at the call site converts errors to responses
- Effect.mapError to transform errors without handling them
- For simple code without Effect: let errors throw naturally
</error-handling>

<side-effects>
- Raw functions with side effects must return void or Promise<void>
- Exception: when wrapped in Effect.try / Effect.tryPromise, the Effect container signals the side effect
- Pure functions return values, side-effecting functions return void (or an Effect)
</side-effects>

<naming>
- camelCase always
- No abbreviations ever: `pocketBase` not `pb`, `response` not `res`, `request` not `req`
- Function names must be self-explanatory: `tokenToCookie`, `createResponseToSetCookie`, `handleError`
- If you need a comment to explain what a function does, the name is wrong
</naming>

<documentation>
- No comments in generated code - function names and types are the documentation
- No JSDoc - it duplicates what code says and becomes stale
- When logic feels complex: extract to a well-named function instead of commenting
</documentation>

<commits>
- Imperative mood: "Enable user login" not "Enabled user login"
- Describe the value/behavior change, not the implementation
- Good: "Enable user login", "Add password reset flow"
- Bad: "Add loginUser function", "Update auth.ts with new method"
</commits>

<principles>
- Functional programming over object-oriented
- Classes are forbidden - no exceptions unless measured performance necessity
- Readability over performance - only optimize when it's a proven problem
</principles>

<testing>
- TDD is mandatory: red → green → refactor → repeat
- Framework: Vitest
- Write the test first, then the minimal code to make it pass
</testing>

<forbidden>
- Classes
- async/await
- Comments and JSDoc in generated code
- Abbreviations and short variable names
- Intermediate variables (extract to named functions instead)
- Returning encoded errors like { success, data } or { error }
- Functions that have both side effects and return values (unless wrapped in Effect)
- Reading environment variables in deep files (top-level only, pass down explicitly)
- Premature optimization
</forbidden>

<structure>
- Barrel files (index.ts) for clean public APIs
- A file should only import from subfolders of its own folder
- No importing from siblings or parent directories
</structure>

<dependency-injection>
- Top-level file reads environment, passes everything down explicitly
- Deep files must never read environment variables
- With Effect: use Effect's built-in dependency injection (Layers, Services)
- Vitest module mocking is acceptable for testing
</dependency-injection>

<claude-interaction>
- Assume fair knowledge of technology - don't over-explain basics
- When refactoring: produce the Effect pipe pattern immediately, don't start with imperative code
- When writing new code: Schema first, then small functions, then pipe, then error handler
</claude-interaction>
