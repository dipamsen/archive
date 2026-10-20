#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.5.2"


#show: project.with(
  subject: "Algorithms II",
  topic: "String Matching"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt
#let bu(x) = math.bold(math.upright(x))

#title[String Matching]

An important feature of text editors is to be able to search for occurrences of a particular string in a text document. Efficient algorithms to solve this problem can greatly improve the performance of the application, particularly if the text document is large.

We first look at an efficient algorithm to solve this problem, due to Knuth, Morris and Pratt; commonly known as the *KMP String Matching algorithm*.

= Setup

Define the *string matching problem* as follows:

*Input*: The text $T[1..n]$ and a pattern $P[1..m]$ ($m <= n$), which are strings over some alphabet $Sigma$ .

*Output*: Find all valid shifts with which $P$ occurs in $T$, i.e. find all $s$ such that $T[s + 1..s + m] = P[1..m]$.


For example, if $T = \""abcabaabcabac"\"$ and $P = \""abaa"\"$, then $s = 3$ is a valid shift, in fact it is the only valid shift.

#let string-match(text-str, patt-str, shifts: none) = cetz.canvas({
  import cetz.draw: *
  if shifts == none {
    shifts = range(0, text-str.len() - patt-str.len() + 1)
  }
  set-style(stroke: 0.6pt)

  let n = text-str.len()
  let m = patt-str.len()

  for i in range(n) {
    rect((i, 0), (i + 1, 1))
    content((i + 0.5, 0.5), text-str.at(i))
  }  
  content((-2, 0.5), $T = $)

  for i in range(shifts.len()) {
    let y = - (i + 1) * 1.8
    let s = shifts.at(i)
    let mismatch-found = false

    content((-2, y + 0.5), text(0.8em)[$s = #s$])
    
    for i in range(m) {
      let px = s + i
      let cx = px + 0.5
      
      if not mismatch-found {
        if text-str.at(px) == patt-str.at(i) {
          rect((px, y), (px + 1, y + 1), stroke: green)
          content((cx, y + 0.5), text(fill: green, patt-str.at(i)))
          line((cx, y + 1), (cx, y + 1.7), stroke: green)
        } else {
          mismatch-found = true
          rect((px, y), (px + 1, y + 1), stroke: red)
          content((cx, y + 0.5), text(fill: red, patt-str.at(i)))
          
          line(
            (cx, y + 1), 
            (cx + 0.2, y + 1.3), 
            (cx - 0.2, y + 1.4), 
            (cx, y + 1.7), 
            stroke: red
          )
        }
      } else {
        on-layer(-1, { rect((px, y), (px + 1, y + 1), stroke: luma(200))
        content((cx, y + 0.5), text(fill: luma(200), patt-str.at(i))) })
      }
    }
  }
}, length: 0.5cm)

#figure(
  string-match("abcabaabcabac", "abaa", shifts: (3,)),
  caption: [An example instance of the string matching problem]
)

= Naive Algorithm

As per the definition, we can try out all shift positions, and check if there is a match.

#algorithm("Naive-String-Match", params: ([$T[1..n]$, $P[1..m]$],))[
  #aline[#For $i$ from $1$ to $n - m + 1$]
  #aline(indent: 1)[#If $T[i..i + m - 1]$ matches $P[1..m]$]
  #aline(indent: 2)[*output* $i - 1$]
]

This achieves our goal (is correct by definition). It takes $O((n - m + 1) m)$ time, which is tight in the worst case. Some worked examples are shown below.

#figure(
  string-match("aaacabcab", "abca"),
  caption: [Naive string matching for $T = $"aaacabcab", $P = $"abca"]
) <ex>

As shown in @ex, for each shift position $s$, we compare character by character the pattern and the text. If we find a mismatch, we stop and try the next shift. If we match the entire pattern then an occurrence has been found and we output that particular shift value.

How can we improve the running time of the algorithm?

#figure(
  grid(columns: 2, gutter: 5em, string-match("abbabbabbb", "abbb"), string-match("aaaaaaaaab", "aaab")),
  caption: [Naive string matching for (a) $T = $"abbabbabbb", $P = $"abbb" (b) $T = $"aaaaaaaaab", $P = $"aaab" ]
) <redun>

