#let project(body, title: "", author: "", date: "", abstract: []) = {

  set text(font: "New Computer Modern")
  
  block({
    set text(2 * 12pt, font: "New Computer Modern Sans", weight: "black")
    set align(center)
    title
  }, width: 100%)

  v(6pt)

  block({
    set text(1.2* 12pt)
    show: smallcaps
    set align(center)
    author
  }, width: 100%)

  // block({
  //   set text(1.2* 12pt)
  //   set align(center)
  //   date
  // }, width: 100%)
  
  // v(18pt)
  
  // pad(
  //   x: 4em,
  //   block({
  //     abstract
  //   })
  // )

  v(6pt)

  show heading: set text(font: "New Computer Modern Sans")
  // set heading(numbering: "1.")

  show outline.entry: it => context {
    counter(heading).at(it.element.location())
    // it.element.body
  }
  set par(justify: true)
  
  set text(12pt)
  // show raw: set text(12pt)
  set raw(lang: "js")

  set enum(numbering: "(a)")

  show figure.caption: it => context {
    set text(0.8em, fill: luma(100))
    smallcaps[#it.supplement #counter(figure).display()]
    if it.body != [] [: ]
    it.body
  }

  // outline()
  
  // counter(heading).update(-1)
  
  body
}