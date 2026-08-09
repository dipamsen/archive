#import "template.typ": project, infobox
#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2": plot, chart

#show: project.with(
  title: "Assignment 1",
  subtitle: "Asymptotic Bounds"
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

#quest[1.4.1][
  Prove the transitive property *3* of Big-O:
  1. $f = bigO(g)$ and $g = bigO(h)$ $=>$ $f = bigO(h)$
  2. $f = Omega(g)$ and $g = Omega(h)$ $=>$ $f = Omega(h)$
]

#let thereexists = $exists thick$
#let forall = $forall thick$
#let st = "such that"

#let num(body) = {
  set math.equation(numbering: x => [(1.#x)])
  body
}

#ans[
  1. #[
    We have
    #num[$ f = bigO(g) => thereexists c_1 > 0, n_1 > 0, f(n) <= c_1 dot.c g(n) quad forall n >= n_1 $
    $ g = bigO(h) => thereexists c_2 > 0, n_2 > 0, g(n) <= c_2 dot.c h(n) quad forall n >= n_2 $]

    Then, from (1.1) and (1.2), we have

    $
    f(n) <= c_1 c_2 dot.c h(n) quad &forall n >= max(n_1, n_2)\
    => f(n) <= c dot.c h(n) quad &forall n >= n_0
    $

    for $c = c_1 c_2$ and $n_0 = max(n_1, n_2)$.

    This shows that $f(n) = bigO(h(n))$.
  ] #h(1fr)
  
  2. #[
    Similarly, we have
    #num[$ f = Omega(g) => thereexists c_1 > 0, n_1 > 0, f(n) >= c_1 dot.c g(n) quad forall n >= n_1 $
    $ g = Omega(h) => thereexists c_2 > 0, n_2 > 0, g(n) >= c_2 dot.c h(n) quad forall n >= n_2 $]

    Then, from (1.3) and (1.4), we have

    $
    f(n) >= c_1 c_2 dot.c h(n) quad &forall n >= max(n_1, n_2)\
    => f(n) >= c dot.c h(n) quad &forall n >= n_0
    $

    for $c = c_1 c_2$ and $n_0 = max(n_1, n_2)$.

    This shows that $f(n) = Omega(h(n))$.
  ]
]
#v(5mm)
#quest[1.4.2][
  $
  vec(F(n), F(n-1)) = M^(n-1) vec(1, 0) "where" M = mat(1, 1; 1, 0)
  $
  Prove by induction, that $M^n = display(mat(F_(n+1), F_n; F_n, F_(n-1))) thick forall n>= 1$.
]

#ans[
  *Base Case:* For $n = 1$, we have
  $
  M^1 = M = mat(1, 1; 1, 0) = mat(F_2, F_1; F_1, F_0)
  $
  which satisfies the proposition.

  *Inductive Case:* We show that if the proposition is true for some $n = k$, it is also true for $n = k + 1$.
  
  Assume that the proposition is true for some $n = k$. Then we have, 
  $
  M^k = mat(F_(k+1), F_k; F_k, F_(k-1))
  $

  Now, we can find $M^(k+1)$:

  $
  M^(k+1) = M dot M^k = M mat(F_(k+1), F_k; F_k, F_(k-1)) &= mat(1, 1; 1, 0)mat(F_(k+1), F_k; F_k, F_(k-1)) \
  &= mat(F_(k+1) + F_(k), F_(k) + F_(k-1); F_(k+1), F_(k-1))\
  &= mat(F_(k+2), F_(k+1); F_(k+1), F_(k-1))
  $

  Thus, the proposition is true for $n = k + 1$.

  By the principal of mathematical induction, this shows that the proposition is true for all $n >= 1$.
]
#v(5mm)

#quest[1.4.3][
  A function $f(x)$ is said to be *monotonically increasing* if $f(x) <= f(y) forall x <= y$. Suppose $f(n)$ and $g(n)$ are monotonically increasing functions such that in addition, they are non negative. Prove that the following functions are also monotonically increasing:
  1. $f(n) + g(n)$
  2. $f(g(n))$
  3. $f(n) dot.c g(n)$ if $f(n), g(n) > 0$ for all $n$.
]