In @redun, we see two kinds of redundancies that we may try to optimise on in the Naive algorithm. 
In (a), shift $s = 0$ fails after matching $P[1..3] = "abb"$. So we know $T[1..3] = "abb"$. Shifts $1$ and $2$ would need $T[2]$ and $T[3]$ to equal $P[1] = "a"$, but both are $"b"$. These shifts cannot possibly be valid, yet the naive algorithm tries them anyway.

In (b), shift $s = 0$ fails after matching $P[1..3] = "aaa"$. The next shift cannot be ruled out, but we already know $T[2..3] = "aa"$, which matches $P[1..2]$. The naive algorithm still goes back and re-compares these characters.

The trick that we can use to reduce the number of comparisons comes from this fact: *when a mismatch occurs after matching $q$ characters, the text we just read is known to be exactly $P[1..q]$.* So where to search from next depends only on the pattern, not on the text. This lets us
- skip shifts that the pattern shows cannot be valid, and
- never move backwards in $T$, so each text character is read only once.

= Observations

Suppose we are checking shift $s$ and the first $q$ characters of the pattern match, but then we hit a mismatch at $T[i]$. So we know exactly two things:

- $T[s+1..i-1] = P[1..q]$, and
- $T[i] != P[q+1]$.

#align(center)[
  With this knowledge, what is the smallest shift $s' > s$ that could still be valid?
]

#let abstract-match = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.6pt)


  rect((0, 0), (16, 1))
  content((-2, 0.5), $T = $)

  let i = 7
  content((i + 0.5, 1.5), $i$)
  rect((i, 0), (i + 1, 1))

  let y = -1.8
  let s = 5

  rect((2, y), (i, y + 1), stroke: green, fill: green.lighten(80%))
  for j in range(2, i) {
    line((j + 0.5, y + 1), (j + 0.5, y + 1.8), stroke: green)
  }
  rect((i + 1, y), (10, y + 1), stroke: luma(200))
  rect((i, y), (i + 1, y + 1), stroke: red, fill: red.lighten(80%))
  let cx = i + 0.5
  line(
    (cx, y + 1), 
    (cx + 0.2, y + 1.35), 
    (cx - 0.2, y + 1.45), 
    (cx, y + 1.8), 
    stroke: red
  )

  line((0, y + 0.5), (2, y + 0.5), mark: (end: ">", fill: black, scale: 0.8), name: "s")
  content((rel: (0, 0.2), to: "s"), text(0.8em)[$s$], anchor: "south")

  line((2, y + 0.3), (i, y + 0.3), mark: (symbol: "stealth", scale: 0.7, fill: luma(100)), stroke: luma(100), name: "q")
  content((rel: (0, 0.4), to: "q"), text(luma(100), 0.8em)[$q$])

  let y = 2 * -1.8

  rect((4, y), (i, y + 1), stroke: green, fill: green.lighten(80%))
  for j in range(4, i) {
    line((j + 0.5, y + 1), (j + 0.5, y + 1.8), stroke: green)
  }
  rect((i + 1, y), (12, y + 1), stroke: luma(200))
  rect((i, y), (i + 1, y + 1))

  line((0, y + 0.5), (4, y + 0.5), mark: (end: ">", fill: black, scale: 0.8), name: "s'")
  content((rel: (0, 0.2), to: "s'"), text(0.8em)[$s'$], anchor: "south")

  line((4, y + 0.3), (i, y + 0.3), mark: (symbol: "stealth", scale: 0.7, fill: luma(100)), stroke: luma(100), name: "q'")
  content((rel: (0, 0.4), to: "q'"), text(luma(100), 0.8em)[$k$])

  content((16, y + 0.5), text(0.8em)[$=>P[1..k] = P[q - k + 1..q]$])

}, length: 0.6cm)

#figure(abstract-match, caption: [Key observation for the KMP algorithm]) <obs>

@obs shows this situation. Suppose $s'$ is a valid shift, and let $k$ be the number of pattern characters that correspond to the part of the text before $i$.

