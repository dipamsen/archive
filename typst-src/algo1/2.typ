#import "template.typ": project, infobox
#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2": plot, chart
#import "@preview/fletcher:0.5.8": diagram, node, edge

#show: project.with(
  title: "Assignment 2",
  subtitle: "Solving Recurrences"
)

#let high1 = text.with(fill: rgb("#8c0000"))

#set enum(numbering: it => [#strong(high1([#it.]))])

#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$),
)

#let quest(number, body) = grid(columns: (3em, 1fr), strong[#high1(number)], body)

#let high2 = text.with(fill: blue)

#let ans(body) = grid(columns: (3em, 1fr), strong(high2[Sol.]), body)

#set math.mat(delim: "[")
#set math.vec(delim: "[")

#show math.equation.where(block: false): math.display

#show strong: high1
#let bigO = scr("O")

#quest[2.4.1][
  Using the substitution method, show that the solution of the recurrence $T(n) = T(n-1) + n$ is $O(n^2)$. Establish it also using recursion tree method.
]

#let thereexists = $exists thick$
#let forall = $forall thick$
#let st = "such that"

#let num(body) = {
  set math.equation(numbering: x => [(1.#x)])
  body
}

#ans[
  *Substitution Method*

  
  Assume *inductive hypothesis*: $T(k) <= c k ^2$ for some $c > 0$ for all $k < n$.

  Then,
  $
  T(n) = T(n-1) + n
  $
  *Step:*
  $
  T(n) &<= c (n - 1)^2 + n\
  &= c n^2 - 2 c n + c + n\
  &<= c n^2 quad "for" c >= 1, n > 1
  $
  Suitable basis condition is $c = 1, n_0 = 2$

  This proves that $T(n) = O(n^2)$.

  *Recursion Tree Method*
  $
  T(n) = T(n-1) + n
  $
  #align(center, diagram({
    node((0, 0), $T(n)$, stroke: 1pt)
    edge("->")
    node((0, 1), $T(n-1)$, stroke: 1pt)
    edge("->")
    node((0, 2), $dots.v$)
    edge("->")
    node((0, 3), $T(1)$, stroke: 1pt)

    edge((-1, 0), (-1, 3), "<|-|>", $n$, label-side: center)

    node((2, 0), $n$)
    node((2, 1), $n-1$)
    node((2, 2), $dots.v$)
    node((2, 3), $1$)
  }))

  At each level of the recursion tree, input size decreases by 1. Hence the number of levels is $n$. Each level has exactly one node and work done at $k$th node is $n - k$, so total time across each level is $sum_(i=1)^n i = frac(n (n+1), 2) => T(n) = O(n^2)$.
]
#v(5mm)

