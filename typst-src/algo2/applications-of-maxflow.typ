#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Applications of Maximum Flow"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Applications of Maximum Flow]

We have studied the maximum flow problem, and discussed various algorithms for computing a maximum flow in a network. We have already discussed that many different situations can be modelled as a flow network, such as fluid in pipes, currents in a circuit, or traffic in a computer network to name a few. As it turns out, there are also a surprising number of seemingly unrelated problems, that can be *reduced* into a maximum flow problem. Thus, efficient max-flow algorithms can be used to solve these problems. We look at some of such problems in this module.

= Min Cut Problem

Given a flow network $G = (V, E)$, we wish to find a partition of $V$, $(S, T)$, having minimum capacity, i.e. $
  min_("cut" (S, T))sum_(u in S, v in T\ (u, v) in E) c(u, v)
$

We have already discussed previously, that we can find a minimum cut by first finding a max-flow $f$ of $G$, computing its residual graph $G_f$, and then finding the set $S = { v in V | v "is reachable from" s "in" G_f }$ by doing a BFS from $s$. Then, ${S, V without S}$ is a minimum cut.



#let node = node.with(radius: 4mm)

#let d3 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s", stroke: red)
  node((1, -1), $v_1$, name: "v1", stroke: red)
  node((1, 1), $v_2$, name: "v2", stroke: red)
  node((4, -1), $v_3$, name: "v3", stroke: blue)
  node((4, 1), $v_4$, name: "v4", stroke: red)
  node((5, 0), $t$, name: "t", stroke: blue)

  edge(<s>, <v1>, "-|>", $11\/16$)
  edge(<s>, <v2>, "-|>", $12\/13$, label-side: right)
  edge(<v1>, <v3>, "-|>", $12\/12$)
  edge(<v2>, <v1>, "-|>", $1\/4$, label-side: left)
  edge(<v3>, <v2>, "-|>", $0\/9$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $11\/14$)
  edge(<v4>, <v3>, "-|>", $7\/7$)
  edge(<v3>, <t>, "-|>", $19\/20$)
  edge(<v4>, <t>, "-|>", $4\/4$, label-side: right)
}, spacing: 0.8cm)


#let d4 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s", stroke: red)
  node((1, -1), $v_1$, name: "v1", stroke: red)
  node((1, 1), $v_2$, name: "v2", stroke: red)
  node((4, -1), $v_3$, name: "v3", stroke: blue)
  node((4, 1), $v_4$, name: "v4", stroke: red)
  node((5, 0), $t$, name: "t", stroke: blue)

  edge(<s>, <v1>, "-|>", $5$, bend: -10deg, label-sep: 0pt)
  edge(<s>, <v1>, "<|-", $11$, bend: 10deg)
  edge(<s>, <v2>, "-|>", $1$, bend: 10deg, label-sep: 0pt)
  edge(<s>, <v2>, "<|-", $12$, bend: -10deg)
  edge(<v1>, <v3>, "<|-", $12$)
  edge(<v2>, <v1>, "-|>", $3$, bend: 10deg, label-sep: 0pt)
  edge(<v2>, <v1>, "<|-", $1$, bend: -10deg)
  edge(<v3>, <v2>, "-|>", $9$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $3$, bend: 10deg)
  edge(<v2>, <v4>, "<|-", $11$, bend: -10deg)
  edge(<v4>, <v3>, "<|-", $7$)
  edge(<v3>, <t>, "-|>", $1$, label-side: left, bend: 10deg)
  edge(<v3>, <t>, "<|-", $19$, bend: -10deg, label-sep: 0pt)
  edge(<v4>, <t>, "<|-", $4$, label-side: right)
}, spacing: 0.8cm)

#figure(grid(
  columns: 2, gutter: 3em,
  d3, d4
), caption: [A flow network $G$ with a max flow $f$. $S = {s, v_1, v_2, v_4}$. $(S, V without S)$ is a min-cut of $G$.])


Observe, that instead of giving an algorithm for the Min-Cut problem, we instead showed a procedure to solve a Min-Cut problem, provided that we have some way to solve an instance of the Max-Flow problem. In other words, we have shown that, if we have a subroutine to find a maximum flow in a flow network, we can use it to find a minimum cut in the flow network. We say, that *the minimum cut problem _reduces_ in linear time to the maximum flow problem*.

