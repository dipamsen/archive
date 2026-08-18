#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Maximum Flow"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Maximum Flow]

We know that graphs can be used to model problems involving traversal and routes, like the shortest path problem. Another useful interpretation of a directed graph is as a *flow network*, and solve problems about material flows. We consider a source node and a sink node, and analyse the flow of a material through the network from the source to the sink. Flow networks can model many problems, such as liquid flows through pipes, parts through assembly lines, electricity through wires, etc.


= Flow Networks

A *flow network* $G = (V, E)$ is a directed graph in which each edge $(u, v) in E$ has a non negative *capacity* $c(u, v) >= 0$. If $(u, v) in.not E, c(u, v) = 0$.

We have two special vertices in a flow network, a *source* $s$ and a *sink* $t$. We assume that there are no incoming edges to $s$, and no outgoing edges from $t$.

For convenience, we assume that all vertices $v$ lie on a path from $s$ to $t$. So, $s arrow.squiggly v arrow.squiggly t$ is a path in the graph. Thus the graph is connected, and $|E| >= |V| - 1$.

We also assume, that there are no self loops in the graph and no loops of size 2 (antiparallel edges), i.e. if $(u, v) in E$, then $(v, u) in.not E$. 

A *flow* in $G$ is a real valued function $f : V times V -> RR$ that satisfies the following properties:

+ *Capacity constraint:* $forall u, v in V$ we require  $f(u, v) <= c(u, v)$.
+ *Skew symmetry:* $forall u, v in V$ we require $f(u, v) = -f(v, u)$.
+ *Flow conservation:* For all $u in V without {s, t}$, we require $ sum_(v in V) f(u, v) = 0  = sum_(v in V) f(v, u) $

The value $f(u, v)$ (which can be zero, positive or negative) is called the *flow* from $u$ to $v$.

The *value* of flow $f$ is defined as

$
|f| = sum_(v in V)  f(s, v)
$

i.e. the total flow out of the source.




#let node = node.with(radius: 4mm)
#let d1 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $16$)
  edge(<s>, <v2>, "-|>", $13$, label-side: right)
  edge(<v1>, <v3>, "-|>", $12$)
  edge(<v2>, <v1>, "-|>", $4$)
  edge(<v3>, <v2>, "-|>", $9$,label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $14$)
  edge(<v4>, <v3>, "-|>", $7$)
  edge(<v3>, <t>, "-|>", $20$)
  edge(<v4>, <t>, "-|>", $4$, label-side: right)
}, spacing: 0.8cm)

#let d2 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $11\/16$)
  edge(<s>, <v2>, "-|>", $8\/13$, label-side: right)
  edge(<v1>, <v3>, "-|>", $12\/12$)
  edge(<v2>, <v1>, "-|>", $1\/4$, label-side: left)
  edge(<v3>, <v2>, "-|>", $4\/9$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $11\/14$)
  edge(<v4>, <v3>, "-|>", $7\/7$)
  edge(<v3>, <t>, "-|>", $15\/20$)
  edge(<v4>, <t>, "-|>", $4\/4$, label-side: right)
}, spacing: 0.8cm)


#figure(
  grid(columns: 2, gutter: 3em, d1, d2),
  caption: [A flow network $G$, and a flow $f$ on $G$ with value $|f| = 19$. The notation $a\/b$ on an edge $(u, v)$ denotes $f(u, v) = a$ and $c(u, v) = b$. Only positive flow values are shown.]
)

- The capacity constraint restricts the flow through an edge to exceed its capacity.
- Skew symmetry is a notational convenience which says that flow from $u$ to $v$ is the negative of the flow from $v$ to $u$.
- Flow conservation states that total incoming flow (or total outgoing flow) in a non sink-source should be 0.
- When neither $(u, v)$ nor $(v, u)$ exists in $E$, then $f(u, v) = f(v, u) = 0$.

We also define the *total positive flow entering $v$* as 
$
sum_(u in V\ f(u, v) > 0) f(u, v)
$
and similarly, the *total positive flow exiting $v$*. The *total net flow* at $v$ is the total positive flow minus the total negative flow. So, flow conservation states, for any non source/sink node, its total net flow  must equal $0$.

*A notational convenience*

We extend the definition for $f$ for sets of vertices, as follows:

$
f(X, y) = sum_(x in X) f(x, y) quad quad f(x, Y) = sum_(y in Y) f(x, y) quad quad 
f(X, Y) = sum_(x in X) sum_(y in Y) f(x, y)
$

Then, flow conservation can be expressed simply as $f(u, V)  = f(V, u) = 0$ for all $u in V without {s, t}$.

The value of a flow is $|f| = f(s, V)$.

== Some Identities

Let $G = (V, E)$ be a flow network, and let $f$ be a flow in $G$. Then,

1. For all $X subset.eq V$, $f(X, X) = 0$.

    *Proof: * $f(X, X) = sum_(u, v in X) f(u, v) = sum_(u, v in X) -f(v, u) = -f(X, X) => f(X, X) = 0$.

2. For all $X, Y subset.eq V$, $f(X, Y) = -f(Y, X)$.

    *Proof: * $f(X, Y) = sum_(u in X) sum_(v in Y) f(u, v) = sum_(u in X) sum_(v in Y) -f(v, u) = -f(Y, X)$.

3. For all $X, Y, Z subset.eq V$, $X inter Y = phi$, we have $
  f(X union Y, Z) = f(X, Z) + f(Y, Z)\
  f(Z, X union Y) = f(Z, X) + f(Z, Y)
$

    *Proof: *
    $
    f(X union Y, Z) = sum_(u in X union Y) f(u, Z) = sum_(u  in X) f(u, Z) + sum_(u in Y) f(u, Z) = f(X, Z) + f(Y, Z)\
    f(Z, X union Y) = sum_(u in X union Y) f(Z, u) = sum_(u  in X) f(Z, u) + sum_(u in Y) f(Z, u) = f(Z, X) + f(Z, Y)\
    $

Using these identities, we can show e.g. $|f| = f(V, t)$.

$
|f| &= f(s, V)\
&= f(V, V) - f(V - s, V)\
&= f(V, V - s)\
&= f(V, t) + f(V, V - {s, t})\
&= f(V, t) - sum_(u in V without {s, t}) f(u, V)\
&= f(V, t)
$

*Maximum Flow Problem:* Given a flow network $G$ with source $s$, sink $t$ and capacity function $c$, find a flow of maximum value.

How might one approach solving this problem? A naive approach might be to find some path from $s$ to $t$ in which all edges are edges of $G$, and all these edges can admit more flow, and keep increasing the flow, until no such path exists. This algorithm doesn't always terminate on the maximum flow. (Come up with a counter example.)

= Max-Flow Min-Cut Theorem

A *cut* $(S, T)$ of a flow network $G$ is a partition of $V$ into $S$ and $T = V without S$ such that $s in S$ and $t in T$. 

If $f$ is a flow, then the *net flow* across the cut $(S, T)$ (with respect to $f$) is defined as $f(S, T)$. 

The *capacity* of the cut is defined as $c(S, T)$. A *minimum cut* of a network is a cut whose capacity is the minimum over all possible cuts of the network.

#figure(diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $11\/16$)
  edge(<s>, <v2>, "-|>", $8\/13$, label-side: right)
  edge(<v1>, <v3>, "-|>", $12\/12$)
  edge(<v2>, <v1>, "-|>", $1\/4$, label-side: left)
  edge(<v3>, <v2>, "-|>", $4\/9$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $11\/14$)
  edge(<v4>, <v3>, "-|>", $7\/7$)
  edge(<v3>, <t>, "-|>", $15\/20$)
  edge(<v4>, <t>, "-|>", $4\/4$, label-side: right)
}, spacing: 0.8cm,
render: (grid, nodes, edges, options) => {
  cetz.canvas({
    fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)

    import cetz.draw: *
    
    line((3.5, -0.5), (3.5, 4.5), stroke: (paint: primary-color, dash: "dotted"))
    content((3.5, -0.8), text(primary-color)[Cut 1])

    line((7, 0), (2.5, 4.5), stroke: (paint: black, dash: "dotted"))
    content((7.2, -0.2), [Cut 2])
  })
}
), caption: [Two cuts $(S_1, T_1)$ and $(S_2, T_2)$ of $G$. $S_1 = {s, v_1, v_2}$. $S_2 = {s, v_1, v_2, v_4}$])

The above figure shows two possible cuts of $G$.

The net flow across Cut 1 is
$
f(S_1, T_1) &= f(v_1, v_3) + f(v_2, v_3) + f(v_2, v_4) \
&= 12 + (-4) + 11 = 19
$

and the capacity of Cut 1 is
$
c(S_1, T_1) &= c(v_1, v_3 ) + c(v_2, v_4) \ &= 12 + 14 = 26
$

Similarly, the net flow across Cut 2 is
$
f(S_2, T_2) &= f(v_1, v_3) + f(v_2, v_3) + f(v_4, v_3) + f(v_4, t)\
&= 12 + (-4) + 7 + 4 = 19
$

and its capacity is 
$
c(S_2, T_2) &= c(v_1, v_3) + c(v_4, v_3) + c(v_4, t)\
&= 12 + 7 + 4 = 23
$

Observe that the net flow across both the cuts is 19, which is also the value of the flow $f$. This is not a coincidence.

*Lemma 1:* Let $f$ be a flow in $G$ with source $s$ and sink $t$. Let $(S, T)$ be a cut in $G$. Then the net flow across $(S, T)$ is $f(S, T) = |f|$.

*Proof:*
$
f(S, T) &= f(S, V) - f(S, S)\
&= f(S, V)\
&= f(s, V) + f(S - s, V)\
&= f(s, V)\
&= |f|
$

In other words, given a network $G$ with a flow $f$, the flow across any cut $(S, T)$ will be equal to the value of the flow $|f|$.


From our capacity constraint, we know that $f(u, v) <= c(u, v)$ for all $(u, v) in V times V$. So from this, and Lemma 1, we can write:

*Lemma 2:* The value of any flow $f$ in $G$ is bounded above by the capacity of any cut of $G$.

*Proof:*
$
|f| &= f(S, T) \
&= sum_(u in S\ v in T) f(u, v) &<= sum_(u in S\ v in T) c(u, v)\
&= c(S, T)
$

In other words, the value of a flow can never exceed the capacity of any cut of the network.

