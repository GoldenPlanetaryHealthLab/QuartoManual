// Simple numbering for non-book documents
#let equation-numbering = "(1)"
#let callout-numbering = "1"
#let subfloat-numbering(n-super, subfloat-idx) = {
  numbering("1a", n-super, subfloat-idx)
}

// Theorem configuration for theorion
// Simple numbering for non-book documents (no heading inheritance)
#let theorem-inherited-levels = 0

// Theorem numbering format (can be overridden by extensions for appendix support)
// This function returns the numbering pattern to use
#let theorem-numbering(loc) = "1.1"

// Default theorem render function
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  if full-title != "" and full-title != auto and full-title != none {
    strong[#full-title.]
    h(0.5em)
  }
  body
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#f1f3f5")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



// This is an example typst template (based on the default template that ships
// with Quarto). It defines a typst function named 'article' which provides
// various customization options. This function is called from the 
// 'typst-show.typ' file (which maps Pandoc metadata function arguments)
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-show.typ' entirely. You can find 
// documentation on creating typst templates and some examples here: 
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#let poster_header(
  title,
  author,
  subtitle,
  header_block_color: "6b1f50",
  header_logo: none,
  header_font: "JetBrains Mono",
  
) = {
    
  set text(fill: white, font: header_font)
  
  stack(
    dir: ttb,
    block(
      fill: rgb(header_block_color),
      width: 100%,
      height: 100%,
      inset: 1in,
      grid(
        columns: (4fr, .5fr),
        align(left + horizon)[#stack(
          spacing: 0.5in,
          text(size: 92pt,weight: "extrabold",fill: rgb("ffdb43"))[#title],
          text(size: 58pt, weight: "bold")[#subtitle],
          text(size: 48pt)[#author],
        )],
        align(right + horizon)[
          #if header_logo != none {
            box(width: 100%)[#image(header_logo)]
          }
        ]
      )
    )
  )
}

#let poster_body(
  body_color: "cccccc",
  body_font: "JetBrains Mono",
  heading_color: "6b1f50",
  doc
) = {
  set text(
    fill: black,
    font: body_font,
    size: 38pt
  )

  show heading: set text(fill: rgb(heading_color))

  stack(
    dir: ttb,
    block(
      fill: rgb(body_color),
      width: 100%,
      height: 100%,
      inset: (top: .75in, right: 1in, bottom: .5in, left: 1in),
      columns(3, gutter: 2em)[
        #doc
      ]
    )
  )
}

#let poster(
  title: "",
  author: "",
  subtitle: "",
  width: 48in,
  height: 36in,
  header_block_color: "6b1f50",
  header_logo: "logo.png",
  header_font: "JetBrains Mono",
  body_color: "cccccc",
  body_font: "JetBrains Mono",
  heading_color: black,
  doc,
) = {
  set page(
    height: height,
    width: width,
    margin: 0in,
  )

  set par(justify: true)

  set text(size: 24pt)

  grid(
    columns: 1,
    rows: (15%, 85%),
    poster_header(
      title,
      author,
      subtitle,
      header_block_color: header_block_color,
      header_logo: header_logo,
      header_font: header_font,
    ),
    poster_body(
      body_color: body_color,
      body_font: body_font,
      heading_color: heading_color,
      doc
    )
  )
}

#set table(
  inset: 6pt,
  stroke: none 
)

#set block(spacing: 2em)
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)


// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: doc => poster(
  title: "Quarto Manuals",
  subtitle: "Executable software operations manuals built from interdependent Quarto pages",
  author: "Edenian",
  header_logo: "dummy-thchan.png",
doc,
)



PLACEHOLDER CONTENT. NOT YET IMPLEMENTED

#import "@preview/showybox:2.0.4": showybox 
#let main = rgb("#6b1f50")

