# Technical Writing Two

Google for Developers, https://developers.google.com/tech-writing/two
Licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/); code samples Apache 2.0. Converted to Markdown; no wording changed.

## Contents

* [Technical Writing Two introduction](#technical-writing-two-introduction)
* [Self-editing](#self-editing)
* [Organizing large documents](#organizing-large-documents)
* [Illustrating](#illustrating)
* [Creating sample code](#creating-sample-code)
* [Using large language models (LLMs) in technical writing](#using-large-language-models-llms-in-technical-writing)
* [Summary of Technical Writing Two](#summary-of-technical-writing-two)

## Technical Writing Two introduction

Source: https://developers.google.com/tech-writing/two

*Technical Writing Two*
helps technical people advance their technical communication skills.

### Target audience

We've aimed this course at people who have completed
[Technical Writing One](https://developers.google.com/tech-writing/one). If you've never taken any technical
writing training, we recommend completing *Technical Writing One* before taking
this class.

### Learning objectives

This course focuses on several intermediate topics in technical writing.
After completing both the pre-class and instructor-led components of this
class, you will know how to do the following:

* Choose among several different tactics to write first drafts and
  additional tactics for writing second and third drafts.
* Use several techniques to detect mistakes in your own writing.
* Organize large documents.
* Introduce a document's scope and any prerequisites.
* Write clear figure captions.
* Pick the proper information density for technical illustrations.
* Focus the reader's attention to selected parts of a technical illustration.
* Establish context through a "big picture" technical illustration.
* Create useful sample code that demonstrates a range of complexity.
* Identify different documentation types.
* Develop a systematic approach to describing complex technical topics.
* Empathize with a beginner audience and write a tutorial for them.
* Use LLMs to generate, edit, format, and summarize technical documents
  more efficiently.

It takes years of focused practice to become a great engineer or a great
technical writer. This course will improve your technical writing but
won't instantly transform you into a great technical writer.

### Pre-class and instructor-led components

The course consists of the following two components:

* Pre-class
* Instructor-led

(You are viewing the start of the pre-class component.)

The instructor-led component enhances the lessons taught in the pre-class
components. That said, even if you never attend the instructor-led component,
the pre-class lessons on their own still provide a valuable educational
experience.

### Hardware and network requirements

Although this course is optimized for a laptop or desktop, you may
take the course on a tablet or phone. Note that you'll do a lot of
typing during the instructor-led component.

You need an internet connection to take the course. You cannot download
the course. The course is not available on tangible media.

The pre-class component contains a few short videos, all of which are optional
viewing. If you want to skip the videos, then you can take the course on a
low-bandwidth internet connection.

**Next unit:** [Self-editing](https://developers.google.com/tech-writing/two/editing)

## Self-editing

Source: https://developers.google.com/tech-writing/two/editing

**Estimated Time:** 10 minutes

Imagine that you just wrote the first draft of a document. How do you make it
better? In most cases, working towards a final published document is an
iterative process. Transforming a blank page into a first draft is often the
hardest step. After you write a first draft, make sure you set aside plenty of
time to refine your document.

The editing tips in this unit can help turn your first draft into a document
that more clearly communicates the information your audience needs. Use one tip
or use them all; the important thing is to find a strategy that works for you,
and then make that strategy part of your writing routine.

**Note:** The tips in this unit build on the basic writing and editing skills
from Technical Writing One. This unit includes a summary of useful editing
techniques from that course. For a more detailed refresher, visit the
[self-study units](https://developers.google.com/tech-writing/one) from Technical Writing One.

### Adopt a style guide

Companies, organizations, and large open source projects frequently either adopt
an existing style guide for their documentation or write their own. Many of
the documentation projects on the [Google Developers](https://developers.google.com/) site follow the
[Google Developer Documentation Style Guide](https://developers.google.com/style). If you've never relied on
a style guide before, at first glance the Google Developer Documentation Style
Guide might seem a little intimidating, offering detailed guidance on topics
such as grammar, punctuation, formatting, and documenting computer interfaces.
You might prefer to start by adopting the
[style-guide highlights](https://developers.google.com/style/highlights).

**Note:** For smaller projects, such as team documentation or a small open source
project, you might find the highlights are all you need.

Some of the guidelines listed in the highlights are covered in Technical Writing
One. You might recall some of the following techniques:

* Use [active voice](https://developers.google.com/tech-writing/one/active-voice) to make clear who's
  performing the action.
* Format sequential steps as
  [numbered lists](https://developers.google.com/tech-writing/one/lists-and-tables).
* Format most other lists as bulleted lists.

The highlights introduce many other techniques that can be useful when writing
technical documentation, such as:

* [Write in the second person](https://developers.google.com/style/person). Refer to your audience as
  "you", not "we".
* [Place conditions before instructions](https://developers.google.com/style/sentence-structure),
  not after.
* Format [code-related text as code font](https://developers.google.com/style/code-in-text).

### Think like your audience

Who is your audience? Step back and try to read your draft from their point of
view. Make sure the purpose of your document is clear, and provide definitions
for any terms or concepts that might be unfamiliar to your readers.

It can be helpful to outline a persona for your audience. A persona can consist
of any of the following attributes:

* A role, such as *Systems Engineer* or *QA Tester*.
* An end goal, such as *Restore the database*.
* A set of assumptions about the persona and their knowledge and experience.
  For example, you might assume that your persona is:
  * Familiar with Python.
  * Running a Linux operating system.
  * Comfortable following instructions for the command line.

You can then review your draft with your persona in mind. It can be especially
useful to tell your audience about any assumptions you've made. You can also
provide links to resources where they can learn more if they need to brush up on
a specific topic.

Note that relying too heavily on a persona (or two) can result in a document
that is too narrowly focused to be useful to the majority of your readers.

For a refresher and more information on this topic from Technical Writing One,
see the [Audience](https://developers.google.com/tech-writing/one/audience) self-study unit.

### Read it out loud

Depending on the context, the style of your writing can alienate, engage, or
even bore your audience. The desired style of a given document depends to an
extent on the audience. For example, the contributor guide for a new open source
project aimed at recruiting volunteers might adopt a more informal and
conversational style, while the developer guide for a commercial enterprise
application might adopt a more formal style.

To check if your writing is conversational, read it out loud. Listen for awkward
phrasing, too-long sentences, or anything else that doesn't feel natural.
Alternatively, consider using a [screen
reader](https://en.wikipedia.org/wiki/Screen_reader) to voice the content for
you.

For more information on adjusting the style of your writing to suit your
audience, see [Style and authorial tone](https://developers.google.com/style/tone).

### Come back to it later

After you write your first draft (or second or third), set it aside. Come back
to it after an hour (or two or three) and try to read it with fresh eyes.
You'll almost always notice something that you could improve.

### Change the context

Some writers like to print their documentation and review a paper
copy, red pencil in hand. A change of context when reviewing your own work can
help you find things to improve. For a modern take on this classic tip, copy
your draft into a different document and change the font, size, and color.

### Find a peer editor

Just as engineers need peers to review their code, writers need editors to give
them feedback on docs. Ask someone to review your document and give you
specific, constructive comments. Your peer editor doesn't need to be a subject
matter expert on the technical topic of your document, but they do need to be
familiar with the style guide you follow.

### Exercise

If you have a document that you're working on, use one or more of the tips on
this page to make it better. If you don't have a document in progress, edit the
paragraph below.

> Determine whether or not you can simplify your document through the use of
> terminology that is equivalent but relatively shorter in length and therefore
> more easily comprehensible by your audience. It's important to make sure your
> document is edited before it is seen by your audience, which might include
> people that are less or more familiar with the matter covered by your document.
> The first thing you need is a rough draft. Some things that can help make your
> document easier to read are making sure you have links to background
> information, and also checking for active voice instead of passive voice. If
> you have long sentences you can consider shortening them or implementing the
> use of a list to make the information easier to scan.

##### Click the icon to see the answer.

To help your audience understand your document, apply these basic editing
principles:

* Use active voice instead of passive voice.
* Consider using simpler words that mean the same thing.
* Include links to background information.
* Break long sentences into shorter sentences or lists.

---

**Next unit:** [Organizing large documents](https://developers.google.com/tech-writing/two/large-docs)

## Organizing large documents

Source: https://developers.google.com/tech-writing/two/large-docs

**Estimated Time:** 20 minutes

How do you organize a large collection of information into a cohesive document
or website? Alternatively, how do you reorganize an existing messy document or
website into something approachable and useful? The following tactics can help:

* Choosing to write a single, large document or a set of documents
* Organizing a document
* Adding navigation
* Disclosing information progressively

### When to write large documents

You can organize a collection of information into longer standalone documents
or a set of shorter interconnected documents. A set of shorter interconnected
documents is often published as a website, wiki, or similar structured
format.

Some readers respond more positively than others to longer documents. Consider
the following perspectives from two hypothetical readers you're writing
documentation for:

* Hong finds reading long documents difficult and disorientating. He prefers
  to use site search to find answers to his questions.
* Rose is comfortable navigating large documents. She often uses the built-in
  page search feature in her web browser to find useful information on the
  current page.

So, should you organize your material into a single document or into a set of
documents in a website? Consider the following guidelines:

* How-to guides, introductory overviews, and conceptual guides often work
  better as shorter documents when aimed at readers who are new to the subject
  matter. For example, a reader who is completely new to your subject matter
  might struggle to remember lots of new terms, concepts, and facts.
  Remember that your audience might be reading your documentation to gain a
  quick and general overview of the topic.
* In-depth tutorials, best practice guides, and command-line reference pages
  can work well as lengthier documents, especially when aimed at readers who
  already have some experience with the tools and subject matter.
* A great tutorial can rely on a narrative to lead the reader through a series
  of related tasks in a longer document. However, even large tutorials can
  sometimes benefit from being broken up into smaller parts.
* Many longer documents aren't designed to be read in one sitting. For example,
  users typically scan through a reference page to search for an explanation
  of a command or flag.

The remainder of this unit covers techniques that can be useful for writing
longer documents, such as tutorials and some conceptual guides.

### Organize a document

This section suggests some techniques for planning a longer document, including
creating an outline and drafting an introduction. After you've completed the
first draft of a document, you can review it against your outline and
introduction to make sure you haven't missed anything you originally intended
to cover.

#### Outline a document

Starting with a structured, high-level outline can help you group topics and
determine where more detail is needed. The outline helps you move topics around
before you get down to writing.

You might find it useful to think of an outline as the narrative for your
document. There is no standard approach to writing an outline, but the following
guidelines provide practical tips you might find useful:

* Before you ask your reader to perform a task, explain to them why they are
  doing it. For example, the following bullet points illustrate a section of
  an outline from a tutorial about auditing and improving the accessibility of
  web pages:
  * Introduce a browser plugin that audits the accessibility of web pages;
    explain that the reader will use the results of the audit report to fix
    several bugs.
  * List the steps to run the plugin and audit the accessibility of a web
    page.
* Limit each step of your outline to describing a concept or completing a
  specific task.
* Structure your outline so that your document introduces information when
  it's most relevant to your reader. For example, your reader probably doesn't
  need to know (or want to know) about the history of the project in the
  introductory sections of your document when they're just getting started
  with the basics. If you feel the history of the project is useful, then
  include a link to this type of information at the end of your document.
* Consider explaining a concept and then demonstrating how the reader can
  apply it either in a sample project or in their own work. Documents that
  alternate between conceptual information and practical steps can be a
  particularly engaging way to learn.
* Before you start drafting, share the outline with your contributors.
  Outlines are especially useful if you're working with a team of contributors
  who are going to review and test your document.

#### Outline exercise

Review and update the following high-level outline of an introduction to a long
tutorial. To solve this exercise, you can do any of the following:

* Rearrange the existing topics.
* Add any missing topics you feel should be in an introduction.
* Remove any topics you feel are irrelevant for an introduction.

```
## The history of the project

Describes the history of the development of the project.

## Prerequisites

Lists concepts the reader should be familiar with prior to starting, as well as
any software or hardware requirements.

## The design of the system

Describes how the system works.

## Audience

Describes who the tutorial is aimed at.

## Setting up the tutorial

Explains how to configure your environment to follow the tutorial.

## Troubleshooting

Explains how to diagnose and solve potential problems that might occur when
working through the tutorial.

## Useful terminology

Lists definitions of terms that the reader needs to know to follow the
tutorial.
```

##### Click the icon to see a possible answer.

The following is one possible solution:

```
## Audience

Describes who the tutorial is aimed at.

## Prerequisites

Lists concepts the reader should be familiar with prior to starting, as well as
any software or hardware requirements.

## Setting up the tutorial

Explains how to configure your environment to follow the tutorial.

## Useful terminology

Lists definitions of terms that the reader needs to know to follow the
tutorial.
```

---

#### Introduce a document

If readers of your documentation can't find relevance in the subject, they are
likely to ignore it. To set the ground rules for your users, we recommend
providing an introduction that includes the following information:

* What the document covers.
* What prior knowledge you expect readers to have.
* What the document doesn't cover.

Remember that you want to keep your documentation easy to maintain, so don't
try to cover everything in the introduction.

The following paragraph demonstrates the ideas from the preceding list
as an overview for a hypothetical document publishing platform called Froobus:

```
This document explains how to publish Markdown files using the Froobus system.
Froobus is a publishing system that runs on a Linux server and converts
Markdown files into HTML pages. This document is intended for people who are
familiar with Markdown syntax. To learn about the syntax, see the Markdown
reference. You also need to be comfortable running simple commands in a
Linux terminal. This document doesn't include information about installing or
configuring a Froobus publishing system. For information on installing Froobus,
see Getting started.
```

After you've completed the first draft, check your entire document against
the expectations you set in your overview. Does your introduction provide
an accurate overview of the topics you cover? You might find it useful to
think of this review as a form of documentation quality assurance (QA).

#### Introduction exercise

For this exercise, review and revise the following introduction for a best
practices guide for a hypothetical programming language called F@. Remove any
information you feel is irrelevant in this context and add any information you
feel is missing.

```
This guide lists best practices for working with the F@ programming language.
F@ was developed in 2011 as an open source community project. This guide
supplements the F@ style guide. In addition to the best practices in this guide,
make sure you also install the F@ command-line linter and run it on your code.
The programming language is widely adopted in the health industry. If you have
suggestions for additions to the list of best practices, file an issue in the
F@ documentation repository.
```

##### Click the icon to see a possible answer.

The following is one possible solution:

```
This guide lists best practices for working with the F@ programming language.
Before you review this guide, complete the introductory tutorial for new F@
developers. This guide supplements the F@ style guide. In addition to the best
practices in this guide, make sure you also install the F@ command-line linter
and run it on your code. If you have suggestions for additions to the list of
best practices, file an issue in the F@ documentation repository.
```

---

### Add navigation

Providing navigation and signposting for your readers ensures they can find what
they are looking for and the information they need to get unstuck.

Clear navigation includes:

* introduction and summary sections
* a clear, logical development of the subject
* headings and subheadings that help users understand the subject
* a table of contents menu that shows users where they are in the document
* links to related resources or more in-depth information
* links to what to learn next

The tips in the following sections can help you plan the headings in your
documentation.

#### Prefer task-based headings

Choose a heading that describes the task your reader is working on. Avoid
headings that rely on unfamiliar terminology or tools. For example, suppose you
are documenting the process for creating a new website. To create the site, the
reader must initialize the Froobus framework. To initialize the Froobus
framework, the reader must run the `carambola` command-line tool. At first
glance, it might seem logical to add either of the following headings to the
instructions:

* Running the carambola command
* Initializing the Froobus framework

Unless your readers are already very experienced with the terminology and
concepts for this topic, a more familiar heading might be preferable, such as
*Creating the site*.

#### Provide text under each heading

Most readers appreciate at least a brief introduction under each heading to
provide some context. Avoid placing a level three heading immediately after a
level two heading, as in the following example:

```
## Creating the site
### Running the carambola command
```

In this example, a brief introduction can help orient the reader:

```
## Creating the site

To create the site, you run the `carambola` command-line tool. The command
displays a series of prompts to help you configure the site.

### Running the carambola command
```

#### Heading exercise

Helping readers navigate through your documentation helps them find the
information they need to successfully use your tool. Often, a clear and
well-organized table of contents or outline acts like a map that helps your
users navigate the functionality of your tool.

For this exercise, improve the following outline. You can rearrange,
add, and delete topics and create secondary entries too.

```
About this tutorial
Advanced topics
Build the asset navigation tree
Define resource paths
Defining and building projects
Launch the development environment
Defining and building resources
What's next
Define image resources
Audience
See also
Build an image resource
Define an image project
Build an image project
Setting up the tutorial
Select the tutorial asset root
About this guide
```

##### Click the icon to see a possible answer.

The following is one possible solution:

```
## About this tutorial

### Audience

### About this guide

### Advanced topics

## Setting up the tutorial

### Select the tutorial asset root

### Launch the development environment

### Build the asset navigation tree

### Define resource paths

## Defining and building resources

### Define image resources

### Build an image resource

## Defining and building projects

### Define an image project

### Build an image project

## Defining and building databases

### Define a database

### Build a database

## Pushing, publishing, and viewing a database

### Push a database

### Publish a database

### View a database

## Configuring display rules for point data

### Define, configure, and build vector data

## See also

### Sample data files

## What's next
```

---

### Disclose information progressively

Learning new concepts, ideas, and techniques can be a rewarding experience for
many readers who are comfortable reading through documentation at their own
pace. However, being confronted with too many new concepts and instructions too
quickly can be overwhelming. Readers are more likely to be receptive to longer
documents that progressively disclose new information to them when they need it.
The following techniques can help you incorporate progressive disclosure in your
documents:

* Where possible, try introducing new terminology and concepts near the
  instructions that rely on them.
* Break up large walls of text. To avoid multiple large paragraphs on a single
  page, aim to introduce tables, diagrams, lists, and headings where
  appropriate.
* Break up large series of steps. If you have a particularly long list of
  complicated steps, try to re-arrange them into shorter lists that explain
  how to complete sub-tasks.
* Start with simple examples and instructions, and add progressively more
  interesting and complicated techniques. For example, in a tutorial for
  creating forms, start by explaining how to handle text responses, and then
  introduce other techniques to handle multiple choice, images, and other
  response types.

**Next unit:** [Illustrating](https://developers.google.com/tech-writing/two/illustrations)

## Illustrating

Source: https://developers.google.com/tech-writing/two/illustrations

**Estimated Time:** 10 minutes

Remember when your teacher assigned you a hefty chapter to read?
You flipped through the assigned section of the textbook, desperately
hoping for...yes, pictures! Viewing illustrations was so much
more fun than reading text. In fact, when it comes to reading
technical material, the vast majority of adults are still little
kids—still yearning for pictures rather than text.

Three children read a book while pointing at the pictures.

**Figure 1. Good graphics engage readers in ways that text cannot.**

[Nirmal Dulal [CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0)]](https://commons.wikimedia.org/wiki/File:Nepalese_Children.JPG "Nirmal Dulal [CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0)], via Wikimedia Commons")

According to research by [Sung and Mayer
(2012)](https://www.sciencedirect.com/science/article/pii/S0747563212000921),
providing any graphics—good or bad—makes readers like the document more;
however, only *instructive* graphics help readers learn. This unit suggests
a few ways to help you create figures truly worth a thousand words.

### Write the caption first

It is often helpful to write the caption *before* creating the
illustration. Then, create the illustration that best represents the caption.
This process helps you to check that the illustration matches the goal.

Good captions have the following characteristics:

* They are **brief**. Typically, a caption is just a few words.
* They explain the **takeaway**. *After viewing this graphic,
  what should the reader remember?*
* They **focus** the reader's attention. Focus is particularly important
  when a photograph or diagram contains a lot of detail.

**Note:** By convention, the caption always follows the diagram.

#### Exercise

Target Audience: CS undergraduate students taking an "Introduction to Data
Structures" class.

Consider the following three figures, each of which uses the
same caption.

Multicolored chain

**Caption A. A singly linked list node stores content and a reference to the
next node.**

Four boxes connected by three arrows

**Caption B. A singly linked list node stores content and a reference to the
next node.**

Four boxes (each with content and a pointer) connected by three
     arrows.

**Caption C. A singly linked list node stores content and a reference to the
next node.**

Which of the three preceding figures best illustrates its caption?

##### Click the icon to see the answer.

* Figure A is bad. The chain is pretty, but information-free. The chain also
  erroneously implies that a single-linked list points both backwards and
  forwards.
* Figure B is okay. The illustration helps students realize that the first
  item points to the second item, the second points to the third, and so on.
  However, although the caption refers to both *content* and a
  *pointer*, the illustration shows pointers but does not show content.
* Figure C is the best and most instructive choice. The illustration
  clearly delineates the content part of each node from the pointer part.

---

### Constrain the amount of information in a single drawing

Few intellectual tasks can be quite as rewarding as studying a fine painting,
gradually uncovering layers of insight and meaning. People pay good money to
do exactly that in the world's art museums.

Portrait of Pere Tanguy By Vincent van Gogh - Musée Rodin, Public Domain, https://commons.wikimedia.org/w/index.php?curid=119599

**Figure 2. You'd happily study this Van Gogh painting.**

[Portrait of Pere Tanguy By Vincent van Gogh - Musée Rodin [Public domain]](https://commons.wikimedia.org/wiki/File:Van_Gogh_-_Portrait_of_Pere_Tanguy_1887-8.JPG "Vincent van Gogh
 [Public domain], via Wikimedia Commons")

By contrast, highly complex technical illustrations like the following tend
to discourage most readers:

A schematic, filled with lines and small print

**Figure 3. Complex block diagrams overwhelm readers.**

Just as you avoid overly-long sentences, strive to avoid visual run-ons. As a
rule of thumb, don't put more than one paragraph's worth of information in a
single diagram. (An alternative rule of thumb is to avoid illustrations that
require more than five bulleted items to explain.) I can hear you saying,
"But real-life technical systems can be vastly more complex than the one
shown in Figure 3." You are correct, but you probably don't feel compelled to
explain real-life complex systems in a single paragraph.

The trick to reducing visual clutter into something coherent and helpful
is to organize complex systems into subsystems, like those shown in the
following figure:

Three blocks, each with a simple label

**Figure 4. A complex system organized into three subsystems.**

After showing the "big picture," provide separate illustrations of each
subsystem.

A zoomed in segment of figure 4 with slightly more detail

**Figure 5. Expanded detail for one subsystem of a complex system.**

Alternatively, start with a simple "big picture" and then gradually expand
detail in each subsequent illustration.

### Focus the reader's attention

When confronted with a complex screenshot like the following, readers
struggle to determine what's relevant:

Screenshot of 6 menu items that seem equally important

**Figure 6. Readers don't know what to focus on.**

Adding a visual cue, for example, the red oval in the following
figure, helps readers focus on the relevant section of the screenshot:

Same screenshot, but with one menu item enclosed in red ellipse

**Figure 7. Readers focus on a shape that breaks the pattern.**

**Callouts** provide another way to focus the reader's attention. For pictures
and line art, a callout helps our eyes find just the right spot to land on.
Callouts in pictures are often better than paragraph long explanations of the
pictures because callouts focus the reader's attention on the most important
aspects of the picture. Then, in your explanation, you can focus directly on the
relevant part of the diagram, rather than spending time describing what part of
the image you are talking about.

In the example image, the callout and arrow quickly direct the reader to the
purpose.

Arrow pointing to a proposed landing site on Phobos

**Figure 8. A callout directs readers' eyes.**

[NASA / JPL-Caltech / University of Arizona [Public domain]](https://commons.wikimedia.org/wiki/File:Phobos_colour_2008.jpg "NASA / JPL-Caltech / University of Arizona [Public domain], via Wikimedia Commons")

### Illustrating is re-illustrating

As with writing, the first draft of an illustration is seldom good
enough. Revise your illustrations to clarify the content.
As you revise, ask yourself the following questions:

* How can I simplify the illustration?
* Should I split this illustration into two or more simpler
  illustrations?
* Is the text in the illustration easy to read? Does the text contrast
  sufficiently with its background?
* What's the takeaway?

For instance, consider the
[evolution of the London Tube
map](https://wikipedia.org/wiki/Tube_map#History).
Prior to 1931, the Tube map was drawn to scale, complete with above ground
roads and tube lines that curved as the tracks did.

Complex map of the 1908 London Tube that includes above ground roads

**Figure 9. 1908 to scale map of the London Tube with above ground roads.**

[[Public domain]](https://commons.wikimedia.org/wiki/File:Tube_map_1908.jpg "London Tube Map 1908 [Public domain], via Wikimedia Commons")

In 1931, Harry Beck pioneered a new type of public transit map that
simplified the older map by removing above ground markers and removing scale.
His design instead focused on what people using the maps really cared about:
getting from station A to station B. Even with the success of his 1931 map,
Beck still iterated on the diagram for many years to simplify and clarify the
map. Consider now the [modern tube
map](https://www.google.com/search?tbm=isch&q=london+tube+map), although new
lines and stations have appeared, they still remain close to Beck's design.

#### Exercise

Consider the following original illustration:

A complex visual of recursion that uses inaccessible colors and
          confusing arrows

**Figure 10. A complex diagram.**

The takeaway of the preceding diagram is supposed to be:

> For a recursive solution, call the function itself in the return statement
> until you reach a base case solution.

In what ways does the complexity of the diagram hide the takeaway? How
might you address these problems?

##### Click the icon to see the answer.

Some possible issues with the diagram include:

* **Issue**: The bright colors pull the reader's attention away
  from other aspects of the diagram.  
  **Solution**: Choose colors
  carefully so that they do not overpower the diagram.
* **Issue**: The diagram does not have sufficient color contrast.
  This makes the diagram inaccessible for some people with low vision or
  certain types of color blindness.  
  **Solution**: Remove
  unnecessary use of color and ensure that colors pass
  [standard color contrast recommendations](https://m3.material.io/foundations/designing/color-contrast).
* **Issue**: The arrows point in both directions which
  makes it unclear which way the diagram flows.  
  **Solution**:
  Separate the arrows into two parts with one set illustrating invoking a
  function and the other set illustrating returning from the function.

There are additional issues in the diagram that are not identified here.

---

Here is an improved illustration:

Improved version of the previous figure that simplifies colors and adds labels to arrows

**Figure 11. A simplified version of the preceding diagram.**

What flaws do you see in the improved illustration?

##### Click the icon to see the answer.

Here are two of the flaws that still exist:

* This diagram is still too complex. It would take far more than a paragraph
  to explain this illustration. Consider how removing extra information or
  adding clarifying labels might simplify the interpretation.
* While separating the arrows helped display when the functions invoke or
  return data to each other, the return arrows might benefit from labels that
  tell the reader what the return values are.

---

### Illustration tools

There are many options available for creating diagrams. Three options that are
free or have free options include:

* [Google Drawings](https://drawings.google.com)
* [diagrams.net](https://diagrams.net)
* [LucidChart](https://www.lucidchart.com/pages/)

When exporting diagrams from these tools to use in documentation, it is usually
best to export the files as [Scalable Vector
Graphics](https://wikipedia.org/wiki/Scalable_Vector_Graphics) (SVG).
The SVG format easily scales diagrams based on space constraints so
that no matter the size, you end up with a high quality image.

**Next unit:** [Creating sample code](https://developers.google.com/tech-writing/two/sample-code)

## Creating sample code

Source: https://developers.google.com/tech-writing/two/sample-code

**Estimated Time:** 10 minutes

Good sample code is often the best documentation. Even if your paragraphs and
lists are as clear as blue water, programmers still prefer good sample code.
After all, text and code are different languages, and it is code that the
reader ultimately cares about. Trying to describe code with text is like
trying to explain an Italian poem in English.

Good samples are **correct** and **concise** code that your readers can
**quickly understand** and **easily reuse** with **minimal side effects**.

### Correct

Sample code should meet the following criteria:

* Build without errors.
* Perform the task it claims to perform.
* Be as production-ready as possible. For example, the code shouldn't
  contain any security vulnerabilities.
* Follow language-specific conventions.

Sample code is an opportunity to directly influence how your users write code.
Therefore, sample code should set the best way to use your product. If
there is more than one way to code the task, code it in the manner
that your team has decided is best. If your team hasn't considered
the pros and cons of each approach, take time to do so.

Always test your sample code. Over time, systems change and your sample
code may break. Be prepared to test and maintain sample code as you would
any other code.

Many teams reuse their unit tests as sample programs, which is sometimes a
bad idea. The primary goal of a unit test is to test; the only goal of a
sample program is to educate.

A **snippet** is a piece of a sample program, possibly only one or a few
lines long. Snippet-heavy documentation often degrades over time because
teams tend not to test snippets as rigorously as full sample programs.

#### Running sample code

Good documents explain how to run sample code. For example, your document might
need to tell users to perform activities such as the following prior to running
the samples:

* Install a certain library.
* Adjust the values assigned to certain environment variables.
* Adjust something in the integrated development environment (IDE).

Users don't always perform the preceding activities properly. In some
situations, users prefer to run or (experiment with) sample code directly
in the documentation. ("Click here to run this code.")

Writers should consider describing the expected output or result of sample code,
especially for sample code that is difficult to run.

### Concise

Sample code should be short, including only essential components. When
a novice C programmer wants to learn how to call the `malloc` function,
give that programmer a brief snippet, not the entire Linux source tree.
Irrelevant code can distract and confuse your audience. That said, never
use bad practices to shorten your code; always prefer correctness over
conciseness.

### Understandable

Follow these recommendations to create clear sample code:

* Pick descriptive class, method, and variable names.
* Avoid confusing your readers with hard-to-decipher programming tricks.
* Avoid deeply nested code.
* Optional: Use bold or colored font to draw the reader's attention
  to a specific section of your sample code. However, use highlighting
  judiciously—too much highlighting means the reader won't focus on
  anything in particular.

#### Exercise

Which of the following would be a more helpful line of code in a
sample program? Assume that the target audience consists of
software engineers new to the `go.so` API.

1. `MyLevel = go.so.Level(5, 28, 48)`
2. `MyLevel = go.so.Level(rank=5, 28, 48)`
3. `MyLevel = go.so.Level(rank=5, dimension=28, opacity=48)`

##### Click the icon to see the answer.

Answer **3** is the best choice here. Although it is tempting to keep sample
code as short as possible, omitting parameter names makes it harder for novices
to learn.

---

### Commented

Consider the following recommendations about comments in sample code:

* Keep comments short, but always prefer clarity over brevity.
* Avoid writing comments about *obvious* code, but remember that what
  is obvious to you (the expert) might not be obvious to newcomers.
* Focus your commenting energy on anything non-intuitive in the code.
* When your readers are very experienced with a technology, don't explain
  *what* the code is doing, explain *why* the code is doing it.

Should you place descriptions of code inside code comments or in
text (paragraphs or lists) outside of the sample code? Note that readers
who copy-and-paste a snippet gather not only the code but also any embedded
comments. So, put any descriptions that belong in the pasted code into the code
comments. By contrast, when you must explain a lengthy or tricky concept,
you should typically place the text before the sample program.

**Note:** If you must sacrifice production readiness in order to make the
code shorter and easier to understand, explain your decisions in the comments.

#### Exercise

What problems do you see in the comments within the following snippet?
Assume that the code is aimed at programmers who are new to the `br` API
but who have some experience with the concept of streams:

```
/* Create a stream from the text file at pathname /tmp/myfile. */
mystream = br.openstream(pathname="/tmp/myfile", mode="z")
```

##### Click the icon to see the answer.

The comments contain the following flaws:

* The comment elaborates on a fairly obvious part of the code.
* The snippet doesn't explain the non-obvious portion of the code. Namely,
  what is the mode parameter and what does a value of z
  mean?

---

### Reusable

For your reader to easily reuse your sample code, provide the following:

* All information necessary to run the sample code, including any
  dependencies and setup.
* Code that can be extended or customized in useful ways.

Having easy-to-understand sample code that's concise and compiles is
a great start. If it blows up your reader's app, though, they won't
be happy. Therefore, when writing sample code, consider any potential
side effects caused by your code being integrated into another program.
Nobody wants insecure or grossly inefficient code.

### The example and the anti-example

In addition to showing readers *what to do*, it is sometimes wise to show
readers *what not to do*. For example, many programming languages
permit programmers to place white space on either side of the equals sign.
Now suppose that you were writing a tutorial on a language (such as bash)
that does not permit white space on either side of the equals sign. In this
case, showing both a good example and an anti-example will benefit the reader.
For example:

```
# A valid string assignment.
s="The rain in Maine."
```

```
# An invalid string assignment because of the white space on either side of the
# equals sign.
s = "The rain in Maine."
```

### Sequenced

A good sample code set demonstrates **a range of complexity**.

Readers completely unfamiliar with a certain technology typically
crave simple examples to get started. The first and most basic
example in a sample code set is usually termed a
[Hello World program](https://wikipedia.org/wiki/%22Hello,_World!%22_program). After mastering the basics, engineers
want more complex programs. A good set of sample code provides a healthy
range of simple, moderate, and complex sample programs.

#### Exercise

Which of the following would be a good set of sample functions to support
a tutorial introducing newcomers to the concept of functions?

1. The following set of functions:
   1. A function that takes no parameters and doesn't return anything.
   2. A function that takes one parameter but doesn't return anything.
   3. A function that takes one parameter and returns one value.
   4. A function that takes three parameters and returns one value.
2. The following set of functions:
   1. A function that takes three parameters and returns one value.
3. The following set of functions:
   1. A function that takes one parameter and returns one value.
   2. A function that takes three parameters and returns one value.

##### Click the icon to see the answer.

The best answer is **1**. Providing samples that cover a range of complexity
is usually the wisest choice—particularly for newcomers. Resist the
temptation to *rush* towards very complex sample programs, bypassing
the beginner and intermediate sample programs that newcomers crave.

---

**Next unit:** [Using LLMs in tech writing](https://developers.google.com/tech-writing/two/llms)

## Using large language models (LLMs) in technical writing

Source: https://developers.google.com/tech-writing/two/llms

**Estimated Time:** 20 minutes

[**Large language models**](https://developers.google.com/machine-learning/glossary#large-language-model)
(**LLMs**) such as [Gemini](https://gemini.google.com) can help you improve
your documents. On the other hand, careless use of LLMs can inject mistakes
into your documents. This section focuses on responsible use of LLMs to
help you do the following:

* Generate a first draft.
* Revise a document.
* Format a document.
* Summarize a document.

The requests you make to an LLM are called
[**prompts**](https://developers.google.com/machine-learning/glossary#prompt). An LLM reacts to prompts
by generating [**responses**](https://developers.google.com/machine-learning/glossary#response). This module
explains how to write prompts that generate useful responses.

In general, writing good prompts requires following good technical writing
principles.

**Caution:** Responses sometimes contain errors. Always check responses carefully,
not only for factual errors but also for instances where the response
doesn't "feel" right.

### Generate a first draft

An LLM can help you write that dreaded, bang-your-head-against-the-screen
first draft. To get a good first draft, you'll need to supply good prompts.

LLMs generate the best responses for topics they "know" about. LLMs know
the following:

* The information the LLM was
  [**pre-trained**](https://developers.google.com/machine-learning/glossary#pre-training) on.
* Any additional information the LLM was subsequently
  [**fine-tuned**](https://developers.google.com/machine-learning/glossary#fine-tuning) on.
* Information traditionally available through a search engine (if the LLM
  is enhanced with
  [Retrieval-Augmented Generation (RAG)](https://developers.google.com/machine-learning/glossary#retrieval-augmented_generation)).
* Any additional information you provide in prompts or attachments.

For example, most LLMs are pre-trained on a lot of information about the
Python programming language. Therefore, most LLMs can generate a first draft
of text about any standard Python function. However, an LLM doesn't know about
the Python function that you wrote this morning unless you pass that source
code within a prompt.

The rest of this section explores specific ways to write effective prompts
for generating a first draft.

#### Take on a role

LLMs tend to generate better responses when the prompt tells the LLM to
impersonate a role. For example:

Recommended

> You are an expert technical writer...

> You are a patient senior software engineer talking to a junior software
> engineer...

> You are a computer science professor writing slides for your first-year
> students...

To choose a role, imagine who could best explain or teach a certain topic
to the target audience.

#### Identify your target audience

Prompts should specify the target audience.
For example, the following prompt does *not* identify a target audience,
so the LLM's response may or may not be helpful:

Not recommended

> Describe the Carambola app.

In contrast, the following prompts are far more specific and will likely yield
better responses:

Recommended

> Describe the Carambola app to new hires on my team responsible for
> maintaining the app.

> Describe the Carambola app to a software engineer on another team...

> Describe the Carambola app to the vice-president of marketing...

#### Specify the document type

What *type* of document do you want the LLM to generate?
The following prompt, for example, doesn't answer the preceding question:

Not recommended

> Generate a document...

In contrast, the following prompts are more specific:

Recommended

> Generate an FAQ...

> Generate an email...

Consider prompting for a subset of a lengthy document rather than the entire
document. For example, if a programmer's guide needs to be hundreds of pages
long, then the following prompt might yield a poor response:

Not recommended

> Generate a complete programmer's guide on...

In contrast, prompting for specific chapters might yield better responses:

Recommended

> Generate the section of the programmer's guide that explains how to
> book a reservation.

> Generate the section of the programmer's guide that explains how to
> change a reservation.

#### Define the goal of the document

People read technical documentation in order to learn something or do
something. A good prompt tells the LLM what the reader intends to with
the information. For example, the following prompts provide practical
goals:

Recommended

> After reading the FAQ, readers should be able to debug common
> problems themselves.

> After reading this tutorial, the reader should know the difference between
> regular functions and lambda functions in Python.

#### Choose the style

LLM responses are typically a lot of bulleted lists connected by short
paragraphs. That's usually an appropriate style for technical writing.
However, your prompt can suggest a different style or a format. For example:

Recommended

> ... Organize the release notes in the following order:
>
> 1. An introductory paragraph
> 2. A table containing one-line summaries of each bug
> 3. Subsections for each bug, detailing the problem and any workarounds

Alternatively, if you like the style of another document, you can attach
that document to the prompt and tell the LLM to mimic its style (or selected
aspects of its style). You can even specify a style guide to mimic.
For example:

Recommended

> Write comments for the following Python function that conform to the
> Google Python Style Guide.

LLM responses tend to be too long. Consider telling the LLM to
abbreviate a response. For example:

Recommended

> ... Limit the bulleted list to the most important three items.

**Note:** LLMs sometimes make math mistakes, so the resulting bulleted list
might not contain exactly three items.

#### Add prompt constraints

You can reduce [hallucinations](https://developers.google.com/machine-learning/glossary#hallucination)
in the LLM response by adding specific constraints to your prompt. For
example, you can constrain the LLM to only use information that you provide
in the prompt:

Recommended

> Only use information from the following text in your response:

You can also constrain the LLM to only use information from a specific
set of files.

#### Iterate and refine

Your initial prompt generally won't produce a perfect response.
You'll probably need to prompt multiple times, making adjustments each time.
If the responses still aren't very good, consider the following questions:

* Do your prompts identify a role, a target audience, and a document type?
* Are your prompts sufficiently specific? Are you asking for exactly what
  you want?
* Is your prompt clear? Would your prompt conform to the technical writing
  lessons in [Technical Writing One](https://developers.google.com/tech-writing/one)?
  If you gave the same prompt to a human, would that person know what you
  are requesting?

Sometimes, the perfect is the enemy of the good. If a response is very good,
but not quite perfect, it is tempting to continue refining the prompt. However,
it can be more efficient to edit the very good response yourself rather than
endlessly refine the prompt.

**Note:** LLMs often produce different responses to the *same* prompt. So, even
re-issuing the same prompt can sometimes be a form of iteration.

#### Set the context

As mentioned earlier, LLMs can only use the sources available to them.
Providing additional information to establish context helps LLMs generate
better responses. The additional information could include just about any
information relevant to the topic, including:

* Documents
* Meeting transcripts
* Source code
* Emails
* Diagrams

For example, attaching the relevant source code to a prompt can help an LLM
generate a first draft of documentation:

Recommended

> Base the documentation on the attached source code.

An LLM generally assumes that information in attachments is factual, and this
can cause problems. For example, an LLM might mistakenly assume that the bugs
in attached source code are actually features.

#### Consider this counterpoint

When you rely on an LLM to create a first draft, you lose the *benefits* of the
writing process.

> "One writes to know what one is thinking" - Abraham Verghese

Writing is a struggle, but that struggle crystallizes ideas, turning vague
notions into focused plans. Until you write a design document, you haven't
fully worked through all the issues and their solutions. Clear technical
writing is the byproduct of clear technical thought.

#### Exercise

A design team recorded a brainstorming session aimed at designing a new app.
We captured
[the transcript](https://developers.google.com/tech-writing/two/artifacts/design-meeting-transcript) of
that highly creative session. Prompt an LLM to create an email based on the
transcript. The email should aim to convince the vice-president of engineering
to fund development of the pet translator app. The vice-president is busy, so
keep the email short and focused.

##### Click the icon to see a possible answer.

Prompting almost never has a single right answer. That said, here is
one possible prompt:

> You are a senior engineer. Based on the transcript, write an email to convince
> the vice-president of engineering to fund development of the pet translator app.
> Make the tone serious and formal. The vice-president of engineering is busy, so
> keep the email short. Start the email with an opening paragraph summarizing the
> proposal. Then, provide a three-item bulleted list. Finish with a one-sentence
> call to action.

---

### Revise a document

LLMs excel at critical analysis. LLMs are such good critics that they can even
find mistakes in the text that *they* generated.

#### Reorganize

We recommend fixing organizational issues before editing grammar and style
issues. When prompting an LLM to reorganize documents, a clear detailed prompt
will outperform a vague prompt. For example, the following prompt forces the
LLM to guess at your intentions:

Not recommended

> Reorganize the attached course.

In contrast, the following prompt provides context and specificity to help
guide the LLM to reorganize more effectively.

Recommended

> The attached course is an introduction to logistic regression in machine
> learning. The course is aimed at second-year computer science students
> who know how to program in Python but know little to nothing about machine
> learning fundamentals. Can you recommend a better organization of the
> course modules? For example, what material should I move to a different
> module? Should the course discuss classification threshold earlier?

#### Copy edit

LLMs "know" a tremendous amount about grammar, punctuation, and spelling.
So, a general prompt like the following usually detects embarrassing problems:

Recommended

> Find grammatical, punctuation, and spelling issues in the attached passage.

#### Find style problems

LLMs can spot stylistic issues. For example:

Recommended

> Identify any passive voice in the following passage:

Going a step further, you can ask an LLM to suggest edits. For example:

Recommended

> Replace any passive voice sentences in the following passage with their
> active voice equivalents.

You can ask an LLM to perform a general hunt for style issues:

Recommended

> How does the attached document deviate from the writing principles in Google's
> Technical Writing One course? Assume that the document is aimed at expert
> software engineers seeking to get better at testing automation.

#### Find other issues

LLMs also excel at finding logical inconsistencies or outright mistakes in
documentation. Providing a role within the prompt can help put the LLM in
the proper "mindset." For example:

Recommended

> You are a computer science professor reviewing the attached first draft of
> a paper that describes research on a new machine translation paradigm.
> Examine the Introduction section for any mistakes in the description of
> prior algorithms. Then, assess the rest of the paper for any possible
> logical flaws.

### Format a document

LLMs can convert a document from one format to another. For example, you can
ask an LLM to convert a Word document to HTML or Markdown. To do so, you'll
need to provide the following:

* The document to convert.
* The target format.
* Any specific formatting requirements.

For example:

Recommended

> Convert the attached Word document to Markdown, making all headings
> either level 2 or level 3.

You can also ask an LLM to reformat a document to conform to a specific
style guide. For example:

Recommended

> Reformat the attached HTML document to conform to the Google developer
> documentation style guide.

### Summarize a document

Condensing lengthy writing down to 50 or 100 words is so challenging that most
technical professionals struggle to write abstracts, executive summaries,
and overviews. Fortunately, LLMs generally excel at summarization.
Prompts to summarize text should typically identify the following:

* Style
* Target audience
* Purpose
* Optionally, tone

For example, here is a good summarization prompt:

Recommended

> Write a one-sentence summary of the attached course.
> Aim the summary at software engineers who will use the summary
> to determine whether to take the course. Make the summary engaging,
> yet professional; the summary shouldn't look like marketing literature.

Ironically, a good summarization prompt might be longer than the
generated summary.

In some cases, summaries must match a specific style. Therefore, your
prompt should identify or attach the relevant style guide.

In other cases, although the style isn't codified in a style guide,
your summary should still resemble certain summaries. You can pass those
exemplar summaries as part of the prompt. (This technique is called
[few-shot prompting](https://developers.google.com/machine-learning/glossary/#few-shot-prompting).)
For example:

Recommended

> Write a tldr-style summary for the attached design doc that matches
> the style of the following tldr summaries:
> This fun four-hour course gives software engineers a solid grounding
> in Python.
> This hands-on two-hour course guides software engineers through building
> better prompts for generating Python code.

#### Alternate media for summaries

If the medium you are working in *requires* a textual summary, then you'll
need to provide text. Sometimes though, technical people default to producing
textual summaries when a non-text summary (for example, an image or a video)
might be more memorable or engaging.

Or, viewing the problem in a different way, you could ask an LLM to write
a textual summary of an image.

#### Exercise

We've captured [the
transcript](https://developers.google.com/tech-writing/two/artifacts/design-meeting-transcript) of
an overly creative brainstorming session to design a new app.

**Task 1:** Prompt your favorite LLM to generate a one-sentence summary of the
pet translation app discussed in the brainstorming meeting. (Copy-and-paste the
transcript along with the prompt.) This summary should get other engineers
interested in working on the project.

##### Click the icon to see a possible answer.

As always, many different prompts will produce a good response.
Here is one possible prompt:

> You are a respected senior engineer. Generate a one-sentence summary of
> the attached app discussed in the attached transcript. Aim the summary
> at junior engineers. The summary should get those junior engineers interested
> in working on the project.

---

**Task 2:** Prompt your favorite LLM to create an image representing the app.
The image should help non-technical people understand the app.

##### Click the icon to see a possible answer.

Here is one possibility:
> Create an image that helps non-technical people understand the app.

---

### What's next?

Congratulations: you've completed the pre-class work for Technical Writing Two.

If your organization is offering the in-class portion of Technical Writing Two,
do take it. If you'd like to facilitate the in-class portion
of Technical Writing Two, see the
[facilitator's guide](https://developers.google.com/tech-writing/for-instructors/two/instructors-guide).

A quick compilation of the topics covered in Technical Writing Two
is available on the [Summary](https://developers.google.com/tech-writing/two/summary) page.

## Summary of Technical Writing Two

Source: https://developers.google.com/tech-writing/two/summary

**Estimated Time:** 1 minute

Congratulations! You've completed the pre-class portion of Technical Writing
Two, which covered the following intermediate principles of technical writing:

| Section | Lesson |
| --- | --- |
| [Self-editing](https://developers.google.com/tech-writing/two/editing) |
| Adopt a style guide. |
| Think like your audience. |
| Read documents out loud to yourself. |
| [Organizing large docs](https://developers.google.com/tech-writing/two/large-docs) |
| Determine whether to organize a large amount of information into a single long document or a collection of shorter documents. |
| Outline first. Alternatively, write free form and then reorganize. |
| Introduce a large document by explaining what it covers. |
| Choose headings that describe the task your reader is working on. |
| [Illustrating](https://developers.google.com/tech-writing/two/illustrations) |
| Consider writing the caption *before* creating the illustration. |
| Constrain the amount of information in a single drawing. |
| Focus the reader's attention on the relevant part of a picture or diagram by describing the takeaway in the caption or by adding a visual cue to the picture. |
| [Creating sample code](https://developers.google.com/tech-writing/two/sample-code) |
| Create sample code that is accurate, clear, short, easy to understand, and well-commented. |
| Consider providing not only examples but also anti-examples. |
| In tutorials, provide code samples that demonstrate a range of complexity. |
| [Using LLMs in tech writing](https://developers.google.com/tech-writing/two/llms) |
| Construct detailed prompts by defining a role for the LLM, a target audience, a document type, and a specific goal. |
| Revise documents by prompting an LLM to reorganize content, copy edit for errors, and identify stylistic or logical issues. |
| Generate concise summaries by identifying the summary's purpose, target audience, and style. |

The *in-class component* of Technical Writing Two helps you practice
intermediate technical writing principles.

If your organization offers the instructor-led portion of Technical Writing Two,
you're now ready for that class. If your organization doesn't offer the
instructor-led portion of Technical Writing Two, note that Google occasionally
offers the course. See the [Announcements page](https://developers.google.com/tech-writing/announcements) for
details.