As a consequence, the *maximum flow in a network is bounded above by the minimum cut of the network*. The value of the flow is the total flow passing through the network, so it must also pass through the minimum cut. The *minimum cut* is the bottleneck which bounds the possible maximum flow rate of the material through the network.


We state a theorem that states that in fact both these quantities are equal. We shall be proving this theorem shortly.


#theorem(title: "Max-Flow Min-Cut Theorem", numbered: false)[
  For any flow network $G = (V, E)$ with source $s$ and sink $t$,
  the maximum flow equals the minimum cut capacity.
]

= Residual Graph and Augmenting Paths

Let's think of how we can try to find the maximum flow of the network. Given a flow, can we check if we can increase its value? That is, could we somehow push more material through the network?

Consider a pair of vertices $(u, v)$. By capacity constraint, $f(u, v) <= c(u, v)$. So, intuitively, the additional flow we can 'push' through $(u, v)$ is $c(u, v) - f(u, v)$ without violating the constraints.


Define the *residual capacity* of a pair of vertices $(u, v) in V times V$ as:

$
c_f (u, v) = c(u, v) - f(u, v)
$

Notice that this also holds if $c(u, v) = 0$ and $f(u, v)$ is negative. This can happen if $(v, u) in E$. Consider, $f(u, v) = -5$, $c(u, v) = 0$. Then, we can 'increase' the flow from $(u, v)$ by 5 units, which is mathematically equivalent to decreasing the flow from $v$ to $u$ to 0.

Define the *residual graph* of $G$ induced by flow $f$ as $G_f = (V, E_f)$, where

$
E_f = {(u, v) in V times V : c_f (u, v) > 0}
$

Essentially, the residual graph consists of edges that can admit more flow.

#let d1 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $11\/16$)
  edge(<s>, <v2>, "-|>", $8\/13$, label-side: right)
  edge(<v1>, <v3>, "-|>", $12\/12$)
  edge(<v2>, <v1>, "-|>", $1\/4$, label-side: left)
  edge(<v3>, <v2>, "-|>", $4\/9$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $11\/14$)
  edge(<v4>, <v3>, "-|>", $7\/7$)
  edge(<v3>, <t>, "-|>", $15\/20$)
  edge(<v4>, <t>, "-|>", $4\/4$, label-side: right)
}, spacing: 0.8cm)



#let d2 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $5$, bend: -10deg, label-sep: 0pt)
  edge(<s>, <v1>, "<|-", $11$, bend: 10deg)
  edge(<s>, <v2>, "-|>", $5$, bend: 10deg, label-sep: 0pt)
  edge(<s>, <v2>, "<|-", $8$, bend: -10deg)
  edge(<v1>, <v3>, "<|-", $12$)
  edge(<v2>, <v1>, "-|>", $3$, bend: 10deg, label-sep: 0pt)
  edge(<v2>, <v1>, "<|-", $1$, bend: -10deg)
  edge(<v3>, <v2>, "-|>", $5$, label-sep: 0mm, bend: 10deg)
  edge(<v3>, <v2>, "<|-", $4$, label-sep: 0mm, bend: -10deg)
  edge(<v2>, <v4>, "-|>", $3$, bend: 10deg)
  edge(<v2>, <v4>, "<|-", $11$, bend: -10deg)
  edge(<v4>, <v3>, "<|-", $7$)
  edge(<v3>, <t>, "-|>", $5$, label-side: left, bend: 10deg)
  edge(<v3>, <t>, "<|-", $15$, bend: -10deg)
  edge(<v4>, <t>, "<|-", $4$, label-side: right)
}, spacing: 0.8cm)


#figure(
  grid(
    columns: 2,
    gutter: 3em,
    d1, d2
  ),
  caption: [Residual graph of $G$ induced by $f$.]
)

Let's call a edge $(u, v) in E$ to be *saturated*, if $f(u, v) = c(u, v)$, i.e. no more flow can be pushed through the edge. 
Call an edge to be *zeroed out* if $f(u, v) = 0$.


Some interesting properties of the residual graph (which can be shown):

1. If an edge $(u, v) in E$, if $(u, v)$ is saturated, then $(v, u) in E_f$, but $(u, v) in.not E_f$.
2. If an edge $(u, v) in E$, if $(u, v)$ is zeroed out, then $(u, v) in E_f$, but $(v, u) in.not E_f$.
3. If an edge $(u, v) in E$ is neither saturated nor zeroed out, then $(u, v) in E_f$ and $(v, u) in E_f$.


Each edge of the residual network is a *residual edge* which can admit more flow. 

We need to find the maximum flow from $s$ to $t$. For this, we look at paths from $s$ to $t$ in $G_f$. Given a flow network $G = (V, E)$ and a flow $f$, an *augmenting path* $p$ is a simple path from $s$ to $t$ in $G_f$. 

Clearly, every edge on a augmenting path can admit more flow. This means, that we have a potential opportunity to increase the total flow from $s$ to $t$.

Define the *residual capacity* of path $p$ as
$
c_f (p) = min{ c_f (u, v) | (u, v) in p}
$



Clearly, we can add $c_f (p)$ amount of flow to each edge in $p$, and still have a valid flow.

#let augment = op("Augment")

We define a procedure #augment on a augmenting path $p$, which updates the flow $f$ by adding $c_f (p)$ to the flow of all edges in path $p$. 



  
#let d1 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $11\/16$)
  edge(<s>, <v2>, "-|>", $8\/13$, label-side: right)
  edge(<v1>, <v3>, "-|>", $12\/12$)
  edge(<v2>, <v1>, "-|>", $1\/4$, label-side: left)
  edge(<v3>, <v2>, "-|>", $4\/9$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $11\/14$)
  edge(<v4>, <v3>, "-|>", $7\/7$)
  edge(<v3>, <t>, "-|>", $15\/20$)
  edge(<v4>, <t>, "-|>", $4\/4$, label-side: right)
}, spacing: 0.8cm)

#let augpath = arguments(stroke: (paint: primary-color, thickness: 2pt), mark-scale: 0.3)

#let d2 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
  node-fill: white,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $5$, bend: -10deg, label-sep: 0pt)
  edge(<s>, <v1>, "<|-", $11$, bend: 10deg)
  edge(<s>, <v2>, "-|>", $bold(5)$, bend: 10deg, label-sep: 0pt, ..augpath)
  edge(<s>, <v2>, "<|-", $8$, bend: -10deg)
  edge(<v1>, <v3>, "<|-", $12$)
  edge(<v2>, <v1>, "-|>", $3$, bend: 10deg, label-sep: 0pt)
  edge(<v2>, <v1>, "<|-", $1$, bend: -10deg)
  edge(<v3>, <v2>, "-|>", $5$, label-sep: 0mm, bend: 10deg)
  edge(<v3>, <v2>, "<|-", $bold(4)$, label-sep: 0mm, bend: -10deg, ..augpath)
  edge(<v2>, <v4>, "-|>", $3$, bend: 10deg)
  edge(<v2>, <v4>, "<|-", $11$, bend: -10deg)
  edge(<v4>, <v3>, "<|-", $7$)
  edge(<v3>, <t>, "-|>", $bold(5)$, label-side: left, bend: 10deg, ..augpath)
  edge(<v3>, <t>, "<|-", $15$, bend: -10deg)
  edge(<v4>, <t>, "<|-", $4$, label-side: right)
}, spacing: 0.8cm)



#let d3 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

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
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((4, -1), $v_3$, name: "v3")
  node((4, 1), $v_4$, name: "v4")
  node((5, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $5$, bend: -10deg, label-sep: 0pt)
  edge(<s>, <v1>, "<|-", $11$, bend: 10deg)
  edge(<s>, <v2>, "-|>", $1$, bend: 10deg, label-sep: 0pt)
  edge(<s>, <v2>, "<|-", $8$, bend: -10deg)
  edge(<v1>, <v3>, "<|-", $12$)
  edge(<v2>, <v1>, "-|>", $3$, bend: 10deg, label-sep: 0pt)
  edge(<v2>, <v1>, "<|-", $1$, bend: -10deg)
  edge(<v3>, <v2>, "-|>", $5$, label-sep: 0mm)
  edge(<v2>, <v4>, "-|>", $3$, bend: 10deg)
  edge(<v2>, <v4>, "<|-", $11$, bend: -10deg)
  edge(<v4>, <v3>, "<|-", $7$)
  edge(<v3>, <t>, "-|>", $1$, label-side: left, bend: 10deg)
  edge(<v3>, <t>, "<|-", $15$, bend: -10deg)
  edge(<v4>, <t>, "<|-", $4$, label-side: right)
}, spacing: 0.8cm)


#figure(
  grid(
    columns: 2,
    gutter: 3em,
    d1, d2, d3, d4
  ),
  caption: [Augmenting flow $f$ along a path $p$. (a) A flow $f$. (b) An augmenting path $p$ in $G_f$. (c) The augmented flow $f'$. (d) The residual graph $G_f'$ after updating the flow $f$.]
)

In the above example, we start with a flow $f$ on $G$. In the residual graph $G_f$, we find a augmenting path $p = chevron.l s, v_2, v_3, t chevron.r$. Its residual capacity is the minimum residual capacity of its edges, which is $c_f (p) = min(5, 4, 5) = 4$.

This indicates, we can push 4 units of material through path $p$, which should increase the value of flow $f$ by $4$. The updated flow values are shown in (c).

Note that the edge $(v_3, v_2)$ originally had flow $4$ before augmentation, but has $0$ flow after. Since the path $p$ moves from $v_2$ to $v_3$, the flow value on the real edge $(v_3, v_2)$ _decreases_. This matches our notion of skew-symmetric flows, mathematically increasing flow on a reverse edge $(v, u)$ is equivalent to decreasing flow on the real edge $(u, v)$. (Unlike the naive algorithm, where once a flow has been set it can never decrease, using the skew-symmetric flow function and the residual graph allows us to 'undo' our mistakes, i.e. reduce the flow of material through an edge, if it leads to a better flow.)



*Lemma 3: (Flow Augmentation)* Let $f$ be a flow in $G$, and let $p$ be an augmenting path from $s$ to $t$ in $G_f$. Define the *augmented flow* $f'$ as


$
f'(u, v) = cases(f(u, v) + c_f (p) quad &"if" (u, v) in p, f(u, v) - c_f (p) quad &"if" (v, u) in p, f(u, v) quad &"otherwise")
$

Then, $f'$ is a flow in $G$, and $|f'| > |f|$.


*Proof*:

