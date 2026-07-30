
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
$if(title)$
  title: "$title$",
$endif$
$if(subtitle)$
  subtitle: "$subtitle$",
$endif$
$if(author)$
  author: "$author$",
$endif$
$if(mainfont)$
  font: "$mainfont$",
$endif$
$if(header_block_color)$
  header_block_color: "$header_block_color$",
$endif$
$if(header_logo)$
  header_logo: "$header_logo$",
$endif$
$if(body_color)$
  body_color: "$body_color$",
$endif$
$if(body_font)$
  body_font: "$body_font$",
$endif$
$if(heading_color)$
  heading_color: "$heading_color$",
$endif$
doc,
)


