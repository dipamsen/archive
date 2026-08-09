// shared page template, imported by other files — not a standalone doc
#let primary-color = rgb("#3b08c7")


#let project(body, subject: "Subject Name", topic: "Topic Name") = {
  set text(font: "TeX Gyre Pagella")

  set page(
    header: {
      set text(luma(100))
      [#subject #h(1fr) #topic]
      box(line(length: 100%, stroke: 0.5pt))
    },
    footer: context {
      h(1fr)
      counter(page).display()
    }
  )

  show math.equation: set text(font: "TeX Gyre Pagella Math")

  show title: set align(center)
  show title: set text(24pt) 

  set par(justify: true)

  show smallcaps: set text(font: "STIX Two Text")


  show heading: set text(primary-color)
  show title: set text(primary-color)
  
  show figure.caption: it => text(0.8em, luma(50), [Figure: #it.body])
  
  body
}

#let soln-box(body) = {
  block(
    width: 100%,
    fill: primary-color.lighten(90%),
    inset: (x: 1em, y: 0.8em),
    stroke: (left: 1pt + primary-color),
    {
      set text(0.9em)
      body
    }
  )
}