For $s'$ to be valid, these $k$ characters must match the last $k$ characters in the text before $i$. But, we know that these $k$ characters are the ones which were earlier matched by the last part of $P[1..q]$. 

Thus, by the diagram we can conclude this: For $s'$ to be a valid shift, we require

$
  P[1..k] = P[q - k + 1..q]
$

In other words, $P[1..k]$ is a proper prefix of $P[1..q]$, which is also a suffix of $P[1..q]$. This is a necessary condition, so we can skip those shifts which do not follow this.

We want the smallest such $s'$ (as we don't want to skip over any valid shift); this means we want the largest such $k$. So, we need to compute *the longest proper prefix of $P[1..q]$ which is also its suffix*. Notice that this quantity does not involve $T$ so we can precompute it for every $q$. Also, after shifting to $s'$, we already know that the first $k$ characters match, so we resume the comparison from $T[i]$ and never move back in the text.

== LPS Table

#let lps = "LPS"

Let the pattern be $P[1..m]$. Define the *longest prefix-suffix* $lps[q]$ ($1 <= q <= m$) as the *length of the longest proper prefix of $P[1..q]$ which is also a suffix of it.* ($0 <= lps[q] < q$)

Consider the pattern $P = $"ababaca". We can compute the LPS table for this pattern as shown in @lps. For instance, $lps[5] = 3$, since for the string $P[1..5] = $"ababa", its longest proper prefix-suffix is "aba", whose length is 3. 
Note that $lps[1] = 0$ always.

#let lps-tab = table(
  columns: 8,
  stroke: none,
  align: right,
  [$q$], table.vline(stroke:0.5pt), ..range(1, 8).map(i => [#i]),
  table.hline(stroke:0.5pt),
  [$P[q]$], ..("a","b","a","b","a","c","a"),
  [$lps[q]$], [0], [0], [1], [2], [3], [0], [1],
)

#figure(lps-tab, caption: [LPS table for $P = $"ababaca"], kind: image) <lps>

Suppose we have matched the first $5$ characters of $P$, but we get a mismatch at $T[i]$ with $P[6]$. *What are all the valid shifts we need to check ahead?* By @obs, the only shifts that can still be valid are those for which a prefix of $P[1..5] = $"ababa" is also a suffix of it. These are, from longest to shortest, "aba", "a" and $epsilon$ (the empty string), and they correspond to the shifts in @chain. Each of them is consistent with the part of $T$ we have already matched.

#let compute-lps(p) = {
  let f = (0,)  // f.at(q - 1) = lps[q]
  let k = 0
  for q in range(1, p.len()) {
    while k > 0 and p.at(k) != p.at(q) { k = f.at(k - 1) }
    if p.at(k) == p.at(q) { k += 1 }
    f.push(k)
  }
  f
}

