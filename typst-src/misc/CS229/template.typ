#let make-title(title) = {
  set text(3em)
  title
}


#let MatrixCols(param, count) = $mat(bar, bar, , bar; param(1), param(2), dots.c, param(count); bar, bar, , bar)$

#let MatrixDiag(param, count) = $mat(param(1), , , ; , param(2), , ; , , dots.down, ; , , , param(count))$

#let MatrixRows(param, count) = $mat(bar.h, param(1), bar.h; bar.h, param(2), bar.h; , dots.v, ; bar.h, param(count), bar.h)$

#let project(body, title: "") = {
  set text(font: "New Computer Modern", 12pt)

  show raw.where(block: true): set par(justify: false)
  set raw(lang: "py")
  set text(region: "gb")
  set page(numbering: "1")

  make-title(title)

  show heading.where(level: 1): it => {
    set text(1.5*12pt)
    block[#it
    #v(3mm)
    #place(line(length: 100%))
  ]
  }

  let nums = ("1.", "(a)")

  show math.equation.where(block: true): e => [
    #block(width: 100%, inset: 0em, [
        #set align(center)
        #e
    ])
  ]

  set enum(full: true, numbering: (..args) => {
    let nums = args.pos()
  
    if nums.len() == 1 {
      numbering("1.", nums.at(0))
    } else if nums.len() == 2 {
      numbering("(a)", nums.at(1))
    } else if nums.len() == 3 {
      numbering("i.", nums.last())  
    } else {
      
    }
    
  })

  let col = gray.lighten(80%)

  // show figure.caption.where(kind: raw): it => context {
  //   strong(smallcaps[#it.supplement #it.counter.display(): ])
  //   linebreak()
  //   it.body
  // }

  // show figure.where(kind: raw): it => {
  //   grid(
  //     columns: (1fr, 3%, 2%, 20%), 
  //     // gutter: 2em, 
  //     inset: (y: 3mm),
  //     stroke: (x, y) => if x == 0 or x == 1 {(y: 1pt + luma(200))} else {(:)} + if x == 1 {(right: 1pt + luma(200))} else {(:)},
  //     it.body, [], [],
  //     align(left)[
  //       #it.caption
  //     ]
  //   )
  // }

  let create-raw(txt, froms, tos) = {
    show raw.line: it => {
      set text(1.2em)
      let rendered = false
      for m in range(froms.len()) {
        let from = froms.at(m)
        let to = tos.at(m)
        let k = if it.text == "" { "" } else { it }
        if it.number - 1 >= from and it.number - 1 <= to {
          rendered= true
          if it.number - 1 == from or it.number - 1 == to {
            v(-1em)
          } else if it.number - 1 == from + 1 and it.number - 1 == to - 1 {
            set box(radius: (top: 30%, bottom: 30%))
            box(k, fill: col, width: 100%, outset: (top: 0.6 * 1em, bottom: 0.7em, x: 2mm))
          } else if it.number - 1 == from + 1 {
            set box(radius: (top: 30%))
            box(k, fill: col, width: 100%, outset: (top: 0.6 * 1em, bottom: 0.4em, x: 2mm))
          } else if it.number - 1 == to - 1 {
            set box(radius: (bottom: 30%))
            box(k, fill: col, width: 100%, outset: (top: 0.3 * 1em, bottom: 0.7em, x: 2mm))
          } 
          else {
            box(k, fill: col, width: 100%, outset: (top: 0.3 * 1em, bottom: 0.4em, x: 2mm))
          }
        }
      }
      if not rendered {
        //set text(fill: luma(120))
        it.body
        // it
      }
    }
    raw(lang: "py", txt, block: true)

  }

  let start-ind = "# *** START CODE HERE ***"  
  let end-ind = "# *** END CODE HERE ***"

  show raw.where(lang: "focus"): it => {
    set text(font: "Libertinus Serif")
    let lines = it.text.split("\n")
    let start-indexes = ()
    let end-indexes = ()
    for i in range(lines.len()) {
      if lines.at(i).trim() == start-ind {
        start-indexes.push(i)
      }
      if lines.at(i).trim() == end-ind {
        end-indexes.push(i)
      }
    }
      create-raw(it.text.replace(start-ind, "").replace(end-ind, ""), start-indexes, end-indexes)
  }

  set math.mat(delim: "[") 
  set math.vec(delim: "[")

  set par(justify: true)

  let phi = symbol(
    str(sym.phi.alt),
    ("alt", str(sym.phi))
  )

  body
}