#quest[2.4.2][
  Show that the solution of $T(n) = T(ceil(n\/2)) + 1$ is $O(lg n)$.
]
#ans[
  #infobox[
  *Claim:* $
  n_k= underbrace(ceil(...ceil(n\/2)...\/2), k "ceilings") = ceil(n\/2^k)
  $

  *Proof of claim:* (Induction over $k$)
  
  #high1[Basis:] For $k = 1$, statement is trivially true. $ceil(n\/2) = ceil(n\/2^1)$.

  #high1[Step:] Assume that the statement is true for $k  = m - 1$. Then $n_(m-1) = underbrace(ceil(...ceil(n\/2)...\/2), m-1 "ceilings") = ceil(n\/2^(m-1))$

  For $k = m$,

  $
  n_m = underbrace(ceil(...ceil(n\/2)...\/2), m "ceilings") = ceil(n_(m-1)\/2) = ceil(ceil(n\/2^(m-1))\/2)
  $

  Let us take $2^(m-1) = p$. We need to simplify $ceil(ceil(n\/p)\/2)$.

  Let us write $n$ in terms of $2 p$. We can write $n = 2p q + r$, for $0 <= r < 2 p$, with unique $q, r in ZZ$.

  #high2[Case 1:] $r = 0$

  $
  ceil(ceil(n\/p)\/2) = ceil(ceil((2 p q)\/p)\/2) = ceil(ceil(2 q)\/2) = q
  $
  
  #high2[Case 2:] $0 < r <= p$

  $
  ceil(ceil(n\/p)\/2) = ceil(ceil((2 p q + r)\/p)\/2) = ceil(ceil(2 q + r\/p)\/2)
  $
  Here $0 < r/p <= 1$, so we get $ceil((2 q  + 1) \/ 2) = ceil(q + 1\/2) = q + 1$.

  #high2[Case 3:] $p < r < 2p$

  $
  ceil(ceil(n\/p)\/2) = ceil(ceil((2 p q + r)\/p)\/2) = ceil(ceil(2 q + r\/p)\/2)
  $
  Here $1 < r/p < 2$, so we get $ceil((2 q + 2) \/ 2) = ceil(q+  1) = q + 1$.

  Thus, 

  #num[$
  ceil(ceil(n\/p)\/2) = cases(q quad &r = 0, q + 1 quad &r != 0)
  $]

  Notice that this is equivalent to the expression $ceil(n\/ 2 p)$:

  #high2[Case 1:] $r = 0$

  $
 ceil(n\/ 2 p) = ceil(2 p q \/ 2 p) = q
  $
  
  #high2[Case 2:] $0 < r <= 2 p$

  $
  ceil(n\/ 2 p) = ceil((2 p q + r) \/ 2 p) = ceil(q + r \/ 2p )
  $
  Here $0 < r/(2p) <= 1$, so we get $q + 1$.

  Thus we have
  #num[$
  ceil(n\/2p) = cases(q quad &r = 0, q + 1 quad &r != 0)
  $]

  From (1.1) and (1.2) we can say

  $
  ceil(ceil(n\/p)\/2) = ceil(n\/2p)
  $

  For $p = 2^(m-1)$, we have $ceil(ceil(n\/2^(m-1))\/2) = ceil(n\/ 2^(m))$. This proves our inductive step and thus completes the induction. Thus our claim is verified.

]

  Let's solve the given recurrence using *Recursion Tree Method*.

  By using the *claim*, we can simplify the recurrence nodes. At $k$th level, the recursive step will be $T\(underbrace(ceil(...ceil(n\/2)...\/2), k "ceilings")) = T(n_k) = T(ceil(n\/2^k))$.
  
   $ T(n) = T(ceil(n\/2)) + 1 $

   #align(center, diagram({
    node((0, 0), $T(n)$, stroke: 1pt)
    edge("->")
    node((0, 1), $T(ceil(n\/2))$, stroke: 1pt)
    edge("->")
    node((0, 2), $T(ceil(n\/4))$, stroke: 1pt)
    edge("->")
    node((0, 3), $dots.v$)
    edge("->")
    node((0, 4), $T(1)$, stroke: 1pt)

    edge((-1, 0), (-1, 4), "<|-|>", $O(lg n)$, label-side: center)

    node((2, 0), $1$)
    node((2, 1), $1$)
    node((2, 2), $1$)
    node((2, 4), $1$)
  }, spacing: (1cm, 0.6cm)))

  Each level has one node, and extra work at each level is constant. Thus, the height of the tree itself gives the total work, which is $O(lg n)$.

  $
  T(n) = O(lg n)
  $
]

#v(5mm)

#quest[2.4.3][
  Using Recursion Tree Method, show that $T(n) = 2 T(floor(n\/2) + 17) + n$ is $O(n lg n)$.
]

#ans[
  Since we need to find the upper bound, we can approximate $floor(n\/2)$ as $n/2$, and this won't change the asymptotic behaviour of the recurrence.

  $ T(n) = 2 T(n/2 + 17) + n $
  
   #align(center, scale(80%, reflow: true, diagram({
    node((0, 0), $T(n)$)
    node((-2, 1), $T(n/2 + 17)$)
    node((2, 1), $T(n/2 + 17)$)
    node((-3, 2), $T(n/4 + 17 dot 3/2)$)
    node((-1, 2), $T(n/4 + 17 dot 3/2)$)
    node((3, 2), $T(n/4 + 17 dot 3/2)$)
    node((1, 2), $T(n/4 + 17 dot 3/2)$)

    edge((0, 0), (-2, 1), "->")
    edge((0, 0), (2, 1), "->")
    edge((-2, 1), (-3, 2), "->")
    edge((-2, 1), (-1, 2), "->")
    edge((2, 1), (1, 2), "->")
    edge((2, 1), (3, 2), "->")

    node((-3, 2.5), $dots.v$)
    node((-1, 2.5), $dots.v$)
    node((1, 2.5), $dots.v$)
    node((3, 2.5), $dots.v$)

    node((-3, 3), $T(1)$)
    node((-1, 3), $T(1)$)
    node((1, 3), $T(1)$)
    node((3, 3), $T(1)$)

    // edge((-1, 0), (-1, 4), "<|-|>", $O(lg n)$, label-side: center)

    // node((2, 0), $1$)
    // node((2, 1), $1$)
    // node((2, 2), $1$)
    // node((2, 4), $1$)
    node((8, 0), $n$)
    node((8, 1), $n + 34$)
    node((8, 2), $n + 34 times 3$)
    node((8, 3), $n + 34 (2^k - 1)$)
  }, spacing: (0cm, 2cm))))

  Work at $k$th level:

  $
  &= 2^k times (n / 2^k  + 17 times (1 + 1/2  + ... + 1/2^(k-1)))\
  &= n + 17 times (2 + 4 + ... + 2^k)\
  &= n + 34 times (1 + 2 + 4 + ... + 2^(k - 1)) = n + 34 times (2^k - 1)
  $

  Total levels = $Theta(lg n)$.

  Summing up all the works for each level, we have

  $
  T(n) &= sum_(k= 1)^(lg n) n + sum_(k=1)^(lg n) 34 (2^k - 1)\
  &= n lg n + O(2^lg(n)) \ &= n lg n + O(n)\
  

   => T(n) &= O(n lg n) $
]


