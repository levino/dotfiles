---
name: levino-coding
description: Levin Keller's coding style preferences. Always apply when writing, reviewing, or refactoring code - functional programming, no classes, no async/await, TDD, Vitest, no comments.
user-invocable: false
---

# Levino Coding

Levin Keller's (levino) coding style and opinions.

<language>
- TypeScript is the default choice when no specific setup exists
- Strict TypeScript always - types are living documentation
- Proficient in TypeScript, prefer it for all new code
- type vs interface: follow official TypeScript best practices
</language>

<tooling>
- Testing: Vitest
- Package manager: npm
- Formatting and linting: Biome
</tooling>

<libraries>
- Effect (https://effect.website/) - preferred for functional TypeScript
  - Use for functional pipes, compositions, and option handling
  - Useful for complex applications where error tracking becomes difficult
  - Nice to have, not always necessary - don't always bring out the big guns
- Ramda, fp-ts - historically used, but Effect is the current preference
  - fp-ts has largely been absorbed into Effect
</libraries>

<functional-programming>
- Composition over imperative code
- Use `flow` and `pipe` to compose transformations
- Prefer point-free style and expression bodies (no curly braces) over function bodies
- Prefer functions over methods: use Effect's Array functions within flow
  - Good: `flow(Array.filter(...), Array.sort(...))`
  - Acceptable: brief method chains for simple cases
  - Avoid: multiple intermediate variable assignments
- Prefer immutability - avoid mutation when possible
- Use map(), reduce() instead of loops with mutation
</functional-programming>

<async>
- Prefer Promise chains over async/await
- Promise chains resemble flow/pipe chains - data flows through visibly
- async/await encourages unnecessary intermediate variables that are hard to name
</async>

<error-handling>
- Either let errors throw, or handle them locally
- Never return encoded errors like { success: true, data } or { error: ... }
- Returning values that encode errors is an abuse of JavaScript
- If you want result-type error handling, use a proper container (Effect)
</error-handling>

<patterns>
- Composition through pipes: data in, data out
- Railroad-oriented programming (for complex applications):
  - Use result containers (Either/Effect) to represent success/failure
  - Map over the happy path, errors short-circuit the chain automatically
  - No explicit error checking at each step - the container handles it
- Structure: Schema → small transform functions → happy path pipe → error handler → exported handler
- Validate input with Effect Schema (Schema.Struct, Schema.decodeUnknown)
- Wrap side effects in Effect.try, chain with Effect.flatMap
- Keep happy path pipe pure, handle errors at the call site with Effect.catchAll
- Effect.runPromise stays outside the business logic pipe
- Example (API route with Effect):
  ```typescript
  const RequestBody = Schema.Struct({ token: Schema.NonEmptyString })

  const tokenToResult = (token: string) =>
    Effect.try(() => { /* side effects here */ })

  const formatResult = (result: string) =>
    new Response("OK", { status: 200, headers: { "X-Result": result } })

  const handleRequest = (context: APIContext) =>
    pipe(
      context,
      Struct.get("request"),
      Schema.decodeUnknown(RequestBody),
      Effect.map(({ token }) => token),
      Effect.flatMap(tokenToResult),
      Effect.map(formatResult),
    )

  const handleError = () =>
    Effect.succeed(new Response("Invalid request", { status: 400 }))

  export const POST: APIRoute = (context) =>
    Effect.runPromise(
      pipe(handleRequest(context), Effect.catchAll(handleError)),
    )
  ```
</patterns>

<side-effects>
- Functions with side effects must not have a return value
- Return void or Promise<void> to signal side effects from the signature
- This makes it clear from the type that the function has side effects
- Pure functions return values, side-effecting functions return void
</side-effects>

<naming>
- Always use camelCase
- No shortcuts or abbreviations ever
- Names must be descriptive and self-explanatory
- Good function names eliminate the need for comments
- Good: `getUsersByAge`, `calculateAveragePrice`, `filterActiveSubscriptions`
- Bad: `u` for users, `calc`, `doFilter`, `data`, `x`
- Variables (when necessary) follow same rules: `activeUsers`, `totalRevenue`
</naming>

<documentation>
- Avoid comments - let clear function names and TypeScript types document the code
- No JSDoc comments - they duplicate what code says and become stale
- When code feels complex enough to warrant a comment, extract to a well-named function instead
  - Provides clarity through naming
  - Extracted functions can be unit tested
  - Extracted logic can be reused
- Complex boolean logic and transformations: extract into named functions
</documentation>

<commits>
- Imperative mood: "Enable user login" not "Enabled user login"
- Describe the feature/behavior change from a user/business perspective
- Commits are puzzle pieces: "what feature do I get if I apply this commit?"
- Never describe implementation details or code changes
- AI can summarize code changes; the commit message explains the value
- Good: "Enable user login", "Add password reset flow"
- Bad: "Add loginUser function", "Update auth.ts with new method"
</commits>

<principles>
- Functional programming over object-oriented
- Classes are forbidden, not discouraged - forbidden
  - Only exception: proven performance gains (measured first)
- Use factories when state is needed, plain functions when not
- Readability over performance - humans read code, make it easy for them
- No optimization without measuring first
- Code is usually fast enough; only optimize when it's a proven problem
</principles>

<testing>
- Everything needs to be tested
- Framework: Vitest
- TDD (Test-Driven Development) is mandatory:
  1. Write a test for functionality that doesn't exist yet
  2. Test fails (red)
  3. Write minimal code to make the test pass (green)
  4. Write the next test, it fails
  5. Extend the function to make it pass
  6. Previous tests stay in place
  7. Repeat
</testing>

<forbidden>
- Classes (except measured performance necessity)
- Premature optimization (measure first, always)
- Writing code before writing tests
- Comments and JSDoc (extract to functions instead)
- Abbreviations and short variable names
- Functions that have both side effects and return values
- Returning encoded errors like { success, data } or { error }
- async/await (use Promise chains instead)
- Implicit dependency injection
- Reading environment variables in deep files
</forbidden>

<structure>
- Use barrel files (index.ts) for clean public APIs
- Import rule: a file should only import from subfolders of its own folder
  - No importing from siblings or parent directories
- Structure depends on project type (Astro routing, libraries, etc.)
</structure>

<dependency-injection>
- If using Effect: use Effect's dependency injection (superb and type-safe)
- No implicit dependency injection
- Top-level file may read from environment, then pass everything down explicitly
- Deep files must never change behavior based on environment variables
  - Even logging should be injected
- Vitest module mocking is acceptable
</dependency-injection>

<claude-interaction>
- Assume fair knowledge of technology - don't over-explain basics
- Do explain unusual patterns or unexpected behavior
- Workarounds require special handling:
  - Explain what was tried and why it didn't work
  - Reference the issue/discussion in a code comment
  - Highlight to user without interrupting workflow
</claude-interaction>

<avoid>
- Data mutation (prefer immutability, but not absolute)
- Multiple intermediate variable assignments
- Importing from parent or sibling directories
</avoid>
