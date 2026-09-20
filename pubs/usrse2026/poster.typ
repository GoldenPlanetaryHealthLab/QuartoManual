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
  header_block_color: "A51C30",
  header_logo: none,
  header_font: "JetBrains Mono",
  body_font: "Arial",
  
) = {
    
  grid(
    rows: (1fr, 0.14in),
    block(
      width: 100%,
      height: 100%,
      grid(
        columns: (3fr, 1fr),
        block(
          fill: rgb(header_block_color),
          width: 100%,
          height: 100%,
          inset: (left: 1in, right: .7in, top: .55in, bottom: .55in),
          [
            #text(font: header_font, size: 88pt, weight: "bold", fill: white)[#title]
            #v(0.16in)
            #text(font: body_font, size: 42pt, weight: "bold", fill: white)[#subtitle]
            #v(0.12in)
            #text(font: body_font, size: 30pt, fill: white)[#author]
          ],
        ),
        block(
          fill: white,
          width: 100%,
          height: 100%,
          inset: .5in,
          align(center + horizon)[
            #if header_logo != none { image(header_logo, width: 100%) }
          ],
        ),
      ),
    ),
    block(fill: rgb(header_block_color), width: 100%, height: 100%),
  )
}

#let poster_body(
  body_color: "F4F4F4",
  body_font: "Arial",
  heading_color: "1E1E1E",
  doc
) = {
  set text(
    fill: black,
    font: body_font,
    size: 32pt
  )

  show heading: set text(font: "Baskerville", fill: rgb(heading_color), weight: "bold")
  set block(spacing: 1em)

  stack(
    dir: ttb,
    block(
      fill: rgb(body_color),
      width: 100%,
      height: 100%,
      inset: (top: .65in, right: .8in, bottom: .55in, left: .8in),
      columns(3, gutter: .45in)[
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
  design_width: 48in,
  design_height: 36in,
  header_block_color: "A51C30",
  header_logo: "logo.png",
  header_font: "Baskerville",
  body_color: "F4F4F4",
  body_font: "Arial",
  heading_color: "1E1E1E",
  doc,
) = {
  set page(
    height: height,
    width: width,
    margin: 0in,
  )

  set par(justify: false)

  set text(size: 24pt)

  scale(
    x: (width / design_width) * 100%,
    y: (height / design_height) * 100%,
    origin: top + left,
    reflow: true,
    block(
      width: design_width,
      height: design_height,
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
          body_font: body_font,
        ),
        poster_body(
          body_color: body_color,
          body_font: body_font,
          heading_color: heading_color,
          doc
        )
      )
    )
  )
}

#set table(inset: 6pt, stroke: rgb("1E1E1E") + 0.5pt)
#import "@preview/fontawesome:0.5.0": *
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
  subtitle: "Executable operator manuals for reproducible scientific workflows",
  author: "Tinashe M. Tapera, Michelle Audirac, Danielle Braun, Christopher Golden",
  header_block_color: "A51C30",
  header_logo: "dummy-thchan.png",
  header_font: "Baskerville",
  body_color: "F4F4F4",
  body_font: "Arial",
  heading_color: "1E1E1E",
  width: 44in,
  height: 33in,
doc,
)


#block(
fill:white,
inset:30pt,
radius:6pt,
[
= The problem
<the-problem>
Scientific workflows depend on local platforms, configuration, versions, permissions, and ordered state changes. A README can describe the workflow steps, but cannot easily show whether it is safe to proceed between steps or whether the workflow succeeded.

= Our approach
<our-approach>
#strong[Quarto Manuals] are ordered #NormalTok(".qmd"); pages for domain-competent scientists who run software. Each page makes inputs, choices, actions, artifacts, and checks visible. The rendered manual is a readable interface; the source page remains the operational record.

])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= The page contract
<the-page-contract>
Each operational page answers three questions: what must already be true, what change(s) will I make, and what evidence says it worked?

