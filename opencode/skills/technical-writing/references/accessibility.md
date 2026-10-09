# Technical writing for accessibility

Google for Developers, https://developers.google.com/tech-writing/accessibility
Licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/); code samples Apache 2.0. Converted to Markdown; no wording changed.

## Contents

* [Tech Writing for Accessibility](#tech-writing-for-accessibility)
* [Tech Writing for Accessibility self-study](#tech-writing-for-accessibility-self-study)
* [Design for everyone](#design-for-everyone)
* [Write helpful alt text](#write-helpful-alt-text)
* [Use sufficient contrast](#use-sufficient-contrast)
* [Choose language that benefits everyone](#choose-language-that-benefits-everyone)
* [Add accessible visuals to writing](#add-accessible-visuals-to-writing)
* [Edit for accessibility](#edit-for-accessibility)
* [Course summary](#course-summary)

## Tech Writing for Accessibility

Source: https://developers.google.com/tech-writing/accessibility

Our mission statement is to organize the world's information and make it
universally accessible and useful. Take this course to learn how to make
your documents more accessible for everyone, including people with disabilities.
For example, this courses teaches you how to create documentation and websites
for screen reader users.

This course is available in the following two formats:

* Instructor-led, which this page describes.
* [Self-study](https://developers.google.com/tech-writing/accessibility/self-study)

Both formats cover similar, though not identical, content.

### Format of instructor-led format

This format is a 90-minute instructor-led workshop, featuring a lot of student
exercises and class discussion.

Google provides all the materials needed to run the in-class sessions at your
own organization. If you'd like to facilitate the in-class sessions for
your organization, see [Facilitating Technical Writing
Courses](https://developers.google.com/tech-writing/for-instructors).

**Note:** Google occasionally provides free, in-class sessions open to the general
public. For details, see [Announcements](https://developers.google.com/tech-writing/announcements).

### Target audience

We've aimed this course at the following roles:

* engineers
* product managers and technical program managers
* technical writers
* anyone else who writes or reviews documents

### Learning objectives

After taking this course, you will know how to do the following:

* Learn to design inclusively.
* Write helpful `alt` text for technical diagrams.
* Check color contrast.
* Create accessible diagrams.
* Detect accessibility errors in documents.

## Tech Writing for Accessibility self-study

Source: https://developers.google.com/tech-writing/accessibility/self-study

This self-study course teaches you how to write more accessible documentation.
In this context, **accessible** means that anyone can read and understand your
documentation, including people with disabilities.

### Target audience

We've designed this course for anyone who writes text, including:

* Engineers
* Program managers
* Technical writers

The accessibility principles in this course are not only relevant for
traditional technical documentation but also for any text, including:

* Design documents
* Code comments
* UI text
* Command-line help
* Error messages

### Learning objectives

After completing this course, you will know how to do the following:

* Write and design documents for everyone.
* Write effective alt text for images.
* Use sufficient color contrast for text and images.
* Create accessible diagrams.
* Identify accessibility pitfalls when editing documents.

#### Learning non-objectives

This course does not teach you everything about accessibility or provide a
detailed checklist for making docs accessible. You can find additional resources
in the course summary.

**Next unit:** [Design for everyone](https://developers.google.com/tech-writing/accessibility/self-study/inclusive-design)

## Design for everyone

Source: https://developers.google.com/tech-writing/accessibility/self-study/inclusive-design

This overview introduces key concepts of writing for everyone.

### Types of disability

Disability can be visible or invisible, and it can be situational, temporary, or
permanent. The following table includes some examples.

|  | **Vision** | **Hearing** | **Speech** | **Mobility** | **Cognition** |
| --- | --- | --- | --- | --- | --- |
| **Situational** | Driving<br>Dark room | Noisy environment | In a library<br>At a lecture | In bed<br>Arms/hands full | Forgetting information<br>Time demands |
| **Temporary** | Dilated pupils<br>Cataracts | Ear infection | Laryngitis | Arm or hand injury | No prior training<br>Multi-tasking |
| **Permanent** | Blindness<br>Vision impairment | Deaf<br>Hard-of-hearing | Dysarthria<br>Stuttering | Amputation<br>Parkinson's disease | Dementia |

According to the [World Health Organization](https://www.who.int/news-room/fact-sheets/detail/disability-and-health),
about 16% of the world's population experiences significant disability. However,
as the preceding table illustrates, disability shows up in various ways and can
affect anyone at different times in life. Designing for everyone does indeed
benefit everyone.

### The curb cut effect

Designing for everyone often results in benefits beyond the intended
use cases.

The *curb cut effect* is a common example of beneficial design in the physical
world. Originally, curb cuts (sidewalk ramps) were designed for people in
wheelchairs. However, many people benefit from curb cuts, such as anyone with a
stroller, suitcase, or delivery cart.

Here are some other examples of the curb cut effect in digital technology:

* **Contrast ratios**: Color contrast requirements were originally designed to
  help people who have low vision or color blindness. Color contrast
  requirements also ended up helping people who are trying to see the phone
  screen on a sunny day, or who had their pupils dilated at the eye doctor.
* **Text to speech and voice commands**: These tools assist people who are blind
  or have low vision. They also turned out to be useful for hands-free
  use while driving, cooking, or holding a baby.
* **Keyboard access**: Improving keyboard navigability improves accessibility
  for screen reader users and people with motor impairments. Keyboard access
  also improves productivity for power users.
* **Clear language**: Simplifying language makes documentation easier to
  understand, and it also eases translation and localization.

**Next unit:** [Write helpful alt text](https://developers.google.com/tech-writing/accessibility/self-study/write-alt-text)

## Write helpful alt text

Source: https://developers.google.com/tech-writing/accessibility/self-study/write-alt-text

*Alternative text* (alt text) is short, descriptive text that acts as a
substitute for visual items on a page. The most common use is for describing
images.

Alt text supports readers in the following ways:

* Screen readers read alt text for people who are blind or who have low vision.
* Descriptive alt text also helps to [improve search results for
  images](https://developers.google.com/search/docs/appearance/google-images).

### Write useful alt text

Alt text acts as a functional equivalent of an image for readers who can't
view the image. The following subsections describe best practices for writing
helpful alt text.

#### Explain the image in context

Explain images in the context of the text. For example, the following
photograph shows a black-capped chickadee perched on a snowy branch:

In the context of the surrounding text, you might choose to emphasize or
omit aspects of an image in your description. Consider the following snippets
of text:

Snippet 1:

> A mixed-species flock is a flock of different bird species that travel
> together. In northern temperate zones, chickadees and titmice typically lead
> mixed flocks with other small songbirds. The calls of the chickadees and
> titmice alert the other species to nearby food or threats.

In the context of this snippet, the purpose of the image is to show an example
of a bird species that leads the mixed flock. The time of year, the specific
type of chickadee, or details about the appearance of the chickadee are not
important for that purpose. Alt text that identifies the bird species is
sufficient.

```
alt="A chickadee perched on a branch."
```

Snippet 2:

> Black-capped chickadees cache food and can remember the locations where they
> stored it for up to 28 days. In winter, they lower their body temperature
> during the night to conserve energy. They also fluff their feathers to trap
> warm air, and the layers of warm air provide insulation from the cold.

This snippet specifically mentions the black-capped chickadee and its fluffed
feathers in cold weather. In this context, the type of chickadee and its
appearance in winter are relevant, so the alt text description should
include those aspects of the image:

```
alt="A black-capped chickadee perched on a snowy branch with fluffed feathers."
```

The following Google Chrome Developers video explores other examples of how
context affects the way you describe an image:

[Video: https://www.youtube.com/watch?v=flf2vS0IoRs](https://www.youtube.com/watch?v=flf2vS0IoRs)

#### Briefly summarize the image's purpose

Use a short phrase or one or two sentences. Long descriptions interrupt the
reading flow for screen reader users.

* Don't include extra words like "Image of" or "Photo of."
* Capitalize the first word and include a final period.
* Use other punctuation as necessary.

Screen readers generally pause for periods and some other types of
punctuation. Although a final period is not technically required, it
provides auditory separation between the image description and the body
text that follows the image.

The Web Accessibility in Mind site provides guidelines for designing content
that is compatible with screen readers, including a summary of
[how screen readers read content](https://webaim.org/techniques/screenreader/#how).

If you can't capture the meaning of the image in a sentence or two, describe the
meaning of your image in the text of your document. See [Describe complex images
in your document](https://developers.google.com/tech-writing/accessibility/self-study/write-alt-text#complex-images).

#### Avoid duplicating the surrounding text

If the meaning of your document would be the same without the image, add
an empty alt text attribute to the image (`alt=""`). Assistive technologies
ignore the empty attribute.

Use empty alt text in the following situations:

* The image is decorative (not informative), such as an image of a horizontal
  line that is meant to be a visual border at the end of a page.

  Consider making a decorative image a CSS background image, since background
  images are always ignored by screen readers.
* The image duplicates information that is already expressed in text on the
  page.

If you don't include alt text for an image, then screen readers read the
filename aloud instead of ignoring the image. A user of a screen reader has
no information to indicate whether the image contains useful information.

#### Describe complex images in your document

The information in a complex image such as a flowchart, graph, or map can be
difficult to describe in a few short sentences. In this situation, provide
a short description of the image in the alt text and a longer textual
description in the main text of your document or on a separate page that you
link to.

* For graphs, you can provide a data table on the same page or on a separate
  page.
* For flowcharts and diagrams, explain the process or parts of your image in the
  text of your document.

For example, the [Software supply chain threats](https://cloud.google.com/software-supply-chain-security/docs/attack-vectors) page
has a diagram with phases of software development and potential entry points for
vulnerabilities and software attacks.

* The alt text for the diagram is `A diagram that shows entry points for
  software supply chain attacks.`
* The body text introduces the image, explains the use of the image
  legend, and then explains each section of the diagram in context.

In situations where the image and the detailed description aren't close
together, specify the location of the detailed description in the alt text. The
following alt text example includes the section heading for the detailed
description.

```
alt="Route map with rest stop locations. Rest stop locations are listed under
Taking breaks during your ride."
```

**Note:** Avoid using the `longdesc` attribute to describe complex images. The
`longdesc` attribute is not well supported by screen readers. The attribute is
also an [obsolete feature](https://html.spec.whatwg.org/multipage/obsolete.html) in the HTML Living
Standard.

#### Include demographic information only when necessary

When you describe people, include demographic information only if it is critical
to the main point of the image. Otherwise, use *person* or another term that
provides key context about the person's activity or role in the image, such as
*musician*, *basketball player*, *teacher*, or *doctor*.

For information about using appropriate language to describe people, see
[Inclusive language](https://developers.google.com/style/inclusive-documentation) in the Google developer
documentation style guide.

#### Other considerations

* For repeated images, use consistent alt text.
* Avoid all caps.
  * Words in all caps always have a rectangular shape,
    whereas words in regular case have distinct shapes. Some people with visual
    or cognitive disabilities rely more on the shape of words to read them.
  * Screen readers might misread words in all caps as acronyms.
* Introduce diagrams in the body text, not in the alt text.

### Examples

The following examples apply the principles of writing helpful alt text.

Review the alt text options for each example. The most appropriate option
provides concise and relevant context for the image.

#### Example 1

Consider these alt text options:

* Too concise: `alt="Waffles."`
* Too wordy: `alt="Photo of a round
  white plate with 17 slices of red strawberries surrounding a stack of three
  golden-brown waffles with two whole red strawberries on top, with leaves."`
* Just right: `alt="A stack of waffles on a
  plate with strawberries."`

#### Example 2

The Go gopher is the mascot of the Go programming language.

Consider these alt text options:

* Too concise: `alt="Gopher."`
* Too wordy: `alt="Drawing of blue Go gopher
  with large round eyes, small yellow paws, single white tooth, and pink hat
  with small tassel, blowing noisemaker with orange and yellow stripes."`
* Just right: `alt="Go gopher with
  noisemaker and 10th anniversary party hat."`

### Exercises

Practice what you have learned by writing some alt text.

For each image:

1. Imagine a context for the image.
2. Write alt text that's appropriate for the context you chose.

#### Exercise 1

##### Click the icon to see possible answers.

Possible answers:

* Too concise:
  `alt="Google Cardboard user."`
* Too wordy:
  `alt="Person wearing gray and white striped shirt with orange cuffs,
  holding Google Cardboard viewer in front of eyes, with teeth exposed."`
* Just right:
  `alt="Person looking into Google Cardboard viewer and smiling."`

---

#### Exercise 2

Image source: [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:United_States_per_capita_energy_use_1650-2010.png)

##### Click the icon to see possible answers.

Possible answers:

* Too concise:
  `alt="United States Per Capita Energy Use."`
* Too wordy: `alt="Line graph
  showing per capita energy use in the United States from the year 1650
  through the year 2000, showing a large increase after 1900 with the peak
  between 1970 and 1980."`
* Just right: `alt="United States
  per capita energy use increased sharply after 1900 and peaked around 1975."`

---

#### Learn more

* Read the Google developer documentation style guidelines on
  [Accessibility](https://developers.google.com/style/accessibility) and
  [Alt text](https://developers.google.com/style/images#alt-text)
* Read the [W3C tutorial for images](https://www.w3.org/WAI/tutorials/images/)
* Read the [Web Accessibility in Mind alt text guidelines](https://webaim.org/techniques/alttext/)

**Next unit:** [Use sufficient contrast](https://developers.google.com/tech-writing/accessibility/self-study/sufficient-contrast)

## Use sufficient contrast

Source: https://developers.google.com/tech-writing/accessibility/self-study/sufficient-contrast

Higher contrast makes it easier for everyone to read text and images. When there
is low contrast, everyone has difficulty viewing content.

Color blindness affects over 300 million people worldwide: 1 in 12 men and 1 in
200 women.

Higher contrast helps people with color blindness and low vision, or anyone that views a screen in
bright sunlight.

Visit [Colour Blind Awareness](https://www.colourblindawareness.org/colour-blindness/types-of-colour-blindness/) to learn more about the effects of color blindness.

[WCAG](https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html) suggests these minimum contrast ratios:

* 4.5:1 for small text
* 3:1 for large text (at least 14 pt bold/18 pt regular)

Consider the following contrast examples:

* Poor contrast
* Better contrast
* Best contrast

### Exercise: Choose colors with sufficient contrast

Complete the following exercise to practice measuring sufficient color contrast:

1. In a separate browser window, open the [Contrast Checker](http://webaim.org/resources/contrastchecker) by Web Accessibility In Mind (WebAIM).
2. In the contrast checker, enter the following Hex colors to find out which foreground-background ratios meet contrast requirements. Record the contrast ratios on a notepad or separate document to compare your answers with the [possible answers](https://developers.google.com/tech-writing/accessibility/self-study/sufficient-contrast#answers).

1. First rectangle:
   * Foreground: #148695
   * Background: #FD9C32
2. Second rectangle:
   * Foreground: #EBFF33
   * Background: #667E8B
3. Third rectangle:
   * Foreground: #128697
   * Background: #EAEAEA

**Click the icon to see the expected answers.**

1. First rectangle: FAIL
   * Foreground: #148695
   * Background: #FD9C32
2. Second rectangle: FAIL
   * Foreground: #EBFF33
   * Background: #667E8B
3. Third rectangle: FAIL
   * Foreground: #128697
   * Background: #EAEAEA

Even though some of the pairs may *look* higher contrast, none of them actually meets WCAG standards.
Unfortunately, "eyeballing it isn't enough"—it's best to use a contrast checker.

Use minimum contrast guidelines to ensure that everyone can see your content.

**Next unit:** [Choose inclusive language](https://developers.google.com/tech-writing/accessibility/self-study/inclusive-language)

## Choose language that benefits everyone

Source: https://developers.google.com/tech-writing/accessibility/self-study/inclusive-language

When writing about people with disabilities or about accessibility, be mindful
about using unintentionally biased language that may cause harm.

### Write thoughtfully about disability

Don't use euphemisms or patronizing terms:

* **Avoid** describing people without disabilities as *normal* or *healthy*.
* **Better**: *nondisabled person, sighted person, hearing person, person
  without disabilities, neurotypical person*.
* **Avoid** terms that reflect or project feelings and judgements about a
  person's disability, such as *victim of, suffering from, wheelchair-bound*.
* **Better**: *experiencing, living with, uses a wheelchair*

### Person-first and identity-first language

When writing about accessibility and people with disabilities, be sure to
center the person or community, and avoid terms that remove personhood.

* **Avoid** language like *the disabled*
* **Better**: *people with disabilities*

**Note**: While person-first language is generally preferred (person with a
cognitive impairment, person with low vision), some people prefer identity-first
language; for example, this preference is common in Deaf and neurodivergent
communities (Deaf person, neurodivergent person).

Before writing about a community, take time to educate yourself about how the
community prefers to be identified and described. Some helpful resources include
the following:

* [Write documentation for all](https://developers.google.com/style/inclusive-documentation): General guidelines and examples that
  illustrate some best practices for writing documentation for everyone.

**Next unit:** [Add accessible visuals to writing](https://developers.google.com/tech-writing/accessibility/self-study/visual-cues)

## Add accessible visuals to writing

Source: https://developers.google.com/tech-writing/accessibility/self-study/visual-cues

In this unit, you learn how to create accessible visuals that use a mix of text
and visual elements, rather than relying on visual cues to convey information.

### Why visual indicators are insufficient

Visual cues like color, shape, and pattern can be effective tools for
communicating information. However, to ensure that content is accessible to a
wide audience, don't rely exclusively on the visual elements, such as the
following:

* colors
* patterns
* images
* font styling
* directional words (for example, "top-right corner")

Instead, use a mix of these visual elements and accompany them with descriptive
text to convey information. It is also important to provide text descriptions or
alternative text when using images, diagrams, or other diagrams.

Users with visual impairments, including color blindness, may not fully perceive
certain visual cues. Incorporating a mix of visual elements with accompanying
descriptive text helps ensure that the intended meaning is conveyed to everyone,
regardless of their ability to perceive the visuals. This approach can also help
eliminate ambiguity that might arise if the meaning or purpose of a color or
shape is not clear to everyone.

### Examples

The following examples help illustrate why it's important not to rely only on
color to communicate information, and how you can use text, color, and symbols
to enhance the accessibility of your visuals.

#### Don't rely on color alone

The following example of comma usage, adapted from the [Google
developer documentation style
guide](https://developers.google.com/style/commas#commas-separating-two-independent-clauses), relies only on color (red and green) to communicate important
information, thus excluding anyone who is color blind or otherwise visually
impaired.

In this example, the red sentences use commas incorrectly, and the green
sentences use commas correctly:

* The libraries make feed creation easier, and
  they ensure that only valid feeds are produced.
* The libraries make feed creation easier and they
  ensure that only valid feeds are produced.
* Type your ID and click OK.
* Type your ID, and click OK.

Some color-blind users can't distinguish between the red text and the green
text, so they'd be unable to tell from the previous example alone which example
is correct. The only distinguishing factor in this example is the color, so
people who either can't see the text or can't distinguish between the colors
wouldn't be able to tell which is the correct example.

#### Use text, color, and symbols for better accessibility

The following example uses the red "thumbs down" and the green "thumbs up"
symbols in addition to text. This change makes it so the text would be clear
even if you removed all color and other visual indicators.

Recommended: The
libraries make feed creation easier, and they ensure that only valid feeds
are produced.

Not recommended: The
libraries make feed creation easier and they ensure that only valid feeds
are produced.

Recommended: Type your
ID and click **OK**.

Not recommended: Type
your ID, and click
**OK**.

The use of color with the thumbs up and thumbs down symbols could be a useful
visual reference for people who can see them. For people who can't see or
distinguish between the visual cues, providing descriptive text (in this case,
"Not recommended" and "Recommended") is helpful.

### Exercise: Fix a diagram

Next, think about how you could edit the following diagram to make it more
accessible.

(Image: Sample diagram with yellow, blue, purple, and green rectangles connected by arrows.)

This diagram uses rectangles of different colors to represent categories.
Because the diagram relies solely on color to differentiate categories, it
presents accessibility challenges. To make the diagram more accessible, consider
incorporating design elements such as different shapes, line weights, patterns, or
text labels to clearly differentiate the categories.

##### Click the icon to see a possible answer.

Possible answer:

(Image: Sample diagram with a yellow trapezoid labeled A, a blue circle labeled B, a purple triangle labeled C, and a green rectangle labeled D.)

Instead of relying only on color to convey information, this version of the diagram enhances accessibility by combining text labels, color, and shape. Each category has a unique shape (trapezoid, circle, triangle, rectangle) and a text label (A, B, C, D).

---

**Next unit:** [Edit for accessibility](https://developers.google.com/tech-writing/accessibility/self-study/editing-accessibility)

## Edit for accessibility

Source: https://developers.google.com/tech-writing/accessibility/self-study/editing-accessibility

In this unit, you learn how to edit your own and others' writing to make it more
accessible to all users. The unit focuses on ways to write—and
edit—your documentation to make it accessible to everyone. This unit is not meant
as an exhaustive reference, but it does describe some general best practices for
editing documentation to focus on accessibility.

### Cultivate an accessibility mindset for doc editing

When you are aware of and focus on the fundamentals of good writing, you also
make your documentation more accessible.

With practice, self-editing can help you catch accessibility pitfalls, such as
these:

* poor or missing headings
* uninformative link text
* dense, complex text

### Create helpful headings

Headings help your audience understand what's in your document. Clear,
well-structured document headings simplify navigation for people with
cognitive disabilities and those who use screen readers.

* Tag headings with heading elements.
  * HTML: `<h1>`, `<h2>`, `<h3>` ...
  * Markdown: `#`, `##`, `###` ...
* Use a level-1 heading for the page title or main content heading.
* Don't skip levels of the heading hierarchy. For example, don't jump from an
  `<h1>` to an `<h3>`.

References:

* [Headings and titles](https://developers.google.com/style/headings)
* [Cognitive accessibility design pattern:  Make the site hierarchy easy
  to understand and
  navigate](https://www.w3.org/WAI/WCAG2/supplemental/patterns/o2p02-site-structure/)
* [Making content usable for people with cognitive and learning disabilities](https://www.w3.org/TR/coga-usable/#summary-find)

### Include informative link text

People who use screen readers often use them to scan a page to hear just the
links. Use informative link text to ensure that your audience hears meaningful
information, not just "Learn more, learn more, learn more."

* Avoid:
  * [Learn more](https://developers.google.com/style/tables)
  * [Click here](https://developers.google.com/style/tables)
  * [This document](https://developers.google.com/style/tables)
* Good:
  * Learn how to [format tables](https://developers.google.com/style/tables).
  * Read about [machine learning](https://developers.google.com/machine-learning).

> **Bonus:** Informative link text also improves search engine optimization.

Reference: [Link text](https://developers.google.com/style/link-text)

### Use straightforward language and short sentences

Other units in this course talk about making visual images accessible to
everyone. Remember that abstract and unfamiliar *written* representations
can also be particularly challenging for users with cognitive or visual
impairments.

Avoid unfamiliar jargon, US-based slang, pop-cultural references, and
complicated linguistic constructions. Use active voice and short sentences,
and define your technical terms on first use if they are not commonly
understood.

References:

* [Active voice](https://developers.google.com/style/voice)
* [Jargon](https://developers.google.com/style/jargon)
* [Designs that make use of abstract imagery and metaphors](https://www.w3.org/TR/coga-usable/#amy-scenario-3-designs-that-make-use-of-abstract-imagery-and-metaphors)

### Exercise: Edit a document

In this exercise, you edit a short document to make it more accessible.

Focus on the order in which the information is presented; place writing tips
first. Simplify the wording where possible. You can change anything, but
especially look for accessibility pitfalls such as missing or unnecessary
headings, uninformative link text, and dense, complex text.

Whenever possible, streamline and simplify the wording. This suggestion isn't
accessibility-specific; however, as with many writing tips, good writing is good
for accessibility.

Now, make a copy of the following exercise and edit it for
accessibility.

> #### A list of reasons why simplifying a document through editing is good
>
> Determine whether or not you can simplify your document through the use of
> terminology that is equivalent but relatively shorter in length and therefore
> more easily comprehensible by your audience. It's important to make sure your
> document is edited before it is seen by your audience, which might include
> people that are less or more familiar with the matter covered by your
> document.
>
> Step 1
>
> The first thing you need is a rough draft. Some things
> that can help make your document easier to read are making sure you have links
> to background information, and also checking for active voice instead of
> passive voice. If you have long sentences you can consider shortening them or
> implementing the use of a list to make the information easier to scan.
>
> Step 2
>
> The second thing you need is a list of resources that will help you edit, like
> [this page](https://developers.google.com/style/).
>
> Also [this other one is
> good,too](https://learn.microsoft.com/en-us/style-guide/accessibility/writing-all-abilities).
>
> Once you have editing resources to use as you edit, you can use them to edit
> your document.

#### Tips for getting started

The title of the exercise is *A list of reasons why simplifying a
document through editing is good*; one approach might be to look for language
that could be presented in a bulleted list or lists.

Highlight or otherwise identify phrases that could work as bulleted items. Start to build your bulleted list (or lists). As you do so, look for ways to make complex text simpler by using active voice and short phrases. Revise link text to be informative. Keep list items parallel.

##### Build your bulleted list

The following table shows how you might begin to break down the longer paragraphs into concise bulleted lists.

| **Existing text** | **Possible list items** | **Edited list items** |
| --- | --- | --- |
| Paragraph 1: Determine whether or not you can **simplify your document** through the use of **terminology that is equivalent but relatively shorter in length** and therefore more easily **comprehensible by your audience**. | * Determine whether or not you can **simplify your document**.<br>* Use **terminology that is equivalent but relatively shorter in length.**<br>* Make sure your material is **comprehensible to your audience**. | * **Simplify**: Use short sentences.<br>* Check **terminology**: If you use words that might be unfamiliar to your audience, include definitions.<br>* *Note: The second bullet covers this already.* |
| Paragraph 2: It's important to **make sure your document is edited** before it is seen by **your audience**, **which might include people that are less or more familiar**with the matter covered by your document. | * Make sure your document is **edited**.<br>* *Note: You've already addressed the need to **know your audience**. You can cut this repetitive information.* | * **Edit**: Request a review or peer edit from someone who is familiar with your subject matter. |

> **Note:** Learn more about creating lists in [Tech Writing One](https://developers.google.com/tech-writing/one/lists-and-tables).

If you continue breaking down the existing text into possible bulleted items,
you can organize and order the items logically, which will make the information
easier for your readers to understand and act on.

##### Click the icon to see a possible answer.

Before you share a document, use these basic editing techniques to make sure
that your audience can understand your message.

* Simplify: Use short sentences.
* Use active voice: Change passive voice to active voice.
* Include lists: If possible, change long paragraphs to lists to make
  information easier to scan.
* Know your audience: Focus on the needs and knowledge level of your
  potential users.
* Check terminology: If you use words that might be unfamiliar to your
  audience, include definitions.
* Provide background information: Include links to resources that your
  audience might find useful.
* Edit: Request a review or peer edit from someone who is familiar with
  your subject matter.

Read more about writing and editing documentation for accessibility in
the following resources:

* [*Google developer documentation style guide*](https://developers.google.com/style)
* [*Microsoft style guide:* Writing for all abilities](https://learn.microsoft.com/en-us/style-guide/accessibility/writing-all-abilities)

---

### Test your content for accessibility

Finally, to get a feel for some different ways your users might access and
consume your document, try these testing tips:

* Change the zoom level to help accommodate readers on small screens or
  full-size monitors.
* Use only the keyboard to navigate your document. For example, see
  [Keyboard shortcuts in Chrome](https://support.google.com/chrome/answer/157179).
* Use a screen reader:
  * ChromeVox for ChromeOS
  * VoiceOver for Mac

These methods can help you assess the usability of your document for different
audiences as you edit your own and others' documents for accessibility.

**Next unit:** [Conclusion](https://developers.google.com/tech-writing/accessibility/self-study/conclusion)

## Course summary

Source: https://developers.google.com/tech-writing/accessibility/self-study/conclusion

Technical Writing for Accessibility focused on the following ideas:

* Accessibility in documentation benefits
  people with permanent, temporary, or situational disabilities.
* Every image requires an alt text element. Alt text acts as a functional
  equivalent for an image by providing a concise summary of the image's purpose
  and context.
* Sufficient color contrast helps readers with color blindness or low vision.
* Write for a broad spectrum of readers.
* Avoid relying only on visual indicators, such as colors or patterns, to
  communicate important information.
* Practice editing for accessibility to ensure proper heading structure,
  descriptive link text, and clear language.

### Continue learning

* [Write accessible documentation](https://developers.google.com/style/accessibility): Accessibility
  guidelines
