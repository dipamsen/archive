#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/cetz:0.5.2"


#show: project.with(
  subject: "Algorithms II",
  topic: "Karger's Min Cut"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Karger's Min Cut]

Here, we discuss a randomised polynomial time algorithm to compute a cut of minimum size in an unweighted undirected graph.

= Randomized Algorithms

A randomized algorithm is an algorithm which uses randomness to make some choice in its procedure. This means, the algorithm uses some source of random bits to guide its behaviour, in hopes of achieving *good performance* (in terms of *running time* or *correctness*), in the _average case_ over all possible random choices made.

Thus, for a randomized algorithm, either the running time of the algorithm, or the output of the algorithm, (or both) will be a random variable.

We can thus broadly classify randomized algorithms into two categories:
+ *_Las-Vegas_ type randomized algorithms*: These randomized algorithms always output a correct result (so their output is deterministic), but their running time depends on the random bits used. (The time complexity is a random variable.)

+ *_Monte-Carlo_ type randomized algorithms*: These randomized algorithms run in similar time regardless of the random bits (deterministic time complexity), however it may sometimes answer wrongly. (The output is a random variable.)

An example of a _Las-Vegas_ type randomized algorithm is Quicksort. For these types of algorithms, we study their expected time complexity.

The algorithms that we will discuss here are examples of _Monte-Carlo_ type randomized algorithms. For these types of algorithms, we study the probability that the algorithm outputs a correct (or a wrong) result.


= Setup

Let $G = (V, E)$ be an undirected unweighted graph, $G$ may have parallel edges (but no self-loops).

A *cut* of $G$ is a non-empty strict subset $U subset.neq V, U != phi$ of the vertices. The *size of a cut* $w(U)$ is the number of edges whose exactly one end point belongs to $U$, i.e.
$
  w(U) = lr(|{{x, y} in E | x in U, y in.not U}|)
$

The *min-cut* problem is computing a cut of minimum size in $G$. Alternatively, the size of a min-cut is the minimum number of edges to be removed from $G$ to make it disjoint.

We can give a flow-based algorithm that finds the min-cut which runs in polynomial time. Here we discuss a randomised algorithm for solving this problem.


= Karger's Randomized Min-Cut Algorithm

== Edge Contraction

For a graph $G = (V, E)$, let $e = {x, y} in E$ be an edge. Then, define the operation *edge-contraction* of $e$ in $G$ as follows:
1. Remove the vertices $x$ and $y$ (and all their edges).
2. Add a new vertex $v_(x y)$. Add edges from $v_(x y)$ to all vertices which were earlier adjacent to $x$ or $y$. (this may introduce parallel edges). Don't add any self-loop.
Call the resulting graph $G \/ e$.

== The algorithm

#algorithm("Karger-Min-Cut", params: ([$G$],))[
  #aline[#While $|V| > 2$]
  #aline(indent: 1)[pick an edge $e$ uniformly at random]
  #aline(indent: 1)[contract $e$ in $G$]
  #aline[let $U$ be the set of vertices that contracted to form one of the remaining vertices]
  #aline[#Return $U$]
]

On the graph $G$, continuously contract edges randomly. Do so until you are left with 2 vertices. Return this cut as the min cut of $G$.

(Yes, #link("https://www.pasteboard.co/kauDs0kN528x.png")[you read that right], that's exactly what the algorithm is!)

// EXAMPLE

== Error Bound

Ok, so the algorithm won't always find the min-cut, it might return a cut which isn't the min-cut. We want to get a bound on the probability that the cut found is not a min-cut, i.e. the algorithm reports an incorrect output.

=== Some Observations

Consider a cut $S$ in $G$, and an edge ${u, v} in E$. Say, that the cut $S$ is *killed* by $e$ if $u$ and $v$ are on the opposite sides of the cut, i.e. $u in S, v in.not S$ or $u in.not S, v in S$. Otherwise (if both vertices are on the same side of the cut), say that cut $S$ *survives* $e$.

This notion indicates, that if we ever contract the edge $e = {u, v}$, then whatever the final cut will be obtained, necessarily $u$ and $v$ must be on the same side of the cut  (since during contraction, we merged them into the same vertex). So any cut $S$ where $u$ and $v$ are on the opposite sides are _killed_, in the sense that they are eliminated from the list of potential cuts that the algorithm could have output.

Then, we have the following observation:

#theorem(title: "Contraction preserves surviving cuts", numbered: false)[
  Let $G = (V, E)$ be an undirected graph. Let $G' = G \/ e$ for some $e in E$. The cuts of $G'$ are in one-to-one correspondence with the cuts of $G$ that survived $e$, with corresponding cuts having the same size.
]