1. Capacity constraint: If $(u, v) in p$,  $f'(u, v) = f(u, v) + c_f (p) <= f(u, v) + c_f (u, v) = c(u, v)$.
2. Flow conservation: For some node $u in V without {s, t}$ which lies on path $p$, with predecessor $x$ and successor $y$. ($(x, u) in p$, $(u, y) in p$) Then
  $
  f'(u, V) =sum_(v in V) f'(u, v) & = f'(u, v_1) + dots + f'(u, x) + f'(u, y) + dots + f'(u, v_n) \
  &= f(u, v_1) + dots + f(u, x) + c_f (p) + f(u, y) - c_f (p)  + dots + f'(u, v_n)\
  &= sum_(v in V) f(u, v) = f(u, V) = 0
  $
3. Skew symmetric: Let $(u, v) in p$, then $f'(v, u) = f(v, u) - c_f (p) = - f(u, v) - c_f (p) = -f'(u, v)$. If $(u, v) in.not p and (v, u) in.not p$ then $f' = f$ so skew symmetry holds.
4. Value of flow: The value of flow has been modified for exactly one edge out of all the edges connected with $s$.
  $
  |f'|= f'(s, V) = sum_(v in V) f'(s, v) = sum_(v in V) f(s, v) + c_f (p) = |f| + c_f (p) > |f|
  $
  
At this point, we are at a position to give the proof of the max-flow min-cut theorem: (The following is an equivalent restatement)

*Theorem 1: (Optimality Conditions for Maximum Flow)* If $f$ is a flow in $G = (V, E)$ with source $s$ and sink $t$, then the following conditions  are equivalent:

1. $f$ is a maximum flow in $G$.
2. The residual graph $G_f$ contains no augmenting paths.
3. $|f| = c(S, T)$ for some cut $(S, T)$ in $G$.

*Proof:*

$1 => 2$: Let $f$ be a maximum flow in $G$. Suppose, that there does exist some augmenting path $p$ in $G_f$. Then, by the #augment procedure (Lemma 3), we can find a new flow $f'$, such that $|f'| > |f|$. This contradicts the maximality of $f$. Hence, there does not exist any augmenting path in $G_f$.

$2 => 3$: In $G_f$, there does not exist any paths from $s$ to $t$. Then, define
$
S = {v in V | v "is reachable from" s "in" G_f}.
$

Clearly, $s in S, t in.not S$. In the cut $(S, T = V - S)$, consider any pair of vertices $(u, v)$, $u in S, v in T$. For these pairs, $c_f (u, v) = 0$ (since these aren't edges in $G_f$, otherwise we could reach vertices in $T$ from $s$), which means that $f(u, v) = c(u, v)$. So, summing over all such pairs, we get

$
sum_(u in S) sum_(v in T) f(u, v) &= sum_(u in S) sum_(v in T) c(u, v)\
f(S, T) &= c(S, T)\
|f| &= c(S, T)
$

$3 => 1$: We have, $|f| = c(S, T)$. By Lemma 2, this is necessarily a maximum flow. #h(1fr) $square$

In Figure 4(d), note that there are no more augmenting paths in $G_f$. Thus, the flow $f'$ is a maximum flow, and the value of the maximum flow is $f(s, V) = 23$ (which is also the capacity of cut 2 (Figure 2), which is a min cut!)

= Ford Fulkerson Algorithm

We have shown that the maximum flow is equal to the minimum cut in the network. Lemma 3 also gives us a way to augment a flow to get a flow of higher value. We can use it to get an algorithm for finding the maximum flow.

The basic method for finding the max-flow is, we start with a 0 flow (all $f(u, v) = 0$), choose some augmenting path $p$ in $G_f$, and augment the flow by Lemma 3. Continue doing so, till there are no augmenting paths. At this point, the flow is a maximal flow, by Theorem 1.


#algorithm("Ford-Fulkerson-Method", params: ([$G, s, t$],))[
  #aline[initialise $f$ to $0$]
  #aline[#While there exists an augmenting path $p$ in $G_f$]
  #aline(indent: 1)[augment flow $f$ along $p$]
  #aline[#Return $f$]
]

See Figure 26.5 from CLRS Second Ed (or Figure 26.6 from CLRS Third Ed) for a demonstration of complete execution of this algorithm.

Here, the convergence and time complexity of this algorithm depends on the type of the graph, and how the path $p$ is chosen on line 2.

== Basic Algorithm Complexity

First, let's assume that all edge capacities are integers, and we pick the path $p$ arbitrarily (say, using DFS). We will show that the algorithm runs in $O(E |f^*|)$ time, where $f^*$ is a max-flow.

Each iteration of the algorithm requires finding a path $p$, which takes $O(V + E) = O(E)$, and augmenting the flow along path $p$, which is also $O(E)$. Initially, the value of flow $f$ is 0, and after each iteration, it increases by at least 1 unit (since all edges have integral  capacities). So in at most $|f^*|$ iterations, the algorithm will find the max flow and then terminate. Hence the algorithm's time complexity is $O(E|f^*|)$.


#let d1 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((2, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $1000$, ..augpath)
  edge(<s>, <v2>, "-|>", $1000$, label-side: right)
  edge(<v1>, <v2>, "-|>", $1$, label-side: left, ..augpath)
  edge(<v1>, <t>, "-|>", $1000$)
  edge(<v2>, <t>, "-|>", $1000$, label-side: right, ..augpath)
}, spacing: 0.8cm)


#let d2 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "v1")
  node((1, 1), $v_2$, name: "v2")
  node((2, 0), $t$, name: "t")

  edge(<s>, <v1>, "-|>", $999$, bend: 10deg)
  edge(<v1>, <s>, "-|>", $1$, bend: 10deg, label-sep: 0pt)
  edge(<s>, <v2>, "-|>", $1000$, label-side: right, ..augpath)
  edge(<v2>, <v1>, "-|>", $1$, label-side: right, label-sep: 0pt, ..augpath)
  edge(<v1>, <t>, "-|>", $1000$, ..augpath)
  edge(<v2>, <t>, "-|>", $999$, label-side: right, bend:  -10deg)
  edge(<t>, <v2>, "-|>", $1$, label-side: right, bend:  -10deg, label-sep: 0pt)
}, spacing: 0.8cm)


#figure(
  grid(
    columns: 2,
    gutter: 3em,
    d1, d2
  ),
  caption: [A flow network for which Ford-Fulkerson may takes $O(E |f^*|)$ time.]
)

In the above example, the value of maximum flow is $|f^*| = 2000$. But suppose our choice of path $p$ is such that we choose $p_1 = chevron.l s, v_1, v_2, t chevron.r$ in the first iteration, then $c_f (p_1) = 1$, and we increase our flow by 1. Then, our choice of path might be $p_2 = chevron.l s, v_2, v_1, t chevron.r$, in which case again, $c_f (p_2) = 1$ and our flow increases by 1. Assuming we keep choosing $p_1$ in odd iterations and $p_2$ in even iterations, to reach the maximum flow of $2000$, the algorithm will need 2000 iterations.

Also, since $|f^*| <= sum_(e in E) c(e)$, we can write the time complexity as $O(|E| sum c(u, v))$.

Observe, that the time complexity of the algorithm is a  polynomial function of the _input values_ (not of the *input size*!). Such a complexity is said to be *pseudo-polynomial* time.#footnote[In terms of the input size, this algorithm runs in exponential time.]

= Edmonds-Karp Algorithm

Can we do better, and get a algorithm which runs in running time polynomial in the input size?

The bound on Ford-Fulkerson can be improved if we implement the choice of path $p$ using a Breadth-First Search, i.e. if we always select a shortest path (in terms of number of edges) from $s$ to $t$ in $G_f$. This algorithm is called the *Edmonds-Karp algorithm*. It can be shown to run in $O(m^2 n)$ time.


#algorithm("Edmonds-Karp", params: ([$G, s, t$],))[
  #aline[initialise $f$ to $0$]
  #aline[#While there exists an augmenting path in $G_f$]
  #aline(indent: 1)[find a shortest augmenting path $p$ by running BFS on $G_f$]
  #aline(indent: 1)[augment flow $f$ along $p$]
  #aline[#Return $f$]
]

/**
Define G_f^L <- succinct representation of shortest paths in G_f.

Want to show, while loop runs for m n iterations.

At ith step fi, Gfi, GfiL, delta(s, t) = ...

delta0, delta1, ..., deltak = oo

to prove monotonic, show delta i <= delta i+1

**/

(Note that for purposes of defining 'a shortest path' and 'length of a path', we consider graphs to be unweighted, so each edge contributes to a length of 1 unit.)

We will prove the time complexity bound for this algorithm to be $O(m^2 n)$. First, the body of the while loop runs in $O(m + n) = O(m)$ (BFS and updating the flow). It suffices to show, that the number of iterations that the while loop runs for is $O(m n)$.

== Layered Residual Graph

For the purposes of this proof, let us define the *layered residual graph* $G_f^L$, which is a subgraph of $G_f$ as follows:
- $delta_G (s, v) = $ length of the shortest path from $s$ to $v$ in $G$.
- Let $L_i = {v in V | delta_G_f (s, v) = i}$, the set of vertices whose shortest path distance from $s$ is $i$.
- Let $delta_G_f (s, t) = ell$.
- $G_f^L = (V, E_f^L)$, $E_f^L = {(u, v) in E | u in L_i, v in L_(i + 1) "for some" i}$.



#let d_generic = cetz.canvas(length: 1cm, {
  import cetz.draw: *

  rect((-0.6, -1.8), (0.6, 1.8), fill: primary-color.lighten(60%), stroke: none, radius: 4pt)
  content((0, -2.2), $L_0$)

  rect((1.4, -1.8), (2.6, 1.8), fill: primary-color.lighten(60%), stroke: none, radius: 4pt)
  content((2, -2.2), $L_1$)

  rect((3.4, -1.8), (4.6, 1.8), fill: primary-color.lighten(60%), stroke: none, radius: 4pt)
  content((4, -2.2), $L_2$)

  rect((5.4, -1.8), (6.6, 1.8), fill: primary-color.lighten(60%), stroke: none, radius: 4pt)
  content((6, -2.2), $L_3$)

  circle(fill: white, (0, 0), radius: 0.4, name: "s")
  content("s", $s$)
  circle(fill: white, (2, -1), radius: 0.4, name: "a1")
  content("a1", $a_1$)
  circle(fill: white, (2, 1), radius: 0.4, name: "a2")
  content("a2", $a_2$)
  circle(fill: white, (4, -1), radius: 0.4, name: "b1")
  content("b1", $b_1$)
  circle(fill: white, (4, 1), radius: 0.4, name: "b2")
  content("b2", $b_2$)
  circle(fill: white, (6, 0), radius: 0.4, name: "t")
  content("t", $t$)
  line("s", "a1", mark: (end: ">", fill: black))
  line("s", "a2", mark: (end: ">", fill: black))
  line("a1", "b1", mark: (end: ">", fill: black))
  line("a1", "b2", mark: (end: ">", fill: black))
  line("a2", "b2", mark: (end: ">", fill: black))
  line("b1", "t", mark: (end: ">", fill: black))
  line("b2", "t", mark: (end: ">", fill: black))
})


