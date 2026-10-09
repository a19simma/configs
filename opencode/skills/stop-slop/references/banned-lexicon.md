# Banned Lexicon

Local addition. Single-word and phrase-level tells. Grep-style, no rationale per entry.
Structural tells live in `structures.md`; sentence-level filler in `phrases.md`.

Derived from Wikipedia:Signs of AI writing (WikiProject AI Cleanup), blader/humanizer v3.1.0,
and the anti-slop skill ecosystem. Ban the word only when it is doing decorative work. A `robust`
retry policy in a design doc is fine; `robust solution` is not. The same goes for `gate`, `key`
and `landscape`: keep the technical sense.

## Vocabulary

delve, delves, delving, tapestry, landscape, ecosystem, realm, space (as in "the AI space"),
journey, fabric, testament, vibrant, pivotal, crucial, intricate, intricacies, meticulous,
meticulously, bolster, bolstered, garner, garnered, underscore, underscores, interplay,
multifaceted, nuanced, foster, fostering, leverage, utilize, commence, facilitate, encompass,
encompassing, paramount, groundbreaking, cutting-edge, game-changing, game-changer, transformative,
revolutionize, revolutionise, seamless, seamlessly, robust, comprehensive, holistic, endeavor,
endeavour, aforementioned, harnessing, spearheading, navigating, showcase, showcasing, highlight,
highlighting, emphasizing, enhance, enhancing, unprecedented, remarkable, stunning, profound, epic,
myriad, plethora, elevate, empower, supercharge, streamline, unlock, curated, bespoke, synergy,
synergies, enduring, indelible, valuable, key (adjective), gated, gating (figurative)

Sales words: nestled, in the heart of, renowned, breathtaking, must-visit, diverse array, rich
(figurative), natural beauty, commitment to

## Copulative substitutes

Replace with `is`, `are`, `was`, `has`, `does`:

serves as, stands as, acts as, functions as, operates as, emerged as, represents, constitutes,
embodies, exemplifies, marks, positions itself as, plays a key role in, is characterized by,
boasts, features, offers, maintains (when `has` fits)

## Phrases

"It's important to note that", "Let's dive in", "Let's dive deeper", "Let's delve into",
"In the realm of", "A testament to", "This is where X comes in", "Whether you're a X or a Y",
"From X to Y", "The bottom line is", "Here's the deal", "Without further ado", "In a nutshell",
"Buckle up", "Take it to the next level", "Unlock the power of", "Elevate your",
"Streamline your", "Supercharge your", "Bridge the gap", "Move the needle", "In conclusion",
"Overall,", "To sum up", "Firstly... Secondly... Thirdly", "I hope this email finds you well",
"As per my last email", "Please don't hesitate to reach out", "stands as a testament",
"rich tapestry of", "It is important to remember", "evolving landscape", "indelible mark",
"enduring legacy", "a step in the right direction"

## Openers

"Certainly,", "Absolutely,", "Sure,", "Of course!", "Great question!", "That's a great point!",
"You're absolutely right", "I'd be happy to", "As an AI", "As a language model",
"However, it's important to", "Moreover,", "Furthermore,", "Additionally,", "Interestingly,",
"Notably,", "Importantly,", "Indeed,", "Ultimately,", "Essentially,", "Crucially,"

## Chat residue

A chatbot wrapper left in text that should stand alone. The surest tell. Remove the wrapper, keep
the content.

"Here is a...", "I hope this helps", "Let me know if", "Would you like...", "Want me to...?",
"Should I continue?", "Feel free to ask"

## Formatting tells

- Curly quotes and curly apostrophes when the surrounding text uses straight ones.
- Title Case On Every Heading.
- Headings written for effect ("The decision, on one screen") instead of naming the content
  ("How the six options compare").
- A top-level heading that repeats the document title.
- Bold mid-sentence for emphasis. Reserve bold for headers and table keys.
- Inline-header vertical lists: `- **Term:** explanation` repeated down a list, where the labels
  carry nothing the sentences don't.
- Emoji or arrows (→) on headings and list items, unless the user's own samples use them.
- Horizontal rules between every section.
- Hyphenated pairs after the noun: "the report is high-quality" reads "high quality". Before the
  noun the hyphen stays: "a high-quality report".
- `utm_source=chatgpt.com` or similar tracking params left in citation URLs.

## Never touch

A banned word inside anything SKILL.md lists under Preserve verbatim stays.