#let lps-chain(p, q) = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.6pt)
  let f = compute-lps(p)
  let ks = (q,)
  while ks.last() > 0 { ks.push(f.at(ks.last() - 1)) }

  rect((-1, 1.8), (7, 2.8))

  content((-2.5, 2.3), $T = $)
  content((-0.5, 2.3), $dots$)
  content((6.5, 2.3), $dots$)
  for i in range(6) {
    rect((i, 1.8), (i + 1, 2.8))
    content((i + 0.5, 2.3), "ababa ".at(i))
  }

  for (r, k) in ks.enumerate() {
    let y = -r * 1.8
    let nxt = if k > 0 { f.at(k - 1) } else { 0 }
    if k > 0 { content((-1.5, y + 0.5), $P[1..#k]$) }
    if k == 0 {
      content((q - 0.5, y + 0.5), $epsilon$)
    }
    for i in range(k) {
      let x = q - k + i
      let shaded = i >= k - nxt
      rect((x, y), (x + 1, y + 1), fill: if shaded { luma(220) } else { none })
      content((x + 0.5, y + 0.5), p.at(i))
      if shaded { line((x + 0.5, y), (x + 0.5, y - 0.8)) }
      if r == 0 { line((x + 0.5, y + 1), (x + 0.5, y + 1.8), stroke: green) }
    }
    rect((q, y), (q + 1, y + 1), stroke: luma(200))
    if r == 0 {
      let cx = q + 0.5
      line(
        (cx, y + 1), 
        (cx + 0.2, y + 1.3), 
        (cx - 0.2, y + 1.4), 
        (cx, y + 1.8), 
        stroke: red
      )
    }
    if k > 0 { content((q + 4, y + 0.5), $lps[#k] = #nxt$) }
  }
  line((q, 1.4), (q, -(ks.len() - 1) * 1.8 - 0.4), stroke: (dash: "dashed"))
}, length: 0.6cm)

#figure(lps-chain("ababaca", 5), caption: [All proper prefix-suffixes of $P[1..5]$]) <chain>

All of this information is actually encoded in the LPS table itself: We can get all the shift positions by getting the length of each valid prefix-suffix by iterating on the $lps$ array.

*Claim*: The lengths of the proper prefix-suffixes of $P[1..q]$ are exactly $lps[q], lps[lps[q]], dots, 0$.

_Proof._ Write $lps^((j))[q]$ for $lps$ applied $j$ times to $q$.

($supset.eq$) Note that a proper prefix-suffix of $P[1..k]$ is also a proper prefix-suffix of $P[1..q]$, if $k$ is a length of a prefix-suffix of $P[1..q]$. Since $P[1..lps[q]]$ is a proper prefix-suffix of $P[1..q]$, so every $P[1..lps^((j))[q]]$ is also a proper prefix-suffix of $P[1..q]$, by induction on $j$.

($subset.eq$) Let $P[1..k]$ be a proper prefix-suffix of $P[1..q]$, and let $k' = lps[q]$, so $k <= k'$. If $k = k'$ we are done. Otherwise $k < k'$, and both $P[1..k]$ and $P[1..k']$ are suffixes of $P[1..q]$, so $P[1..k]$ is a suffix of $P[1..k']$. It is also a prefix of $P[1..k']$, so it is a proper prefix-suffix of $P[1..k']$. Again, an inductive argument shows $k$ appears in the sequence. #h(1fr) $square$

Therefore, after a mismatch at $T[i] != P[q + 1]$, we will shift by $q - lps[q]$ (equivalently, the matched length which was earlier $q$ will now become $k = lps[q]$) to get the next possible valid shift, and again try matching $T[i]$, and continue on. Thus we can formulate the KMP algorithm.

#let shift-fig = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.6pt)

  let T = "acababaababaca"   // T[13..26] of the big example
  let P = "ababaca"
  let n = T.len()
  let m = P.len()

  // the text (drawn once)
  for i in range(n) {
    rect((i, 0), (i + 1, 1))
    content((i + 0.5, 0.5), T.at(i))
  }
  content((-2, 0.5), $T = $)

  // ---------- shift s: q = 5 characters match, then a mismatch ----------
  let s = 2
  let q = 5
  let y = -1.8

  for j in range(m) {
    let px = s + j
    let cx = px + 0.5
    if j < q {
      rect((px, y), (px + 1, y + 1), stroke: green)
      content((cx, y + 0.5), text(fill: green, P.at(j)))
      line((cx, y + 1), (cx, y + 1.7), stroke: green)
    } else if j == q {
      rect((px, y), (px + 1, y + 1), stroke: red)
      content((cx, y + 0.5), text(fill: red, P.at(j)))
      line((cx, y + 1), (cx + 0.2, y + 1.3), (cx - 0.2, y + 1.4), (cx, y + 1.7), stroke: red)
    } else {
      on-layer(-1, { rect((px, y), (px + 1, y + 1), stroke: luma(200))
      content((cx, y + 0.5), text(fill: luma(200), P.at(j))) })
    }
  }

  line((0, y + 0.5), (s, y + 0.5), mark: (end: ">", fill: black, scale: 0.8), name: "s")
  content((rel: (0, 0.2), to: "s"), text(0.8em)[$s$], anchor: "south")

  line((s, y - 0.2), (s + q, y - 0.2),
    mark: (symbol: "stealth", scale: 0.7, fill: black), name: "q")
  content((rel: (0, -0.4), to: "q"), text(0.8em)[$q$])



  // ---------- shift s' = s + (q - k): first k = 3 characters already match ----------
  let k = 3
  let s2 = s + q - k
  let y = -5

  for j in range(m) {
    let px = s2 + j
    let cx = px + 0.5
    if j < k {
      rect((px, y), (px + 1, y + 1), stroke: green)
      content((cx, y + 0.5), text(fill: green, P.at(j)))
      line((cx, y + 1), (cx, y + 1.7), stroke: green)
    } else {
      on-layer(-1, { rect((px, y), (px + 1, y + 1), stroke: luma(200))
      content((cx, y + 0.5), text(fill: luma(200), P.at(j))) })
    }
  }

  line((0, y + 0.5), (s2, y + 0.5), mark: (end: ">", fill: black, scale: 0.8), name: "s2")
  content((rel: (0, 0.2), to: "s2"), text(0.8em)[$s' = s + 2$], anchor: "south")

  line((s2, y - 0.2), (s2 + k, y - 0.2),
    mark: (symbol: "stealth", scale: 0.7, fill: black), name: "k")
  content((rel: (0, -0.5), to: "k"), text(0.8em)[$k = lps[q]$])
}, length: 0.6cm)

#figure(
  shift-fig,
  caption: [Shift $s$ matches $q = 5$ characters of $P$ and then mismatches. The next shift we should try is $s' = s + (q - k)$, where $k = "LPS"[q] = 3$.]
) <shift-example>

#pagebreak()

= The Matching Algorithm

The following is the matching algorithm of KMP, given we know how to compute the LPS table for $P$ (which we will discuss shortly).

#algorithm("KMP-String-Match", params: ([$T[1..n]$, $P[1..m]$],))[
  #aline[#lps $<-$ #call("Compute-LPS");($P$)]
  #aline[$q <- 0$]
  #aline[#For $i$ from $1$ to $n$]
  #aline(indent: 1)[#While $q > 0$ and $P[q + 1] != T[i]$]
  #aline(indent: 2)[$q <- lps[q]$]
  #aline(indent: 1)[#If $P[q + 1] = T[i]$]
  #aline(indent: 2)[$q <- q + 1$]
  #aline(indent: 1)[#If $q = m$]
  #aline(indent: 2)[*output* $i - m$]
  #aline(indent: 2)[$q <- lps[q]$]
]
#let kmp-match(text-str, patt-str) = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.6pt)

  let n = text-str.len()
  let m = patt-str.len()

  // LPS table: f.at(k - 1) = LPS[k]
  let f = (0,) * m
  let k = 0
  for j in range(1, m) {
    while k > 0 and patt-str.at(j) != patt-str.at(k) { k = f.at(k - 1) }
    if patt-str.at(j) == patt-str.at(k) { k += 1 }
    f.at(j) = k
  }

  // the text
  for i in range(n) {
    rect((i, 0), (i + 1, 1))
    content((i + 0.5, 0.5), text-str.at(i))
  }
  content((-2, 0.5), $T = $)

  // one row per iteration i of the for loop
  let q = 0
  for i in range(n) {
    let y = -(i + 1) * 1.8
    let q0 = q                       // q at the start of the iteration
    let s = i - q0                   // P[q0+1] sits under T[i]
    let ok = patt-str.at(q0) == text-str.at(i)

    content((-2, y + 0.5), text(0.8em)[$i = #(i + 1)$])

    for j in range(m) {
      let px = s + j
      if px >= n { break }
      let cx = px + 0.5

      if j < q0 {
        rect((px, y), (px + 1, y + 1), stroke: green)
        content((cx, y + 0.5), text(fill: green, patt-str.at(j)))
        line((cx, y + 1), (cx, y + 1.7), stroke: green)
      } else if j == q0 {
        if ok {
          rect((px, y), (px + 1, y + 1), stroke: green + 1.4pt)
          content((cx, y + 0.5), text(fill: green, strong(patt-str.at(j))))
          line((cx, y + 1), (cx, y + 1.7), stroke: green)
        } else {
          rect((px, y), (px + 1, y + 1), stroke: red + 1.4pt)
          content((cx, y + 0.5), text(fill: red, strong(patt-str.at(j))))
          line((cx, y + 1), (cx + 0.2, y + 1.3), (cx - 0.2, y + 1.4), (cx, y + 1.7), stroke: red)
        }
      } else {
        on-layer(-1, { rect((px, y), (px + 1, y + 1), stroke: luma(200))
        content((cx, y + 0.5), text(fill: luma(200), patt-str.at(j))) })
      }
    }

    // run the real iteration to get the next q, and build the label
    let path = (q,)
    while q > 0 and patt-str.at(q) != text-str.at(i) {
      q = f.at(q - 1)
      path.push(q)
    }
    let label = path.map(str).join(" ⇒ ")
    if patt-str.at(q) == text-str.at(i) {
      q += 1
      label += " → " + str(q)
    }
    let lbl = [$q$: #label]
    if q == m {
      q = f.at(q - 1)
      label += " ⇒ " + str(q)
      lbl = [$q$: #label \ *match at #(i + 1 - m)*]
    }
    content((n + 1, y + 0.5), text(0.8em, lbl), anchor: "west")
  }
}, length: 0.4cm)


We scan $T$ once from left to right and keep a number $q$, the length of the prefix of the pattern we are currently matching. Precisely, at the start of every iteration $i$, we have the *invariant*:

#align(center)[
  $q$ is the length of the longest prefix of $P$ with $q < m$ that is a suffix of $T[1..i-1]$.
]

On each iteration:
- [Lines 4-5] If $T[i]$ is a mismatch, it can't extend the current matched $P[1..q]$. We try other shifts of the pattern which are consistent with what we have matched, by iterating over $lps[q], lps[lps[q]], ...$ till we find a match or hit 0.
- [Lines 6-7] If we managed to match $T[i]$, then the match grows by one character.
- [Lines 8-10] If $q = m$, we have found a full match, so output the result. Then, we go to the next possible valid shift ($q <- lps[q]$) and continue.

@trace shows a full worked example of the algorithm.


== Time Complexity

Let's discuss the time complexity of the matching algorithm (other than that of computing the LPS array). We will show that the running time is $Theta(n)$. The only tricky part is showing that the #While loop of lines 4-5 executes $O(n)$ times altogether, which we show by aggregate analysis.

We know that $lps[q] < q$, so in each iteration of the #While loop, $q$ must strictly decrease. On each iteration of the outer #For loop, $q$ can increase at most once, on line 7. So, the value of $q$ can never exceed $n$ (since $q$ starts off at $0$ and there are $n$ iterations of the for loop). Then it follows, that the total number of iterations of the #While loop can not exceed $n$, since $q$ never becomes negative (why?). Thus, the overall running time of the matching algorithm (except LPS computation) is $Theta(n)$, i.e. linear time.


#figure(kmp-match("abababacababacababaababacacb", "ababaca"), caption: [
  A worked out example of the KMP algorithm, for $T = $"abababacababacababaababacacb" and $P = $"ababaca". Refer to the LPS table of $P$ in @lps. On the right, changes to $q$ show how the matching and shifts proceed. $->$ represents an increment to $q$, and $=>$ represents an update of $q$ to $lps[q]$.

]) <trace>

== Correctness

We show that the invariant is maintained. Suppose it holds at the start of iteration $i$. At the end of this iteration we want $q$ to be the length of the longest prefix of $P$ which is a suffix of $T[1..i]$. Let this value be $k + 1$, so $P[k + 1] = T[i]$. Then, it should be the case that $P[1..k]$ is a suffix of $T[1..i - 1]$. By the invariant and the claim, this means $k$ should be one of $q, lps[q], lps[lps[q]], ..., 0$. We visit each such possible value in the while loop in decreasing order and stop if we can match $T[i]$, thus we get the new longest match, hence the invariant holds. If we couldn't match $T[i]$ and hit $0$, then the new $q$ is $0$. If we are able to match $m$ characters, then we output the match and then restore the invariant by setting $q <- lps[q]$.

#let abstract-correct = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.6pt)

  let i = 9

  // the text
  rect((0, 0), (16, 1))
  content((-2, 0.5), $T = $)
  content((i + 0.5, 1.5), $i$)
  rect((i, 0), (i + 1, 1))

  // (start of matched block, does P[len+1] match T[i]?, length label, right-hand note)
  let rows = (
    (3, false, $q$,  [$P[q + 1] != T[i]$], []),
    // (5, false, $k'$, [$P[k' + 1] != T[i]$], [$lps[q] = k'$]),
    (7, true,  $k$,  [$P[k + 1] = T[i] =>$ next $q = k + 1$], [$k =lps^((j)) [q]$]),
  )

  for (r, row) in rows.enumerate() {
    let (start, ok, len-label, note, note2) = row
    let y = -(r + 1) * 1.8
    let cx = i + 0.5
    let col = if ok { green } else { red }

    // matched part P[1..len], ending at T[i-1]
    rect((start, y), (i, y + 1), stroke: green, fill: green.lighten(80%))
    for j in range(start, i) {
      line((j + 0.5, y + 1), (j + 0.5, y + 1.8), stroke: green)
    }

    // rest of the pattern, not yet compared
    rect((i + 1, y), (i + 4, y + 1), stroke: luma(200))

    // the cell compared with T[i]
    rect((i, y), (i + 1, y + 1), stroke: col, fill: col.lighten(80%))
    if ok {
      line((cx, y + 1), (cx, y + 1.8), stroke: green)
    } else {
      line((cx, y + 1), (cx + 0.2, y + 1.35), (cx - 0.2, y + 1.45), (cx, y + 1.8), stroke: red)
    }

    // length arrow
    let nm = "len" + str(r)
    line((start, y + 0.3), (i, y + 0.3),
      mark: (symbol: "stealth", scale: 0.7, fill: luma(100)),
      stroke: luma(100), name: nm)
    content((rel: (0, 0.4), to: nm), text(luma(100), 0.8em)[#len-label])

    content((15.5, y + 0.5), text(0.8em, note), anchor: "west")
    content((1, y + 0.5), text(0.8em, note2), anchor: "east")
  }
}, length: 0.6cm)

#figure(
  abstract-correct,
  caption: [Maintaining the invariant. $P[1..q]$ is the longest prefix of $P$ (with $q < m$) that is a suffix of $T[1..i-1]$. We want the longest such prefix which can be extended so that $T[i]$ is also matched.]
) <correct>


= Computing the LPS table

It turns out that computing the LPS values is very similar to the matching algorithm itself: instead of matching $P$ with $T$, we match $P$ with itself.


#algorithm("Compute-LPS", params: ([$P[1..m]$],))[
  #aline[$lps[1] <- 0$]
  #aline[$k <- 0$]
  #aline[#For $q$ from $2$ to $m$]
  #aline(indent: 1)[#While $k > 0$ and $P[k + 1] != P[q]$]
  #aline(indent: 2)[$k <- lps[k]$]
  #aline(indent: 1)[#If $P[k + 1] = P[q]$]
  #aline(indent: 2)[$k <- k + 1$]
  #aline(indent: 1)[$lps[q] <- k$]
  #aline[#Return #lps]
]