#figure(d_generic, caption: [Structure of a layered residual graph])

#let d1 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
{
  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "a1")
  node((1, 1), $v_2$, name: "a2")
  node((3, -1), $v_3$, name: "b1")
  node((3, 1), $v_4$, name: "b2")
  node((4, 0), $t$, name: "t")
  edge(<s>, <a1>, "-|>", $10$, bend: 10deg, label-sep: 0pt)
  edge(<a1>, <s>, "-|>", $4$, bend: 10deg)
  edge(<s>, <a2>, "-|>", $8$, bend: 10deg, label-sep: 0pt)
  edge(<a2>, <s>, "-|>", $2$, bend: 10deg)
  edge(<a1>, <b1>, "-|>", $5$, bend: -10deg)
  edge(<a2>, <b1>, "-|>", $4$, label-sep: 0pt)
  edge(<a2>, <b2>, "-|>", $6$)
  edge(<b1>, <a1>, "-|>", $2$, bend: -10deg, label-side: right)
  edge(<b1>, <t>, "-|>", $7$, bend: 10deg, label-sep: 0pt)
  edge(<t>, <b1>, "-|>", $3$, bend: 10deg)
  edge(<b2>, <t>, "-|>", $9$, bend: 10deg, label-sep: 0pt)
  edge(<t>, <b2>, "-|>", $5$, bend: 10deg)
}, spacing: 0.8cm)

#let d2 = diagram(
  node-shape: circle,
  node-stroke: 1pt,
  mark-scale: 1.5,
  node-fill: white,
{
  node(enclose: (<s>, (0, -1.5), (0, 1.5)), fill: primary-color.lighten(80%), stroke: none, corner-radius: 4pt, shape: rect)
  node(enclose: (<a1>, <a2>, (1, -1.5), (1, 1.5)), fill: primary-color.lighten(80%), stroke: none, corner-radius: 4pt, shape: rect)
  node(enclose: (<b1>, <b2>, (2, -1.5), (2, 1.5)), fill: primary-color.lighten(80%), stroke: none, corner-radius: 4pt, shape: rect)
  node(enclose: (<t>, (3, -1.5), (3, 1.5)), fill: primary-color.lighten(80%), stroke: none, corner-radius: 4pt, shape: rect)

  node((0, 0), $s$, name: "s")
  node((1, -1), $v_1$, name: "a1")
  node((1, 1), $v_2$, name: "a2")
  node((2, -1), $v_3$, name: "b1")
  node((2, 1), $v_4$, name: "b2")
  node((3, 0), $t$, name: "t")
  edge(<s>, <a1>, "-|>", $10$, label-sep: 0pt, label-pos: 0.75)
  edge(<s>, <a2>, "-|>", $8$, label-sep: 0pt, label-pos: 0.35)
  edge(<a1>, <b1>, "-|>", $5$)
  edge(<a2>, <b1>, "-|>", $4$, label-sep: 0pt, label-pos: 0.65)
  edge(<a2>, <b2>, "-|>", $6$)
  edge(<b1>, <t>, "-|>", $7$, label-sep: 0pt, label-pos: 0.35)
  edge(<b2>, <t>, "-|>", $9$, label-sep: 0pt, label-pos: 0.65)
}, spacing: 0.8cm)

#figure(
  grid(columns: 2, gutter: 3em, align: horizon, d1, d2),
  caption: [A residual graph $G_f$ and its layered residual graph $G_f^L$]
)


In other words, in the layered residual graph, we have arranged the vertices into layers according to the shortest path distances from $s$. We only keep the edges which go from a vertex closer to $s$ to a vertex farther from $s$. We remove any *back edges* (edges that go to a node which is closer to $s$), and *cross edges* (edges that connect nodes whose distance from $s$ is the same).

*Lemma 4:* Any shortest path from $s$ to $v$ in $G_f$ also exists in $G_f^L$.

*Proof: * Let $v in L_i$, let $p$ be a shortest path from $s$ to $v$ in $G_f$. Assume, that $p$ does not exist in $G_f^L$. For this to happen, $p$ must contain some edge which was removed, so one of the edges of $p$ must be a back edge or a cross edge. Now, since $v in L_i$, and $s in L_0$, and at least one edge in $p$ is a back edge or a cross edge, this implies that $|p| > i$. But this contradicts the minimality of $p$. Thus, any shortest path from $s$ to $v$ in $G_f$ must also be present in $G_f^L$.

This lemma essentially states, that *the layered residual graph $G_f^L$ is a succinct representation of the shortest paths in $G_f$.* 

== Complexity
Now we can come to the analysis of the number of iterations of the algorithm.

Assume that #op("Edmonds-Karp") runs for $k$ iterations.

After the $i$th iteration, let the flow be $f_i$. The corresponding residual graph is $G_f_i$.

Define $delta_i = delta_G_f_i (s, t)$. We have, $delta_k = oo$ (after $k$ iterations, $s$ and $t$ are disconnected.)

*Claim:* $delta_0 <= delta_1 <= delta_2 <= dots.c <= delta_(k - 1) < delta_k = oo$.

*Proof:* Let the current distance between $s$ and $t$ be $delta_i$. In the next iteration, we choose a shortest path from $s$ to $t$ (in $G_f_i$), and augment our flow along this path. 

Call an edge $(u, v)$ in an augmenting path $p$ in $G_f$ *critical*, if $c_f (p) = c_f (u, v)$, i.e. it's residual capacity is the minimum on its path. Each augmenting edge has at least one critical edge. When we augment the flow along $p$, $(u, v)$ gets saturated.

Once we choose some shortest path $p$ in $G_f_i$, let $(u, v)$ be a critical edge in $p$. After augmentation, the resulting residual graph is $G_f_(i + 1)$. Due to augmentation, the edge $(u, v)$ will become saturated, so won't be present in $G_f_(i + 1)$. 

What is $delta_(i + 1)$?

1. Case 1: There is still some path $p$ in $G_f_(i + 1)$ of length $delta_i$.

  Then, $delta_(i + 1) = delta_i$.

2. Case 2: Otherwise: $delta_(i + 1) > delta_i$. This is because, if $delta_(i + 1)$ were to be smaller than $delta_i$, that would mean there is a path from $s$ to $t$ in $G_f_(i + 1)$ shorter than $delta_i$. But this path must then also exist in $G_f_i$. This is a contradiction by definition of $delta_i$.

So we have shown, $delta_(i + 1) >= delta_i$.

We can also bound the value of $delta_i$ after any iteration $i$: $delta_i <= n - 1$, since length of any path in a $n$ node graph cannot exceed $n - 1$.

Now, to get a bound on the total number of iterations ($k$), we need to bound the number of iterations for which $delta_i$ can remain unchanged.

Let
$
delta_(i - 1) < delta_i = delta_(i + 1) = delta_(i + 2)= ... = delta_(i + t) < delta_(i + t + 1)
$

What is the maximum value of $t$? Observe, that after each iteration, at least one edge gets removed from $G_f_i$. Importantly, $G_f^L$ only loses edges, it never gains new edges. This is because the critical edge is always in $G_f^L$ (by Lemma 4) which it loses, and the possible edges that get added to $G_f$ are the reverse edges of those in $p$, which are always back edges, so they don't exist in $G_f^L$.

Then, after at most $|E|$ iterations, there will not exist any more shortest paths of length $delta_i$. Therefore, $t <= m$.

Overall, this bounds the total number of iterations to be $k <= m n$ ($n$ possible values of $delta_i$, and at most $m$ iterations spent for each value).

Thus, as each iteration takes $O(m)$ time, and there are at most $m n$ iterations, #op("Edmonds-Karp") runs in $O(m^2 n)$ time, which is polynomial in the input.

= Dinic's Algorithm

We can try to do even better. Dinic's algorithm is a modification on #op("Edmonds-Karp"), which runs in $O(n^2 m)$ time.

First, let's identify, can we decrease the number of iterations? If we could ensure $delta_(i + 1) < delta_i$ (strict inequality), then our number of iterations of our algorithm is bounded by $n$. For this, we need Case 1 (above) to not happen. So, we must eliminate all shortest paths of length $delta_i$ in the $i$th iteration itself.

So, in a single iteration, we find a set of $s-t$ paths in the layered residual graph $G_f^L$, till at least one edge on every $s-t$ path has been saturated; such a set of paths forms a *blocking flow*. Then, we augment our flow with this blocking flow.

#algorithm("Dinic", params: ([$G, s, t$],))[
  #aline[initialise $f$ to $0$]
  #aline[#While there exists an augmenting path in $G_f$]
  #aline(indent: 1)[build the layered residual graph $G_f^L$]
  #aline(indent: 1)[compute a blocking flow $b$ in $G_f^L$]
  #aline(indent: 1)[$f  <- f + b$ #comment[augment $f$ with $b$]] 
  #aline[#Return $f$]
]

A flow $f$ in a network $G$ is a *blocking flow*, if every $s-t$ path in $G$ contains at least one saturated edge.

We argue about the correctness of the algorithm: After each iteration we get a blocking flow $b$ of $G_f^L$, and then augment $f$ by $b$. Let the $s-t$ before an iteration be $delta_i$, then after the augmentation, it necessarily has to be $> delta_i$, since all  shortest paths of length $delta_i$ have at least one edge removed. So there are at most $n$ iterations. Also, since $delta$ increases monotonically, after at most $n$ iterations it must grow to $oo$, i.e. $s$ and $t$ become disconnected in $G_f$. By Theorem 1, $f$ is a maximum flow of $G$.

Since each blocking flow computation (line 4) can be done in $O(m n)$ (Problem 16), and there are at most $O(n)$ iterations, Dinic's algorithm runs in a time bound of $O(n^2 m)$ which is a better asymptotic bound than Edmonds-Karp for dense graphs.

= Summary

