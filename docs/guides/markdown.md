# Markdown

The LTSP project uses [GitHub Flavored
Markdown](https://github.github.com/gfm/), with a few differences noted below.

## Inline elements

Markdown uses two trailing spaces at the end of a line to indicate a `<br />`.

### Text formatting

| Element             | HTML                 | When to use                                  |
| ------------------- | -------------------- | -------------------------------------------- |
| `*asterisk1*`       | em                   | *Emphasis*                                   |
| `**asterisk2**`     | strong               | **Strong importance**                        |
| `***asterisk3***`   | em>strong[¹](#notes) | ***For*** ▸ ***menus*** and ***GUI labels*** |
| `` `backtick` ``    | code                 | `commands, filenames, terminal stuff`        |
| `` *`a1>b`* ``      | em>code              | *`Smart roles`*[²](#notes)                   |
| `` **`a2>b`** ``    | strong>code          | Keystrokes: **`Ctrl`**+**`Alt`**+**`Del`**   |

#### Notes

1. Pymarkdown renders `***` as `strong>em`, while markdown-it as `em>strong`.
   We cover both cases in our CSS.
2. Smart roles are not implemented nor used yet. For example, *`page`* could
   automatically link to page.md and show a tooltip with its title.
3. In vscode-markdown-extended, underscore is rendered as u (underline) instead
   of em. Also some other parsers have issues with underscores. Avoid them,
   e.g. don't use `_text_` for emphasis.

### Images

A normal image is `![alt](image.png)` and a link is `[text](url)`.

For right-aligned, shrinked, clickable images, use this syntax:
`[![](image.png)](image.png)`

## Block elements

### Code blocks

Use fenced code blocks for multiline shell code:

````md
```shell
code
```
````

Blank lines are not necessary. Do not use four spaces to indicate code blocks
as some markdown implementations get confused e.g. in list > code, then code.

### Lists

In the original markdown and in pymarkdown, indentation is always four spaces.
This is necessary when we need to [nest lists, admonitions
etc](https://github.com/Python-Markdown/markdown/issues/1172#issuecomment-987120301),
so we may use it always. Typing **`Tab`** after the dash is usually enough.

1.  For numbered lists, `1.␣␣actual numbers` with two spaces

    -   For bulleted lists, `-␣␣␣dashes` with three spaces

### Admonitions

For now the
[pymarkdown-extras](https://python-markdown.github.io/extensions/admonition/)
syntax is used, which is also supported by
[vscode-markdown-extended](https://github.com/qjebbs/vscode-markdown-extended#admonition):

!!! tip "Optional tip title"
    Let's hope pymarkdown gets support for [general purpose
    blocks](https://github.com/Python-Markdown/markdown/issues/1175) similar to
    [pandoc's fenced
    divs](https://pandoc.org/MANUAL.html#extension-fenced_divs)!

## Markdown research notes

### Classes

It's possible to add classes to any inline element by appending
`{.class}`{.green} to its right, while in block elements it goes underneath.
Kramdown uses `{:.class}` instead, and it's supported by pymarkdown, but not by
vscode-markdown-extended.

### Admonitions

> [!NOTE]  
> Blockquotes are used for admonitions by the [Microsoft Docs Authoring
> Pack](https://docs.microsoft.com/en-us/contribute/markdown-reference)


> *📝 NOTE*{.green}  
> The same thing could be achieved by standard markdown and classes.
> Unfortunately, pymarkdown can only add the class to either the first or
> the last blockquote line, not to all of it.