In each iteration of the for loop, $q$ is the index in $P$ for which $lps$ is to be computed, and as an invariant, at the start of each iteration $q$, we have
#align(center)[
  $k = lps[q - 1]$
]
In the iteration, we try to match $P[q]$ with $P[k + 1]$ (so as to extend the previous match). If it doesn't work, we shrink $k$ to the next possible value, and continue doing so until we are able to match $P[q]$.

See @lps-trace for an example of an LPS table computed for a pattern.


#let lps-trace(p) = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.6pt)

  let m = p.len()

  // LPS table (0-based storage: f.at(j) = LPS[j + 1]), computed as we go
  let f = (0,) * m
  let k = 0

  // the pattern, acting as the text
  for i in range(m) {
    rect((i, 0), (i + 1, 1))
    content((i + 0.5, 0.5), p.at(i))
  }
  content((-2, 0.5), $P = $)

  // one row per iteration q = 2..m  (j = q - 1 is the 0-based index)
  for j in range(1, m) {
    let y = -j * 1.8
    let k0 = k                       // k at the start of the iteration
    let s = j - k0                   // P[k0+1] sits under P[q]
    let ok = p.at(k0) == p.at(j)

    content((-2, y + 0.5), text(0.8em)[$q = #(j + 1)$])

    for t in range(m) {
      let px = s + t
      if px >= m { break }
      let cx = px + 0.5

      if t < k0 {
        // already matched in earlier iterations
        rect((px, y), (px + 1, y + 1), stroke: green)
        content((cx, y + 0.5), text(fill: green, p.at(t)))
        line((cx, y + 1), (cx, y + 1.8), stroke: green)
      } else if t == k0 {
        // the comparison P[k+1] vs P[q] made at the start
        if ok {
          rect((px, y), (px + 1, y + 1), stroke: green + 1.4pt)
          content((cx, y + 0.5), text(fill: green, p.at(t)))
          line((cx, y + 1), (cx, y + 1.8), stroke: green)
        } else {
          rect((px, y), (px + 1, y + 1), stroke: red + 1.4pt)
          content((cx, y + 0.5), text(fill: red, p.at(t)))
          line((cx, y + 1), (cx + 0.2, y + 1.35), (cx - 0.2, y + 1.45), (cx, y + 1.8), stroke: red)
        }
      } else {
        on-layer(-1, { rect((px, y), (px + 1, y + 1), stroke: luma(200))
        content((cx, y + 0.5), text(fill: luma(200), p.at(t))) })
      }
    }

    // run the real iteration, building the label
    let label = str(k)
    while k > 0 and p.at(k) != p.at(j) {
      k = f.at(k - 1)
      label += " ⇒ " + str(k)
    }
    if p.at(k) == p.at(j) {
      k += 1
      label += " → " + str(k)
    }
    f.at(j) = k
    let lbl = [$k$: #label \ $"LPS"[#(j + 1)] = #k$]
    content((m + 1, y + 0.5), text(0.8em, lbl), anchor: "west")
  }
}, length: 0.6cm)

#figure(
  grid(columns: 2, gutter: 3em, align: horizon, lps-trace("ababaca"), lps-tab),
  caption: [Computing the LPS table for $P = $"ababaca"], kind: image
) <lps-trace>


