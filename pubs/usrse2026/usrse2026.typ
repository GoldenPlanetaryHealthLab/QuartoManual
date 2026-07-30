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


//#assert(sys.version.at(1) >= 11 or sys.version.at(0) > 0, message: "This template requires Typst Version 0.11.0 or higher. The version of Quarto you are using uses Typst version is " + str(sys.version.at(0)) + "." + str(sys.version.at(1)) + "." + str(sys.version.at(2)) + ". You will need to upgrade to Quarto 1.5 or higher to use apaquarto-typst.")

// counts how many appendixes there are
#let appendixcounter = counter("appendix")
// make latex logo
// https://github.com/typst/typst/discussions/1732#discussioncomment-11286036
#let TeX = {
  set text(font: "New Computer Modern",)
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  box(t + h(-0.14em) + e + h(-0.14em) + x)
}

#let LaTeX = {
  set text(font: "New Computer Modern")
  let l = "L"
  let a = text(baseline: -0.35em, size: 0.66em, "A")
  box(l + h(-0.32em) + a + h(-0.13em) + TeX)
}

#let firstlineindent=0.5in

// documentmode: man
#let man(
  title: none,
  runninghead: none,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  font: ("Times", "Times New Roman"),
  fontsize: 12pt,
  leading: 18pt,
  spacing: 18pt,
  firstlineindent: 0.5in,
  toc: false,
  lang: "en",
  cols: 1,
  numbersections: false,
  numberdepth: 3,
  first-page: 1,
  suppresstitlepage: false,
  doc,
) = {

  if suppresstitlepage {counter(page).update(first-page)}
  
   show raw.where(block: true): set par(
    spacing: 6pt,
    leading: 6pt
  )
  
  show raw.where(block: true): set text(
    size: 10pt
  )

  set page(
    margin: margin,
    paper: paper,
    header-ascent: 50%,
    header: grid(
      columns: (9fr, 1fr),
      align(left)[#upper[#runninghead]],
      align(right)[#context counter(page).display()]
    )
  )
  

  

 

  set table(    
    stroke: (x, y) => (
        top: if y <= 1 { 0.5pt } else { 0pt },
        bottom: .5pt,
      )
  )

  set par(
    justify: false, 
    leading: leading,
    first-line-indent: firstlineindent
  )

  // Also "leading" space between paragraphs
  set block(spacing: spacing, above: spacing, below: spacing)

  set text(
    font: font,
    size: fontsize,
    lang: lang
  )
  
  show link: set text(blue)
  show "al.'s": "al.\u{2019}s"

  show quote: set pad(x: 0.5in)
  show quote: set par(leading: leading)
  show quote: set block(spacing: spacing, above: spacing, below: spacing)
  // show LaTeX
  show "TeX": TeX
  show "LaTeX": LaTeX

  // format figure captions
  show figure.where(kind: "quarto-float-fig"): it => block(width: 100%, breakable: false)[
    #if int(appendixcounter.display().at(0)) > 0 [
      #heading(level: 2, outlined: false)[#it.supplement #appendixcounter.display("A")#it.counter.display()]
    ] else [
      #heading(level: 2, outlined: false)[#it.supplement #it.counter.display()]
    ]
    #align(left)[#par[#emph[#it.caption.body]]]
    #align(center)[#it.body]
  ]
  
  // format table captions
  show figure.where(kind: "quarto-float-tbl"): it => block(width: 100%, breakable: false)[#align(left)[
  
    #if int(appendixcounter.display().at(0)) > 0 [
      #heading(level: 2, outlined: false, numbering: none)[#it.supplement #appendixcounter.display("A")#it.counter.display()]
    ] else [
      #heading(level: 2, outlined: false, numbering: none)[#it.supplement #it.counter.display()]
    ]
    #par[#emph[#it.caption.body]]
    #block[#it.body]
  ]]
  
    set heading(numbering: "1.1")
    
    show heading: set text(size: fontsize)


 // Redefine headings up to level 5 
  show heading.where(
    level: 1
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(center)
    #if(numbersections and it.outlined and numberdepth > 0 and counter(heading).get().at(0) > 0) [#counter(heading).display()] #it.body
  ]
  
  show heading.where(
    level: 2
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(left)
    #if(numbersections and it.outlined and numberdepth > 1 and counter(heading).get().at(0) > 0) [#counter(heading).display()] #it.body
  ]
  
  show heading.where(
    level: 3
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(left)
    #set text(style: "italic")
    #if(numbersections and it.outlined and numberdepth > 2 and counter(heading).get().at(0) > 0) [#counter(heading).display()] #it.body
  ]

  show heading.where(
    level: 4
  ): it => text(
    weight: "bold",
    it.body
  )

  show heading.where(
    level: 5
  ): it => text(
    weight: "bold",
    style: "italic",
    it.body
  )
  
  

  if cols == 1 {
    doc
  } else {
    columns(cols, gutter: 4%, doc)
  }
  



}

#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
  columns: 1,
)