Such a conversion of an instance of one problem X into an instance of another problem Y, such that the solution of the instance of problem Y can be used to get a solution of the instance of the problem X is called a *reduction*. In this case, since this conversion can be done in linear time, this is a *linear time reduction* (which is in fact a *polynomial time reduction*).

= Maximum Bipartite Matching

Now we look at a completely different problem (seemingly unrelated to network flows), which is the bipartite matching problem. Before presenting the problem, let us define a few terms:

Given a graph $G = (V, E)$, a *matching* $M$ in $G$ is a subset of edges, such that no two edges share any common vertex.

A graph $G = (V, E)$ is said to be *bipartite*, if there exists a partition of $V$ into $A$ and $B$, $A union.plus B = V$ ($A union.plus B$ denotes a disjoint union, i.e. $A union B$ where $A$ and $B$ are disjoint sets.), such that all $e in E$ are between $v_1 in A$ and $v_2 in B$. No edges connect vertices $(v_1, v_2)$ such that $v_1, v_2 in A$ or $v_1, v_2 in B$.

The *maximum bipartite matching* problem: Given a bipartite graph $G = (V = A union.plus B, E)$ with $|A| = |B|$, find a maximum-cardinality matching in $G$.

A *perfect matching* in a graph $G$ is a matching which covers every vertex of the graph. In a bipartite graph $G = (V = A union.plus B, E)$ where $|A| = |B| = n$, if a perfect matching exists, the cardinality of a perfect matching is $n$.