We have discussed 3 algorithms/methods for finding the Maximum Flow in a network $G$, summarized below:

#figure(table(
  columns: 4,
  stroke: none,
  align: (right, center, center, center),
  table.cell(stroke: none)[], table.vline(), [*Augmenting flow*], table.vline(), [*Time complexity*], table.vline(), [*Type*],
  table.hline(),
  [#op("Ford-Fulkerson")], [Arbitrary $s-t$ path], [$O(m |f|) = O(m sum c)$], [Pseudo-Polynomial],
  [#op("Edmonds-Karp")], [Shortest $s-t$ path], [$O(n m^2)$], [Polynomial],
  [#op("Dinic")], [Blocking flow], [$O(n^2 m)$], [Polynomial]
), caption: [Summary of all three max-flow algorithms])

Next up, we will look at a different paradigm for solving max-flow problems, which lead to some even more optimized algorithms for computing a max-flow.



#v(3em)

#align(center, line(length: 40%))

#pagebreak(weak: true)

= Problems

1. *[Simplifying Input Instance]* Explain how we can assume without loss of generality that the input directed graph for the network flow problem does not contain any self-loops or anti-parallel edges. For two vertices $u$ and $v$, if the graph has an edge from $u$ to $v$ and another edge from $v$ to $u$, then these pair of edges are called anti-parallel edges.

#soln-box[
  Let $G = (V, E)$ be the input directed graph. We construct an equivalent graph $G' = (V', E')$ which does not contain any self-loops or anti-parallel edges.

  To construct $G'$,
  1. remove all self loops $(v, v) in E, v in V$ from $E$.
  2. fix anti-parallel edges. Suppose $(v_1, v_2) in E$ and $(v_2, v_1) in E$. Then, remove the edge $(v_2, v_1)$, and a new node $v$, and add edges $(v_2, v)$ and $(v, v_1)$. Set $c'(v_2, v) = c'(v, v_1) = c(v_2, v_1)$.
  The resultant graph clearly does not contain any self-loops or anti-parallel edges.

  For any flow $f$ in $G$, there exists a corresponding flow $f'$ in $G'$, with $|f| = |f'|$:
  - If $f$ assigned any flow $k$ to a self loop $(v, v)$, remove it (set it to 0). This is still a valid flow with same value since both incoming and outgoing flow at $v$ reduced by $k$.
  - For any anti-parallel set of edges $(v_1, v_2)$ and $(v_2, v_1)$, set $f'(v_2, v) = f'(v, v_1) = f(v_2, v_1)$. This is still a valid flow with same value since capacity constraint is satisfied, and flow conservation on $v$ is satisfied (only one incoming and one outgoing flow).
  - For all other edges $(u, v)$, set $f'(u, v) = f(u, v)$.

  For any flow $f'$ in $G'$, there exists a corresponding flow $f$ in $G$, with $|f| = |f'|$:
  - For all self-loops, assign the flow to be $0$.
  - For our construction of $(v_2, v)$ and $(v, v_1)$ in case of anti-parallel edges in $G$, note that $f'(v_2, v) = f'(v, v_1)$ (flow conservation). Set $f(v_2, v_1) = f'(v_2, v)$. This is a valid flow with same value since capacity constraint is satisfied, and flow conservation in $G$ matches that of $G'$.

  From both these lemmas, it is clear that both graphs are equivalent, i.e. max flow value of $G$ = max flow value of $G'$.
]

2. *[Fattest Augmenting Path]* Run the fattest path first (augment along the path where the maximum amount of flow can be sent from $s$ to $t$) implementation of the Ford-Fulkerson method and the Edmond-Karp algorithm on large random graphs and evaluate their relative performance by varying the number of vertices, edges, and average capacities of the edges. Use your favorite programming language.

#soln-box[
  DIY
]

3. Modify your above code to compute a minimum capacity $s$ − $t$ cut in a flow network.

#soln-box[
  DIY
]

4. [CLRS] Suppose that, in addition to edge capacities, a flow network has vertex capacities. That is each vertex v has a limit $ell(v)$ on how much flow can pass though $v$. Show how to transform a flow network $G(V, E, w : V -> RR_(>0))$ with vertex capacities into an equivalent flow $G' (V', E', w' : E' -> RR_(>0))$ without vertex capacities, such that a maximum flow in $G'$ has the same value as a maximum flow in $G$. How many vertices and edges does $G′$ have?

#soln-box[

  Let us assume that in $G$ we also have edge capacities $w(u, v)$. If not, assign $w(u, v) = oo$ for all $(u, v) in E$.

  For every node $v in V$ in $G$,
  - Add two nodes $v_"in"$ and $v_"out"$ in $V'$.
  - Add an edge $(v_"in", v_"out")$, with $w'(v_"in", v_"out") = w(v)$, the vertex capacity.
  For every edge $(u, v) in E$ in $G$,
  - Add the edge $(u_"out", v_"in")$ with $w'(u_"out", v_"in") = w(u, v)$, the original edge capacity of the edge in $G$.

  #let d1 = diagram(
    node-shape: circle,
    node-stroke: 1pt,
    mark-scale: 1.5,
    node-fill: white,
  {
    
    node((0, 0), $v$, name: "v")
    edge((-1, -1), (0, 0), "-|>", $c_1$,  label-sep: 0pt)
    edge((-1.5, 0), (0, 0), "-|>", $c_2$)
    edge((-1, 1), (0, 0), "-|>", $c_3$,  label-sep: 0pt)

    edge((0, 0), (1, -1), "-|>", $c_4$,  label-sep: 0pt)
    edge((0, 0), (1.5, 0), "-|>", $c_5$)
    edge((0, 0), (1, 1), "-|>", $c_6$, label-sep: 0pt)
  }, spacing: 0.8cm)

  #let d2 = diagram(
    node-shape: circle,
    node-stroke: 1pt,
    mark-scale: 1.5,
    node-fill: white,
  {
    
    node((0, 0), $v_"in"$, name: "vin")
    node((1, 0), $v_"out"$, name: "vout")
    edge((-1, -1), (0, 0), "-|>", $c_1$,  label-sep: 0pt)
    edge((-1.5, 0), (0, 0), "-|>", $c_2$)
    edge((-1, 1), (0, 0), "-|>", $c_3$,  label-sep: 0pt)
    edge(<vin>, "-|>", <vout>, $w(v)$)
    edge((1, 0), (2, -1), "-|>", $c_4$,  label-sep: 0pt)
    edge((1, 0), (2.5, 0), "-|>", $c_5$)
    edge((1, 0), (2, 1), "-|>", $c_6$, label-sep: 0pt)
  }, spacing: 0.8cm)

  #figure(
    grid(columns: 2, gutter: 3em, d1, d2),
    caption: [Transformation of a node in $G$ into $G'$]
  )

  Define the source and sink of $G'$ to be $s_"in"$ and $t_"out"$ respectively.

  $G'$ has $2|V|$ nodes, and $|E| + |V|$ edges.

  For any flow $f$ in $G$ (satisfying vertex and edge constraints), there exists a corresponding flow $f'$ in $G'$ such that $|f| = |f'|$:
  - For $v in V without {s, t}$,  $f'(v_"in", v_"out") = sum_(u in v\ f(u, v) > 0) f(u, v)$, the total positive flow entering (or exiting) $v$.
  - $f'(s_"in", s_"out") = f'(t_"in", t_"out") = |f|$, the value of the flow.
  - For $(u, v) in E$, $f'(u_"out", v_"in") = f(u, v)$.

  $f'$ is a valid flow in $G'$, because
  1. Flow conservation holds on each node $v_"in"$ since the only outgoing edge from $v_"in"$ has a flow equal to total positive flow entering $v$ in $G$. (similarly for $v_"out"$, the incoming edge has flow equal to total positive flow exiting $v$ in $G$).
  2. Capacity constraint holds on normal edges (trivially), and on auxilliary edges due to the fact that, total positive flow entering $v$ in $G$ cannot exceed $w(v)$, which is the capacity of the auxilliary edge.

  For any flow $f'$ in $G'$, there exists a corresponding flow $f$ in $G$ satisfying vertex and edge constraints, such that $|f| = |f'|$:
  - Simply choose $f(u, v) = f'(u_"out", v_"in")$.
  This is a valid flow in $G$ because, flow conservation is satisfied, edge capacity constraints are satisfied, and vertex capacity constraints are satisfied (as total positive flow entering $v$ cannot exceed $w(v)$ due to an edge constraint in $f'$).

  Thus the maximum flow of $G'$ has the same value as the maximum flow of $G$.
]

5. *[Multiple Source and Multiple Sink]* Suppose that we have multiple source and sink vertices in a flow network. The value of a flow in such a network is defined as the total amount of flow going out of all sources. Show how to transform this problem into an equivalent conventional (taught in the class) flow network such that the maximum flow value remains the same.

#soln-box[
  Let $s_1, s_2, ..., s_k$ be the source vertices and $t_1, t_2, ..., t_l$ be the sink vertices in a flow network $G$. We construct an equivalent network $G'$ with a single source and sink.

  Add two vertices, a *supersource* $s$ and a *supersink* $t$ to $G'$. Add edges $(s, s_i)$ and $(t_j, t)$, all with capacity $oo$. Keep all other vertices and edges same as in $G$.

  We can convert any flow $f$ in $G$ into a corresponding flow $f'$ in $G'$, by setting the flow values of $(s, s_i)$ as the total positive flow exiting $s_i$, and of $(t_j, t)$ as the total positive flow entering $t_j$. This is clearly a valid flow as flow conservation and capacity constraints hold. Its value is equal to the sum of flows of $(s, s_i)$, which is the sum of total flows exiting source $s_i$, which is exactly the value of flow $f$.

  Thus, these problems are equivalent.
]

6. *[Flow with Vertex Capacities]* Suppose every vertex $v$, except $s$, $t$, has a capacity $c_v$, meaning that at most $c_v$ units of flow may pass through v. Design an algorithm that computes a maximum $s$ − $t$ flow subject to both edge capacities and vertex capacities.

#soln-box[
  Convert the network to an equivalent network with only edge capacity constraints (as in Problem 4). Run a standard max-flow algorithm (Ford-Fulkerson / Edmonds-Karp). Map the max-flow in $G'$ back to $G$. This gives a max $s-t$ flow in $G$. 
]

7. *[Maximum Flow with Lower Bounds]* Each edge $e$ has a lower bound $l_e$ and upper bound $u_e$, and every feasible flow must satisfy $l_e <= f_e <= u_e$. Design an algorithm to determine whether a feasible $s$ − $t$ flow exists. Then extend your algorithm to compute a maximum feasible $s$-$t$ flow.