#show: document => man(
  runninghead: "EXECUTABLE SOFTWARE OPERATIONS MANUALS BUILT FROM INTERDEPENDENT QUARTO PAGES",
  paper: "us-letter",
  fontsize: 12pt,
  lang: "en",
  toc: true,
  numberdepth: 3,
  document,
)

\
\
#heading(level: 1, outlined: false, numbering: none)[Quarto Manuals]
<title>
#set align(center)
#block[
\
Tinashe M. Tapera#super[1], Chris#super[1], Danielle#super[2,3], and Michelle#super[4]

#super[1]Clinical Psychology Program, Department of Psychology, Ana and Blanca's University

#super[2]Danielle's Primary Affiliation

#super[3]Danielle's Secondary Affiliation

#super[4]Buffalo, NY

]
#set align(left)
\
\
#heading(level: 1, outlined: false, numbering: none)[Author Note]
<author-note>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Tinashe M. Tapera #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", alt: "Orcid ID Logo: A green circle with white letters ID", width: 4.23mm)) #link("https://orcid.org/0000-0001-9080-5010")

Chris #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", alt: "Orcid ID Logo: A green circle with white letters ID", width: 4.23mm)) #link("https://orcid.org/0000-0000-0000-0002")

Danielle #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", alt: "Orcid ID Logo: A green circle with white letters ID", width: 4.23mm)) #link("https://orcid.org/0000-0000-0000-0003")

Michelle #box(image("_extensions/wjschne/apaquarto/ORCID-iD_icon-vector.svg", alt: "Orcid ID Logo: A green circle with white letters ID", width: 4.23mm)) #link("https://orcid.org/0000-0000-0000-0004")

Carina Mengano is now at Generic University.

The authors have no conflicts of interest to disclose.

Author roles were classified using the Contributor Role Taxonomy (CRediT; #link("https://credit.niso.org")[credit.niso.org]) as follows: #emph[Tinashe M. Tapera]#strong[: ]conceptualization and writing -- original draft. #emph[Chris]#strong[: ]project administration and formal analysis. #emph[Danielle]#strong[: ]formal analysis and writing -- original draft. #emph[Michelle]#strong[: ]writing -- original draft, methodology, and formal analysis

Correspondence concerning this article should be addressed to Tinashe M. Tapera, Clinical Psychology Program, Department of Psychology, Ana and Blanca's University, 1234 Capital St., Albany, NY 12084-1234, USA, Email: #link("mailto:ttapera@hsph.harvard.edu")[ttapera\@hsph.harvard.edu]

#pagebreak()

#heading(level: 1, outlined: false, numbering: none)[Abstract]
<abstract>
#block[
to be fleshed out from bullet form below

]
#heading(level: 1, outlined: false, numbering: none)[Impact Statement]
<impact>
#block[
Scientific programming workflows are becoming increasingly complex, while existing support mechanisms remain poorly matched to that complexity. Traditional documentation is flexible but non-executable, command-line wrappers are executable but often too rigid, and current agentic systems are promising but not yet sufficiently reliable for many high-stakes workflow setup tasks. We propose Quarto Manuals, an executable documentation framework built on Quarto that helps authors create flexible, scalable, and reproducible workflow manuals composed of structured pages with explicit procedures and checks. Powered by the quarto-emit backend, Quarto Manuals enable authors to create executable documentation that allows users to conveniently step through scientific computing workflows while generating reproducible project artifacts and receiving immediate feedback on whether each step has been implemented correctly.

]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
#emph[Keywords]: APA Style, Quarto, Markdown, apaquarto

#pagebreak()



#show outline.entry: it => {show link: set text(fill: black)
link(it.element.location(),it.indented(none, it.inner(), ))}

#outline(title: [Table of Contents], indent: 1.5em)

#pagebreak()

#heading(level: 1, numbering: none)[Quarto Manuals]
<firstheader>
- programming is already hard and the data is only going to get bigger. workflows are blowing up in complexity and scale. scientists need rigour in their workflows.

- to get around this, we could write good docs. but good docs have limitations:

  - good docs break down in usefulness when we have to scale

  - good docs are not executable, meaning artifacts are not reproducible

  - good docs do not have a flexible feedback loop to confirm the user is acting correctly

- What about command line wrappers? They are executable but they are totally inflexible.

  - You build it once and everyone has to do it that way, or

  - you inundate yourself with a million flags and options to try to make it flexible. This is not a good solution for repetitive but unexpectedly parametric workflows.

- what about AI, LLMs, agents?

  - This is a promising solution, but (fact) LLMs are non-deterministic, meaning some steps in larger and more complex workflows will inevitably have results that may not be reproducible.

  - Additionally (opinion) agents are not yet mature enough to be reliable for some of the complex workflows we have in mind (though we are working on it with agentic workflows).

- To solve this in the meantime, we need a new type of documentation that is executable, flexible, and scalable. This is where Quarto comes in.

- We propose Quarto Manuals, an executable documentation framework that is flexible, scalable, and reproducible. Internally, a Quarto Manual is a custom starter template and extension for Quarto.

