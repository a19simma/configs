# Testing

Sources: [Vitest](https://vitest.dev/guide/), [Playwright](https://playwright.dev/docs/intro), [Testing Library — guiding principles](https://testing-library.com/docs/guiding-principles/).

## What to test

Test behaviour at a module's public surface. A test that imports an unexported helper through a back door is testing an implementation detail and will fail on the next refactor that changes nothing a user can see.

| Kind | Runner | Scope | Count |
| --- | --- | --- | --- |
| Unit | Vitest | One module, no I/O | Most |
| Integration | Vitest | Several modules plus a real adapter (test DB, test server) | Some |
| End-to-end | Playwright | The running app through a browser | Few, on the paths that lose money |

**Rule:** the domain layer is unit-testable with no mocks at all, because it takes its capabilities as parameters. If testing a domain function requires a mock, `architecture.md` was not followed.

## Structure

```ts
import { describe, expect, it } from "vitest";
import { orderTotal } from "./order-total";

describe("orderTotal", () => {
  it("applies the bulk discount at ten units", () => {
    const order = anOrder({ lines: [aLine({ quantity: 10, unitPrice: cents(500) })] });

    const total = orderTotal(order);

    expect(total).toEqual(cents(4500));
  });
});
```

- The name states the behaviour and the condition. `it("works")` is not a test name.
- Arrange, act, assert — with the blank lines. One act per test.
- No branching in a test. An `if` in a test means two tests, or a test that sometimes asserts nothing.
- No `beforeEach` that builds shared mutable state. A builder function (`anOrder`) called per test is clearer and cannot leak between cases.

## Builders over fixtures

```ts
export function anOrder(over: Partial<Order> = {}): Order {
  return { id: orderId("ord_0000000000000001"), lines: [], status: "open", ...over };
}
```

The test then names only what matters to it, and adding a required field to `Order` updates one place instead of ninety.

## Assertions

- `toEqual` for structural equality, `toBe` for identity and primitives. `toStrictEqual` where `undefined` properties and class identity matter.
- Assert the whole value where you can. Six `expect(x.a)` lines miss the seventh field going wrong.
- `await expect(p).rejects.toThrow(ConfigError)` for throws — never a bare `try`/`catch` with `expect(true)`.
- Snapshots only for output that is genuinely large and genuinely stable, and reviewed like code when they change. An auto-updated snapshot nobody reads asserts nothing.

## Mocking

Sparingly, and at the boundary. A mock is a claim about how a collaborator behaves, and it goes stale silently.

- Prefer a real in-memory implementation of your own interface (`InMemoryOrderStore`) over `vi.mock`. It is type-checked and reusable.
- `vi.mock` for module-level third-party boundaries you cannot inject.
- `vi.useFakeTimers()` for anything time-dependent; a `Clock` parameter is better still.
- Never assert on how many times an internal function was called. That is a test of the implementation.
- Never mock the thing under test.

## Async

- `await` every assertion on a promise. A floating promise in a test makes it pass regardless.
- `expect.assertions(n)` in tests where a missed assertion would silently pass.
- No `setTimeout` sleeps. Await the condition, or use fake timers.

## End-to-end

- Locate by user-visible semantics: `getByRole`, `getByLabel`, `getByText`. Fall back to `data-testid` only for genuinely unnamed elements — never CSS class selectors, which change with every restyle.
- Playwright's auto-waiting replaces retry loops. If a test needs an explicit wait, the app is missing a state the user could also not see.
- Each spec sets up its own data and is independent of the others. Tests that must run in order are one test wearing a costume.
- End-to-end covers the critical paths only: sign-in, checkout, the destructive action. Everything else is cheaper and more precise one layer down.

## Coverage

A number, not a goal. **Rule:** no coverage threshold in CI. Thresholds produce tests written to touch lines rather than to check behaviour. Read the report to find untested branches that matter, then decide.

Untested code that ships is a decision; make it deliberately and say so.
