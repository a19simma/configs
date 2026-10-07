# Documentation

Sources: [Svelte basic markup, comments](https://svelte.dev/docs/svelte/basic-markup#Comments), [Svelte FAQ](https://svelte.dev/docs/svelte/faq#How-do-I-document-my-components), [compiler warnings](https://svelte.dev/docs/svelte/compiler-warnings), [svelte compiler options](https://svelte.dev/docs/svelte/svelte-compiler#ModuleCompileOptions), [vite-plugin-svelte config](https://github.com/sveltejs/vite-plugin-svelte/blob/main/docs/config.md#compileroptions).

The `<script lang="ts">` and `<script module>` blocks and every `.svelte.ts` file follow `typescript/references/docs.md`. This file covers what Svelte adds.

## What may appear in a component

| Form | Status |
| --- | --- |
| `<!-- @component … -->` | Doc comment. One per component that is used outside its own route |
| `/** … */` on `interface Props` fields and on symbols in `<script>` or `<script module>` | Doc comment, per `typescript/references/docs.md` |
| Any other `<!-- -->`, `//` or `/* */` | Banned, CSS included |
| `<!-- svelte-ignore … -->` | Banned. Drop the warning by its code in `compilerOptions.warningFilter` in `svelte.config.js` |

## Component doc

> "The `@component` is necessary in the HTML comment which describes your component."
> Source: [Svelte FAQ](https://svelte.dev/docs/svelte/faq#How-do-I-document-my-components)

The language server shows it on hover, and it accepts markdown ([basic markup](https://svelte.dev/docs/svelte/basic-markup#Comments)).

```svelte
<!--
@component
Renders trusted HTML from the CMS. Owns the only `:global` rules for that markup.
-->
<script lang="ts">
  interface Props {
    /** Sanitised HTML. */
    html: string;
  }
  let { html }: Props = $props();
</script>
```

## Props docs

`/** */` on each `Props` field that the name and type do not explain. Field JSDoc shows in IntelliSense where the prop is used: "the props you actually do provide to the component show their JSDoc comments in their own tooltips" ([language-tools#1308](https://github.com/sveltejs/language-tools/issues/1308); see also [sveltejs/svelte#10541](https://github.com/sveltejs/svelte/issues/10541)). Hovering the component does not list props ([language-tools#1308](https://github.com/sveltejs/language-tools/issues/1308)).

**Rule:** every `$bindable` prop states why two-way binding is needed, in the `@component` doc or the prop's doc comment. See `components.md`.

## Where the reason lives

| Construct | Where the reason lives |
| --- | --- |
| `:global` | the `@component` doc of the boundary component that owns it |
| `$effect` writing `$state` | the name of the function the effect calls |
| `untrack` | inside that named function |

## Wording

Doc prose follows `stop-slop`.
