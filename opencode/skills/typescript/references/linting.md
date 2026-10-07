# Compiler and Lint Configuration

Sources: [TSConfig Reference](https://www.typescriptlang.org/tsconfig/), [typescript-eslint: typed linting](https://typescript-eslint.io/getting-started/typed-linting/), [Prettier options](https://prettier.io/docs/options), [ESLint: disabling inline comments](https://eslint.org/docs/latest/use/configure/rules#disable-inline-comments), [ESLint: configuration files](https://eslint.org/docs/latest/use/configure/configuration-files), [typescript-eslint: ban-ts-comment](https://typescript-eslint.io/rules/ban-ts-comment/), [typescript-eslint: triple-slash-reference](https://typescript-eslint.io/rules/triple-slash-reference/), [typescript-eslint: config (deprecated)](https://typescript-eslint.io/packages/typescript-eslint/#config-deprecated), [ESLint: linter.js warnInlineConfig](https://github.com/eslint/eslint/blob/main/lib/linter/linter.js), [typescript-eslint: ban-ts-comment.ts](https://github.com/typescript-eslint/typescript-eslint/blob/main/packages/eslint-plugin/src/rules/ban-ts-comment.ts), [TypeScript: parser.ts](https://github.com/microsoft/TypeScript/blob/v5.9.3/src/compiler/parser.ts#L10589).

## tsconfig

```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitReturns": true,
    "noPropertyAccessFromIndexSignature": true,

    "module": "preserve",
    "moduleResolution": "bundler",
    "verbatimModuleSyntax": true,
    "isolatedModules": true,
    "resolveJsonModule": true,
    "forceConsistentCasingInFileNames": true,

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
> Source: [TSConfig Reference](https://www.typescriptlang.org/tsconfig/#strict)

These four sit outside it and are the ones worth the noise:

| Option | What it buys |
| --- | --- |
| `noUncheckedIndexedAccess` | "will add `undefined` to any un-declared field in the type". `arr[0]` stops lying about empty arrays |
| `exactOptionalPropertyTypes` | "`colorThemeOverride: undefined` is not the same as `colorThemeOverride` not being defined". Separates absent from explicitly-undefined, which matters for every patch/merge operation |
| `noImplicitOverride` | "ensure that the sub-classes never go out of sync". A renamed base method becomes a compile error, not a silently dead override |
| `verbatimModuleSyntax` | "any imports or exports without a `type` modifier are left around". No accidental runtime import of a module you only used for a type |

`skipLibCheck: true` is a deliberate exception: it skips checking `.d.ts` files in `node_modules`, which are not yours to fix and which regularly disagree with each other. It does not weaken checking of your own code.

`noEmit: true` because Vite does the emitting. `tsc` is the type gate, run as `tsc --noEmit` in CI; bundlers strip types without checking them, so a build passing is not a type check passing.

## ESLint

Type-aware linting or none. The rules worth having all need type information.

**`eslint.config.js`:**
```js
import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig(
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
      "@typescript-eslint/triple-slash-reference": ["error", { lib: "never", path: "never", types: "never" }],
      "no-console": ["error", { allow: ["warn", "error"] }],
    },
  },
  {
    linterOptions: { noInlineConfig: true },
    rules: {
      "@typescript-eslint/ban-ts-comment": ["error", { "ts-expect-error": true }],
    },
  },
  { files: ["**/*.test.ts"], rules: { "@typescript-eslint/no-non-null-assertion": "off" } },
);
```

`strictTypeChecked` rather than `recommended`. It is noisier on first adoption; every rule it adds catches a real class of bug.

`no-unnecessary-condition` deserves a note: it flags checks the types say can never fail. Most hits are dead defensive code; some reveal a type that claims more certainty than the runtime has. Both are worth knowing.

`noInlineConfig` makes every `eslint-disable` and `/* eslint */` directive inert, so the rule it tried to silence still fires. With `noInlineConfig` set in `eslint.config.*` (not the `--no-inline-config` flag), ESLint reports each inert directive as a warning, which `--max-warnings 0` turns into a failure. The `@ts-*` comments are not ESLint directives. `ban-ts-comment` matches every `@ts-*` form tsc honours. The forms it skips (`/* @ts-nocheck */`, `@ts-nocheck` after the first statement, and `@ts-ignore` on a non-last line of a block comment) are inert to tsc too.

`defineConfig` from `eslint/config` needs ESLint 9.22.0 or later. It replaces `tseslint.config()`, which typescript-eslint deprecates.

## Escape hatches

None in code. Obey the rule, or scope it off in `eslint.config.*` with a `files` override, as the test override above does:

| Form | Status |
| --- | --- |
| `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` | **Banned.** Fix the type. `ban-ts-comment` catches every form tsc honours |
| `eslint-disable*`, `/* eslint */` | **Banned.** Disable the rule in `eslint.config.*` with a `files` override |
| `/* global */` | **Banned.** Declare it in `languageOptions.globals` |
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
svelte-check --fail-on-warnings
eslint . --max-warnings 0
prettier --check .
vitest run
```

`svelte-check` runs only in projects with `.svelte` files. All five block the merge. An exception is a rule disabled in `eslint.config.*` with a `files` override.