#soln-box[
  To determine if a feasible flow exists, we transform the network $G$ into an equivalent max-flow problem with edge capacities $G'$:
  
  1. Add a supersource $s'$ and a supersink $t'$.
  2. For each edge $(u, v) in E$, set its new capacity $c'(u, v) = u_(u, v) - l_(u, v)$.
  3. By forcing $l_(u, v)$ flow across each edge, we create flow imbalances at the nodes (flow conservation is violated). For each vertex $v in V$, define the *net demand* 
     $ Delta(v) = sum_((v, w) in E) l_(v, w) - sum_((u, v) in E) l_(u, v) $
  4. If $Delta(v) > 0$, add an edge $(v, t')$ with capacity $Delta(v)$. If $Delta(v) < 0$, add an edge $(s', v)$ with capacity $-Delta(v)$.
  5. To satisfy the conservation of flow from $s$ to $t$, add an artificial edge $(t, s)$ with infinite capacity $c'(t, s) = oo$.

  Compute the maximum $s'-t'$ flow in this new network. A feasible flow exists in the original network if and only if all edges leaving $s'$ and entering $t'$ are fully saturated. If so, the feasible flow on each original edge is $f(u, v) = f'(u, v) + l_(u, v)$.

  #let d1 = diagram(
    node-shape: circle,
    node-stroke: 1pt,
    mark-scale: 1.5,
    node-fill: white,
  {
    node((0, 0), $s$, name: "s")
    node((1, -1), $v_1$, name: "v1")
    node((1, 1), $v_2$, name: "v2")
    node((2, 0), $t$, name: "t")
  
    edge(<s>, <v1>, "-|>", $1-3$)
    edge(<s>, <v2>, "-|>", $3-4$, label-side: right)
    edge(<v2>, <v1>, "-|>", $0-1$)
    edge(<v1>, <t>, "-|>", $2-3$)
    edge(<v2>, <t>, "-|>", $2-3$, label-side: right)
  }, spacing: 0.8cm)

  #let d2 = diagram(
    node-shape: circle,
    node-stroke: 1pt,
    mark-scale: 1.5,
    node-fill: white,
  {
    node((-1, 0), $s'$, name: "S")
    node((0, 0), $s$, name: "s")
    node((1, -1), $v_1$, name: "v1")
    node((1, 1), $v_2$, name: "v2")
    node((2, 0), $t$, name: "t")
    node((3, 0), $t'$, name: "T")
  
    edge(<s>, <v1>, "-|>", $2$)
    edge(<s>, <v2>, "-|>", $1$, label-side: right)
    edge(<v2>, <v1>, "-|>", $1$, label-pos: 0.4)
    edge(<v1>, <t>, "-|>", $1$)
    edge(<v2>, <t>, "-|>", $1$, label-side: right)

    edge(<t>, <s>, "-|>", bend: 0deg, label-pos: 0.2, $oo$)

    edge(<s>, <T>, "-|>", $4$, bend: 90deg)
    edge(<v1>, <T>, "-|>", $1$, bend: 20deg)
    edge(<S>, <v2>, "-|>", $1$, label-side: right, bend: -30deg)
    edge(<S>, <t>, "-|>", $4$, bend: -90deg)
  }, spacing: 0.8cm)

  #figure(grid(columns: 2, gutter: 3em, d1, d2, align: horizon), caption: [(a) Network $G$ with lower and upper bounds on edges (b) Equivalent network $G'$ with edge capacities])

  *Proof*: 

  1. If a feasible flow $f$ exists in $G$, then a max-flow exists in $G'$ where all $s'$/$t'$ edges are saturated.

  We define a flow $f'$ in $G'$:
  - $f'(u, v) = f(u, v) - l_(u,v)$, $f'(t, s) = |f|$, $f'(s',v) = c'(s', v)$, $f'(v, t') = c'(v, t')$.
  - This is a valid flow because
    - $l_(u, v) <= f(u, v) <= u_(u, v) => 0 <= f'(u, v) <= c'(u, v)$
    - $v in S - {s, t}$, $
    sum_((v, w) in E) f(v, w) - sum_((u, v) in E) f(u, v) = 0\
    => sum_((v, w)  in E) (f'(v, w) + l_(v, w)) - sum_((u, v) in E) (f'(u, v) + l_(u, v)) = 0\
    => sum_((v, w) in E) f'(v, w) - sum_((u, v) in E) f'(u, v) + sum_((v, w) in E) l_(v, w) - sum_((u, v) in E) l_(u, v) = 0\
    => sum_((v, w) in E) f'(v, w) - sum_((u, v) in E) f'(u, v) + Delta(v) = 0
    $ 
    So flow conservation holds (in either case $Delta > 0$ or $Delta < 0$).
    - For $v = s$ and $v = t$, flow conservation holds as total flow exiting $s$ = $|f|$ which is in its incoming edge $(t, s)$, and vice versa.

  2. If a flow exists in $G'$ where all $s'$/$t'$ edges are saturated, then a feasible flow exists in $G$. (DIY :))

  To compute the *maximum* feasible $s-t$ flow:
  1. Find a feasible flow $f$ of $G$ using the above method. If no feasible flow exists, terminate.
  2. Construct the residual graph $G_f$ using the feasible flow $f$. The residual capacities are bounded by both the upper and lower limits:
     - Forward edge: $c_f (u, v) = u_(u, v) - f(u, v)$
     - Backward edge: $c_f (v, u) = f(u, v) - l_(u, v)$
  3. Run a standard max-flow algorithm from the original $s$ to $t$ on $G_f$ to augment $f$ to $f'$ till you reach a max-flow.
]


8. *[Minimum Cut After Maximum Flow]* Suppose a maximum flow has already been computed. Design an $O(|V| + |E|)$-time algorithm that finds an $s$ − $t$ minimum cut.

#soln-box[
  Compute the residual graph. Run DFS on the residual graph $G_f$ starting from vertex $s$, and find the set 
  $
  S = {v in V | v "is reachable from" s "in" G_f}
  $

  Then, we claim $(S, T = V without S)$ is a $s-t$ minimum cut.

  This algorithm runs $O(V + E)$ time.

  Firstly, note that $t in.not S$. If it were, then there would exist an augmenting path in $G_f$, which by Lemma 3 would imply that $f$ is not a maximum flow. So, $(S, T)$ is a $s-t$ cut.

  Let $E^arrow$ be all edges crossing the cut _from S to T_, and $E^arrow.l$ be edges crossing the cut _from T to S_.
  $
  E^arrow = {(u, v) in E | u in S, v in T}\
  E^arrow.l = {(u, v) in E | u in T, v in S}
  $
  Then,
  1. For some $(u, v) in E^arrow$, note that $(u, v) in.not E_f$. (If it were, then $v$ would be reachable from $s$ in $G_f$, contradicting $v in T$). This means, $c_f (u, v) = 0 => f(u, v) = c(u, v)$, thus $(u, v)$ is saturated.
  2. For some $(u, v) in E^arrow.l$, note that $(v, u) in.not E_f$. This means, $c_f (v, u) = 0 => f(v, u) = c(v, u) = 0$, thus $(u, v)$ is zeroed out.

  The flow of the cut is 
  $
  f(S, T) = sum_(u in S) sum_(v in T) f(u, v) = sum_((u, v) in E^arrow) f(u, v) + sum_((u, v) in E^arrow.l) f(v, u) = sum_((u, v) in E^arrow) c(u, v) = sum_(u in S) sum_(v in T) c(u, v) = c(S, T)
  $

  So, we have $|f| = c(S, T)$. By Lemma 2, this implies that $(S, T)$ is a minimum cut of $G$.
]

9. [CLRS] Suppose that you wish to find, among all minimum cuts in a flow network $G$ with integral capacities, one that contains the smallest number of edges. Show how to modify the capacities of $G$ to create a new flow network $G′$ in which any minimum cut in $G′$ is a minimum cut with the smallest number of edges in $G$.

#soln-box[
  Transform the edge capacities: For $(u, v) in E$, $c'(u, v) = (m + 1) c(u, v) + 1$, where $m = |E|$.

  For any cut $(S, T)$ in $G$, its capacity is $c(S, T) = sum_(u in S) sum_(v in T) c(u, v)$.

  The capacity of the corresponding cut in $G'$ is
  $
    c'(S, T) = sum_(u in S) sum_(v in T) c'(u, v) = sum_(u in S) sum_(v in T) (m + 1) c(u, v) + 1 = (m + 1) c(S, T) + k
  $
  where $k$ is the number of edges crossing the cut $(S, T)$.

  Let $(S^*, T^*)$ be a minimal cut in $G'$ having $k^*$ edges.

  Then for any cut $(S, T)$ with $k$ edges,
  $
  c'(S^*, T^*) <= c'(S, T)\
  (m + 1) c(S^*, T^*) + k^* <= (m + 1) c(S, T) + k\
  
  c(S^*, T^*) + k^* /(m + 1) <= c(S, T) + k/(m + 1)
  $
  Here, both $k^*$ and $k$ are less than $m + 1$, and $c$ values are integral values. For the last inequality to hold, there are only these two cases:

  1. $c(S^*, T^*) < c(S, T)$. (Since both of them are integers, they differ by at least 1, so adding fractional values does not affect the inequality.)

  2. $c(S^*, T^*) = c(S, T)$. This implies $k^* <= k$.

  So, for any cut $(S, T)$, either $(S^*, T^*)$ has a lower capacity, or if it has an equal capacity, it has a lower or same number of edges. This proves that a minimum cut in $G'$ is  a minimal cut in $G$ with a minimum number of edges.
]

10. *[Uniqueness of Minimum Cut]* Design an algorithm to check if a flow network has a unique minimum capacity $s$ − $t$ cut, and if not, then output two different minimum capacity $s$ − $t$ cuts.

