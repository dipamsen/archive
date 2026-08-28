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


  show figure: it => {
    set align(center)
    block(
      above: 1.5em,
      below: 1.8em,
      breakable: true,
      {
        it.body
        v(0.65em)
        if it.caption != none {
          set text(size: 9.5pt, fill: rgb("#333333"))
          set par(justify: false, leading: 0.55em)
          block(
            width: 85%,
            {
              text(
                fill: primary-color,
                weight: "bold",
                size: 9.5pt,
                [#it.supplement #context it.counter.display(it.numbering)]
              )
              [: ]
              it.caption.body
            }
          )
        }
      }
    )
  }

  set figure(numbering: "1")

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

#let disc-box(body) = {
  block(
    width: 100%,
    fill: green.lighten(90%),
    inset: (x: 1em, y: 0.8em),
    stroke: (left: 1pt + green),
    {
      set text(0.9em)
      body
    }
  )
}

#let hl-box(body) = {
  block(
    width: 100%,
    fill: primary-color.lighten(90%),
    inset: (x: 1em, y: 0.8em),
    stroke: (left: 1pt + primary-color),
    {
      body
    }
  )
}


// --- Counter for numbering (one per box type, or shared - your choice) ---
#let theorem-counter = counter("theorem-counter")

// --- Core box function ---
#let theorem-box(
  title: "Theorem",
  color: rgb("#3A0CA3"),
  numbered: true,
  body
) = {
  if numbered { theorem-counter.step() }
  block(
    above: 1.4em,
    below: 1.4em,
    width: 100%,
    breakable: true,
    stroke: (left: 2.5pt + color),
    inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
    fill: color.lighten(96%),
    {
      // Title line
      text(
        fill: color,
        weight: "bold",
        size: 11pt,
        [#title #if numbered [#context theorem-counter.display()]]
      )
      linebreak()
      v(0.3em)
      set text(fill: rgb("#1a1a1a"))
      body
    }
  )
}

// --- Preset variants for common use cases ---
#let theorem(body, title: "Theorem", numbered: true) = theorem-box(
  title: title, color: primary-color, numbered: numbered, body
)

#let definition(body, title: "Definition", numbered: true) = theorem-box(
  title: title, color: rgb("#0C7B93"), numbered: numbered, body
)

#let lemma(body, title: "Lemma", numbered: true) = [
  #theorem-counter.step()
  #text(fill: primary-color, weight: "bold")[#title #context theorem-counter.display():] #body
]

#let important(body, title: "Important") = theorem-box(
  title: title, color: rgb("#C1121F"), numbered: false, body
)

#let example-box(body, title: "Example") = theorem-box(
  title: title, color: rgb("#4C6444"), numbered: false, body
)
