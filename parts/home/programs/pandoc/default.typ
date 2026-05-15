// Letter-size Typst article layout template
// by John Maxwell, jmax@sfu.ca, VERSION as of March 2025
//
// Assumes Pandoc v3.7.0.2; Typst v0.14.2
//
// This template is for Typst with Pandoc
// The assumption is markdown source, with a 
// YAML metadata block (title, author, date...)
// Usage:
//    pandoc article.md \
//      -f markdown --wrap=none \
//      -t pdf --pdf-engine=typst \
//      --template=default.typ \
//      -o article.pdf


// This bit from Pandoc, to help parse incoming metadata
// ---
// title: Rwanda 1994
// authors:
//   - name: me
// date: 2026
// ---
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

#let conf(
  title: none, // These first few come through from markdown metadata
  subtitle: none,
  authors: (),
  keywords: (),
  date: none,
  abstract: none,
  lang: "en",
  region: "US",
  paper: "us-letter",
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  cols: 1,
  font: ("STIX Two Text"),
  font-sans: ("Source Sans 3"),
  fontsize: 12pt,
  sectionnumbering: none,
  pagenumbering: "1",
  doc,
) = {
  set document(
    title: if title != none { title } else { "" },
    author: authors.map(author => content-to-string(author.name)),
    keywords: keywords,
  )
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    columns: cols,
  // Running header:
  //
    header-ascent: 30%,
    header: context {
      if (here().page()) > 1 {  // skip first page
        set text(font: font-sans, size: 9pt, fill: luma(120))
        if calc.odd(here().page()) {  // different headers on L/R pages
          align(right, if title != none { smallcaps(title) } else { "" } )
        } else {
          align(left, if authors.len() > 0 { smallcaps(content-to-string(authors.first().name)) } else { "" } )
        }
      }
    },      
  // Running footer
  //
    footer-descent: 30%,
    footer: context {
      set text(font: font-sans, size: 9pt, fill: luma(120))
      if calc.odd(here().page()) {  // different footers on L/R pages
        align(right,counter(page).display( "1") )
      } else {
        align(left,counter(page).display( "1") )
      }
    },
  )


// Text defaults
//
  set text(lang: lang,
    region: region,
    font: font, // see 'conf' above
    size: fontsize,
    fill: luma(30),
    // spacing: 90%, // tighter than normal is nice 
    // alternates: false,
    // discretionary-ligatures: false,
    // historical-ligatures: false,
    // number-type: "old-style",
    // number-width: "proportional")
    //set strong(delta: 200) // use semibold instead of bold
  )

// Paragraph defaults
//
  set par(
    spacing: 1em,  
    leading: 0.75em,
    justify: true,
    first-line-indent: 0em,
  )

// Block quotations
//
  set quote(block: true)
  show quote: set block(spacing: 1em)
  show quote: set pad(x: 2em)
  show quote: set text(style: "italic", fill: luma(80))

// Code blocks: green monospace
//
  show raw.where(block: true): it => block(
    inset: (x: 1em, y: 0.75em),
    radius: 4pt,
    fill: luma(240),
    width: 100%,
    text(font: "FiraCode Nerd Font Mono", size: 9pt, fill: rgb("#116611"), it)
  )
  show raw.where(block: false): it => text(
    font: "FiraCode Nerd Font Mono", size: 9pt, fill: rgb("#116611"), it
  )

// Images and figures:
//
  set image(fit: "contain")
  show image: align.with(center)
  set figure(gap: 1em, supplement: none, placement: none)
  show figure.caption: set text(size: 9pt, style: "italic") // how to set space below?
  show figure: set block(below: 1.5em)

// Footnote formatting
//
  set footnote.entry(indent: 0em)
  show footnote.entry: set text(size: 9pt)
  show footnote.entry: set par(hanging-indent: 0.5em, spacing: 0.5em)

// LINKS
//
  show link: set text(fill: rgb("#4a90d9"))
  show regex("https?://\\S+"): it => text(fill: rgb("#4a90d9"), it)

// HEADINGS
//
  show heading: set text(font: font-sans, hyphenate: false)
  set heading(numbering: sectionnumbering)

  show heading.where(level: 1): it => block(above: 1em, below: 0.75em)[
    #set text(size: 20pt, weight: "bold", fill: luma(15))
    #it.body 
    #v(2pt) // space below
  ]

  show heading.where(level: 2): it => block(above: 1.5em, below: 0.6em)[
    #set text(size: 16pt, weight: "semibold", fill: luma(25))
    #it.body 
  ]

  show heading.where(level: 3): it => block(above: 1.25em, below: 0.5em)[
    #set text(size: 13pt, weight: "bold", fill: luma(40))
    #it.body 
  ]

  show heading.where(level: 4): it => block(above: 1em, below: 0.4em)[
    #set text(size: 11.5pt, weight: "semibold", style: "italic", fill: luma(50))
    #it.body 
  ]

  show heading.where(level: 5): it => block(above: 1em, below: 0.4em)[
    #set text(size: 10.5pt, weight: "regular", fill: luma(80))
    #smallcaps(it.body) 
  ]

// STYLING LABELLED SECTIONS
//
show <refs>: set par(
  justify: false,
  spacing: 1em,
  first-line-indent: 0em,
  hanging-indent: 2em,
  leading: 0.65em,
)
show <epigraph>: set text(fill: luma(120), style: "italic")
show <epigraph>: set par(justify: false) 

// THIS IS THE TITLE BLOCK
//
if title != none {
  v(1.5em)
  set par(justify: false)
  text(font: font-sans, size: 24pt, weight: "bold", fill: luma(15), title) 
  if subtitle != none {
    v(0.3em)
    text(font: font-sans, size: 16pt, weight: "regular", style: "italic", fill: luma(50), subtitle)
  }
  v(0.5em)
  if authors.len() > 0 {
    text(font: font-sans, size: 11pt, fill: luma(60), authors.map(a => content-to-string(a.name)).join(", "))
  }
  if date != none {
    v(0.3em)
    text(font: font-sans, size: 11pt, fill: luma(120), date)
  }
  if abstract != none {
    v(0.75em)
    block(inset: (x: 1em, y: 0.75em), fill: luma(245), radius: 3pt, width: 100%)[
      #set text(size: 10pt, style: "italic")
      *Abstract:* #abstract
    ]
  }
  v(0.5em)
  line(length: (100%), stroke: 1pt + luma(200))
  v(0.75em)
}

// THIS IS THE ACTUAL BODY:

  counter(page).update(1) // re-set page numbering
  set par(justify: true) //default for the rest of the doc

  doc  // HERE is the actual body content

// COLOPHON at the end

v(1fr)
align(center, text(font: font-sans, size: 8pt, style: "italic", fill: luma(160))[Typeset from Markdown with open-source tools Pandoc and Typst.])  

} // end 'let conf'

#let horizontalrule = line(length: 100%, stroke: 0.5pt)

#show: conf.with(
  $if(title)$title: [$title$],$endif$
  $if(subtitle)$subtitle: [$subtitle$],$endif$
  $if(authors)$
  authors: (
    $for(authors)$
    (name: [$it.name$]),
    $endfor$
  ),
  $endif$
  $if(date)$date: [$date$],$endif$
  $if(abstract)$abstract: [$abstract$],$endif$
  $if(lang)$lang: "$lang$",$endif$
)

$body$