#soln-box[
  Run a maximum flow algorithm and compute the maximum flow $f$.
  
  Let $S^* = {v in V | v "is reachable from" s "in" G_f}$, $T^* = {v in V | t "is reachable from" v "in" G_f}$. Since $s$ and $t$ are disconnected, $S^* inter T^* = phi$

  *Lemma 5:* If $(S, T)$ is a min-cut, there can be no edge crossing the cut in $G_f$.

  *Proof:* By Max-Flow Min-Cut Theorem, $c(S, T) = |f| => c(S, T) = f(S, T)$. So we have
  $
  sum_(u in S\ v in T) c(u, v)  = sum_(u in S\ v in T) f(u, v)\ sum_(u in S\ v in T) (c(u, v) - f(u, v)) = 0
  $
  Each term of this summation is nonnegative, so each term must be zero. So, $c(u, v) = f(u, v) => c_f (u, v) = 0$ for all pairs of nodes $(u, v), u in S, v in T$. So, none of these edges exist in $G_f$.

  *Converse of Lemma 5:* Let $(S, T)$ be a cut, and there are no edges crossing the cut in $G_f$. Then, $(S, T)$ is a min-cut.

  *Proof:* For all edges crossing the cut, $c_f (u, v) = 0, => f(u, v) = c(u, v)$. So, $c(S, T) = f(S, T) = |f|$, thus $(S, T)$ is a min-cut.

  *Theorem:* If $S^* union T^* = V$, then $G$ has a unique min-cut.

  *Proof:* Clearly $S = S^*$, $T = T^*$, $(S, T)$ is a min-cut of $G$. $c(S, T) = |f|$. Assume that there exists another min cut $(S', T')$. WLOG, assume there exists some $u in S'$, $u in.not S$. Since $u in.not S$, $u in T$, so $t$ is reachable from $u$ in $G_f$. Consider the path from $u$ to $t$ in $G_f$, let it be $chevron.l u = v_0, v_1, v_2, ..., v_(k - 1), v_k = t chevron.r$. Let $v_i$ be the first node in this path which belongs to $T'$. Then, $v_(i - 1) in S'$. The edge $(v_(i - 1), v_i)$ crosses the $(S', T')$ cut. This is a contradiction (by Lemma 5). Thus, there is a unique min-cut.

  Compute $S^*$ and $T^*$ (by traversing the residual graph from $s$ and the reverse residual graph from $t$). If their union is $V$, then there exists a unique cut. Otherwise the following are valid different $s-t$ cuts (by Converse of Lemma 5):
  - $(S^*, V - S^*)$
  - $(V - T^*, T^*)$
]

11. *[Edge Capacity Increase]* We are given a flow network and a maximum flow in that network. Assume all edge capacities are positive integers. Suppose we increase the capacity of an edge by 1. Give an $O(m + n)$ time algorithm to update the maximum flow.

#soln-box[
  Let $G$ be the original network, and $G'$ be the network after increasing an edge's capacity by 1. Let $f$ be a max-flow in $G$.

  Compute the residual graph $G'_f$. Find an augmenting path in $G'_f$. There will be at most one augmenting path, with residual capacity $1$. If a path exists, augment along this path, the resulting flow is a max-flow of $G'$. Otherwise, $f$ is already a max-flow of $G'$.

  This runs in $O(n + m)$ time.

  *Proof:* In $G_f$, $s$ and $t$ are disconnected. When we construct $G'$, we increase $c(u, v)$ by 1 for some $(u, v)$. This means in $G'_f$, we have $c'_f (u, v) = c_f (u, v) + 1$ for that $(u, v)$.

  We have two cases:
  1. No $s-t$ path exists in $G'_f$. Then clearly, $f$ is a max-flow of $G'$.
  2. An $s-t$ path exists in $G'_f$. This path must use the $(u, v)$ edge. Also, this means $c_f (u, v) = 0$ (otherwise $f$ won't be a max flow of $G$) and $c'_f (u, v) = 1$.

  We augment along this path to get a flow with value $|f'| = |f| + 1$. We also need to show no further augmentations are possible.

  Let $(S, T)$ be a min-cut in $G$, $c(S, T) = |f|$. In $G'$, capacity of an edge was increased by 1. So, $c'(S, T) <= c(S, T) + 1 = |f| + 1$. By Lemma 2, $|f'| <= c'(S, T) <= |f| + 1$. Thus, we cannot increase $|f'|$ any more, and the current flow is the max-flow of $G'$.
]

12. *[Submodularity of Cuts]* Let $G(V, E)$ be an undirected and unweighted graph. For $X subset.eq V$, we define $delta(X)$ to be the capacity of the cut $(X, V without X)$. Then show the following for every two subsets $A, B subset.eq V$,
    $
    delta(A) + delta(B) >= delta(A union B) + delta(A inter B)
    $

#soln-box[
  We take each edge to have a capacity of 1. Since the graph is  unweighted we have $c(A, B) = c(B, A)$. All other properties of $c$ (as proved above) hold.
  $
  delta(X) = c(X, V without X)
  $

  Let $P_1 = A - B$, $P_2 = A inter B$, $P_3 = B - A$ and $P_4 = V - A - B$. $P_i$s are mutually disjoint and partition the set of vertices $V$.

  $
  delta(A) &= c(A, V - A) &&= c(P_1 union P_2, P_3 union P_4) = c(P_1, P_3) + c(P_2, P_3) + c(P_1, P_4) + c(P_2, P_4)\ 
  delta(B) &= c(B, V - B) &&= c(P_2 union P_3, P_1 union P_4) = c(P_2, P_1) + c(P_3, P_1) + c(P_2, P_4) + c(P_3, P_4)\ 
  delta(A union B) &= c(A union B, V - A union B) &&= c(P_1 union P_2 union P_3,  P_4) = c(P_1, P_4) + c(P_2, P_4) + c(P_3, P_4)\
  delta(A inter B) &= c(A inter B, V - A inter B) &&= c(P_2, P_1 union P_3 union P_4) = c(P_2, P_1) + c(P_2, P_3) + c(P_2, P_4)\
  $

  So,
  $
  delta(A) + delta(B) &= c(P_1, P_2) + 2 c(P_1, P_3)+ c(P_1, P_4) + c(P_2, P_3) + 2 c(P_2, P_4) + c(P_3, P_4)\
  &>= c(P_1, P_2) + c(P_1, P_4) + c(P_2, P_3) + 2 c(P_2, P_4) + c(P_3, P_4)\
  &= delta(A union B) + delta(A inter B)
  $
]
    
13. *[Edge in Every Min Cut]* Given a flow network, design an algorithm of worst-case time complexity $O("time complexity of maximum" s − t "flow computation")$ that identifies all edges that belong to *every* minimum $s − t$ cut.

#soln-box[
 Run a maximum flow algorithm and compute the maximum flow $f$.
  
  Let $S^* = {v in V | v "is reachable from" s "in" G_f}$, $T^* = {v in V | t "is reachable from" v "in" G_f}$.

  Compute $S^*$ and $T^*$ by running BFS on the residual graph and its reverse graph respectively. Iterate over all edges, and check whether $u in S^*$ and $v in T^*$, if so, then $(u, v)$ belongs to every min-cut of $G$.

  This algorithm runs in $O("Max-Flow")$ time.

  *Lemma 6:* If $(u, v) in E$ and $u in S^*$, $v in T^*$, then $(u, v)$ crosses all min-cuts of $G$.

  *Proof:* Let $(u, v) in E, u in S^*, v in T^*$. Let $(S, T)$ be a min-cut of $G$, such that $(u, v)$ does not cross the cut. WLOG, let $u, v in S$. Since $v in T^*$, $v$ is connected to $t$ in $G_f$. Let $chevron.l v_0 = v, v_1, v_2, ..., v_k = t chevron.r$ be the path from $v$ to $t$ in $G_f$. Let $v_i$ be the first vertex which is in $T$. Then, $(v_(i - 1), v_i)$ crosses the cut $(S, T)$. By Lemma 5, $(S, T)$ can't be a min-cut, which is a contradiction. Thus, $(u, v)$ crosses every min-cut of $G$.

  *Converse of Lemma 6:* If $(u, v) in E$ crosses all min-cuts of $G$, then $u in S^*$ and $v in T^*$.

  *Proof:* Since $(u, v)$ crosses all min-cuts, it must cross $(S^*, V - S^*)$, which means $u in S^*$. It must also cross $(V - T^*, T^*)$, which means $v in T^*$.
]

14. *[Flow with a Mandatory Edge]* Given a network and a particular edge $e = (u, v)$, design an algorithm that determines whether there exists a maximum $s$−$t$ flow that sends strictly positive flow through $e$.

#soln-box[
  1. Run a standard algorithm to compute any maximum $s-t$ flow $f$ in the network $G$.
  2. If $f(u, v) > 0$, then we have already found a maximum flow that sends positive flow through $e$. Return true.
  3. If $f(u, v) = 0$, construct the residual graph $G_f$.
  4. Note that since $f(u, v) = 0$, the forward edge $(u, v)$ has its full residual capacity $c_f (u, v) = c(u, v) > 0$, meaning the directed edge $(u, v)$ exists in $G_f$.
  5. Run a DFS in $G_f$ starting from $v$ to check if $u$ is reachable from $v$.
  6. If $u$ is reachable from $v$, there exists a path from $v$ to $u$, which means there is a cycle in $G_f$ containing $(u, v)$. Pushing a small amount of flow $delta > 0$ along this cycle strictly increases the flow on $(u, v)$ without changing the total $s-t$ max flow value (since it is a closed circulation) and without violating any capacity constraints. Thus, return true.
  7. If $u$ is not reachable from $v$ in $G_f$, no such cycle exists. This means there is no way to reroute the existing flow to use $(u, v)$ without decreasing the overall $s-t$ flow. Return false.

  *Time Complexity:* This algorithm takes $O("Max-Flow")$ time to find $f$, and $O(V + E)$ time for the DFS on the residual graph. The overall time complexity is strictly bounded by $O("Max-Flow")$.
]
15. *[Path decomposition of a flow]* A flow $f$ in a flow network $G$ is called _not acyclic_ if there exists a directed cycle in $G$ such that each of its edges carries a positive amount of flow. Otherwise, $f$ is called _acyclic_.
    #set enum(numbering: "(a)")
    + Prove that, for every flow $f$, there exists an acyclic flow $f′$ of value the same as the value of $f$.
    + A path flow is a flow which assigns a positive flow only to the edges of an $s$ − $t$ path. Prove that, every acyclic flow f can be written as the sum of at most $m$ path flows.
    + Is the Ford-Fulkerson algorithm guaranteed to find an acyclic flow?
    + A cycle flow is a flow which assigns a positive flow only to the edges of a directed cycle. Prove that, every flow $f$ can be written as the sum of at most $m$ path flows and cycle flows. Given a flow network and a flow $f$, design an algorithm to find the above decomposition in $O(m n)$ time.

