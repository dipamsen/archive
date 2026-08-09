#let algo-counter = counter("algo-line")

#let aline(indent: 0, body) = {
  algo-counter.step()
  set block(below: 0.7em)
  grid(
    columns: (10pt, auto, 1fr),
    column-gutter: 6pt,
    align(right + top)[#context algo-counter.display()],
    h(indent * 1.2em),
    body,
  )
}

#let algorithm(name, params: (), body) = {
  // v(2mm)
  algo-counter.update(0)
  block(width: 100%, breakable: false)[
    #smallcaps(name);(#params.join(", "))
    #body
  ]
  v(2mm)
}

// generic wrappers
#let kw(s) = strong(s)
#let var(s) = math.italic(s)
#let comment(s) = text(fill: rgb("#5a5a5a"), style: "italic")[#h(1em) $triangle.stroked.r$ #s]
#let call(s) = smallcaps(s)

// --- predefined control-flow / statement keywords ---
#let While   = kw[while]
#let For     = kw[for]
#let To      = kw[to]
#let Downto  = kw[downto]
#let By      = kw[by]
#let If      = kw[if]
#let Then    = kw[then]
#let Else    = kw[else]
#let Elseif  = kw[elseif]
#let Repeat  = kw[repeat]
#let Until   = kw[until]
#let Do      = kw[do]
#let Return  = kw[return]
#let Error   = kw[error]
#let And     = kw[and]
#let Or      = kw[or]
#let Not     = kw[not]

// --- predefined operation / structural keywords ---
#let Call       = kw[call]
#let Break      = kw[break]
#let Continue   = kw[continue]
#let New        = kw[new]
#let Nil        = kw[nil]
#let True       = kw[true]
#let False      = kw[false]
#let Swap       = kw[swap]
#let Input      = kw[input]
#let Output     = kw[output]
#let Print      = kw[print]
