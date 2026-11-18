# Markdown Fence Safety

## When this rule applies

Whenever you write Markdown in a session message or a plan: plans, reviews,
summaries, reports, and any other prose that contains fenced code blocks.

## Background

A fenced code block ends at a closing fence: a line consisting only of the
same fence character (backtick or tilde), at least as long as the opening
fence, optionally preceded by up to three spaces and followed only by spaces.
Markdown has no escape sequence inside a fence. When a snippet contains its
own fenced block and the outer fence is not longer, the inner closing fence
ends the outer block and the rest of the message renders as Markdown.
Some renderers treat a bare same-character fence of equal or greater length
as the closing fence, so the fix belongs in the message source.

## Rule

1. Choose the outer fence so no line inside the snippet can close it:
   - Use a tilde fence if the content contains a backtick fence; otherwise
     use a backtick fence.
   - Use at least three characters, and make the chosen fence longer than the
     longest run of that character in the content.
2. Close every opening fence with a closing fence: the same character, at
   least the same length, and no other text. Keep both fences at column 0 or
   at most three spaces of indentation; four or more spaces is not treated as
   a fence.
3. Before sending the message, scan every fenced block:
   - Each opening fence has a matching closing fence.
   - No line inside is a closing fence for the outer block: at most three
     leading spaces, only the same character, at least the outer length, and
     no other text.
   - The last fence in the message is closed.
4. If a snippet cannot satisfy these checks, do not paste it into the session
   message. Write the redacted artifact to a file and present a short summary
   with the file path instead. For a plan, use the plan file if plan mode
   provides one; otherwise, if a plan directory is available, write the
   artifact there; if neither is available, state that no plan file exists and
   cite the file you wrote.

## Examples

Wrong: in the message below, the outer and inner fences have the same length,
so the inner closing fence ends the outer block and the final fence opens a
new one.

~~~text
```markdown
# Example

```sh
echo hi
```
```
~~~

Right: the tilde fence cannot be closed by the backtick fences inside it.

~~~markdown
# Example

```sh
echo hi
```
~~~