*Proof*: Let $S$ be a cut that survived $e = {x, y}$, so assume WLOG, $x, y in S$, then $S' = (S without {x, y}) union {v_(x y)}$ is the corresponding cut in $G'$. Conversely, if $S'$ is a cut of $G'$ with $v_(x y) in S'$, then $S = (S' without {v_(x y)}) union {x, y}$ is the corresponding surviving cut of $G$. By definition of edge contractions, all edges are preserved (other than the ${x, y}$ edge), so their sizes are the same. #h(1fr)$square$

Thus, by applying this lemma repeatedly, we get the following observation: *after a sequence of contractions, the cuts of the current graph are exactly the cuts of $G$ that survived every edge contraction.*

Another observation that we will use is the *handshaking lemma*: In a graph $G$ with $n$ vertices, suppose the size of the min-cut is $k$. Then, for any vertex $v$, its degree must be at least $k$ (why?). Then, the total number of edges in the graph is at least $n k\/2$.

=== Calculation

Let $k$ be the size of a min-cut of $G$. Fix a min-cut $X$, and let $F$ be the set of the $k$ edges crossing $X$. Let $G_i$ denote the graph when $i$ vertices remain, so $G_n = G$ and the algorithm stops at $G_2$.

Let $e_i$ be the edge that was contracted at stage $G_i$. (So the first edge contracted is $e_n$ and the last edge contracted is $e_3$.)

*Observation.* The run outputs $X$ if and only if none of $e_n, e_(n-1), dots, e_3$ are in $F$.

- If some contracted edge lies in $F$, it kills $X$, so $X$ cannot be the output.
- If none does, $X$ survives all the contractions. By the lemma, $X$ is a cut of $G_2$. But $G_2$ has two vertices, so it has exactly one cut, and that cut must be $X$.

Thus, the probability of the algorithm outputting a fixed min-cut $X$ is exactly the probability that no $e_i in F$.

Initially, the graph has $m = |E|$ edges. The probability that the first edge chosen for contraction is not in $F$ is
$
  p_n = 1 - k / m
$
Now, we know that $m >= (n k)/2$. So,
$
  p_n >= 1 - k / ((n k)/2) = 1 - 2 / n = (n - 2) / n
$
Similarly, the probability that the second edge chosen is not in $F$ is $p_(n - 1) = (n - 3) / (n - 1)$, and so on.


So the overall probability that no contracted edge kills $X$ is
$
  product_(i = 3)^n p_i >= (n - 2) / n times (n - 3) / (n - 1) times ... times 2 / 4 times 1 / 3 = 2 / (n (n - 1)).
$

A single run of Karger's algorithm returns any fixed min-cut $X$ with probability at least $2 slash (n (n - 1))$. Hence it returns _some_ min-cut with at least this probability, and thus the error probability is
$
  p_"fail" <= 1 - 2 / (n (n - 1)).
$


== Improving the error bound

For large $n$ this is a poor bound: the failure probability approaches 1 asymptotically. Can we do better?

Consider the following procedure:
1. Run #op("Karger-Min-Cut") on $G$ independently $c$ times, for some value of $c$.
2. Return the smallest cut found among the $c$ runs.

The procedure fails only if _none_ of the $c$ runs finds a min-cut. The runs use independent random bits, so this probability is the product of the individual failure probabilities:
$
  p_"fail"^c <= (1 - 2 / (n (n - 1)))^c.
$

How large should $c$ be to make this failure probability our desired (constant) value?

If we choose $c = (n (n - 1)) \/ 2$, we get
$
  p_"fail"^c <= (1 - 2 / (n (n - 1)))^(n (n - 1) \/ 2) = (1 - 1 / c)^c <= 1 / e,
$
using the inequality $1 - x <= e^(-x)$ for all real $x$. So with $c = n(n - 1) \/ 2 = O(n^2)$ repetitions#footnote[Observe, that we bounded the success probability of one run to $Omega(1/n^2)$, so we require $O(n^2)$ repetitions to get a constant success probability. This is a general idea in randomised algorithm design: We try to get the success probability to the order of reciprocal of some polynomial in $n$, then we can achieve a constant success probability within polynomial number of repititions.], the algorithm finds a min-cut with probability at least $1 - 1 \/ e approx 0.63$. (We can get to any arbitrary constant probability by multiplying $c$ with a constant value.)