#let node = node.with(radius: 3.5mm)
#let bipartite(n, edges: (:), matching: ()) = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  {
    for i in range(n) {
      node((0, i), text(0.9em, $a_#(i+1)$), name: label("a_" + str(i+1)))
      node((2, i), text(0.9em, $b_#(i+1)$), name: label("b_" + str(i+1)))
    }

    for (k, v) in edges.pairs() {
      for b in v {
        let hl = (int(k), b) in matching
        edge(label("a_" + k), "-", label("b_" + str(b)), stroke: if hl { 1.5pt + primary-color } else { auto }, mark-scale: if hl { 0.4 } else { 1 })
      }
    }
}, spacing: (0.8cm, 0.4cm))


#let flownet(n, edges: (:), matching: ()) = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  {

    node((-1, (n - 1) / 2), $s$, name: <s>)
    node((3, (n - 1) / 2), $t$, name: <t>)

    for i in range(n) {
      let hl1 = matching.any(x => x.first() == i + 1)
      let hl2 = matching.any(x => x.last() == i + 1)
      edge(<s>, "-|>", label("a_" + str(i + 1)), text(0.7em, $1$), label-sep: 2pt, label-side: if i >= n / 2 { right } else { left }, stroke: if hl1 { 1.5pt + primary-color } else { auto }, mark-scale: if hl1 { 0.4 } else { 1 })
      edge(label("b_" + str(i + 1)), "-|>", <t>, text(0.7em, $1$), label-sep: 2pt, label-side: if i >= n / 2 { right } else { left }, stroke: if hl2 { 1.5pt + primary-color } else { auto }, mark-scale: if hl2 { 0.4 } else { 1 })

      node((0, i), text(0.9em, $a_#(i+1)$), name: label("a_" + str(i+1)))
      node((2, i), text(0.9em, $b_#(i+1)$), name: label("b_" + str(i+1)))
    }

    for (k, v) in edges.pairs() {
      for b in v {
        let hl = (int(k), b) in matching
        edge(label("a_" + k), "-|>", label("b_" + str(b)), stroke: if hl { 1.5pt + primary-color } else { auto }, mark-scale: if hl { 0.4 } else { 1 })
      }
    }
}, spacing: (0.8cm, 0.4cm))


#let d1 = bipartite(5, edges: ("1": (1, 2), "2": (1, 2), "3": (1, 2), "4": (2, 3, 4), "5": (4, 5)))
#let d2 = bipartite(5, edges: ("1": (1, 2), "2": (1, 2), "3": (1, 2), "4": (2, 3, 4), "5": (4, 5)), matching: ((1, 2), (2, 1), (4, 3), (5, 4)))
#let d3 = bipartite(5, edges: ("1": (2, 3), "2": (1, 2), "3": (2, 4), "4": (1, 2, 5), "5": (4, 5)))
#let d4 = bipartite(5, edges: ("1": (2, 3), "2": (1, 2), "3": (2, 4), "4": (1, 2, 5), "5": (4, 5)), matching: ((1, 3), (2, 1), (3, 2), (4, 5), (5, 4)))

#figure(
  grid(columns: 5, gutter: 3em, d1, d2, h(0em), d3, d4),
  caption: [Bipartite graphs $G_1$ and $G_2$, and maximal matchings $M_1$ and $M_2$ in them. $|M_1| = 4$, $|M_2| = 5$. $G_1$ does not have any perfect matching. $G_2$ has a perfect matching. ($M_2$ is one.)]
)

== Reduction to Max-Flow

We will show that the maximum-cardinality matching problem on bipartite graphs _reduces_ in linear time to the maximum flow problem on flow networks.

To find a maximum-cardinality matching on a bipartite graph $G = (V = A union.plus B, E)$, we first define a directed graph $G' = (V', E')$, $V' = V union {s, t}$, $E' = {(u, v) | (u, v) in E, u in A, v in B} union {(s, a) | a in A} union {(b, t) | b in B}$. Essentially, we add a source and a sink node, direct all edges from $A$ to $B$, and add edges from the source to vertices in $A$, and from vertices in $B$ to the sink. We give capacity $1$ to all edges connected to $s$ or $t$, and capacity $oo$ to all other edges (ones that are between $A$ and $B$).


#figure(
  grid(
    columns: 2,
    gutter: 3em,
    bipartite(4, edges: ("1": (2, 3), "2": (1, 2), "3": (3, 4), "4": (2,))),
    flownet(4, edges: ("1": (2, 3), "2": (1, 2), "3": (3, 4), "4": (2,)))
  ),
  caption: [A bipartite graph $G$ and its corresponding flow network $G'$ as per our construction. Unlabelled edges have a capacity of $oo$.]
)

We find a integral maximum flow $f$ on $G'$.#footnote[All the max-flow algorithms we have discussed will necessarily find an integral max flow on a network with integral edge capacities. (In an integral flow, flow values on all edges are integral, not just the net value of the flow.)] Once we have this flow, choose $M = {(u, v) in E | f(u, v) = 1}$, i.e. select the edges from $G$ whose corresponding edges in $G'$ have positive flow in $f$. Then, $M$ is a maximum-cardinality matching of $G$.

#figure(
  grid(
    columns: 2,
    gutter: 3em,
    flownet(4, edges: ("1": (2, 3), "2": (1, 2), "3": (3, 4), "4": (2,)), matching: ((1, 3), (2, 1), (3, 4), (4, 2))),
    bipartite(4, edges: ("1": (2, 3), "2": (1, 2), "3": (3, 4), "4": (2,)), matching: ((1, 3), (2, 1), (3, 4), (4, 2))),
  ),
  caption: [(a) Maximum flow of $G'$. Highlighted edges carry flow of $1$. (b) A maximum cardinality matching $M$ of $G$.]
)


As always, we have to show that it works!

#theorem(title: "Maximum-cardinality bipartite matching reduces to Max-flow", numbered: false)[
  Let $G = (A union.plus B, E)$ be a bipartite graph. Let $G' = (V', E')$ be the corresponding flow network constructed from $G$. The maximum cardinality of a matching in $G$ equals the maximum value of an $s-t$ flow in $G'$.
]

#lemma[If $G$ has a matching $M$ of size $k$, then there exists a flow $f$ in $G'$ with $|f| = k$.]

*Proof*: Let $M$ be a matching of $G$, with $|M| = k$. Let $M = {(u_1, v_1), ..., (u_k, v_k)}$. We can construct a flow $f$ in $G'$:
- $f(s, u_i) = 1$ for all $i = 1, 2, ..., k$
- $f(v_i, t) = 1$ for all $i = 1, 2, ..., k$
- $f(u_i, v_i) = 1$ for all $i = 1, 2, ..., k$
- For all other edges $(u, v) in E'$, $f(u, v) = 0$

Clearly, capacity constraints are satisfied. We need to show flow conservation:
- For some node $a in A$,
  - if $a = u_i$ for some $i$, then its only incoming edge is $(s, u_i)$ which has flow 1. One of its outgoing edges is $(u_i, v_i)$, which has flow 1. All other outgoing edges from $a$ have 0 flow since they don't exist in $M$ (by definition of a matching).
  - otherwise, its only incoming edge $(s, a)$ has 0 flow. All its outgoing edges also have zero flow, since they don't exist in $M$.
- For some node $b in B$,
  - if $b = v_i$ for some $i$, then its only outgoing edge is $(v_i, t)$ which has flow 1. One of its incoming edges is $(u_i, v_i)$ which has flow 1. All  other incoming edges to $b$ have 0 flow since they don't exist in $M$.
  - otherwise, its only outgoing edge $(b, t)$ has 0 flow. All its incoming edges also have zero flow, since they don't exist in $M$.

Hence, $f$ is a valid flow.

Value of the flow is the total outflow from $s$: $
  |f| = f(s, V - s) = sum_(a in A) f(s, a) = sum_(i = 1)^k f(s, u_i) + sum_(a in A\ a != u_i) f(s, a) = k + 0 = k
$

#lemma[If $G'$ has an integral flow $f$ with value $|f| = k$, then there exists a matching $M$ in $G$ with cardinality $k$.]

*Proof*: Let $G'$ have an integral flow $f$ with value $|f| = k$. Define a matching $M$ as follows:

$
  M = {(u, v) in E | u in A, v in B, f(u, v) = 1}
$

First let us show that flow in any edge in $f$ will be either $0$ or $1$. Suppose there is some edge $(u, v)$, $f(u, v) >= 2$. Clearly, $u in A, v in B$. (any other type of edge does not have capacity to hold flow $>= 2$.) Then, the outgoing flow from $u$ is $>= 2$. The only incoming edge to $u$ is $(s, u)$ which has a capacity of $1$, which is a contradiction, since flow cannot be conserved in this case. So, $f(u, v) in {0, 1}$ for all $(u, v) in E'$.

To show $M$ is a matching, we need to show that no vertex appears in more than one edge $e in M$.
- Let $a in A$. Suppose there are two edges $(a, b_1)$ and $(a, b_2)$ in $M$. This means, in $f$, $f(a, b_1) = 1$, $f(a, b_2) = 1$. So, total flow exiting $a$ is $>= 2$. The only incoming edge to $a$ is $(s, a)$, which has a capacity of $1$, which is a contradiction, since flow on $a$ isn't conserved.
- Let $b in B$ appear in more than one edge in $M$. Similarly, we can arrive at a contradiction.
Thus, $M subset.eq E$ is a valid matching.

Consider the cut $(s union A, B union t)$ in $G'$. Clearly, the flow through this cut is $|f| = k$. Then,

$
  f(s union A, B union t) &= |f| = k\
  => f(A, B) &= k\
  => sum_(u in A, v in B) f(u, v) &= k
$

Since the flow in any edge can only be $0$ or $1$, the value of the last summation is the count of the edges $(u, v)$, $u in A, v in B$, for which $f(u, v) = 1$, Therefore, $M$ has $k$ edges ($|M| = k$). #h(1fr) $qed$

The Theorem follows from these two lemmas.

== Perfect Matching

Given a bipartite graph $G = (A union.plus B, E)$, $|A| = |B| = n$, does $G$ contain a perfect matching?

We can find this just by the above procedure, find the maximum cardinality matching in $G$, check if the cardinality of the matching is $n$, if so, then it is a perfect matching. If not, then no perfect matching exists. (Why?)

In other words, the decision problem "Does $G$ have a perfect matching?", is equivalent to checking if the value of the max flow of $G'$ is $n$.

Observe that in Figure 3/4, $G$ has a perfect matching.


== Hall's Theorem

Here, we look at a characterisation of the above decision problem, i.e. Does $G$ have a perfect matching?

#figure(
  grid(columns: 5, gutter: 3em, d1, d2, h(0em), d3, d4),
  caption: [Graphs $G_1$ and $G_2$, and their maximal matchings. (Same as Figure 2, reproduced here for the sake of your PDF scrolling sanity.)]
)

Take a look at $G_1$ and $G_2$ in Figure 5. $G_2$ has a perfect matching, but $G_1$ does not. Could we give a succinct argument for why $G_1$ does not have any perfect matching, other than computing it via max-flow?

In the matching $M_1$, $a_3$ is not matched with any vertex in $B$. If we did match $a_3$ with some vertex, say $b_2$, then $a_1$ would become unmatched. The only other vertex that $a_1$ has an edge to is $b_1$, say we match these. Now, $a_2$ becomes unmatched, and the only other vertex $a_2$ has an edge to is $b_2$, but we have already matched it with $a_3$. So it seems like we can never match all of ${a_1, a_2, a_3}$ in graph $G_1$, however we try, one of these vertices gets left out.

Can we formalise this argument?

For some subset of vertices $S subset.eq A$, define the *neighbour set* of $S$: $N(S) = {b in B | exists a in S "s.t." (a, b) in E}$. So, $N(S)$ contains all vertices in $B$ that has some edge with a vertex in $S$.

In $G_1$, let $S = {a_1, a_2, a_3}$. Then, $N(S) = {b_1, b_2}$. Now, $|N(S)| < |S|$, which means the size of the neighbour set is smaller than the size of $S$ itself. From this, it is very clear, that no perfect matching can exist in $G$. Because if it did, then the matched vertices of $a_1, a_2, a_3$ would be distinct, and they would be in $N(S)$, which clearly there aren't enough vertices in $N(S)$ for that to happen.

In general, in a graph $G$, if we find some $S subset.eq A$ such that $|N(S)| < |S|$, then $G$ cannot have any perfect matching. In other words, for $G$ to have a perfect matching, a necessary condition is: for all $S subset.eq A$, $|N(S)| >= |S|$.

Hall's theorem states that this condition is a sufficient condition as well for existence of a perfect matching.

#theorem(title: "Hall's Theorem", numbered: false)[A bipartite graph $G = (V = A union.plus B, E)$ with $|A| = |B| = n$ has a perfect matching if and only if $|S| <= |N(S)|$ for every $S subset.eq A$.]

*Proof:* $[=>]$: Trivial.

$[arrow.double.l]$: Suppose the cardinality of a maximum matching in $G$ is $k$. Construct the flow network $G'$ from $G$ by adding $s$ and $t$, directing edges to go from $A$ to $B$ (all with capacity $oo$), and adding edges from $s$ to $a in A$, and from $b in B$ to $t$ (all with capacity $1$). We know that the value of the max flow of $G'$ is $k$.

By the max-flow min-cut theorem, there exists some cut $(U, W)$ such that $c(U, W) = |f| = k$.

Let $A_1 = U inter A, A_2 = A without A_1$; $B_1 = U inter B, B_2 = B without B_1$. (Note that some of these sets may be empty.)

#figure(cetz.canvas({
  import cetz.draw: *


  line((-1, 0), (0.8, 1.5))
  line((-1, 0), (0.8, 0))
  line((-1, 0), (0.8, -1.5))

  line((4.2, 1.5), (6, 0))
  line((4.2, 0), (6, 0))
  line((4.2, -1.5), (6, 0))

  line((1, 1.5), (4, 1.5))
  line((1, 0), (4, 1.5))
  line((1, 1), (4, -1), stroke: (paint: red, dash: "dotted"))
  line((1, -1.5), (4, 0))
  line((1, -1.5), (4, -1.5))

  circle((1, 0), radius: (0.7, 2), stroke: none, fill: primary-color.lighten(60%))
  circle((4, 0), radius: (0.7, 2), stroke: none, fill: primary-color.lighten(60%))

  circle((-1, 0), radius: 3mm, stroke: 1pt,  fill: white)
  content((-1, 0), $s$)

  content((1, 2.3), $A$)
  content((4, 2.3), $B$)

  content((1, 0.5), $A_1$)
  content((1, -1.2), $A_2$)

  content((4, 1.2), $B_1$)
  content((4, -0.5), $B_2$)

  circle((6, 0), radius: 3mm, stroke: 1pt, fill: white)
  content((6, 0), $t$)

  line((-1, -1.5), (6, 1.5), stroke: (paint: primary-color.darken(20%)))
  content((5.7, 1.7), $U$)
  content((6, 1.1), $W$)

}), caption: [Defining $A_1$, $A_2$, $B_1$, $B_2$ by the min cut $(U, W)$. The red dotted edge cannot exist.])