#block[
#callout(
body: 
[
Check for visible files, tools, configuration, or prior artifacts.

#Skylighting(([#InformationTok("```python");],
[#CommentTok("# Example: check that a file exists");],
[#ImportTok("import");#NormalTok(" os");],
[#ControlFlowTok("assert");#NormalTok(" os.path.exists(");#StringTok("\"data.csv\"");#NormalTok("), ");#StringTok("\"data.csv is required!\"");],
[#InformationTok("```");],));
]
, 
title: 
[
Prerequisite: Start From Current State
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
none
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Perform one bounded transformation while keeping meaningful choices and execution boundaries visible.

#Skylighting(([#InformationTok("```python");],
[#CommentTok("# Example: manipulate the data.csv file");],
[#ImportTok("import");#NormalTok(" pandas ");#ImportTok("as");#NormalTok(" pd");],
[#NormalTok("data ");#OperatorTok("=");#NormalTok(" pd.read_csv(");#StringTok("\"data.csv\"");#NormalTok(")");],
[#CommentTok("# Perform a bounded change, e.g., filter rows");],
[#NormalTok("data_filtered ");#OperatorTok("=");#NormalTok(" data[data[");#StringTok("'value'");#NormalTok("] ");#OperatorTok(">");#NormalTok(" ");#DecValTok("0");#NormalTok("]");],
[#CommentTok("# Save the result to a new file");],
[#NormalTok("data_filtered.to_csv(");#StringTok("\"data_filtered.csv\"");#NormalTok(", index");#OperatorTok("=");#VariableTok("False");#NormalTok(")");],
[#InformationTok("```");],));
]
, 
title: 
[
Procedure: Make One Bounded Change
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
none
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
Prove that the intended state or artifact exists; a successful command alone is not evidence that the workflow succeeded.

#Skylighting(([#InformationTok("```python");],
[#CommentTok("# Assert that the filtered data has the expected properties");],
[#ControlFlowTok("assert");#NormalTok(" ");#KeywordTok("not");#NormalTok(" data_filtered.empty, ");#StringTok("\"Filtered data is empty\"");],
[#InformationTok("```");],));
]
, 
title: 
[
Check: Verify The Result
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
none
, 
body_background_color: 
white
)
]
])

#let captioned-image(path, caption, width: 100%) = {
  stack(
    dir: ttb,
    spacing: 8pt,
    align(
      center,
      text(size: 20pt, weight: "bold", caption),
    ),
    align(
      center,
      image(path, width: width),
    ),
  )
}

#colbreak()

#grid(
  columns: (1fr, 1fr),
  gutter: 0.2in,
  align: top,

  captioned-image(
    "schematic-manual_inkscape2.svg",
    [Structure of a Quarto Manual Page],
  ),

  stack(
    dir: ttb,
    spacing: 0.25in,

    captioned-image(
      "lego_cropped.png",
      [Like playing with LEGO — a build is constructed by taking inventory of your pieces, putting them together, and verifying the result against the instructions],
    ),

    captioned-image(
      "schematic-software.svg",
      [Your Assembled Output is a Reproducible Scientific Software Project],
    ),
  ),
)

#v(0.18in)

#align(center)[
  #stack(
    dir: ttb,
    spacing: 0.10in,
    align(center)[
      #text(size: 60pt, weight: "bold")[Explore Quarto Manuals]
    ],
    align(center)[
      #link("https://goldenplanetaryhealthlab.github.io/QuartoManual")[
        #text(size: 30pt)[goldenplanetaryhealthlab.github.io/QuartoManual]
      ]
    ],
    align(center)[
      #image("quarto-manual-qr.svg", width: 1.85in)
    ],
  )
]

#colbreak()
#block(
fill:rgb("EFF6FF"),
stroke:(left: 6pt + rgb("2563EB")),
inset:30pt,
radius:6pt,
[
= Internals
<internals>
- #strong[Quarto:] a manual is powered by Quarto, a user-friendly scientific publishing system that uses plain text notebooks. Quarto projects can be seamlessly rendered to HTML, PDF, or other formats.
- #strong[Book-as-Manual:] a manual is a Book project with ordered pages and navigation---mimicking a physical instruction manual.
- #strong[Extensions:] thin extensions compose existing Quarto features. We introduce #strong[#NormalTok("quarto-emit");], an extension that reviews source code blocks and materializes them as code, tests, scripts, and configuration.

])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= Why this exists
<why-this-exists>
Scientific software workflows are often too complex for a README and too judgment-heavy to hide behind a single command-line tool. Thorough documentation may #emph[describe] a workflow, but websites, tutorials, and blog posts lack the #emph[interactivity] needed to navigate whether the current state/step is valid, what local environment adjustments are needed, or what evidence permits proceeding to the next step.

#strong[Quarto Manuals] provide a reproducible handoff: the smallest reliable sequence of actions that leaves visible artifacts and confirms progress. They're designed to preserve operator authority where #strong[local constraints] and #strong[scientific judgment] matter, while making repeatable work #strong[mechanical and transparent].

])

#block(
fill:white,
inset:30pt,
radius:6pt,
[
= Future development opportunities
<future-development-opportunities>
A Manual page provides a transparent interface between an operator and an #strong[agentic coding assistant]:

- #strong[Bounded context:] prerequisites verbally identify the approved specification, relevant files, environment, and constraints.
- #strong[Bounded change:] procedures authorize one inspectable modification; an agent may propose or emit source, tests, scripts, and configuration.
- #strong[Verifiable handoff:] checks become executable acceptance criteria, with a human deciding whether the next page may run.

Because #strong[Quarto Manuals promote human writing and review of scientific prose], this structure supports agentic workflows, including:

- #strong[Turn-based execution] --- the traditional human operator and agent take turns writing expectations, executing code, and passing tests;
- #strong[Spec-driven development] (SDD), where a human operator provides a descriptive specification and an agentic system proposes code, configuration, and tests for review;
- #strong[Data Analysis Decision Records] (DADR), where a human operator and an agentic system record the rationale for data analysis decisions, including the specification, code, and tests.

#strong[Takeaway:] Quarto Manuals keep workflow decisions, state transitions, artifacts, verification, and approval points visible---so human-directed and AI-assisted execution remain understandable and accountable.

])




