---
name: presenterm
description: Use when creating or editing terminal presentations with presenterm. Triggers on .md slideshow files, requests to build/structure a presentation, or when the user wants slides in the terminal.
---

# Using Presenterm

Presenterm renders markdown files as terminal slideshows. Run with:
```bash
presenterm slides.md
```

## Slide Structure

Slides are separated by `---`:

```markdown
# Title Slide

Welcome to my talk

---

## Second Slide

Content here
```

---

## Pauses & Incremental Reveals

Use HTML comments to control reveal timing:

```markdown
## My Slide

First point visible immediately.

<!-- pause -->

This appears on next keypress.

<!-- incremental_lists: true -->
* revealed one at a time
* second item
* third item
```

---

## Code Highlighting

### Static — highlight specific lines
````markdown
```rust {1,3}
fn main() {
    let x = 1;       // highlighted
    println!("{x}"); // highlighted
}
```
````

### Dynamic — step-through (advance with keypress)
````markdown
```rust {1-2|4-5}
fn main() {
    let x = 1;
    // step 1: lines 1-2 highlighted
    let y = 2;
    println!("{}", x + y);
    // step 2: lines 4-5 highlighted
}
```
````

Use `+line_numbers` to show line numbers:
````markdown
```python +line_numbers {2|4}
def greet(name):
    msg = f"Hello, {name}"   # step 1
    ...
    return msg               # step 2
```
````

### Code from external files
````markdown
```file +line_numbers
path: src/main.rs
language: rust
start_line: 10
end_line: 25
```
````

---

## D2 Diagrams

Use D2 for architecture, flow, and sequence diagrams. Embed directly in the slide:

````markdown
```d2
Client -> Server: HTTP request
Server -> DB: query
DB -> Server: result
Server -> Client: HTTP response
```
````

````markdown
```d2
direction: right

api: API Gateway
auth: Auth Service
db: Database

api -> auth: validate token
api -> db: fetch data
```
````

D2 renders inline — prefer it over ASCII art or external image files for any diagram that shows relationships, flows, or architecture.

---

## Slide Transitions

Configure in `~/.config/presenterm/config.yaml`:

```yaml
defaults:
  theme: dark
transition:
  style: slide_horizontal   # fade | slide_horizontal | collapse_horizontal
  duration_millis: 300
  frames: 30
```

---

## Key Patterns

| Goal | Syntax |
|------|--------|
| New slide | `---` |
| Pause reveal | `<!-- pause -->` |
| Incremental list | `<!-- incremental_lists: true -->` |
| Highlight lines | ` ```lang {1,3} ` |
| Step highlights | ` ```lang {1-2\|4-5} ` |
| Line numbers | ` ```lang +line_numbers ` |
| D2 diagram | ` ```d2 ` |
| Center content | `<!-- jump_to_middle -->` |
| Extra spacing | `<!-- new_lines: 3 -->` |