Since this is a cut with finite capacity, no edge having $oo$ capacity must cross the cut. This means, for all $a in A_1$, if $(a, b)$ is an edge, then $b in.not B_2, b in B_1$. So, $N(A_1) subset.eq B_1$. (Otherwise there will be an $oo$ edge crossing the cut.)

Now, calculate the capacity of the cut $(U, W)$:

$
  k = c(U, W) &= c(s union A_1 union B_1, A_2 union B_2 union t)\
  &= c(s, A_2) + c(A_1, B_2) + c(B_1, t)\
  &= |A_2| + 0 + |B_1|\
  &= n - |A_1| + |B_1|\
  &>= n - |A_1| + |N(A_1)| quad quad quad quad &&"since" N(A_1) subset.eq B_1\
  &>= n - |A_1| + |A_1| quad quad quad quad &&"since" |A_1| <= |N(A_1)|\
  &= n
$

So, $k >= n$, but we know that max-cardinality  of a matching can't be $> n$, thus $k = n$. Hence, $G$ has a perfect matching. #h(1fr) $qed$

#let konig = "Kőnig"

== #konig's Theorem

This is another theorem that characterises the matching problem on bipartite graphs, into another problem, the *vertex cover problem*.

A *vertex cover* of a graph $G = (V, E)$ is a set of vertices $C subset.eq V$, such that for all edges $e in E$, at least one end point of $e$ must be in $C$. A *minimum vertex cover* of $G$ is a minimum-cardinality vertex cover of $G$.


