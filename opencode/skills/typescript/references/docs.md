# Documentation

Sources: [TSDoc @remarks](https://tsdoc.org/pages/tags/remarks/), [@param](https://tsdoc.org/pages/tags/param/), [@returns](https://tsdoc.org/pages/tags/returns/), [@throws](https://tsdoc.org/pages/tags/throws/), [@example](https://tsdoc.org/pages/tags/example/), [@deprecated](https://tsdoc.org/pages/tags/deprecated/), [eslint-plugin-tsdoc](https://tsdoc.org/pages/packages/eslint-plugin-tsdoc/), [typescript-eslint ban-ts-comment](https://typescript-eslint.io/rules/ban-ts-comment/), [ESLint CLI](https://eslint.org/docs/latest/use/command-line-interface#--no-inline-config).

## What may appear in code

| Form | Status |
| --- | --- |
| `/** … */` on an exported symbol | Doc comment. Required in any package consumed outside its own directory |
| `/** … */` on an internal symbol | Allowed, same conventions |
| Any `//` or other `/* */` | Banned, tests included |
| `/// <reference … />` | Banned. `types` goes in `compilerOptions.types`, `lib` in `compilerOptions.lib`, `path` in `include`. `triple-slash-reference` enforces it |
| `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck` | Banned. `ban-ts-comment` catches every form tsc honours |
| `eslint-disable*`, `/* eslint */` | Banned. `noInlineConfig: true` makes them inert; disable the rule in `eslint.config.*` with a `files` override |
| `/* global */` | Banned. `noInlineConfig: true` makes it inert; declare it in `languageOptions.globals` |

> "This option prevents inline comments like `/*eslint-disable*/` or `/*global foo*/` from having any effect."
> Source: [ESLint CLI --no-inline-config](https://eslint.org/docs/latest/use/command-line-interface#--no-inline-config)

## Shape

> "The main documentation for an API item is separated into a brief "summary" section, optionally followed by a more detailed "remarks" section."
> Source: [TSDoc @remarks](https://tsdoc.org/pages/tags/remarks/)

The summary is the first paragraph. `@remarks` starts the detail and is only needed when there is detail.

## Tags

| Tag | Use | Rule |
| --- | --- | --- |
| `@param name - description` | a parameter | Only where the name and type do not already say it |
| `@returns` | the return value | Only where the type does not already say it |
| `@throws` | a thrown error | Wherever the function can throw. See `errors.md` |
| `@example` | a usage sample | Public entry points whose call shape is not obvious |
| `@deprecated` | a retired API | Always names the replacement |

`@param` uses name, hyphen, description: `@param port - The port to bind`.

```ts
/**
 * Parses the `PORT` environment variable.
 *
 * @throws {@link ConfigError}
 * Thrown when `raw` is not an integer from 1 to 65535.
 */
export function parsePort(raw: string): Port {
```

## Machine checks

`eslint-plugin-tsdoc` has one rule, `tsdoc/syntax`, which checks that comments "conform to the TSDoc specification" ([eslint-plugin-tsdoc](https://tsdoc.org/pages/packages/eslint-plugin-tsdoc/)). It parses each comment on its own with no link to the code, so it cannot see a missing doc comment or a `@param` name that does not match ([eslint-plugin/src/index.ts](https://github.com/microsoft/tsdoc/blob/main/eslint-plugin/src/index.ts)). Presence and drift are the reviewer's job.

Adding `eslint-plugin-tsdoc` needs approval under `packages.md`.

## Wording

Doc comment prose follows `stop-slop`.