== Time Complexity

By representing the graph $G$ as an adjacency matrix, one edge contraction step can be performed in $O(n)$ time.

Then, one run of #op("Karger-Min-Cut") requires $n - 2$ edge contractions, so it takes $O(n^2)$ time.

For achieving a constant error bound, we need to repeat the procedure for $O(n^2)$ times. So the overall time complexity of this algorithm is $O(n^4)$.

== An unrelated result

This leads to an interesting corollary, on the number of min-cuts in a graph. Suppose a graph $G$ has $k$ min-cuts, $X_1$, $X_2$, ..., $X_k$. For each $X_i$, the probability that the algorithm outputs $X_i$ is $2/(n (n - 1))$. Since the algorithm will output exactly one min-cut, these probabilities are disjoint, and can be added:

$
  sum_(i = 1)^k P(X_i) = (2 k) /  (n (n - 1)) <= 1\
  => k <= (n (n - 1)) / 2 = binom(n, 2)
$

So, $binom(n, 2)$ is an upper bound on the number of min-cuts that a graph can have. (This bound is actually tight, and is realised in cycle graphs.)

#pagebreak()

= Karger-Stein Algorithm for Min-Cut

An extension of the above algorithm due to Karger and Stein achieves an order of magnitude improvement.


== Key Observation

The analysis of Karger's algorithm shows that the early contractions are very safe, while the later ones are risky. When the graph has $i$ vertices, the probability that the contracted edge does not lie in $F$ (i.e. min-cut $X$ is not killed) is at least $(i - 2) / i$. This is close to $1$ for large $i$, but only $1 / 3$ when $i = 3$.

Let's only perform the edge contractions for the first few contractions, say till $t$ vertices remain. Thus the probability that $X$ survives the contractions from $n$ vertices down to $t$ vertices is at least
$
  product_(i = t + 1)^n (i - 2) / i = (n - 2) / n times (n - 3) / (n - 1) times ... times (t - 1) / (t + 1) = (t (t - 1)) / (n (n - 1)).
$

Now choose $t = 1 + n \/ sqrt(2)$, i.e. perform $n - n \/ sqrt(2) - 1$ contractions. Then $t (t - 1) >= (1 + n \/ sqrt(2)) (n \/ sqrt(2)) >= n^2 \/ 2$, so
$
  P("X survives the first" n - n \/ sqrt(2) - 1 "contractions") >= (n^2 \/ 2) / (n (n - 1)) >= 1 / 2.
$

Hence, the probability that Karger's algorithm does _not_ output the cut $X$ is small (at most $1 \/ 2$) until the first $n - n \/ sqrt(2) - 1$ iterations, and grows rapidly after that. The idea of Karger and Stein is to run Karger's algorithm for $n - n \/ sqrt(2) - 1$ iterations, and then recurse on the remaining graph twice, and keep the best solution.

== The algorithm

#algorithm("Karger-Stein", params: ([$G$],))[
  #aline[#If $|V| = 2$: #Return the cut]
  #aline[run the contraction algorithm on $G$ for $n - n \/ sqrt(2) - 1$ iterations; let $G'$ be the resulting graph]
  #aline[$U_1 <-$ #op("Karger-Stein");($G'$)]
  #aline[$U_2 <-$ #op("Karger-Stein");($G'$)]
  #aline[#Return the better of $U_1$ and $U_2$]
]

Here, $U_1$ and $U_2$ are computed by two independent recursive calls on the same contracted graph $G'$ (each makes its own random choices).

== Time Complexity

Let us first analyse the running time $T(n)$ of the algorithm. Using an adjacency matrix, we can perform each contraction in $O(n)$ time. Hence, we have the following recurrence:
$
  T(n) = cases(
    2 T(n \/ sqrt(2)) + O(n^2) quad & "when" n >= 3,
    O(1) & "otherwise".
  )
$
The solution of the above recurrence, using the master's theorem, is
$
  T(n) = O(n^2 log n).
$

== Error Bound

As before, let $X$ be a min-cut of $G$ with edges $F$, we want the probability that the algorithm returns $X$. For this, we need to analyse the recursion tree for this algorithm.