In a graph $G$, let $M$ be a matching. Consider a vertex cover $C$ of $G$. For each edge $e in M$, at least one end point of that edge must be present in $C$ (by definition of vertex cover). All endpoints of vertices in $M$ are distinct. So, we have $|C| >= |M|$, i.e. *the size of a maximum matching is a lower bound on the size of the minimum vertex cover of $G$*. #konig's theorem states that this lower bound is always achievable in bipartite graphs.

#theorem(title: [#konig's Theorem], numbered: false)[
  The size of a minimum vertex cover is the same as the size of a maximum cardinality matching in every bipartite graph.
]

*Proof*: Let $G = (V = A union.plus B, E)$ be a bipartite graph. Let the cardinality of a maximum matching be $k$. Construct the flow network $G'$ as usual, let $(U, W)$ be its min cut, so $c(U, W) = k$.

Define $A_1 = U inter A, A_2 = A without A_1$; $B_1 = U inter B, B_2 = B without B_1$.

Again, since $(U, W)$ is a cut with finite capacity, no edge in $G$ must be from $A_1$ to $B_2$. So, $N(A_1) subset.eq B_1$.

Here, if we calculate the capacity of the cut $(U, W)$, we have

$
  k = c(U, W)  &= c(s union A_1 union B_1, A_2 union B_2 union t)\
  &= c(s, A_2) + c(A_1, B_2) + c(B_1, t)\
  &= |A_2| + |B_1|
$

So, $k = |A_2| + |B_1|$.

We claim, that $C = A_2 union B_1$ is a vertex cover of $G$.

Let us check all edges to see if one of their endpoints is in $C$.

For all $(u, v) in E$,
- If $u in A_1$, then $v in N(A_1) => v in B_1 => v in C$.
- Else, $u in A_2 => u in C$.

So $C$ is indeed a vertex cover of $G$. The size of this vertex cover is $|C| = |A_2| + |B_1| = k$, which is the size of the maximum cardinality matching of $G$. Since the size of a matching is a lower bound on the size of a vertex cover, $C$ is a minimum vertex cover of $G$. #h(1fr) $qed$

= Summary

We have looked at some applications of the max-flow problem, how other problems can be reduced to the max flow problem, which gives us efficient algorithms to solve them. We have also seen some uses of flow networks to prove some theorems related to matching in bipartite graphs. Next up, we will look at the matching problem in general graphs.



#v(3em)

#align(center, line(length: 40%))

#pagebreak(weak: true)

= Problems

where are they #emoji.eyes