#v(5mm)

#quest[2.4.4][
  Show that a substitution proof for $T(n) = 4 T(n/3) + n$ fails with $T(n) <= c n^(log_3 4)$, and how to fix it by subtracting a lower order term.
]

#ans[
  $ T(n) = 4 T(n/3) + n $

  *Hypothesis* $T(m) <= c m^(log_3 4)$ for all $m < n$.

  *Step*

  $ T(n) &= 4 T(n/3) + n\
  &<= 4 c (n/3)^(log_3 4) + n\
  &= c n^(log_3 4) + n
  $
  This way, we cannot show $T(n) <= c n^(log_3 4)$.

  We can fix it by making a stronger inductive hypothesis, by subtracting a lower order term.

  *Hypothesis* $T(m) <= c m^(log_3 4) -  d m$ for all $m < n$.

  
  *Step*

  $ T(n) &= 4 T(n/3) + n\
  &<= 4 c (n/3)^(log_3 4) - 4 d (n/3) + n\
  &= c n^(log_3 4) - 4/3 d n + n\
  &= c n^(log_3 4) - d n - n (1/3 d - 1)\
  &<= c n^(log_3 4) - d n quad quad "for" d > 3
  $
  
  This completes the proof.
]

#v(5mm)

#quest[2.4.5][
  Solve the recurrence $T(n) = T(sqrt(n)) + lg n$ by making a change of variables. Give an asymptotically tight bound. Do not worry about whether values are integral.
]

#ans[
  Assume $n = 2^k$. Then we have

  $
  T(2^k) = T(sqrt(2^k)) + lg 2^k\
  => T(2^k) = T(2^(k/2)) + k
  $

  Define a new function $S(k) = T(2^k)$.

  $
  S(k) = S(k/2)  + k
  $

  Clearly, $S(k) >= k$.
  
  If we use recursion tree method, we find that
  $
  S(k) = k + k/2 + ... + 1 <= 2k
  $
  
  Together, this implies $S(k) = Theta(k)$.

  But $S(k) = T(2^k) = Theta(k)$.

  Put $k = lg n$
  $
  => T(n) = Theta(lg n)
  $
]



#quest[2.4.5][
  Solve the recurrence $T(n) =2 T(sqrt(n)) + lg n$ by making a change of variables. Give an asymptotically tight bound. Do not worry about whether values are integral.
]

#ans[
  Assume $n = 2^k$. Then we have

  $
  T(2^k) = 2T(sqrt(2^k)) + lg 2^k\
  => T(2^k) = 2T(2^(k/2)) + k
  $

  Define a new function $S(k) = T(2^k)$.

  $
  S(k) = 2S(k/2)  + k
  $

  #align(center, diagram({
    node((0, 0), $S(k)$)
    node((-2, 1), $S(k/2)$)
    node((2, 1), $S(k/2)$)
    node((-3, 2), $S(k/4)$)
    node((-1, 2), $S(k/4)$)
    node((3, 2), $S(k/4)$)
    node((1, 2), $S(k/4)$)

    edge((0, 0), (-2, 1), "->")
    edge((0, 0), (2, 1), "->")
    edge((-2, 1), (-3, 2), "->")
    edge((-2, 1), (-1, 2), "->")
    edge((2, 1), (1, 2), "->")
    edge((2, 1), (3, 2), "->")

    node((-3, 2.5), $dots.v$)
    node((-1, 2.5), $dots.v$)
    node((1, 2.5), $dots.v$)
    node((3, 2.5), $dots.v$)

    node((-3, 3), $S(1)$)
    node((-1, 3), $S(1)$)
    node((1, 3), $S(1)$)
    node((3, 3), $S(1)$)

    // edge((-1, 0), (-1, 4), "<|-|>", $O(lg n)$, label-side: center)
    edge((-8, 0), (-8, 3), "<|-|>", $O(lg k)$, label-side: center)

    // node((2, 0), $1$)
    // node((2, 1), $1$)
    // node((2, 2), $1$)
    // node((2, 4), $1$)
    node((10, 0), $-> k$)
    node((10, 1), $-> k$)
    node((10, 2), $-> k$)
    node((10, 3), $-> k$)
  }, spacing: (0.1cm, 1cm)))
  
  By recursion tree, we can see that
  $
  S(k) = Theta(k lg k)
  $
  This is because, at each level total work will be $Theta(k)$, and there will be $lg k$ levels.

  
  But $S(k) = T(2^k) = Theta(k lg k)$.

  Put $k = lg n$
  $
  => T(n) = Theta(lg n dot lg lg n)
  $
]


#v(5mm)
#align(center, line(length: 50%))