#soln-box[
    #set enum(numbering: "(a)")
  + #[
    
    Let $f$ be a flow in $G$. We define a new flow $f' = f$. Define the flow subgraph $G^+$ containing only edges with positive flow, $f'(u, v) > 0$.

    While $G^+$ has a directed cycle $C$,
    - Let $delta = min_(e in C) f'(e)$.
    - For every edge $e in C$, update $f'(e) <- f'(e) - delta$.
    - The flow of an edge becomes zero, which gets removed from $G^+$.

    This procedure will terminate in at most $m$ iterations since on each iteration one edge gets removed from the graph $G^+$. 

    $f'$ is a valid flow since for each node in the cycle, one incoming edge and one outgoing edge is depleted of $delta$ flow on each iteration.
    
    The resulting flow $f'$ is acyclic flow, since the flow graph $G^+$ does not contain any directed cycle at the end of the algorithm. 

    The value of the flow is same as that of the original, since we do not modify the flow of any edge connected to $s$ -- under our assumptions, $s$ can't be a part of a directed cycle.
  ]

  + #[
    Let $f$ be an acyclic flow in $G$. Consider the following algorithm to extract path flows from $f$.

    Let $f' = f$. While there is a $s-t$ path in $G^+$,
    - Let $delta = min_(e in p) f'(e)$.
    - For every edge $e in p$, update $f'(e) <- f'(e) - delta$.
    - Add the path flow $p$ with flow value $delta$ to the list of path flows.
    - The flow of an edge becomes zero, which gets removed from $G^+$.

    This procedure will terminate in at most $m$ iterations since on each iteration one edge gets removed from the graph $G^+$.

    Also, at the end of the procedure, (when there is no $s-t$ path in $G^+$), $f'$ must be the zero flow.

    Assume it is not, so there exists some $(u, v) in E$, $f(u, v) > 0$. Since $v$ has an incoming positive flow, it must have an outgoing positive flow through some edge $(v, v_1)$.  Repeating this argument, we can find a sequence $v, v_1, v_2, ...$. Now, no vertex can repeat in this sequence, otherwise we will have a directed cycle with positive flow, which is not allowed. So the only other option is that this sequence terminates at $t$. 

    Similarly, traceback the vertex $u$ to $u_1, u_2, u_3, ...$, this leads to this sequence terminating at $s$. Therefore, we have found an $s-t$ path: $s arrow.squiggly u -> v arrow.squiggly t$, which is a contradiction. So, $f'$ is indeed the zero flow.

    Thus we have decomposed $f$ into at most $m$ path flows.
  ]

  + #[
    
  #let d1 = diagram(
    node-shape: circle,
    node-stroke: 1pt,
    mark-scale: 1.5,
    node-fill: white,
  {
    node((0, 0), $s$, name: "s")
    node((1, 0), $v_1$, name: "v1")
    node((2, 1), $v_2$, name: "v2")
    node((2, -1), $v_4$, name: "v4")
    node((3, 0), $v_3$, name: "v3")
    node((4, 0), $t$, name: "t")
  
    edge(<s>, <v4>, "-|>", $2$)
    edge(<s>, <v2>, "-|>", $2$, label-side: right)
    edge(<v4>, <v1>, "-|>", $2$, label-side: left)
    edge(<v1>, <v2>, "-|>", $2$, label-side: left)
    edge(<v2>, <v3>, "-|>", $2$)
    edge(<v3>, <v4>, "-|>", $2$, label-side: left)
    edge(<v4>, <t>, "-|>", $2$)
    edge(<v2>, <t>, "-|>", $2$, label-side: right)
  }, spacing: 0.8cm)

  No. We show a counter-example:
  
  #figure(d1, caption: [A network for which #op("Ford-Fulkerson") may not find a acyclic flow.])

  On this network, if we choose the path $chevron.l s, v_2, v_3, v_4, t chevron.r$ on the first iteration, and $chevron.l s, v_4, v_1, v_2, t chevron.r$ on the second iteration, we will end up with a flow which is not acyclic, since there is a directed cycle with positive flow, $v_1, v_2, v_3, v_4$.
  
]

+ #[

  The proof follows directly from (a) and (b).

  Define $f' <- f$. Let $G^+$ contain edges where $f'(u, v) > 0$.


  While $f' != 0$,
  - Perform DFS from $s$ on $G^+$. 
    - If a back edge is encountered, we have a directed cycle.
      - Decrease the flow of each edge in the cycle by $delta$, the bottleneck edge. 
      - Store this as a cycle flow.
      - Restart the DFS.
    - If $t$ is reached, we have a $s-t$ path.
      - Decrease the flow of each edge in the path by $delta$, the bottleneck edge. 
      - Store this as a path flow.
      - Restart the DFS.

  This runs in $O(m n)$ time, since on each iteration at least one edge gets removed, so there are at most $m$ iterations. Each iteration runs in $O(n)$ since we stop once we either reach $t$, or a back edge. So we never backtrack on the DFS, we stop after visiting at most $n$ vertices.
]
]

16. *[Dinic's Algorithm]* A _blocking flow_ $f$ in a flow network $G(V, E, c : E -> RR_(>0))$ is a flow such that, in every $s$ − $t$ path, there is at least one edge $e$ such that $c_e = f_e$.
    #set enum(numbering: "(a)")
    1. Given a network $G$, and an $s$ − $t$ flow $f$, construct the BFS tree starting from $s$. Delete backward and cross edges of the BFS tree from the residual graph $G_f$. We call the resulting graph the layered graph $cal(L)_f$ with respect to $f$. Prove that $cal(L)_f$ is acyclic.
    2. Design an $O(m n)$-time algorithm to compute a blocking flow $f$ in $cal(L)_f$. _Hint: Modify the standard DFS appropriately!_ 
    3. Consider the following algorithm for computing a maximum flow in a network. Start with the zero flow. Compute a blocking flow in the corresponding layered graph, augment it with the current flow, and iterate until there is no path from $s$ to $t$ in the residual graph. Prove that the run time of this algorithm $O(m n^2)$. _Hint: How does the distance (number of edges in a shortest path) of any vertex from s changes after every iteration?_


#soln-box[
    #set enum(numbering: "(a)")

    + #[
      Define $ell(v) = delta_G_f (s, v) = $ length of shortest path from $s$ to $v$ in $G_f$. Back edges and cross edges in the BFS tree are those $(u, v)$ which have $ell(v) <= ell(u)$. If we remove these edges in $G_f$, the only edges we keep are $(u, v)$ such that $ell(v) = ell(u) + 1$.

      Suppose there is a directed cycle in $cal(L)_f$: $v_1, v_2, ..., v_k = v_0$, then since each edge increases $ell$ by 1, $ell(v_1) < ell(v_2) < ... < ell(v_k) = ell(v_0)$, which is a contradiction.

      Thus, $cal(L) (f)$ is acyclic.
    ]

    + #[
      To compute the blocking flow in $O(m n)$ time, we use a modified Depth First Search (DFS) with a "current-edge pointer" for each vertex. 
      #set enum(numbering: "1.")

      *Algorithm:*
      1. For each vertex $u in V$, initialize a pointer `ptr[u]` pointing to the first outgoing edge in its adjacency list in $cal(L)_f$. 
      2. Start a DFS from $s$. At the current vertex $u$, look at the edge $e = (u, v)$ pointed to by `ptr[u]`.
      3. If $c_f (e) > 0$, we advance our DFS to $v$. 
      4. If we reach $t$, we have found an $s-t$ path in $cal(L)_f$. 
         - Find the bottleneck capacity $delta$ of this path.
         - Augment the flow along this path by $delta$, updating the residual capacities. (This saturates at least one edge).
         - Restart the DFS from $s$.
5. Let $e = (u, v)$. If $c_f (e) = 0$, or if $v$ is a dead end (meaning `ptr[v]` has reached the end of its adjacency list or it has no outgoing edges), then increment `ptr[u]` and restart the DFS from $s$.
6. The algorithm terminates when `ptr[s]` reaches the end of $s$'s adjacency list. 

*Complexity:*
Because we never reset `ptr[u]`, an edge is removed permanently once it is saturated or leads to a dead end. 
Every DFS starts from $s$ and takes at most $n$ steps. Each DFS run can end in these ways:
  - It reaches $t$. We augment flow, which removes at least one edge from $cal(L)_f$. Since there are at most $m$ edges, this happens at most $m$ times. Time spent on this case across the whole algorithm is bounded by $m times O(n) = O(m n)$.
  - It hits a dead end (or a saturated edge). We advance `ptr[u]` and discard that edge from future consideration. Since there are at most $m$ edges, `ptr` arrays can be advanced at most $m$ times total. Time spent on this case is bounded by $m times O(n) = O(m n)$.

  Thus, the total time complexity is exactly $O(m n)$.
    ]

    + #[
      To prove the $O(m n^2)$ runtime, we must bound the total number of blocking flow iterations. 

      Let $ell(v)$ be the shortest path distance (number of edges) from $s$ to $v$ in $G_f$. By definition, every edge $(u, v)$ in $cal(L)_f$ strictly satisfies $ell(v) = ell(u) + 1$. 

      When we compute and augment a blocking flow in $cal(L)_f$, we saturate at least one edge on *every* possible shortest $s-t$ path. Therefore, in the new residual graph $G_f'$, no $s-t$ paths exist that are made entirely of the forward edges from the previous $cal(L)_f$. 

      Any newly created edges in $G_f'$ are backward edges $(v, u)$, which point strictly backwards relative to the distance layering: $ell(u) = ell(v) - 1$. 

      For a new $s-t$ path to exist in $G_f'$, it must use either these backward edges or cross edges (where $ell(v) <= ell(u)$). Because traversing these edges does not optimally increase the distance from $s$ by $1$ at each step, any valid $s-t$ path in $G_f'$ must require strictly more edges than the shortest path in $G_f$. 

      Thus, after every iteration of augmenting a blocking flow, the shortest path distance $d(t)$ strictly increases. 
      $ d_f' (t) > d_f (t) $

      Since the maximum possible length of a simple path in a graph with $n$ vertices is $n - 1$, the distance $d(t)$ can strictly increase at most $n - 1$ times before $s$ and $t$ become completely disconnected.

      This guarantees there are at most $O(n)$ blocking flow iterations. 
      Since each iteration computes a blocking flow in $O(m n)$ time (from part b), the total time complexity of Dinic's Algorithm is:
      $ O(n) "iterations" times O(m n) "time per iteration" = O(m n^2) $
    ]
]


