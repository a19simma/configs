# Writing helpful error messages

Google for Developers, https://developers.google.com/tech-writing/error-messages
Licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/); code samples Apache 2.0. Converted to Markdown; no wording changed.

## Contents

* [Writing Helpful Error Messages](#writing-helpful-error-messages)
* [General error handling rules](#general-error-handling-rules)
* [Identify the error's cause](#identify-the-errors-cause)
* [Identify the user's invalid inputs](#identify-the-users-invalid-inputs)
* [Specify requirements and constraints](#specify-requirements-and-constraints)
* [Explain how to fix the problem](#explain-how-to-fix-the-problem)
* [Provide examples](#provide-examples)
* [Be concise](#be-concise)
* [Avoid double negatives](#avoid-double-negatives)
* [Write for the target audience](#write-for-the-target-audience)
* [Use terminology consistently](#use-terminology-consistently)
* [Format error messages to enhance readability](#format-error-messages-to-enhance-readability)
* [Set the right tone](#set-the-right-tone)
* [Want to play a game?](#want-to-play-a-game)
* [Course summary](#course-summary)
* [Additional guidelines for back-end engineers](#additional-guidelines-for-back-end-engineers)

## Writing Helpful Error Messages

Source: https://developers.google.com/tech-writing/error-messages

This self-study course helps you write clearer, more effective error messages,
whether they appear in IDEs, command lines, or GUIs. While this course contains
lessons for many error message scenarios, the majority of examples and guidance
focus on developer-facing error messages.

**Note:** Not all guidelines presented in this course are appropriate in every
situation for every target audience. Always aim error messages at the product's
target audience.

### Target audience for this course

We've aimed this course at the following audiences:

* Engineers
* Program managers
* Technical writers

We recommend taking [Technical Writing
One](https://developers.google.com/tech-writing/overview) before taking this
error messages course. After all, good error messages are just another form
of good technical writing. If you'd prefer to skip Technical Writing One for
now, that's okay—you can still benefit from this error messages course.

### Why take this course?

Bad error messages frustrate users. Good error messages provide critical
information when things are not working as expected. Error messages are
often the main way developers interact with users when problems occur.
Some error messages are caused by invalid user inputs or misuse of certain
features and some are caused by product defects; all error messages require
users to figure out what to do next.

Data collected through Google support systems and UX research identified the
following common problems with *bad* error messages:

* unactionable
* vague
* imprecise
* confusing
* inaccurate
* unclear cause
* unknown next steps

Conversely, *good* error messages provide the following benefits:

* Deliver the best user experience.
* Are actionable.
* Are universally accessible. (To learn more, take [Tech Writing for
  Accessibility.](https://developers.google.com/tech-writing/accessibility))
* Enable users to help themselves.
* Reduce the support workload.
* Enable faster resolution of issues.

### Learning objectives

After completing this class, you will know how to do the following:

* Write clearer, more helpful error messages.
* Review your teammates' error messages.

#### Learning non-objectives

This course does not explain the mechanics of generating error messages.
For example, this course does not explain how to display error messages within
a GUI.

### This course in ten seconds

Great error messages answer two questions as clearly and concisely as possible:

* What went wrong?
* How does the user fix that problem?

Yes, it's just that simple.

And, it's just that hard.

**Next unit:** [General error handling rules](https://developers.google.com/tech-writing/error-messages/error-handling)

## General error handling rules

Source: https://developers.google.com/tech-writing/error-messages/error-handling

Before we get to the fun part of the course—wording error messages—let's
discuss a few general error handling rules.

### Don't fail silently

Failure is inevitable; failing to report failures is inexcusable.
Failing silently causes the following problems:

* Users wonder whether something has gone wrong. (*"Why did my order not go
  through?"*)
* Customer support wonders what caused a problem. (*"The log file gave no
  indication of a problem."*)

Embrace your software's fallibility. Assume that humans will make mistakes
using your software. Try to minimize ways for people to misuse your software,
but assume that you can't completely eliminate misuse. Therefore, plan error
messages as you design software.

### Follow the programming language guides

Follow the guidelines on error handling in Google's programming language guides,
including:

* [Google C++ Style
  Guide](https://google.github.io/styleguide/cppguide.html)
* [Google Java Style
  Guide](https://google.github.io/styleguide/javaguide.html)
* [Google Python Style
  Guide](https://google.github.io/styleguide/pyguide.html),
  particularly the [Error
  Messages section](https://google.github.io/styleguide/pyguide.html#3102-error-messages)
* [Google JavaScript Style
  Guide](https://google.github.io/styleguide/jsguide.html)
* [Google Go Style
  Guide](https://google.github.io/styleguide/go),
  particularly the [Error handling
  section](https://google.github.io/styleguide/go/best-practices#error-handling)

### Implement the full error model

Implement the full error model described in the [Errors page of the Google
AIP.](https://google.aip.dev/193)
For instance, note the following quote
about implementing error messages in services:

> Services must return a
> [google.rpc.Status](https://github.com/googleapis/api-common-protos/blob/master/google/rpc/status.proto)
> message when an API error occurs, and must use the
> canonical error codes defined in
> [google.rpc.Code](https://github.com/googleapis/api-common-protos/blob/master/google/rpc/code.proto).

The [Errors page of the Google Cloud API design
guide](https://cloud.google.com/apis/design/errors) provides helpful information about implementing the full error
model for Google APIs.

### Avoid swallowing the root cause

API implementations should not swallow the root cause of issues occurring in
the back end. For example, many different situations can cause a
"Server error" problem, including:

* service failure
* network connection drop
* mismatching status
* permission issues

"Server error" is too general an error message to
help users understand and fix the problem. If the server logs contain
identification information about the in-session user and operation, we recommend
providing additional context on the particular failure case.

### Log the error codes

Numeric **error codes** help customer support monitor and diagnose errors.
Consequently, specifying numeric error codes along with textual error messages is often
quite valuable.

You can specify error codes for both internal and external errors.
For internal errors, provide a proper error code for easy lookup/debugging
by internal support personnel and engineers.

Document all error codes.

### Raise errors immediately

Raise errors as early as useful. Holding on to errors and then raising them
later increases debugging costs dramatically.

**Next unit:** [Identify the error's cause](https://developers.google.com/tech-writing/error-messages/identify-the-cause)

## Identify the error's cause

Source: https://developers.google.com/tech-writing/error-messages/identify-the-cause

Tell users exactly what went wrong. Be specific—vague error messages
frustrate users.

Not recommended

> Bad directory.

Recommended

> The *[Name of directory]* directory exists but is not writable. To add
> files to this directory, the directory must be writable. *[Explanation of
> how to make this directory writable.]*

---

Not recommended

> Invalid field 'picture'.

Recommended

> The 'picture' field can only appear once on the command line; this command
> line contains the 'picture' field *<N>* times.
> Note: Prior to version 2.1, you could specify the 'picture' field more than
> once, but more recent versions no longer support this.

**Next unit:** [Identify the user's invalid inputs](https://developers.google.com/tech-writing/error-messages/invalid-inputs)

## Identify the user's invalid inputs

Source: https://developers.google.com/tech-writing/error-messages/invalid-inputs

If the error involves values that the user can enter or modify (for example,
text, settings, command-line parameters), then the error message should
identify the offending value(s).

Not recommended

> Funds can only be transferred to an account in the same country.

Recommended

> You can only transfer funds to an account within the same country.
> Sender account's country (UK) does not match the recipient account's
> country (Canada).

---

Not recommended

> Invalid postal code.

Recommended

> The postal code for the US must consist of either five or nine digits.
> The specified postal code (4872953) contained seven digits.

If the invalid input is a very long value that spans many lines,
consider doing one of the following:

* Disclose the bad input progressively; that is, provide one or more clickable
  ellipses to enable users to control how much additional error information
  they want to see.
* Truncate the bad input, keeping only its essential parts.

#### Multiple choice exercise

Which of the following error messages is best?

* (correct) The specified bid ($5) is below the minimum bid ($8).

  This answer surfaces the invalid input and provides enough
  information for the bidder to compare their bid with the
  minimum bid.

* The specified bid is too low.

  This error message doesn't surface the invalid input.

* The specified bid ($5) is too low.

  Although this error message does surface the invalid input,
  the error message doesn't provide enough information for the
  user to fix the problem.

* The specified bid is below the minimum bid ($8).

  This answer doesn't surface the invalid input.

**Next unit:** [Specify requirements and constraints](https://developers.google.com/tech-writing/error-messages/specify-requirements)

## Specify requirements and constraints

Source: https://developers.google.com/tech-writing/error-messages/specify-requirements

Help users understand requirements and constraints. Be specific.
Don't assume that users know the limitations of your system.

Not recommended

> The combined size of the attachments is too big.

Recommended

> The combined size of the attachments (14MB) exceeds the allowed limit (10MB).
> *[Details about possible solution.]*

---

Not recommended

> Permission denied.

Recommended

> Permission denied. Only users in <group name> have access.
> *[Details about adding users to the group.]*

---

Not recommended

> Time-out period exceeded.

Recommended

> Time-out period (30s) exceeded. *[Details about possible solution.]*

**Next unit:** [Explain how to fix the problem](https://developers.google.com/tech-writing/error-messages/show-fix)

## Explain how to fix the problem

Source: https://developers.google.com/tech-writing/error-messages/show-fix

Create **actionable error messages**. That is, after explaining the cause of
the problem, explain how to fix the problem.

Not recommended

> The client app on your device is no longer supported.

Recommended

> The client app on your device is no longer supported. To update the client app,
> click the **Update app** button.

Here's a second example:

Not recommended

> Could not fetch resource:
> - Quota 'CPUS' exceeded. Limit: 1.0 in region us-central-1.

Recommended

> You requested 2.0 CPUs, which exceeds your quota of 1.0 CPUs in the
> us-central-1 region. To fix the problem, take either of the following
> actions:
> - Increase your CPU quota in the us-central-1 region.
> - Make your request in a region where you have more CPU quota.
> See *[URL of documentation]* for details.

**Next unit:** [Provide examples](https://developers.google.com/tech-writing/error-messages/provide-examples)

## Provide examples

Source: https://developers.google.com/tech-writing/error-messages/provide-examples

Supplement explanations with examples that illustrate how to correct the
problem.

Not recommended

> Invalid email address.

Recommended

> The specified email address (robin) is missing an @ sign and a
> domain name. For example: robin@example.com.

---

Not recommended

> Invalid input.

Recommended

> Enter the pathname of a Windows executable file. An executable file
> ordinarily ends with the .exe suffix. For example:
> C:\Program Files\Custom Utilities\StringFinder.exe

---

Not recommended

> Do not declare types in the initialization list.

Recommended

> Do not declare types in the initialization list.
> Use calls instead, such as 'BankAccount(owner, IdNum, openDate)' rather than
> 'BankAccount(string owner, string IdNum, Date openDate)'

---

Not recommended

> Syntax error on token "||", "if" expected.

Recommended

> Syntax error in the "if" condition.
> The condition is missing an outer pair of parentheses.
> Add a pair of bounding opening and closing parentheses to the
> condition. For example:
> if  (a > 10) || (b == 0)  # Incorrect
>
> if ((a > 10) || (b == 0)) # Correct

#### Multiple choice exercise

Which of the following error messages is best for an audience
of people who drive cars?

* (correct) The specified license plate (QB2 481) is invalid.
  Valid license plates start with three uppercase letters and
  end with three digits. For example: MBR 918
  and NRS 727 are both valid license plates.

  This error message provides two good examples of valid
  license plates.

* The specified license plate (QB2 481) is invalid because
  license plates must start with three letters and end with
  three digits.

  Although this error message surfaces the invalid input and provides
  an explanation of what went wrong, this error message lacks an
  example.

* The specified license plate (QB2 481) is invalid.
  For example: MBR 918
  and NRS 727 are both valid license plates.

  The error message doesn't provide enough context to make the
  examples useful. The user might be asking, "Why are
  MBR 918 and NRS 727 valid but QB2 481 is invalid?"

**Next unit:** [Be concise](https://developers.google.com/tech-writing/error-messages/be-concise)

## Be concise

Source: https://developers.google.com/tech-writing/error-messages/be-concise

Write concise error messages. Emphasize what's important. Cut unnecessary text.
See the
[Short sentences unit
of Tech Writing One](https://developers.google.com/tech-writing/one/short-sentences)
for tips on reducing sentence length.

Not recommended

> Unable to establish connection to the SQL database. *[Explanation of how to
> fix the issue.]*

Recommended

> Can't connect to the SQL database. *[Explanation of how to fix the issue.]*

---

Not recommended

> The resource was not found and cannot be differentiated. What you selected
> doesn't exist in the cluster.
> *[Explanation of how to find valid resources in the cluster.]*

Recommended

> Resource <name> isn't in cluster <name>.
> *[Explanation of how to find valid resources in the cluster.]*

---

Converting from [passive voice to active voice](https://developers.google.com/tech-writing/one/active-voice)
often makes sentences conciser and easier to understand:

Not recommended

> The Froobus operation is no longer supported by the Frambus app.

Recommended

> The Frambus app no longer supports the Froobus operation.

In your enthusiasm to be concise, don't remove so many words that the
resulting error message becomes cryptic. For example, don't reduce the
preceding error message down to the following:

Not recommended

> Unsupported.

#### Multiple choice exercise

Reorder and shorten the following start of an error message.
How many words can you remove?

* The SiteID <SiteID> you have entered is
  invalid.

* (correct) 5

  Yes. The error should read: Invalid SiteID <SiteID>.

* 4

  That's a concise error message, but you can shorten the
  error message even more.

* 3

  You can remove more words.

* None.

  This message is not concise. You can definitely remove some words.

**Next unit:** [Avoid double negatives](https://developers.google.com/tech-writing/error-messages/avoid-double-negatives)

## Avoid double negatives

Source: https://developers.google.com/tech-writing/error-messages/avoid-double-negatives

A **double negative** is a sentence or phrase that contains two negative words,
such as:

* *not*, including contractions like *can't*, *won't*
* *no*

Readers find double negatives hard to parse. ("Wait, do two negatives make a
positive or is the author of the error message using two negatives to emphasize
something I shouldn't do?")

Some double negatives in error messages are blatant:

Not recommended

> You cannot not invoke this flag.

Recommended

> You must invoke this flag.

Other double negatives are more subtle. For example, the words *prevents* and
*forbidding* in the following error message are both negatives, leading to
a confusing message:

Not recommended

> The universal read permission on *pathname* prevents the operating
> system from forbidding access.

Recommended

> The universal read permission on *pathname* enables anyone to read
> this file. Giving access to everyone is a security flaw. See *hyperlink*
> for details on how to restrict readers.

Similarly, avoid exceptions to exceptions.

Not recommended

> The App Engine service account must have permissions on the image, except the
> Storage Object Viewer role, unless the Storage Object Admin role is available.

Recommended

> The App Engine service account must have one of the following roles:
>
> * Storage Object Admin
> * Storage Object Creator

**Next unit:** [Write for the target audience](https://developers.google.com/tech-writing/error-messages/target-audience)

## Write for the target audience

Source: https://developers.google.com/tech-writing/error-messages/target-audience

Tailor the error message to the target audience. That is:

* Use appropriate terminology for that target audience.
* Be mindful of what the target audience knows and doesn't know.

Beware of the
 [curse
of knowledge](https://developers.google.com/tech-writing/one/audience#curse_of_knowledge) when writing error messages. A term familiar to you might
not be familiar to your target audience.
For example, the following error message contains terminology
appropriate for a target audience of ML experts. If the target audience
includes a significant number of people who aren't ML experts, then the
error message is mystifying:

Recommended for ML experts only

> Exploding gradient problem. To fix this problem, consider gradient clipping.

Now compare the following two error messages. The first error message contains
technical truth, but terms like *server*, *client*, *farm*, and *CPU* are
not going to help most consumers:

Inappropriate for shoppers

> A server dropped your client's request because the server farm is running
> at 92% CPU capacity. Retry in five minutes.

The second error message is more suitable (and comforting) for a
non-technical audience:

Appropriate for shoppers

> So many people are shopping right now that our system can't complete your
> purchase. Don't worry--we won't lose your shopping cart. Please retry your
> purchase in five minutes.

#### Multiple choice exercise

Which audience(s) is the following error message appropriate for?

* This app does not support JPG files. You may only
  upload SVG or PNG files.

* (correct) Software Engineers, System Administrators, and technical end-users

  All three of those audiences understand different file formats.

* People using an app to upload receipts.

  This error message will frustrate users unfamiliar with file formats
  (which is a lot of people). To become more useful, this error
  message would require additional information explaining how end-users
  can determine file format.
  Furthermore, some end users don't know what *upload* means.

* Inappropriate for any audience.

  Most technical people are familiar with different file formats, so
  this is a good, concise error message for certain people.

**Next unit:** [Use terminology consistently](https://developers.google.com/tech-writing/error-messages/use-terminology-consistently)

## Use terminology consistently

Source: https://developers.google.com/tech-writing/error-messages/use-terminology-consistently

Use terminology consistently for all error messages within a single
product area. If you call something a "datastore" in one error message,
then call the same thing a "datastore" in all the other error messages.

Not recommended

> Can't connect to cluster at 127.0.0.1:56. Check whether minikube is running.

Recommended

> Can't connect to minikube at 127.0.0.1:56. Check whether minikube is running.

**Note:** Some authoring systems automatically recommend synonyms to ensure that
you don't keep repeating the same word. Yes, variety spices up paragraphs.
However, variety in error messages can confuse users.

Error messages must appear consistently with similar formats and
non-contradictory content; that is, the same problem must generate the same
error message. For example, if different parts of an app each detect problems
with internet connection, both parts should emit the same error message.

**Next unit:** [Format error messages to enhance
readability](https://developers.google.com/tech-writing/error-messages/format-for-readability)

## Format error messages to enhance readability

Source: https://developers.google.com/tech-writing/error-messages/format-for-readability

A few simple techniques help error messages stand out from the
surrounding text and code.

#### Link to more detailed documentation

When an error requires a lengthy explanation (for example, multiple sentences)
and appropriate documentation is available, use links to redirect users to
more detailed documentation.

Not recommended

> Post contains unsafe information.

Recommended

> Post contains unsafe information. Learn more about safety
> at <link to documentation>.

#### Use progressive disclosure

Some error messages are long, requiring a lot of text to explain the problem
and solution. Unfortunately, users sometimes ignore long error messages,
intimidated by the "wall of text." A good compromise is to display a briefer
version of the error message and then give users the option to click something
to get the full context.

Not recommended

> TextField widgets require a Material widget ancestor, but none were located.
> In material design, most widgets are conceptually “printed” on a sheet of
> material. To introduce a Material widget, either directly include one or use
> a widget that contains a material itself.

Recommended

> TextField widgets require a Material widget ancestor, but none were located.
>
> **...**(Click to see more.)
>
>
>   In material design, most widgets are conceptually "printed" on a
> sheet of material. To introduce a Material widget, either directly include
> one or use a widget that contains a material itself.

#### Place error messages close to the error

For coding errors, place error messages as close as possible to the place
where the error occurred.

Not recommended

> ```
> 1: program figure_1;
> 2: Grade = integer;
> 3: var
> 4. print("Hello")
> Use ':' instead of '=' when declaring a variable.
> ```

Recommended

> ```
> 1: program figure_1;
> 2: Grade = integer;
> ---------^ Syntax Error
> Use ':' instead of '=' when declaring a variable.
> 3: var
> 4. print("Hello")
> ```

#### Handle font colors carefully

A surprising percentage of readers are color blind, so be careful with
colors in error messages. For example, the following error message will
mystify some readers:

Not recommended

> The argument expects only digits. Therefore, the supplied value is
> only partially correct:
> 3728LJ947

Many forms of color blindness exist, so just avoiding a red/green
combination isn't sufficient. Because you can't depend on all your
users being comfortable with color, we recommend pairing color with
another visual cue. For example, the following error message pairs
color with boldface:

Recommended

> The argument expects only digits. Therefore, the highlighted part of the
> supplied value is incorrect:
> 3728**LJ**947

The following example pairs color with extra spaces:

Recommended

> The argument expects only digits. Therefore, the highlighted part of the
> supplied value is incorrect:
> 3728  LJ  947

Alternatively, you could skip color completely:

Recommended

> The argument expects only digits. Therefore, the highlighted characters
> in the supplied value are incorrect:
>
> ```
> 3728LJ947
>     ^^
> ```

**Next unit:** [Set the right tone](https://developers.google.com/tech-writing/error-messages/set-tone)

## Set the right tone

Source: https://developers.google.com/tech-writing/error-messages/set-tone

The tone of your error messages can have a significant effect on how your users
interpret them.

#### Be positive

Instead of telling the user what they did wrong, tell the user how to get
it right.

Not recommended

> You didn't enter a name.

Recommended

> Enter a name.

---

Not recommended

> You entered an invalid postal code.

Recommended

> Enter a valid postal code. *[Explanation of valid postal code.]*

---

Not recommended

> ANSI C++ forbids declaration 'ostream' with no type 'ostream'.

Recommended

> ANSI C++ requires a type for declaration 'ostream' with type 'ostream'.

#### Don't be overly apologetic

While maintaining positivity, avoid the words "sorry" or "please."
Focus instead on clearly describing the problem and solution.

**Note:** Different cultures interpret apologies differently. Some cultures expect
apologies in certain situations; other cultures find apologies from software
corporations somewhat insincere. Although this lesson suggests avoiding
apologies, be aware of your target audience's expectations.

Not recommended

> We're sorry, a server error occurred and we're temporarily unable
> to load your spreadsheet.
> We apologize for the inconvenience. Please wait a while and try again.

Recommended

> Google Docs is temporarily unable to open your spreadsheet. In the meantime,
> try right-clicking the spreadsheet in the doc list to download it.

#### Avoid humor

Don't attempt to make error messages humorous. Humor in error messages can
fail for the following reasons:

* Errors frustrate users. Angry users are generally not receptive to humor.
* Users can misinterpret humor. (Jokes don't always cross borders well.)
* Humor can detract from the goal of the error message.

Not recommended

> Is the server running? Better go catch it :D.

Recommended

> The server is temporarily unavailable. Try again in a few minutes.

#### Don't blame the user

If possible, focus the error message on what went wrong rather than assigning blame.

Not recommended

> You specified a printer that's offline.

Recommended

> The specified printer is offline.

#### Multiple choice exercise

Which of the following error messages do not use the
appropriate tone?

1. Sorry, you are not allowed to leave feedback.
2. You entered an invalid title for your item.
3. 404 Error. Oops, that is embarrassing.

* (correct) 1, 2, and 3.

  All of these errors are inappropriate.

* 1

  1 is inappropriate, but that's not all.

* 2

  2 is inappropriate, but that's not all.

* 3

  3 is inappropriate, but that's not all.

**Next unit:** [Want to play a game?](https://developers.google.com/tech-writing/error-messages/want-to-play-a-game)

## Want to play a game?

Source: https://developers.google.com/tech-writing/error-messages/want-to-play-a-game

Challenge yourself by answering these five questions.

### Question 1

The following error message is supposed to target
non-technical users:

* You entered a bad age (32.6)

If you were reviewing this error message, which replacement error
message would you recommend instead?

* (correct) The specified age, 32.6, contains a decimal point.
  Enter an age that doesn't contain a decimal point. For example: 32

  This answer demonstrates how to correct the problem. The wording is
  appropriate for the target audience.

* The specified age, 32.6, is a floating-point number instead of an
  integer.

  The terms "floating-point number" and "integer" aren't ideal for an
  audience of non-technical users, so the error message doesn't really
  demonstrate how to correct the problem.

* You entered an age, 32.6, that our software can't process.

  This error message doesn't demonstrate how to correct the problem,
  or even explain what the problem is.

### Question 2

Which one of the following error messages would be best for application
programmers?

* (correct) The call read\_file(my\_input\_stream) failed because
  my\_input\_stream does not exist.
  To open a stream for reading, call the
  open\_file function. For example:
  my\_input\_stream = open\_file("~/.bashrc").

  This error message explains the problem and the solution.
  Also, the solution provides an example.

* You forgot to open my\_input\_stream.

  This error message blames the user. Also, this error message doesn't
  provide a solution.

* my\_input\_stream doesn't exist. Open
  my\_input\_stream before calling read\_file.

  This error message is so concise that some helpful information
  (for example, how to open an input stream) has been excluded.

### Question 3

What problem do you see in the following error message:

* The file you are attempting to upload is too big (12 MB).
  Please pick a smaller file and try again.

* (correct) The problem statement is missing the maximum allowable
  file size.

  This error message should have been:


  The file you are attempting to upload is too big (12 MB).
  You can only upload files that are 8MB or smaller.
  Please pick a smaller file and try again.

* The error message doesn't provide a solution to the problem.

  Actually, the error message does provide a solution.

* The error message contains a double negative.

  This error message doesn't contain a double negative.

### Question 4

What problem do you see in the following error message:

* The specified file ('camelia.txt') does not exist.
  Pick a different datastore and try again.

* (correct) The first sentence and second sentence use different terms
  for the same kind of object.

  The first sentence uses the term \*file\*. The second sentence
  calls the same object a \*datastore\*. This error message will
  likely confuse some users.

* The error message doesn't specify the problem.

  Actually, the first sentence of the error message does specify
  the problem.

* The error message blames the user.

  The error message doesn't blame anyone.

* The error message is overly apologetic.

  The error message doesn't apologize.

### Question 5

Consider the following error message displayed for a consumer
appliance:

* Error: Bad checksum. Change the battery in this
  device.

What error message would be more appropriate for a consumer
appliance?

* (correct) The battery is starting to fail. Replace the battery as soon as
  possible by following these directions: <*URL of battery
  replacement documentation*>

  This error message explains the problem in an appropriate way
  for nontechnical people. A full description of how to change a
  battery is probably too detailed for an error message, so
  providing the URL of full documentation is wiser. (Also,
  if the battery is removed, the user cannot read the directions
  in an error message.)

* Your device has reported a bad checksum. Change the battery in
  this device.

  Very few people know what "bad checksum" means, so this phrase
  will just annoy and confuse most people.

* The battery is starting to fail. Replace the battery as soon as
  possible by following these directions:

  1. Turn off the device by moving the switch from 1 to 0.
  2. Unlatch the battery case located in the rear of this
  device.
  ...
  10. Turn the device back on by moving the switch from 0 to 1.

  If the directions for replacing the battery were two steps instead
  of ten steps, then putting battery replacement instructions inside
  the error message might be okay.
  However, for a ten-step process, it is probably wiser to refer
  users to complete documentation that contains illustrations or
  videos. (Also, if the battery is removed, the user cannot read the
  directions appearing in the error message.)

* The error message is fine as is.

  This error message doesn't describe the problem appropriately for
  the target audience. The description of the solution isn't adequate.

**Next unit:** [Summary](https://developers.google.com/tech-writing/error-messages/summary)

## Course summary

Source: https://developers.google.com/tech-writing/error-messages/summary

This course recommended the following best practices when writing
error messages:

* Identify the cause of the error.
  * If the user entered an invalid value, specify the invalid value.
  * Specify requirements and constraints, such as required permissions
    or minimum RAM.
* Explain how to fix the problem.
  * When appropriate, provide an example to help demonstrate the fix.
* Write clearly.
  * Be concise, not wordy. However, don't be so concise that the resulting
    error message becomes cryptic.
  * Avoid double negatives and exceptions to exceptions.
  * Aim the message at the appropriate target audience. Words appropriate
    for software engineers are often inappropriate for non-technical users.
  * Use terminology consistently. For example, don't use the term *directory*
    in one part of an error message and a *folder* in another part.
  * Format long error messages carefully, possibly using progressive
    disclosure or links to expanded documentation.
  * Set a positive tone.
  * Don't be overly apologetic.

**Next unit:** [Additional guidelines for back end engineers](https://developers.google.com/tech-writing/error-messages/back-end)

## Additional guidelines for back-end engineers

Source: https://developers.google.com/tech-writing/error-messages/back-end

This lesson contains recommendations specifically for back-end
software engineers.

### Supply error codes

If an error code exists, include it as part of the error message.
Error codes help technical users identify the error and find more
information from an error index or error catalog.

Not recommended

> Error: You already own this bucket. Select another name from the
> dropdown list.

Recommended

> Error 409: You already own this bucket. Select another name from the
> dropdown list.

---

### Include an Error Identifier

Engineers parse logs to learn how and why errors occurred; therefore, include
an Error Identifier to help engineers find particular errors more easily.
The Error Identifier should stay constant, even if the textual error message
changes.

For more information, see the [Errors unit of
AIP-193.](https://google.aip.dev/193)

Not recommended

> { "error" : "Bad Request - Request is missing a required
> parameter: -collection\_name. Update parameter and resubmit.

Recommended

> { "error" : "Bad Request - Request is missing a required
> parameter: -collection\_name. Update parameter and resubmit.
> Issue Reference Number BR0x0071" }
