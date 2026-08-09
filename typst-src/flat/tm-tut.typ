#show heading: set text(font: "New Computer Modern Sans")
#import "@preview/numbly:0.1.0": numbly
#set enum(full: true, numbering: numbly(
  "({1:a})",
  "{2:1}.",
  "{3:i})"
))

#set text(font: "New Computer Modern", hyphenate: false)
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

// #set enum(numbering: "(a)1.")

#grid(columns: (15%, 1fr), align: (right, left), row-gutter: 1em, column-gutter: 1em)[][

= Tutorial 3A: Turing Machines and Unrestricted Grammars



][#sans[Problem 1]][
  A linear bounded automaton (LBA) is exactly like a 1-tape TM, except that the input string $x in Sigma^*$ is enclosed in left and right end markers $lm$ and $rm$ which may not be overwritten. The machine is constrained to never move left of $lm$ or right of $rm$. It is allowed to read/write between these markers.
  + Give a rigorous formal definition of deterministic linearly bounded automata, including a definition of configurations and acceptance.
  + Let $M$ be a LBA with state set $Q$ of size $k$ and tape alphabet $Gamma$ of size $m$. How many possible configurations are there on input $x$ with $|x| = n$?
  + Argue that it is possible to detect in finite time whether an LBA loops on a given input.

][#sans[Solution]][
  + #[
    $M$ is a deterministic linear bounded automata: #h(1fr)
    $
    M = (Q, Sigma, Gamma, lm, rm, delta, s, t, r)
    $
    #grid(
      columns: 2,
      row-gutter: 0.65em,
      column-gutter: 0.5em,
      grid.cell(rowspan: 9)[where], 
      [$Q$ is the (finite) set of states,],
      [$Sigma$ is the input alphabet,],
      [$Gamma$ is the tape alphabet ($Sigma subset Gamma$),],
      [$lm$ is the left end marker,],
      [$rm$ is the right end marker ($lm, rm in Gamma without Sigma$)],
      [$delta$ is the transition function,],
      [$s$ is the start state,],
      [$t$ is the accept state,],
      [$r$ is the reject state ($s, t, r in Q)$.]
    )

    $
    delta : Q times Gamma -> Q times Gamma times {L, R}
    $
    such that
    $
    forall q in Q, quad delta(q, lm) = (p, lm, R) quad "for some" p in Q\
    forall q in Q, quad delta(q, rm) = (p, rm, L) quad "for some" p in Q.
    $

    Let the input to the LBA be $x$, $|x| = n$.

    A configuration of $M$ is a three-tuple: $C in Q times Gamma^n times {0, ..., n + 1} $
    $
    C = (q, z, m)
    $
    which  indicates
    - the current state is $q in Q$,
    - the current contents of the tape is $lm z rm$, $z in Gamma^n$,
    - the head pointer points at position $m$, $m in {0, ..., n + 1}.$

    We can define the relation $nx(*)$ between configurations as usual.

    Then, $M$ is said to accept $x$ if $(s, x, 0) nx(*) (t, y, l)$ for some $y in Gamma^n, l in {0, ..., n + 1}$.

    So,
    $
    L(M) = {x | (s, x, 0) nx(*) (t, y, l)}
    $
  ]

  + #[
    A configuration is described by $Q times Gamma^n times {0 , 1, ..., n + 1}$. So, the total number of possible configurations are $|Q| times |Gamma|^n times (n + 2) = k (n + 2) m^n$.
  ]

  + #[
    An LBA either halts in finite steps, or loops forever. Since the LBA is deterministic, if an LBA reaches the same configuration twice for some input, it must loop on that input.

    Let $c = k (n + 2) m^n$ denote the total number of possible configurations.

    Let's run the LBA for $c$ steps, then it  will have gone through at most $c + 1$ configurations in total. If it halted before completion of all these steps, we know that it halts on the given input. If it did not halt yet, we know that it *must* loop on this input, since it has seen a configuration twice by now. Thus we can determine in finite time whether an LBA loops on a given input. #h(1fr) $square$
  ]
][#sans[Problem 2]][
  Design an NTM to accept the language 
  $
  {w x y x z | w, x, y, z in {0, 1}^*, |x| = 2026}
  $
][#sans[Solution]][
  #set enum(numbering: "1.")
  $N$ on input $x$:
  1. Move right. At each step, non-deterministically either continue moving right or proceed to Step 2.
  2. Repeat 2026 times: mark the symbol under the head with $hat$, then move right. If the input ends before all 2026 marks are placed, reject.
  3. Move right. At each step, non-deterministically either continue moving right or proceed to Step 4.
  4. Repeat 2026 times: mark the symbol under the head with $'$, then move right. If the input ends before all 2026 marks are placed, reject.
  5. Repeat 2026 times: Scan to the leftmost $hat$-marked symbol; call its value $a$. Scan to the leftmost $'$-marked symbol;  call its value $b$.
    - If $a != b$, reject.
    - Otherwise, erase the $hat$ marker from the previous cell, and erase the $'$ marker from your cell. 
  6. Accept. #h(1fr)$square$
][#sans[Problem 3]][
  A TM $cal(M)$ has a two-way infinite tape. Initially all cells on the tape are blank. Only one cell is storing the symbol $\#$. The head of $cal(M)$ is pointing to a blank. The task of $cal(M)$ is to locate the cell storing $\#$.

  Propose a strategy for doing this,
  + if $cal(M)$ is a DTM,
  + if $cal(M)$ is an NTM.
][#sans[Solution]][
  + #[
    $cal(M)$ on input:
    1. If the current cell has $\#$, report that we have located it.
    2. Mark the current cell with an $X$.
    3. While the current cell contains $X$, go left.
    4. If the current cell has $\#$, report that we have located it.
    5. Mark the current cell with an $X$.
    6. While the current cell contains $X$, go right.
    7. Go to Step 1.
  ]
  + #[$cal(M)$ on  input:
    Repeat:
    1. If the current cell has $\#$, report that we have located it.
    2. Non deterministically, either go left or right.
  ]

  Let us assume that the $\#$ is located at a distance $n$ from the initial starting head pointer.

  We can observe, that $cal(M)$ in (a) will require $O(n^2)$ steps to find the symbol. On the other hand, $cal(M)$ in (b) being a nondeterministic machine, can find the symbol in $O(n)$ steps.#h(1fr) $square$
][#sans[Problem 4]][
  A Jump Turing Machine (JTM) $J = (Q, Sigma, Gamma, delta, lm, blank, s, t, r)$ is like a standard one-tape Turing Machinge (TM) with the only exception that each transition of $J$ is of the form $delta(p, A) = (q, B, m)$, where $p, q in Q, A, B in Gamma, m in ZZ$. 

  This means that if the finite control of $J$ is in the state $p$ and the head of $J$ scans the tape symbol $A$, then the state changes to $q$, the content of the tape cell is changed from $A$ to $B$, and the head jumps by $m$ (integer) cells relative to the current position.

  If $m = 0$, the head stays at the current cell. If $m > 0$, the head makes a right jump. If $m < 0$, the head makes a left jump with the understanding that if the head is at position $i$ on the tape, and $|m| > i$, then the head goes to the leftmost cell (which stores the left end-marker $lm$). Also assume that if $A$ is $lm$, then $m >= 0$.

  Prove that a JTM is equivalent to a TM.
][#sans[Solution]][
  #set enum(numbering: "1.")
  Firstly, any TM can be simulated by a JTM. This is trivial, as any transition $delta(p, A) = (q, B, L) equiv delta'(p, A) = (q, B, -1)$ and $delta(p, A) = (q, B, R) equiv delta'(p, A) = (q, B, +1)$.

  For the other direction, let $J$ be a JTM with transition function $delta$. Note that $delta$ is a finite object, i.e. it has a finite number of transition, each transition can make a finite sized jump.

  So we can create a machine $M = (Q, Sigma, Gamma, delta', lm, blank, s, t, r)$ which simulates $J$.

  For each transition $delta(p, A) = (q, B, +m), m > 0$, $M$ simulates it as
  1. Write $B$ to the tape.
  2. Use a sequence of $m - 1$ intermediate states, scan $m$ steps to the right.
  If $m = 0$,
  1. Write B to the tape, go to an intermediate state, going right on the input tape.
  2. Come back to the original state by going left on the input tape.

  The $m < 0$ case is symmetric as $m > 0$.#h(1fr)$square$
][#sans[Problem 5]][
  Show that the class of recursively enumerable sets is closed under union and intersection.
][#sans[Solution]][
  #set enum(numbering: "1.")
  Let $L_1 = L(M_1)$ and $L_2 = L(M_2)$ be two r.e. sets. Then,
  define $M_union$ and $M_inter$:

  $M_union$ on input $x$: (assume having two tapes)
  1. Copy $x$ to the second tape.
  2. Parallelly run $M_1$ and $M_2$ on both tapes, one at a time.
  3. If any one of them accepts, accept. If both reject, reject.

  $M_inter$ on input $x$:
  1. Run $M_1$ on $x$. If it rejects, then reject.
  2. Run $M_2$ on $x$. If it accepts, then accept. If it rejects, then reject.

  Then, $L(M_union) = L_1 union L_2$, $L(M_inter) = L_1 inter L_2$. Thus, r.e. sets are closed under union and intersection. #h(1fr) $square$
]

#pagebreak()

#let cnt(x) = $\##x$

#grid(columns: (15%, 1fr), align: (right, left), row-gutter: 1em, column-gutter: 1em)[][

= Tutorial 3B

][#sans[Problem 1]][
  Design Turing Machines (TMs) as well as unrestricted grammars for the following languages:
  1. $L_1 = {w in {a, b, c}^* | cnt(a)(w) = cnt(b)(w) = cnt(c)(w)}$
  2. $L_2 = {w w | w in {a, b}^*}$
  3. $L_3 = {a^i b^j c^k d^l | i = k, j = l}$
  4. $L_a = {a^n w c^n | w in {a, b, c}^*, n >= 0, cnt(a)(w) = n}$
  5. $L_b = {a^n w c^n | w in {a, b, c}^*, n >= 0, cnt(b)(w) = n}$
  6. $L_c = {a^n w c^n | w in {a, b, c}^*, n >= 0, cnt(c)(w) = n}$
][#sans[Solution]][
  Only unrestricted grammers for some of the languages are shown here.

  #grid(columns: (1fr, 1fr), gutter: 1em)[+ #[
    $
    S &-> A B C S | eps\ A B &-> B A \ B A &-> A B \ B C &-> C B\ C B &-> B C \ A C &-> C A \ C A &-> A C \ A &-> a \ B &-> b\ C &-> c 
    $
  ]][
  2. #[
    $
    S &-> a A S | b B S | T\
    A a &-> a A \
    A b &-> b A \
    B a &-> a B\
    B b &-> b B\
    A T &-> T a\
    B T &-> T b\
    T &-> eps
    
    $
  ]][
    3. $
      S &-> U V\
      U &-> a U c | T\
      V &-> B V d | eps\
      c B &-> B c\
      T B &-> b T\
      T &-> eps
    $
  ][
    4. $
    S &-> a S A c | V  R \
    c A &-> A c\
    R A &-> a V R\
    V &-> b V | c V | eps\
    R &-> eps
    $
  ]
  #h(1fr)$square$
][#sans[Problem 2]][
  Consider the unrestricted grammar over the singleton alphabet $Sigma = {a}$, having the start symbol $S$, and with the following productions:$
  S &-> A S | a T\
  A a &-> a a a A\
  A T &-> T\
  T &-> eps
  $
  What is the language generated by this unrestricted grammar? Justify.
][#sans[Solution]][
  Some derivations:
  $
  S -> a T -> a\
  S -> A S -> A a T -> a a a A T -> a a a T -> a a a $

  We can observe, that the language generated by this unrestricted grammar is ${a^(3^n) | n >= 0}$.#h(1fr)$square$
][#sans[Problem 3]][
  Prove that, a language $L$ is recursive if and only if there is an enumeration machine enumerating the strings of $L$ in a non-decreasing order of length (strings of the same length may be arranged in lexicographic order). For example, strings of ${0, 1}^*$ would be arranged as $0, 1, 00, 01, 10, 11, 000, 001, 010, 011, 100, 101, 110, 111, ...$
][#sans[Solution]][
  Let $L = L(M)$ be recursive, and $M$ be a total Turing Machine. Then, we can create $E$ (enumeration machine) as follows:
  #set enum(numbering: "1.")
  
  $E$ runs:
  1. Run $M$ on all strings in $Sigma^*$ in a non-decreasing order of length (lexicographic order). If $M$ accepts $x$, then enumerate $x$.

  Thus, $E$ enumerates the strings of $L$ in a non decreasing order of length.

  For the other direction, let $E$ be an enumeration machine which enumerates the strings of $L$ in a non-decreasing order of length. Then we can create a total TM $M$:

  $M$ on input $x$:
  1. Run $E$.
  2. If it enumerates $x$, accept.
  3. If it enumerates $y$, $|y| > |x|$, reject.

  Thus, $M$ is a total TM which accepts the strings enumerated by $E$.#h(1fr)$square$
][#sans[Problem 4]][
  Prove that any grammar, defined over non terminals $N$ and terminals $Sigma$, can be converted to an equivalent grammar with rules of the form $alpha A gamma -> alpha beta gamma$, for $A in N$ and $alpha, beta, gamma in (Sigma union N)^*$. 
][#sans[Solution]][
  Left as an exercise to the reader.
]