- benefits:

  - flexible: can be used for different audiences, can be used for different purposes, can be used for different programming languages

  - scalable: can be used for different projects, can be used for different teams, can be used for different organizations, and can scale in complexity required of the project

  - reproducible: side effects are intentional, meaning they can be used to generate reproducible artifacts for the workflow itself

  - relies on quarto and can leverage the full ecosystem of quarto, including quarto extensions, quarto publishing, and quarto rendering

- drawbacks:

  - requires some programming knowledge to use

  - requires quarto; might be a new framework for some

  - requires active user participation, not fully automated (but this is a feature, not a bug)

- we show three examples in action: a simple example, an intermediate example, and a complex example.

- Importantly, we use #NormalTok("quarto-emit");, a new extension, for the backend. A Quarto Manual is just a cognitive framework physically materialized by Quarto's custom Divs, and powered in the backend by a simple but powerful file export extension, #NormalTok("quarto-emit");.

- For manual Authors:

  - Authors call #NormalTok("quarto use template GoldenPlanetaryHealthLab/QuartoManuals"); to create a new Quarto Manual that instructs users on how to do something complex and procedural, for e.g., "SetupMyProject"

  - Helpful prompts throughout the template help guide manual authors to use the template effectively, but leave them with the flexibility to implement their workflows to their desired level of sophistication.

  - Authors implement each page check with a testing suite to give the user feedback on whether they are implementing the workflow correctly.

  - inter-page dependencies are gently suggested, but not enforced to reduce implementation overhead for the extension and allow for flexibility in workflow design.

  - #NormalTok("git push"); to push the manual to a GitHub repository (or code hosting site of your choice)

- For manual Users:

  - In your home directory or otherwise, #NormalTok("quarto use template MyLab/SetupMyProject"); clones the SetupMyProject Manual project to your local machine.

  - Step through the pages of the manual, leaving behind setup artifacts as you go, like .venv files, .Renviron files, and other scripts or configuration files. These artifacts are reproducible and can be used to set up your project environment.

  - Run #NormalTok("quarto render"); to render the manual to HTML, PDF, or DOCX. If the manual has checks implemented in a testing suite, quarto render will execute the testing suite, providing you with a visual report of your progress in the manual and whether you are implementing the workflow correctly.

  - If all goes well, you now have a fully setup project as the original author intended, and you can now start working on your implementation of the project.

== Hypotheses, Aims, and Objectives
<hypotheses-aims-and-objectives>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
The last paragraph of the introduction usually states the specific hypotheses of the study, often in a way that links them to the research design.

= Method
<method>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
General remarks on method. This paragraph is optional. Not all papers require each of these sections. Edit them as needed. Consult the #link("https://apastyle.apa.org/jars")[Journal Article Reporting Standards] for what is needed for your type of article.

== Participants
<participants>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Who are they? How were they recruited? Report criteria for participant inclusion and exclusion. Perhaps some basic demographic stats are in order. A table is a great way to avoid repetition in statistical reporting.

== Measures
<measures>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
This section can also be titled #strong[Materials] or #strong[Apparatus]. Whatever tools, equipment, or measurement devices used in the study should be described.

=== Measure A
<measure-a>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Describe Measure A.

=== Measure B
<measure-b>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Describe Measure B.

==== Subscale B1.
<subscale-b1>
A paragraph after a 4th-level header will appear on the same line as the header.

==== Subscale B2.
<subscale-b2>
A paragraph after a 4th-level header will appear on the same line as the header.

===== Subscale B2a.
<subscale-b2a>
A paragraph after a 5th-level header will appear on the same line as the header.

===== Subscale B2b.
<subscale-b2b>
A paragraph after a 5th-level header will appear on the same line as the header.

== Procedure
<procedure>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
What did participants do? How are the data going to be analyzed?

= Results
<results>
== Descriptive Statistics
<descriptive-statistics>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Describe the basic characteristics of the primary variables. My ideal is to describe the variables well enough that someone conducting a meta-analysis can include the study without needing to ask for additional information.

#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
#link(<tbl-mymarkdowntable2>)[Table~1] is an example of a plain markdown table. Note the that the caption begins with a colon.

#figure([
#table(
  columns: 2,
  align: (center,center,),
  table.header([Letters], [Numbers],),
  table.hline(),
  [A], [1],
  [B], [2],
  [C], [3],
)
], caption: figure.caption(
position: top, 
[
My Caption.
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-mymarkdowntable2>


= Discussion
<discussion>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Describe results in non-statistical terms.

== Limitations and Future Directions
<limitations-and-future-directions>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Every study has limitations. Based on this study, some additional steps might include…

== Conclusion
<conclusion>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Describe the main point of the paper.

= References
<references>
References marked with an asterisk indicate studies included in the meta-analysis.

#set par(first-line-indent: 0in, hanging-indent: 0.5in)
#block[
] <refs>
#set par(first-line-indent: 0.5in, hanging-indent: 0in)



#set bibliography(style: "\_extensions/wjschne/apaquarto/apa.csl")