#showybox(
  title-style: (
    boxed-style: (
      anchor: (
        x: center,
        y: horizon
      ),
      radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt),
    )
  ),
  frame: (
    title-color: main,
    body-color: main.lighten(80%),
    footer-color: main.lighten(60%),
    border-color: main.darken(20%),
    radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt)

  ),
  title: "tl;dr",
  footer: text(size: 30pt, weight: 600, emph("Check it out, you can also add Typst code to make math functions or diagrams."))
)[
  This is a Typst template that can be used with Quarto to execute code and automatically render outputs like text, plots, and tables.
  Forget about copying and pasting screenshots 

  $ frac(diff^n f, diff x_i ... diff x_j)(a_1, a_2, ..., a_n) = frac(diff^n f, diff x_j ... diff x_i)(a_1, a_2, ..., a_n) $
]
#block(
fill:white,
inset:30pt,
radius:6pt,
[
= #strong[INSTALLATION]
<installation>
To install this poster template, go to your project root and run:

#Skylighting(([#ExtensionTok("quarto");#NormalTok(" install extension https://codeberg.org/edenian-prince/quarto-typst-poster/archive/main.zip");],));
You can also add the template/demo quarto document by running the code below, but note, it adds all the files in the repo currently..

#Skylighting(([#ExtensionTok("quarto");#NormalTok(" use template https://codeberg.org/edenian-prince/quarto-typst-poster/archive/main.zip");],));
])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= #strong[USAGE]
<usage>
After installing, change the format in your Quarto document's yaml front matter to #NormalTok("format: poster-typst");

#Skylighting(([#CommentTok("---");],
[#AnnotationTok("format:");],
[#CommentTok("  poster-typst: default");],
[#CommentTok("---");],));
You can also add other options in the front matter like a title, subtitle, and color options. See the codeberg repo for a complete list of options.

= #strong[ADDING SECTIONS]
<adding-sections>
This format is a Typst canvas, but Quarto is where you write the sections that contain text, code, and outputs. These sections are what you are reading now. To create these sections in white blocks (or whatever color you want…), wrap your sections in fenced divs like this:

#Skylighting(([#NormalTok(":::{.block fill=\"white\" inset=\"30pt\" radius=\"6pt\"}");],
[],
[#NormalTok("Headings, text, and code go here");],
[],
[#NormalTok(":::");],));
])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= #strong[ADDING PLOTS]
<adding-plots>
Run put your code in the Quarto document like you normally would and it will render here.

- Center the plot with #NormalTok("#| fig-align: center");
- Adjust the width with #NormalTok("#| fig-width: 12");
- Adjust the height with #NormalTok("#| fig-height: 9");
- Adjust plot attributes in your code

Add a footer or something underneath

])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= #strong[ADDING TABLES]
<adding-tables>
Likewise, you can add tables by doing the same as above.

#NormalTok("tinytable"); seems to look the best in this format fyi.

])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= #strong[TYPST CODE]
<typst-code>
You can add Typst snippets in the Quarto doc like this with showybox. This is how I made the #NormalTok("tl;dr"); and #NormalTok("Source Code"); blocks.

#Skylighting(([#InformationTok("```{=typst}");],
[#InformationTok("#import \"@preview/showybox:2.0.4\": showybox ");],
[],
[#InformationTok("#showybox(...)");],
[],
[#InformationTok("```");],));
])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= #strong[RENDER THE POSTER]
<render-the-poster>
#Skylighting(([#ExtensionTok("quarto");#NormalTok(" render poster.qmd");],));
])


#showybox(
  title-style: (
    boxed-style: (
      anchor: (
        x: center,
        y: horizon
      ),
      radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt),
    )
  ),
  frame: (
    title-color: main,
    body-color: main.lighten(80%),
    footer-color: main.lighten(60%),
    border-color: main.darken(20%),
    radius: (top-left: 10pt, bottom-right: 10pt, rest: 0pt)
  ),
  title: "Source Code",
)[
]



