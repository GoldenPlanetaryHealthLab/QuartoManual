
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