#ans[
  The definition as given above states that a function $f$ is monotonically increasing if $f(x) <= f(y) forall x <= y$. Thus to prove that a function is monotonically increasing, it suffices to show $x <= y => f(x) <= f(y)$.
  
  1. #[
    Let $x <= y$. Then,
    #num[
      $
      f(x) <= f(y) 
      $
      $
      g(x) <= g(y) 
      $
    ]
    Adding $(1.5)$ and $(1.6)$ we have
    $
    f(x) + g(x) <= f(y) + g(y)
    $
    thus, $f(n) + g(n)$ is monotonically increasing.
  ]

  2. #[
    Let $x <= y$. Then, $g(x) <= g(y)$.
    
    Let $g(x) = k_1$, $g(y) = k_2$. Clearly, $k_1 <= k_2$. Since $f$ is monotonically increasing, we have
    $
    f(k_1) <= f(k_2)\
    => f(g(x)) <= f(g(y))
    $
    This, $f(g(n))$ is monotonically increasing.
  ]

  3. #[
    Let $x <= y$. We know that #num[$ 0 < f(x) <= f(y) $] and #num[$ 0 < g(x) <= g(y) $].

    From (1.7), we can write
    $
    f(x) g(x) <= f(y) g(x)
    $
    and from (1.8) we can write
    $
    f(y) g(x) <= f(y) g(y)
    $

    which together imply 
    $
    f(x) g(x) <= f(y) g(y)
    $
    thus showing that $f(n) g(n)$ is monotonically increasing.
  ]
]

#v(5mm)

#quest[1.4.4][
  What is the smallest value of $n$ such that an algorithm whose running time is $100 n^2$ runs faster than an algorithm whose running time is $2^n$ on the same machine?
]

#ans[
  Assuming that each operation takes equal time, we can find the threshold value of $n$ where $100n^2 < 2^n$ by trial and error:

  $
  n = 5: &100 n^2 = 2500 &&> 2^n = 32\
  n = 7: &100 n^2 = 4900 &&> 2^n = 128\
  n = 10: &100 n^2 = 10000 &&> 2^n = 1024\
  n = 12: &100 n^2 = 14400 &&> 2^n = 4096\
  n = 13: &100 n^2 = 16900 &&> 2^n = 8192\
  n = 14: &100 n^2 = 19600 &&> 2^n = 16384\ 
  #high1[$bold(n = 15)$]: &100 n^2 = 22500 &&< 2^n = 32768\ 
  $

  Thus, the algorithm with a running time of $100 n^2$ will run faster than the algorithm with a running time of $2^n$ on the same machine for input sizes $n >= 15$.
]

#v(5mm)

#quest[1.4.5][
  Prove the following:
  1. $n! = o(n^n)$
  2. $lg(n!) = Theta(n lg n)$ [Prove it in two different ways, one using calculus.]
]

