# Compiler and Lint Configuration

Sources: [TSConfig Reference](https://www.typescriptlang.org/tsconfig/), [typescript-eslint — typed linting](https://typescript-eslint.io/getting-started/typed-linting/), [Prettier options](https://prettier.io/docs/options).

## tsconfig

```jsonc
{
  "compilerOptions": {
    // Correctness
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitReturns": true,
    "noPropertyAccessFromIndexSignature": true,

    // Modules
    "module": "preserve",
    "moduleResolution": "bundler",
    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "resolveJsonModule": true,
    "forceConsistentCasingInFileNames": true,

    // Output
    "target": "ES2022",
    "lib": ["ES2023", "DOM", "DOM.Iterable"],
    "noEmit": true,
    "skipLibCheck": true,
    "sourceMap": true
  }
}
```

### Why each of the four beyond `strict`

`strict` is a bundle that grows over time:

> "The `strict` flag enables a wide range of type checking behavior that results in stronger guarantees of program correctness. […] Future versions of TypeScript may introduce additional stricter checking under this flag"
> — [TSConfig Reference](https://www.typescriptlang.org/tsconfig/#strict)

These four sit outside it and are the ones worth the noise:

| Option | What it buys |
| --- | --- |
| `noUncheckedIndexedAccess` | "will add `undefined` to any un-declared field in the type" — `arr[0]` stops lying about empty arrays |
| `exactOptionalPropertyTypes` | "`colorThemeOverride: undefined` is not the same as `colorThemeOverride` not being defined" — separates absent from explicitly-undefined, which matters for every patch/merge operation |
| `noImplicitOverride` | "ensure that the sub-classes never go out of sync" — a renamed base method becomes a compile error, not a silently dead override |
| `verbatimModuleSyntax` | "any imports or exports without a `type` modifier are left around" — no accidental runtime import of a module you only used for a type |

`skipLibCheck: true` is a deliberate exception: it skips checking `.d.ts` files in `node_modules`, which are not yours to fix and which regularly disagree with each other. It does not weaken checking of your own code.

`noEmit: true` because Vite does the emitting. `tsc` is the type gate, run as `tsc --noEmit` in CI; bundlers strip types without checking them, so a build passing is not a type check passing.

## ESLint

Type-aware linting or none. The rules worth having all need type information.

```js
// eslint.config.js
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  js.configs.recommended,
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: { parserOptions: { projectService: true } },
    rules: {
      "@typescript-eslint/no-explicit-any": "error",
      "@typescript-eslint/no-non-null-assertion": "error",
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
      "@typescript-eslint/consistent-type-imports": "error",
      "@typescript-eslint/consistent-type-definitions": ["error", "interface"],
      "@typescript-eslint/switch-exhaustiveness-check": "error",
      "@typescript-eslint/no-unnecessary-condition": "error",
      "@typescript-eslint/restrict-template-expressions": "error",
      "no-console": ["error", { allow: ["warn", "error"] }],
    },
  },
  { files: ["**/*.test.ts"], rules: { "@typescript-eslint/no-non-null-assertion": "off" } },
);
```

`strictTypeChecked` rather than `recommended`. It is noisier on first adoption and every rule it adds catches a real class of bug — the noise is the point.

`no-unnecessary-condition` deserves a note: it flags checks the types say can never fail. Most hits are dead defensive code; some reveal a type that claims more certainty than the runtime has. Both are worth knowing.

## Escape hatches

| Form | Status |
| --- | --- |
| `@ts-expect-error` with a reason after it | **The only sanctioned suppression.** It fails the build once the error goes away, so it cannot rot |
| `@ts-ignore` | **Banned.** Silently survives the fix, then hides the next real error at that line |
| `eslint-disable-next-line <rule> -- reason` | Allowed, rule named explicitly, reason required |
| Bare `eslint-disable` for a whole file | Banned |
| `any`, `as any`, `as unknown as T`, `!` | Banned outside tests. See `types.md` |

## Formatting

Prettier, defaults, with no per-project bikeshedding. The whole value of a formatter is that nobody spends a minute on the question.

```json
{ "singleQuote": false, "semi": true, "trailingComma": "all", "printWidth": 100 }
```

Formatting is a CI check (`prettier --check`), not a lint rule. `eslint-config-prettier` turns off the stylistic ESLint rules that would otherwise fight it.

Biome would replace both ESLint and Prettier with one fast binary; it does not yet have the type-aware rules above, which are the ones that catch bugs rather than style. Adopting it needs express permission and a decision about what type-aware coverage is being given up.

## Svelte

`.svelte` files are outside `tsc`'s reach. `svelte-check` is the type gate for them and runs beside `tsc --noEmit` in CI, not instead of it. Add `eslint-plugin-svelte` for the component-level rules.

## The CI gate

```
tsc --noEmit
svelte-check --fail-on-warnings     # projects with .svelte files
eslint .
prettier --check .
vitest run
```

All five block the merge. No exceptions without an inline suppression carrying a reason.