== Correctness

Suppose that $lps[j]$ for all $j < q$ has been computed correctly, and at the start of the $q$th iteration, $k = lps[q - 1]$. We wish to find $lps[q]$, i.e. the length of the longest prefix-suffix of $P[1..q]$. Call this value $k' + 1$. Then, $P[k' + 1] = P[q]$ and $P[1..k']$ must be a suffix of $P[1..q - 1]$. By the claim, this means $k' in {k, lps[k], lps[lps[k]], ..., 0}$. Thus, we iterate over each of these possibilities in decreasing order of length and stop if we are able to match $P[q]$. At this point, $k' + 1$ is the length of the longest prefix-suffix of $P[1..q]$, so we store it. If we hit $0$, then no proper prefix-suffix of $P[1..q]$ exists, so we store $0$.



== Time Complexity

By a similar aggregate analysis, we can show that this procedure runs in $Theta(m)$ time.

In total, we get an overall time complexity of the KMP algorithm to be $Theta(m + n)$, where $Theta(m)$ is preprocessing time and $Theta(n)$ is the actual time for matching a string.

= Summary

We have discussed about the String Matching problem, first discussing the naive algorithm which runs in $O((n - m + 1) m)$ time. Then we made some specific observations, which we used to describe the KMP string matching algorithm which runs in total $Theta(n + m)$ time.


/**

0. define the problem
1. naive matching
  - example
  - complexity
2. observations
3. define LPS
4. how to find matches using lps
5. time complexity, correctness
6. how to compute lps, time complexity, correctness
**/

#pagebreak()

= Problems and Solution Sketches

8. [CLRS] Give a linear-time algorithm to determine whether a text $T$ is a cyclic rotation of another string $T'$.

#soln-box[
  First, check if $|T| = |T'|$. Then, use the KMP algorithm to check if $T$ occurs in the string $T' || T'$. If so, then $T$ and $T'$ are cyclic rotations of each other. (Prove)
]
