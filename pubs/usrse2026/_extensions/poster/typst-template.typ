
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
}

#set table(inset: 6pt, stroke: rgb("1E1E1E") + 0.5pt)