#ans[
  1. #[Let $c > 0$ be arbitrary. We need to show that $thereexists n_0 > 0$ such that
  $
  n! < c dot.c n^n quad forall n >= n_0
  $ or equivalently, $display(c > n!/n^n)$.
  $
  => n!/n^n &= 1/n dot 2/n dot dots.c dot (n-1)/n dot n/n\
  &= product_(i=1)^floor(n\/2) i / n times product_(i=floor(n\/2) + 1)^n i / n
  $
  Here, for $i = 1$ to $floor(n/2)$, we have $i/ n <= 1/2$, and for $i = floor(n/2) + 1$ to $n$, $i/n <= 1$.

  Thus,
  $
  n!/n^n &<= (1/2)^floor(n\/2) <= (1/2)^(n\/2) < c
  $

  $
  (1/2)^(n\/2) < c &=> -n/2 < lg c\
  &=> n > -2 lg c
  $

  Thus, for any arbitrary $c > 0$, we can choose $n_0 = max(- 2 lg c, 0)$, such that $n! < c dot n^n thick forall n > n_0$. This shows that $n! = o(n^n)$.

      #strong(high2("Method 2:"))

    We can directly use the Stirling approximation:

    $
    n! = sqrt(2 pi n) (n/e)^n (1 + Theta(1/n))
    $

    Consider $f(n) = n!$, $g(n) = n^n$.

    Then

    $
    lim_(n->oo) f(n)/g(n) = lim_(n->oo) n!/n^n = lim_(n->oo) sqrt(2 pi n) /e^n (1 + Theta(1/n)) = 0
    $
    Thus, $n! = o(n^n)$.
  ] #h(1fr)

  2. #[
    We have,
    $
      lg(n!) = sum_(i=1)^n lg(i) <= sum_(i=1)^n lg(n)<= n lg n 
    $
    This shows that $lg(n!) = bigO(n lg n)$.

    Also, 
    $
    lg(n!) &= sum_(i=1)^n lg(i)\
    &= sum_(i=1)^ceil(n\/2) lg (i) + sum_(i = ceil(n\/2) + 1)^n lg(i)\
    $

    Here, for $i = 1$ to $ceil(n/2)$, $lg(i) >= 0$, and for $i = ceil(n/2) + 1$ to $n$, $lg(i) >= lg(n/2)$.

    Thus, 
    $
    lg(n!) &>= sum_(i=ceil(n\/2) + 1)^n lg(n/2) = floor(n/2) lg(n/2) >= (n/2 - 1) lg(n/2)\
    &>= (1/2 n -1)(lg n - 1) = 1/2 n lg(n) - n/2 - lg(n) + 1\
    &>= 1/2 n lg(n) + 1 >= Theta(n lg n)
    $

    This shows that $lg (n!) = Omega(n lg n)$.

    Together, this implies that $lg(n!) = Theta(n lg n)$.

    #strong(high2("Method 2:"))

    We can apply Stirling's approximation:

    $
    n! &= sqrt(2 pi n) (n/e)^n (1 + Theta(1/n))\
    => lg(n!) &= lg sqrt(2pi) + 1/2 lg n + n lg n - n lg e + lg (1 + Theta(1/n))\
    &= Theta(n lg n)
    $

    
    #strong(high2("Method 3:"))

    Consider $lg(n!) = sum_(i=2)^n lg(i)$. Since $lg(x)$ is monotonically increasing, this sum is upper bounded by the integral $integral_2^(n+1) lg(x) dif x$, and lower bounded by the integral $integral_1^n lg(x) dif x$. This is clear from the below figures.

    
    #figure(cetz.canvas({
      import cetz.draw: *
      
     plot.plot(
       size: (12, 6), 
       x-label: $x$,
       y-label: $y$,
       x-tick-step: 1, 
       y-tick-step: none,
       y-ticks: (
         (0, 0),
         (calc.log(2, base: 2), $lg(2)$),
         (calc.log(3, base: 2), $lg(3)$),
         (calc.log(4, base: 2), $lg(4)$),
         (calc.log(5, base: 2), $lg(5)$),
         (calc.log(6, base: 2), $lg(6)$),
       ), 
       axis-style: "school-book",
       {
         plot.add(domain: (2, 6.5), x => calc.log(x, base:2),  hypograph: true)
         plot.add((
           (2, 0), 
           (2, calc.log(2, base: 2)),
           (3, calc.log(2, base: 2)),
           (3, 0),
           (3, calc.log(3, base: 2)),
           (4, calc.log(3, base: 2)),
           (4, 0),
           (4, calc.log(4, base: 2)),
           (5, calc.log(4, base: 2)),
           (5, 0),
           (5, calc.log(5, base: 2)),
           (6, calc.log(5, base: 2)),
           (6, 0),
           (6, calc.log(6, base: 2)),
           (6.5, calc.log(6, base: 2))
         ), hypograph: true)
         // plot.add(domain: (2, 6.5), x => calc.log(x - 1, base:2),  hypograph: true,)
         for i in range(2, 7) {
           plot.add(
             (
               (1, calc.log(i, base: 2)), 
               (i, calc.log(i, base: 2))
             ),
             style: (stroke: (dash: "dotted")),
             
           )
         }
         plot.add(domain: (1, 2), x => calc.log(x, base:2),  style: (stroke: blue))
       }
     )
    }), caption: [Plot showing $sum_(i=2)^n lg(i) < integral_2^(n+1) lg(x) dif x$. The blue plot represents $lg(x)$ and the red rectangles represent the discrete sum.])


    #figure(cetz.canvas({
      import cetz.draw: *
      
     plot.plot(
       size: (12, 6), 
       x-label: $x$,
       y-label: $y$,
       x-tick-step: 1, 
       y-tick-step: none,
       y-ticks: (
         (0, 0),
         (calc.log(2, base: 2), $lg(2)$),
         (calc.log(3, base: 2), $lg(3)$),
         (calc.log(4, base: 2), $lg(4)$),
         (calc.log(5, base: 2), $lg(5)$),
         (calc.log(6, base: 2), $lg(6)$),
       ), 
       axis-style: "school-book",
       {
         plot.add((
           (1, 0), 
           (1, calc.log(2, base: 2)),
           (2, calc.log(2, base: 2)),
           (2, 0),
           (2, calc.log(3, base: 2)),
           (3, calc.log(3, base: 2)),
           (3, 0),
           (3, calc.log(4, base: 2)),
           (4, calc.log(4, base: 2)),
           (4, 0),
           (4, calc.log(5, base: 2)),
           (5, calc.log(5, base: 2)),
           (5, 0),
           (5, calc.log(6, base: 2)),
           (6, calc.log(6, base: 2)),
           (6, 0),
           (6, calc.log(7, base: 2)),
           (6.5, calc.log(7, base: 2))
         ), hypograph: true, style: (stroke: red, fill: red.lighten(80%)))
         // plot.add(domain: (2, 6.5), x => calc.log(x - 1, base:2),  hypograph: true,)
         plot.add(domain: (1, 6.5), x => calc.log(x, base:2),  hypograph: true, style: (stroke: blue, fill: blue.lighten(80%)))

         for i in range(2, 7) {
           plot.add(
             (
               (1, calc.log(i, base: 2)), 
               (i - 1, calc.log(i, base: 2))
             ),
             style: (stroke: (dash: "dotted")),
             
           )
         }
       }
     )
    }), caption: [Plot showing $sum_(i=2)^n lg(i) > integral_1^(n) lg(x) dif x$. The blue plot represents $lg(x)$ and the red rectangles represent the discrete sum. Note that here the red rectangles are shifted left, as compared to the previous figure.])


    #infobox[
      We can give a general statement for the above observation:

      For a continuous monotonically increasing function $f(x)$, we have

      $
       integral_(a-1)^b f(x) dif x <= sum_(i=a)^b f(i) <= integral_a^(b+1) f(x) dif x
      $

      Also, the reverse inequality holds for a monotonically decreasing function.
    ]

    Thus,

    $
    integral_1^n lg(x) dif x <= sum_(i=2)^n lg(i) <= integral_2^(n+1) lg(x) dif x\
    $

    We can simplify the integrals: 
    $
    integral lg(x) dif x = 1/log(2) integral log(x) dif x = 1/log(2) (x log x - x)
    $

    So we have,
    $
    1/log(2) (n log n - n + 1) &<= lg(n!) \ &<= 1/log(2) ((n+1) log (n + 1) - n - 2 log 2  + 2) $$
    => Theta(n lg n) <= lg(n!) <= Theta(n lg n)
    $

    Hence, this shows that $lg(n!) = Theta(n lg n)$.
  ]
]

#v(5mm)
#align(center, line(length: 50%))