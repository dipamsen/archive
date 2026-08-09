#show heading: set text(font: "New Computer Modern Sans")
#set page(margin: 1.8cm)
#import "@preview/numbly:0.1.0": numbly
#set enum(full: true, numbering: numbly(
  "({1:a})",
  "{2:1}.",
  "{3:i})"
))

#set text(font: "New Computer Modern Sans", hyphenate: false)
#set par(justify: true)

#let sans(body) = {
  set text(font: "New Computer Modern Sans")
  body
}

#show regex("Problem \d+"): strong

#let blank = "␣"
#let eps = sym.epsilon

#let up = math.upright
#let rm = $class("normal", tack.l)$
#let lm = $class("normal", tack.r)$
#let nx = $-->^1_M$
#let nx(m) = $-->^#m;_M$
#let red = $scripts(<=)_upright(m)$
#let phi = sym.phi.alt

// #set enum(numbering: "(a)1.")

// #set table.cell(stroke: (y: 1pt, x: none))

#table(columns: (13%, 1fr), align: (right, left), inset: (y: 1em), stroke: (x, y) => {
  if y > 0 { (y: 1pt, x: none) }
})[][

= Tutorial 4: Undecidability, Reducibility, Rice's Theorems


][#sans[Problem 1]][
    For a language $L$ over the alphabet ${0, 1}$, define the language
    $
    "HALF"(L) = { x | x in Sigma^*, "and there exists" y in Sigma^* "such that" |x| = |y| "and" x y in L}
    $
    Prove/Disprove the following statements.
    + If $L$ is R.E., then $"HALF"(L)$ must be R.E.
    + If $L$ is recursive, then $"HALF"(L)$ must be recursive.
][#sans[Solution]][
  + #[Let $M$ be a DTM recognising $L$.

  Create an NTM $N$ for $"HALF"(L)$:

  $N$ on input $x$:
  - Nondeterministically choose $y in Sigma^*$ such that $|x| = |y|$.
  - Simulate $M$ on $x y$.
  - If $M$ accepts, accept $x$.
  Thus, $"HALF"(L)$ is R.E.
  ]
  + #[
    Let $M$ be a total TM deciding $L$.

    Create a total TM $N$ for $"HALF"(L)$:

    $N$ on input $x$:
    - Check for all $y in Sigma^*$ and $|x|= |y|$:
      - Simulate $M$ on $x y$.
    - If $M$ accepts in any of the cases, accept $x$. Otherwise, reject.
  Thus, $"HALF"(L)$ is recursive.
  ]#h(1fr)$square$
][
  #sans[Problem 2]][
  Prove that the following language is not recursive:
  $
  "WB" = {M \# w | M "writes the blank symbol in some step on input" w}
  $
][#sans[Solution]][
  We show a reduction $"HP" red "WB"$:
  $
  N \# v|-> M \# w\
  N "halts on" v <==> M "writes the blank symbol in some step on" w
  $

  $M$ on input $w$:
  - Simulate $N$ on $v$.
    - Use a different symbol if $N$ tries to write the blank symbol.
  - If $N$ halts, write the (actual) blank symbol on the input.

  Thus, $"WB"$ is not recursive.#h(1fr)$square$
][#sans[Problem 3]][
  Prove:
  + $E_2026 = {M | M "halts on exactly" 2026 "inputs"}$ is not R.E.
  + $"AL"_2026 = {M | M "halts on at least" 2026 "inputs"}$ is R.E. but not recursive.
  
][#sans[Solution]][
  + #[
    Show a reduction $dash("HP") red E_2026$:
    $
    M \# w |-> N\
    M "does not halt on" w <==> N "halts on exactly" 2026 "inputs"
    $ #h(1fr)

    $N$ on input $v$:
    - If $v = 0^k$, $k < 2026$, accept.
    - Simulate $M$ on $w$.
    - If $M$ halts, accept.
    Denote by $L_H (N)$, the set of all inputs on which $N$ halts. Then,
    $
    L_H (N) = cases(Sigma^* quad &"if" M "halts on" w, {0^k | k < 2026} &"if" M "does not halt")
    $

    which satisfies the reduction constraint.

    Thus, $E_2026$ is not R.E. 
  ]   
  + #[
    Create a TM $N$ recognising $"AL"_2026$:
    
    $N$ on input $M$:
    - Simulate $M$ on all inputs on a time sharing basis.
    - If $M$ halts on at least 2026 inputs, accept.
    Thus, $"AL"_2026$ is R.E.

    Show a reduction from $"HP" red "AL"_2026$:
    $
    M \# w |-> N\
    M "halts on" w <==> N "halts on at least" 2026 "inputs"
    $

    $N$ on input $v$:
    - Simulate $M$ on $w$.
    - If $M$ halts, accept $v$.
    Here,
    $
    L_H (N) = cases(Sigma^* quad &"if" M "halts on" w, phi quad &"otherwise")
    $
    Thus, the reduction is correct, and $"AL"_2026$ is not recursive.
  ]#h(1fr)$square$
][#sans[Problem 4]][
  Let $k$ be a constant positive integer. Consider the following languages:
  - $"LE"_k = {M | "DTM" M "loops on at most" k "inputs"}$
  - $"LT"_k = {M | "DTM" M "loops on less than" k "inputs"}$
  - $"GE"_k = {M | "DTM" M "loops on at least" k "inputs"}$
  - $"GT"_k = {M | "DTM" M "loops on more than" k "inputs"}$
  Prove that all these languages are non-R.E. and non-co-R.E.
  
][#sans[Solution]][

  First note that $dash("LE"_k) = "GT"_k$, $dash("LT"_k) = "GE"_k$. So we only need to show:
  - $dash("HP") red "LE"_k$ and $dash("HP") red "GT"_k$ ($"LE"_k$ and $"GT"_k$ are non-R.E. and non-co-R.E.)
  - $dash("HP") red "LT"_k$ and $dash("HP") red "GE"_k$ ($"LT"_k$ and $"GE"_k$ are non-R.E. and non-co-R.E.)
  
  $dash("HP") red "LE"_k$:
  $
  M \# w |-> N\
  M "does not halt on" w <==> N "loops on at most" k "inputs" $$
  M "does not halt on" w &=> N "loops on at most" k "inputs"\
  M "halts on" w &=> N "loops on more than" k "inputs"\
  $
  $N$ on input $v$:
  - Simulate $M$ on $w$ for $|v|$ steps.
  - If $M$ did not halt yet, accept (and halt). Otherwise, loop.

  Let $K'$ denote the set of strings on which $N$ loops.

  If $M$ does not halt on $w$, then $K' = phi$. If $M$ halts on $w$ in $s$ steps, then, $K' = {v | |v| >= s}$. So,
  $
  |K'| = cases(0 quad &"if" M "does not halt on" w, oo quad &"if" M "halts on" w)
  $
  which satisfies our reduction constraint. Hence, $dash("HP") red "LE"_k$.

  (The same construction also shows $dash("HP") red "LT"_k$.)

  $dash("HP") red "GT"_k$:
  $
  M \# w |-> N\
  M "does not halt on" w <==> N "loops on more than" k "inputs" $$
  M "does not halt on" w &=> N "loops on more than" k "inputs"\
  M "halts on" w &=> N "loops on at most" k "inputs"\
  $

  $N$ on input $v$:
  - Simulate $M$ on $w$.
  - If $M$ halts on $w$, accept $v$.

  If $M$ halts on $w$, $K' = phi$. If $M$ does not halt, then $K' = Sigma^*$. So

  $
  |K'| = cases(oo quad &"if" M "does not halt on" w, 0 quad &"if" M "halts on" w)
  $
  which satisfies our reduction constraint. Hence, $dash("HP") red "GT"_k$.
  
  (The same construction also shows $dash("HP") red "GE"_k$.) #h(1fr) $square$
][#sans[Problem 5]][
  Let $"nsteps"(M, w)$ denote the number of steps of $M$ on $w$. If $M$ loops on $w$, take $"nsteps"(M, w) = oo$. If $N$ also loops on $v$, take $"nsteps"(M, w) = "nsteps"(N, v)$.

  Prove: recursive / R.E but not recursive / non-R.E.?

  + $L_a = {M \# N | "nsteps"(M, eps) < "nsteps"(N, eps)}$
  + $L_b = {M \# N | "nsteps"(M, eps) <= "nsteps"(N, eps)}$
  + $L_c = {M \# N | "nsteps"(M, w) < "nsteps"(N, v) "for some" w, v}$
  + $L_d = {M \# N | "nsteps"(M, w) < "nsteps"(N, v) "for all" w, v}$
][#sans[Solution]][
  + #[R.E. but not recursive.

  To create a recogniser for $L_a$, simulate both $M$ and $N$ on $eps$ parallelly, and if $M$ halts earlier, then accept. 

  To show $"HP" red L_a$:
  $
  K \# w |-> M \# N \
  K "halts on" w <==> "nsteps"(M, eps) < "nsteps"(N, eps)
  $
  $
  K "halts on" w &=> "nsteps"(M, eps) < "nsteps"(N, eps)\
  K "does not halt on" w &=> "nsteps"(M, eps) >= "nsteps"(N, eps)\
  $

  $M$ on input $v_1$:
  - Simulate $K$ on $w$.
  - If it halts, accept.

  $N$ on input $v_2$:
  - Loop unconditionally.

  Here, we have
  - If $K$ halts on $w$, then $"nsteps"(M, eps) = "finite"$, $"nsteps"(N, eps) = oo$; so $"nsteps"(M, eps) < "nsteps"(N, eps)$.
  - If $K$ does not halt on $w$, then $"nsteps"(M, eps) = oo = "nsteps"(N, eps)$; so $"nsteps"(M, eps) >= "nsteps"(N, eps)$.

  So, $L_a$ is non recursive.]

  + #[non--R.E.

  Intuitively, we cannot create a recogniser for $L_b$, because in the case where $"nsteps"(M, eps) = "nsteps"(N, eps) = oo$, we cannot accept $M \# N$ in finite time. (Their simulation will keep on looping and never halt, so our recogniser can't accept the input.)

  To show $dash("HP") red L_b equiv "HP" red dash(L_b)$.

  Note that $dash(L_b) = {M \# N | "nsteps"(M, eps) > "nsteps"(N, eps)}$ is essentially the same as $L_a$, just with the roles of $M$ and $N$ reversed. So the same construction as in (a) can be used (by switching $M$ and $N$) to show $"HP" red dash(L_b)$.

  Thus, $L_b$ is non-R.E.
  ]
  + #[
    R.E. but non-recursive.

    Consider an NTM which nondeterministically chooses some $w$ and $v$ to run $M$ and $N$ on (parallelly), and if $M$ halts before $N$, then accepts. This is a recogniser for $L_c$.

    $"HP" red L_c$ follows from the same construction as (a).

    $
    K \# x |-> M \# N \
    K "halts on" x <==> exists w, v quad "nsteps"(M, w) < "nsteps"(N, v)
    $
    $
    K "halts on" x &=> exists w, v quad "nsteps"(M, w) < "nsteps"(N, v)\
    K "does not halt on" x &=> forall w, v quad "nsteps"(M, w) >= "nsteps"(N, v)\
    $

  From the construction of $M$ and $N$ in (a),
  - If $K$ halts on $x$, then $"nsteps"(M, w) = "finite"$, $"nsteps"(N, v) = oo$; so $"nsteps"(M, w) < "nsteps"(N, v)$, 
    for any $w, v$.
  - If $K$ does not halt on $x$, then $"nsteps"(M, w) = oo = "nsteps"(N, v)$; so $"nsteps"(M, w) >= "nsteps"(N, v)$, for all $w, v$.

  So, $L_c$ is non recursive.
  ]

  + #[
    non-R.E.

    To show $dash("HP") red L_d$:

    $
    K \# x |-> M \# N\
    K "does not halt on" x <==> "nsteps"(M, w) < "nsteps"(N, v) quad forall w, v
    $
    $
    K "does not halt on" x &=> forall w, v quad "nsteps"(M, w) < "nsteps"(N, v)  \
    K "halts on" x &=> exists w, v quad "nsteps"(M, w) >= "nsteps"(N, v) 
    $

    $M$ on input $w$:
    - Simulate $K$ on $x$ for $|w|$ steps.
    - If $K$ did not halt yet, accept $w$ (and halt). Otherwise, loop.

    $N$ on input $v$:
    - Simulate $K$ on $x$.
    - If it halts, accept $v$.

    If $K$ does not halt on $x$, then 
    - $M$ will halt on all strings in finite steps.
    - $N$ will loop on every string.
    - So, we have $forall w, v quad "nsteps"(M, w) < "nsteps"(N, v)$

    If $K$ halts on $x$, say in $s$ steps:
    - $M$ loops on strings $w$, with $|w| >= s$. 
    - $N$ will halts on all strings in finite steps.
    - So, we have $exists w, v quad "nsteps"(M, w) >= "nsteps"(N, v)$

    Thus, the reduction is correct.

    Therefore, $L_d$ is non-R.E.
  ]#h(1fr)$square$
][#sans[Problem 6]][
  Prove that the following languages are not recursive.
  + $L_1 = {M \# N | L(M) = L(N)}$
  + $L_2 = {M \# N | L(M) subset.eq L(N)}$
  + $L_3 = {M \# N | L(M) inter L(N) = phi}$
  + $L_4 = {M \# N \# P | L(M) inter L(N) = L(P)}$
][#sans[Solution]][
  + #[
    To show $"HP" red L_1$: #h(1fr)
    $
    K \# w |-> M \# N\
    K "halts on" w <==> L(M) = L(N)
    $
    $M$ on input $v_1$:
    - Accept $v_1$.
    $N$ on input $v_2$:
    - Simulate $K$ on $w$. 
    - If $K$ halts, then accept $v_2$.

    $
    L(M) &= Sigma^*\
    L(N) &= cases(Sigma^* quad &"if" K "halts on" w, phi quad &"if" K "does not halt on" w)
    $
    So, if $K$ halts on $w$, $L(M) = L(N)$ and if $K$ does not halt on $w$, then $L(M) != L(N)$, completing the reduction.
    Thus, $L_1$ is non-recursive.
  ]
  + #[
    To show $"HP" red L_2$.
    
    Use the same construction as in (a).

    If $K$ halts on $w$, $L(M) subset.eq L(N)$, and if $K$ does not halt on $w$, then $L(M) subset.eq.not L(N)$, completing the reduction. Thus, $L_2$ is non-recursive.
  ]
  + #[
    Here we will show $dash("HP") red L_3$.
    $
    K \# w |-> M \# N\
    K "does not halt on" w <==> L(M) inter L(N) = phi
    $
    $
    K "does not halt on" w &=> L(M) inter L(N) = phi\
    K "halts on" w &=> L(M) inter L(N) != phi\
    $
    Again use the same construction as in (a).

    If $K$ halts on $w$, $L(M) inter L(N) = Sigma^* != phi$. If $K$ does not halt on $w$, then $L(M) inter L(N) = phi$.

    Thus, $L_3$ is non-R.E., and consequently also non-recursive.
  ]
  + #[
    To show $dash("HP") red L_4$.
    $
    K \# w |-> M \# N \# P\
    K "does not halt on" w <==> L(M) inter L(N) = L(P)
    $
    $
    K "does not halt on" w &=> L(M) inter L(N) = L(P)\
    K "halts on" w &=> L(M) inter L(N) != L(P)\
    $
    $M$ on input $v_1$:
    - Simulate $K$ on $w$.
    - If $K$ halts, accept $v_1$.

    $N$ on input $v_2$:
    - Accept $v_2$

    $P$ on input $v_3$:
    - Reject $v_3$.

    Here, 
    $
    L(M) &= cases(Sigma^* quad &"if" K "halts on" w, phi quad &"if" K "does not halt on" w)\
    L(N) &= Sigma^*\
    L(P) &= phi
    $
    So, if $K$ halts on $w$, $L(M) inter L(N) = Sigma^* != phi = L(P)$. If $K$ does not halt on $w$, then $L(M) inter L(N) = phi = L(P)$.

    Thus, $L_4$ is non-R.E. and thus consequently non-recursive.
  ]#h(1fr) $square$
][#sans[Problem 7]][
  Prove that the following problems on a TM $M$ are decidable.
  + Decide whether $M$ halts on some input within 2026 steps.
  + Decide whether $M$ on a given input $w$ moves left at least 2026 times.
][#sans[Solution]][
  + #[
    Simulate $M$ on all possible inputs $w$, $|w| <= 2026$, parallelly, for 2026 steps. If it halts on any one of them (within 2026 steps), then accept $M$. Otherwise, reject.

    Why does this work?
    - *Case 1:* $M$ does not halt on any input within 2026 steps. Then our decider correctly rejects $M$ (since it won't halt in 2026 steps on our chosen inputs).
    - *Case 2:* $M$ halts on some input $w^*$ within 2026 steps.
       - If $|w^*| <= 2026$, then again our decider correctly accepts $M$ since its simulation of $w^*$ will halt within 2026 steps.
       - If $|w^*| > 2026$, and we know that $M$ halts on $w^*$ within 2026 steps. This must mean that $M$ only ever sees at most 2026 characters of $w^*$ from the start (to see more characters, it would require more steps). Then, consider the prefix $alpha$ of $w^*$ consisting of its first 2026 characters. The behaviour of $M$ on $alpha$ should be identical to that on  $w^*$, since the part of the input tape which is reachable by the machine is identical. Therefore, $M$ halts on $alpha$ within 2026 steps. Hence, our decider correctly accepts $M$, since its simulation of $alpha$ will halt within 2026 steps.
  ]
  + #[
    Simulate $M$ on $w$ for $2026 times (|w| + |Q|)$ steps. During the simulation, if $M$ moves left at least 2026 times, accept. Otherwise, reject.

    Why does this work? Between any two $L$ moves that $M$ makes, what is the maximum number of $R$ moves it can take? If it is at the start of the tape (at the $lm$), it can go right for $|w|$ steps, reaching the end of the string. Then, it can go further right, finding a blank symbol, say at state $q_1$. It may move right again, going to some state $q_2$. If it keeps moving right, at some point it will repeat states and be stuck in a loop, forever moving right (because it keeps seeing $blank$ symbols). So, we can bound the number of consecutive right moves $M$ can take before taking a left move, to be $|w| + |Q|$. So between two $L$ moves, there can be at most $|w| + |Q|$ $R$ moves. Thus, it follows that if $M$ has at least $k$ left moves, they must happen within $k(|w| + |Q|)$ steps.
  ]#h(1fr) $square$
][#sans[Problem 8]][
  Use Rice's theorems to prove that neither the following languages nor their complements are R.E.
  + FIN = ${M | L(M) "is finite"}$.
  + REG = ${M | L(M) "is regular"}$.
][#sans[Solution]][
  + #[
    FIN is non monotone, since $phi subset.eq Sigma^*$, but $P_"FIN" (phi) = T$, and $P_"FIN" (Sigma^*) = F$. Therefore by Rice's theorem, FIN is non-R.E.

    $dash("FIN")$ is monotone, so we cannot comment on it by Rice theorem. We must show $dash("HP") red dash("FIN")$ to prove it is non-R.E.
  ]
  + #[
    Let $A = {a^p | p "is prime"}$.

    REG is non monotone, since $phi subset.eq A$, but $P_"REG" (phi) = T$ and $P_"REG" (A) = F$. Therefore by Rice's theorem, REG is non-R.E.

    $dash("REG")$ is non monotone, since $A subset.eq Sigma^*$, but $P_dash("REG") (A) = T$ and $P_dash("REG") (Sigma^*) = F$. Therefore by Rice's theorem, $dash("REG")$ is non-R.E.
  ]#h(1fr)$square$
][#sans[Problem 9]][
  Prove/disprove: No non-trivial property of R.E. languages is semidecidable.
][#sans[Solution]][
  Counter example: Non-emptiness.

  ($dash(E_"TM") = {M | L(M) != phi}$ is a non trivial property, which is semidecidable.)#h(1fr)$square$
]