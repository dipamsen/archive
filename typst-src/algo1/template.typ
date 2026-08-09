#let infobox(it) = block(
      stroke: (left: (thickness: 2pt, paint: green)),
      fill: green.lighten(80%),
      width: 100%,
      inset: 0.6em
    )[
      #set text(0.9em)
      #it
    ]

#let primary-color = rgb("#8c0000")

#let project(title: "", subtitle: "", body) = {
  set text(11pt, font: "TeX Gyre Pagella")
  set document(title: title, author: "Dipam Sen")

  show math.equation: set text(font: "TeX Gyre Pagella Math")

  set page(footer: context {
    let no = counter(page).get().first()
    [
      #line(length: 100%)
      #v(-0.6em)
      #align(center, [#no])
    ]
  }, header: context {
    let no = counter(page).get().first()
    if no > 1 [
      #title #h(1fr) *#subtitle*
      #v(-0.6em)
      #line(length: 100%, stroke: 2pt)
    ]
  }, margin: (y: 3.2cm, x: 2cm))

  set par(justify: true)

  show figure.caption: it => context {
    set text(0.8em)
    set align(left)
    text(fill: primary-color, strong(it.supplement + [ ] + counter(figure.where(kind: it.kind)).display() + it.separator))
    it.body
  }
  
  block({
    set align(center)
    set text(2.5em, weight: "black")
    title
  }, width: 100%)
  v(1mm)
  block({
    set align(center)
    set text(1.5em, weight: "black")
    subtitle
  }, width: 100%)

  v(2mm)

  block({
    set align(center)
    set text(1.1em)
    [Name: Dipam Sen\ Roll No: 24CS10059]
  }, width: 100%)

  line(length: 100%)

  
  
  body
}