#figure(
  cetz.canvas({
    import cetz.draw: *
    import cetz.tree: tree

    set-style(stroke: 0.6pt)
    let ks-tree = (
      [$n$],
      (
        [$n slash sqrt(2)$],
        ([$n slash 2$], ([$dots.v$], $2$), ([$dots.v$], $2$)),
        ([$n slash 2$], ([$dots.v$], $2$), ([$dots.v$], $2$))
      ),
      (
        [$n slash sqrt(2)$],
        ([$n slash 2$], ([$dots.v$], $2$), ([$dots.v$], $2$)),
        ([$n slash 2$], ([$dots.v$], $2$), ([$dots.v$], $2$))
      )
    )

    // Draw the tree
    tree(
      ks-tree,
      direction: "down",
      spread: 1, // Widened to fit edge labels
      grow: 1,   // Increased vertical spacing
      draw-node: (node, ..) => {
        circle((), radius: 0.6, stroke: if node.content != $dots.v$ { black })
        content((), text(0.8em)[#node.content])
      },
      draw-edge: (from, to, ..) => {
        let in-path = "0-1-0-0-0".starts-with(to.name)
        line(
          from.group-name, 
          (to.group-name, 0.6, from.group-name), 
          mark: (end: "stealth", fill: black, scale: if in-path { 0.7 * 0.6 / 1.5 } else { 0.7 }),
          stroke: if in-path { 1.5pt + primary-color } else { 0.6pt }
        )
      }
    )

    for i in range(5) {
      content((-4, -i * 2.19), if i != 3 { text(0.8em)[
        height #if i == 4 { $0$ }
        #if i == 0 { $h = log_sqrt(2) n$}
        #if i == 1 { $h -1$}
        #if i == 2 { $h -2$}
      ] }, anchor: "west")
    }

  }, length: 0.7cm), caption: [Recursion tree for a run of #op("Karger-Stein")]
)

Each recursive call to #op("Karger-Stein") is represented by a node in the recursion tree. Since each call makes two recursive calls (other than the base case), the tree is a full binary tree. The recursive calls are made with a graph with $n\/sqrt(2)$ nodes, if the original graph had $n$ nodes. At the base case, the graph only has 2 nodes. Note that the input graph to both recursive calls made by a node is the same, only the random choices made by the two children differ.

At each non-leaf node, edge contractions are performed (randomly) to get the graph from $n$ nodes to $n\/sqrt(2)$ nodes. Each leaf node returns a cut. Finally, the output of the algorithm is the best cut of all the cuts returned by the leaf nodes.

We want to find the probability that the algorithm returns the cut $X$. For this to happen, there must be at least one leaf node which returns the cut $X$, so this means that $X$ survived all the edge contractions that happened in the path from the root node to this leaf.

*Observation*: At any non-leaf node, the probability that $X$ survives all the edge contractions that happen at this node is at least $1/2$.

(This follows from our original observation for the KS algorithm: we only perform enough contractions so that the probability of $X$ getting killed does not exceed $1/2$).

For some non-leaf node $v$, let $p(v)$ denote the probability that there exists some path from $v$ to a leaf node, such that $X$ survived every edge contraction on that path (call such a path a *good path*).

Let the left child and right child of $v$ be $v_L$ and $v_R$. Then we can find $p(v)$ as:
$
  p(v) &= P(X "survived edge contractions in" v) times P("either" v_L "or" v_R "has a good path")\
  &>= 1/2 times (1 - P("neither" v_L "nor" v_R "has a good path"))\
  &= 1/2 times (1 - P(v_L "does not have a good path") times P(v_R "does not have a good path"))\
$

Now, observe by symmetry, $p(v)$ must be same for all nodes at the same height. So, let's denote by $p(d) = p(v)$, for any node $v$ at a height $d$. Set $p(0) = 1$.

Then,
$
  p(d) &>= cases(display(1/2 times (1 - (1 - p(d - 1))^2)) quad quad &"if" d > 0, 1 quad quad &"if" d = 0)
$

Simplifying the recurrence for $d > 0$,
$
  p(d) >= 1/2 (1 - (1 - p(d - 1))^2) = 1/2 (2 p(d - 1) - p(d - 1)^2) = p(d - 1) - 1/2 p(d - 1)^2.
$

*Claim*: $p(d) >= 1/(d + 2)$.

*Proof*: By induction on $d$. For $d = 0$ we have $p(0) = 1 >= 1 \/ 2$. For $d > 0$, assume $p(d - 1) >= 1 \/ (d + 1)$. The function $f(y) = y - y^2 \/ 2$ is increasing on $[0, 1]$ (since $f'(y) = 1 - y >= 0$), and $p(d) = f(p(d - 1))$, so
$
  p(d) >= f(1 / (d + 1)) = 1 / (d + 1) - 1 / (2 (d + 1)^2) >= 1 / (d + 1) - 1 / ((d + 1)(d + 2)) = 1 / (d + 2)
$
where the last inequality uses $2 (d + 1) >= d + 2$. #h(1fr)$square$

The root of the recursion tree has height $h = log_sqrt(2) n = 2 log_2 n$, and its input is $G$ itself. Hence the probability that the algorithm outputs $X$ is
$
  p(h) >= 1 / (h + 2) = 1 / (2 log_2 n + 2) = Omega(1 / (log n))
$

== Improving the error bound

A single run of #op("Karger-Stein") succeeds with probability $Omega(1 \/ log n)$ in time $O(n^2 log n)$. 

We repeat the algorithm independently $Theta(log n)$ times and return the smallest cut found. By the same argument as earlier (using $1 - x <= e^(-x)$), this boosts the success probability to $Omega(1)$ (constant probability). The overall running time of the algorithm is
$
  O(log n) times O(n^2 log n) = O(n^2 log^2 n).
$

This is a substantial improvement over the $O(n^4)$ time of the basic algorithm.

#figure(table(
  columns: 3,
  stroke: 0.7pt,
  align: (left, center, center),
  [*Algorithm*], [*Time per run*], [*Total time for constant success probability*],
  [#op("Karger")], [$O(n^2)$], [$O(n^4)$],
  [#op("Karger-Stein")], [$O(n^2 log n)$], [$O(n^2 log^2 n)$],
), caption: [Time complexities of the algorithms discussed])

#pagebreak()

= Problems and Solution Sketches

1. Prove that the worst-case time complexity of one run of Karger's min-cut algorithm is $O(n^2)$. Assume that we can pick an edge uniformly randomly in $O(log m)$ time.


#soln-box[
  One run of Karger's min-cut algorithm involves $n - 2$ iterations of the following steps:
  1. Choosing an edge uniformly at random ($O(log m)$, given)
  2. Contracting the edge ($O(n)$, will show)

  Thus, the worst case time complexity of one run of Karger's min-cut algorithm is $O(n) times O(n + log m) = O(n^2)$.

  *Edge Contraction:* Using an adjacency matrix, it can be implemented in $O(n)$ (show).
]


2. Extend Karger's Min-Cut algorithm for weighted undirected graphs with positive edge weights without changing its worst-case time complexity.

#soln-box[
  Let $G = (V, E, w)$ be an undirected graph with positive edge weights $w: E -> RR_(> 0)$, given as an $n times n$ weighted adjacency matrix (so there are no parallel edges or self-loops). The *weight* of a cut $U$ is $w(U) = sum_({x, y} in E, x in U, y in.not U) w({x, y})$, and a *min-cut* is a cut of minimum weight.

  Modify the Karger's min-cut algorithm as follows:

  Instead of choosing the edge uniformly at random, assign probabilities for each edge to be chosen as follows:
  $
    p(e) = w_e / (sum_(e in E) w_e) = w_e / W
  $

  So, the modified algorithm is: iteratively choose an edge by sampling from this probabilty distribution, and the contract that edge. When only two vertices remain, return the corresponding cut.

  - In this modified version, similarly choosing an edge and contracting the edge can be implemented in $O(n)$ time (show). Thus, one run of the algorithm runs in $O(n^2)$.

  Error bound:
  - The cuts of $G \/ e$ correspond to the cuts of $G$ that are not killed by $e$, with the same weights.
  - If the min-cut has weight $k$, every vertex has _weighted degree_ at least $k$, so $W >= n k \/ 2$ when $n$ vertices remain.
  - When $i$ vertices remain and $X$ has survived so far, the probability that the next contracted edge kills $X$ is at most $2 \/ i$.
  - The probability that $X$ is returned is at least $2\/(n (n - 1))$.

  Thus, by the same analysis we can repeat the algorithm for $Theta(n^2)$ times to get constant success probability. Therefore the algorithm runs in worst case $O(n^4)$.
]


