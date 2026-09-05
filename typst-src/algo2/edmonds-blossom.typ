#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz
#import "@preview/cetz:0.5.2": canvas, draw


#show: project.with(
  subject: "Algorithms II",
  topic: "Maximum Matching in General Graphs"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt
#let symdiff = math.class("binary", sym.Delta)

#title[Maximum Matching in General Graphs]

We have already discussed the Maximum Matching problem for bipartite graphs, by reducing it to the Maximum Flow problem. Here, we discuss the maximum matching problem on general graphs. In particular, we will discuss the *Edmonds' Blossom Algorithm* which finds the maximum matching in a general graph in polynomial time.

= The Problem

Recall, that a *matching* in a graph $G$ is a subset of edges, such that no two edges share any common vertex.

The *maximum matching problem*: Given a general graph $G$, find a maximum-cardinality matching $M$ in $G$.

A *perfect matching* in a graph $G$ is a matching which covers every vertex of the graph. If $G$ has $n$ nodes, a perfect matching in $G$ will have $n/2$ edges (if it exists). If a perfect matching exists in $G$, then it is a maximum matching of $G$.


#let graph-diagram(
  nodes: (:),
  edges: (),
  matched: (),
  exposed: (),
  red: (),
  blue: (),
  node-styles: (:),
  radius: 1.5mm,
  node-style: (fill: white, stroke: black + 0.7pt),
  edge-style: (stroke: black + 0.7pt),
  matched-style: (stroke: 2.5pt + primary-color),
  label-size: 9pt,
  labels: false,
  annotate: none,
  ..canvas-args,
) = {
  canvas(length: 1cm, ..canvas-args, {
    import draw: *

    for (name, pos) in nodes {
      if (name in exposed) { circle(pos, radius: 3mm, stroke: none, fill: gradient.radial(std.red, white)) }
    }

    for e in edges {
      let a = e.at(0)
      let b = e.at(1)
      let extra = if e.len() > 2 { e.at(2) } else { (:) }
      let is-matched = matched.contains((a, b)) or matched.contains((b, a))
      let style = if is-matched { matched-style } else { edge-style }
      line(nodes.at(a), nodes.at(b), ..style, ..extra)
    }

    for (name, pos) in nodes {
      let fill = (if name in red { std.red } else if name in blue { std.blue } else { white }).lighten(40%)
      circle(
        pos, radius: radius, name: name,
        ..node-style, fill: fill, ..node-styles.at(name, default: (:))
      )

      if labels {
        content(name, text(size: label-size)[#name])
      }
    }

    if annotate != none { annotate() }
  })
}

#figure(grid(columns: 2, gutter: 3em, graph-diagram(
  nodes: (
    a: (.3, 1.7), b: (1, 1), c: (2, 0),
    d: (3, 1), e: (3.7, 1.7), f: (2, -1)
  ),
  edges: (
    ("a", "b"), ("b", "c"), ("c", "d"), ("d", "e"), ("b", "d"), ("c", "f")
  ),
  matched: (
    ("a", "b"), ("c", "d"),
  ),
), graph-diagram(
  nodes: (
    a: (.3, 1.7), b: (1, 1), c: (2, 0),
    d: (3, 1), e: (3.7, 1.7), f: (2, -1)
  ),
  edges: (
    ("a", "b"), ("b", "c"), ("c", "d"), ("d", "e"), ("b", "d"), ("c", "f")
  ),
  matched: (
    ("a", "b"), ("c", "f"), ("d", "e")
  ),
)), caption: [Two matchings $M_1$ and $M_2$ in a graph $G$. $M_2$ is a perfect matching. (Note that $G$ is not bipartite.)])

Consider the graph $G$ in Figure 1. Observe that $G$ is not bipartite, since it has a cycle of odd length (i.e. a 3-cycle). Due to this, we cannot use simple algorithms that find matching in bipartite graphs (that we have discussed earlier). The presence of odd cycles is what makes it not very easy to find the maximum matching. To find a maximum matching in such a graph, we will need to specially handle these odd cycles, and do so in polynomial time.


*Goal:* Given a graph $G$, in polynomial time, find a maximum matching $M$ in $G$. As a simpler version, we will try to answer this question: *Does $G$ have a perfect matching?*

= Improvement

In our algorithm, we will start with the empty matching, and iteratively improve $M$ by finding a matching of larger size, till we find a maximum matching.

1. How to know if $M$ is a maximum matching?
2. If $M$ is not a maximum matching, how to find a matching $M'$ of larger value ($|M'| > |M|$)?

We define some terminologies and state a theorem for answering these questions:

Let $M$ be any matching in graph $G = (V, E)$.

A vertex $v in V$ is said to be *$M$-matched*, if there exists $u in V$, such that $(u, v) in M$ (i.e. $v$ exists in the matching $M$). Otherwise, $v$ is said to be *$M$-exposed*.

The *defect* of a matching $M$ is the number of unmatched vertices in $M$, i.e. the number of vertices that are $M$-exposed. A maximum matching has minimum defect, and a perfect matching has zero defect. (In Figure 1, $M_1$ has a defect of $2$.)

Define a *$M$-augmenting path* as follows: Any path $p = chevron.l v_0, v_1, ..., v_k chevron.r$ ($k >= 1$) is an $M$-augmenting path, if
1. $v_0$ and $v_k$ are $M$-exposed.
2. Alternating edges in the path are in the matching, i.e. $(v_1, v_2), (v_3, v_4), ..., (v_(k - 2), v_(k - 1)) in M$.

#figure(
  graph-diagram(
    nodes: (
      "0": (0, 0), "1": (1, 0), "2": (2, 0), "3": (3, 0), "4": (4, 0), "5": (5, 0)
    ),
    edges: (("0", "1"), ("1", "2"), ("2", "3"), ("3", "4"), ("4", "5")),
    matched: (("1", "2"),("3", "4")),
    exposed: ("0", "5"),
    length: 2cm,
  ),
  caption: [An $M$-augmenting path $p$ (in a larger graph $G$). Glowing vertices are $M$-exposed.]
)

Observe, that given an $M$-augmenting path, we can *augment along path $p$*: exchange the matched edges to be unmatched and the unmatched edges to be matched in the path $p$. Doing so necessarily gives us a larger matching $M'$ (such that $|M'| = |M| + 1$). (Mathematically, we may write $M' = M symdiff p$ where $p$ denotes the set of edges in path $p$.)

#figure(
  graph-diagram(
    nodes: (
      "0": (0, 0), "1": (1, 0), "2": (2, 0), "3": (3, 0), "4": (4, 0), "5": (5, 0)
    ),
    edges: (("0", "1"), ("1", "2"), ("2", "3"), ("3", "4"), ("4", "5")),
    matched: (("0", "1"), ("2", "3"), ("4", "5")),
    length: 2cm,
  ),
  caption: [Matching $M'$ obtained by augmenting along $M$-augmenting path $p$, $M'$ has one more matched edge as compared to $M$.]
)

For example, in Figure 1, matching $M_1$ is not a maximum matching. There exists a $M_1$-augmenting path (the path from the top-right corner vertex to the bottom vertex, passing through the right side of the triangle which is matched). If we augment along this path, we get $M_2$ which is a matching of larger size (and also happens to be the maximum matching.)

Clearly, if $M$ is a maximum matching, there will not exist any $M$-augmenting paths. (Otherwise we can find a matching of larger size). It turns out, that this condition is sufficient as well.

#theorem(title: "Theorem 1 (Berge's Theorem)",  numbered: false)[A matching $M$ is a maximum cardinality matching in a graph $G$ if and only if there is no $M$-augmenting path in $G$.]

*Proof*: We need to show that, if $M$ is not a matching of maximum cardinality, then there must exist a $M$-augmenting path. Suppose $M$ is a non-maximum matching in $G$. Let $M'$ be another matching, with $|M'| > |M|$.

Consider the subgraph $G_(M symdiff M') = (V, E = M symdiff M')$. This subgraph only has edges in $M$ or in $M'$ but not both. For a given vertex $v in V$, it can only be a part of at most one edge in $M$ and at most one edge in $M'$, thus its degree must be $0$, $1$ or $2$. So, $G_(M symdiff M')$ will be a collection of isolated vertices, and vertex-disjoint cycles and paths. In any cycle/path, edges must alternate being in $M$ and in $M'$.

In the cycles, the number of $M'$ edges and the number of $M$ edges are equal. In a path, either there is one more $M'$ edge, or one more $M$ edge. There must necessarily be at least one path out of these, in which the number of $M'$ edges is more (why?). This is a $M$-augmenting path:
1. The end vertices are not connected to any $M$ edges, so they are $M$-exposed.
2. Every alternating edge in this path is $M$.

Thus, there must exist a $M$-augmenting path, if $M$ is not a maximum matching. #h(1fr) $qed$

#let d1 = graph-diagram(
  nodes: (
    "0": (7, -3), "1": (4, -5), "2": (10, -5), "3": (5, -8), "4": (9, -8), "5": (4, -10), "6": (10, -10), "7": (12, -5), "9": (2, -5), "10": (7, -1)
  ),
  edges: (
    ("9", "10"), ("0", "10"), ("0", "1"), ("1", "3"), ("1", "9"), ("5", "9"), ("3", "5"), ("5", "6"), ("3", "4"), ("4", "6"), ("2", "4"), ("0", "2"), ("7", "10"), ("6", "7"), ("2", "7")
  ),
  matched: (
    ("0", "10"), ("2", "7"), ("1", "3"), ("5", "6")
  ),
  length: 0.5cm
)

#let d2 = graph-diagram(
  nodes: (
    "0": (7, -3), "1": (4, -5), "2": (10, -5), "3": (5, -8), "4": (9, -8), "5": (4, -10), "6": (10, -10), "7": (12, -5), "9": (2, -5), "10": (7, -1)
  ),
  edges: (
    ("9", "10"), ("0", "10"), ("0", "1"), ("1", "3"), ("1", "9"), ("5", "9"), ("3", "5"), ("5", "6"), ("3", "4"), ("4", "6"), ("2", "4"), ("0", "2"), ("7", "10"), ("6", "7"), ("2", "7")
  ),
  matched: (
    ("0", "10"), ("2", "7"), ("1", "9"), ("3", "5"), ("4", "6")
  ),
  length: 0.5cm,
  matched-style: (stroke: orange + 2.5pt)
)

#let d3 = graph-diagram(
  nodes: (
    "0": (7, -3), "1": (4, -5), "2": (10, -5), "3": (5, -8), "4": (9, -8), "5": (4, -10), "6": (10, -10), "7": (12, -5), "9": (2, -5), "10": (7, -1)
  ),
  edges: (
    ("9", "10"), ("0", "10"), ("0", "1"), ("1", "3", (stroke: primary-color + 2.5pt)), ("1", "9"), ("5", "9"), ("3", "5"), ("5", "6", (stroke: primary-color + 2.5pt)), ("3", "4"), ("4", "6"), ("2", "4"), ("0", "2"), ("7", "10"), ("6", "7"), ("2", "7")
  ),
  matched: (
    ("1", "9"), ("3", "5"), ("4", "6")
  ),
  length: 0.5cm,
  edge-style: (stroke: luma(180) + 0.7pt),
  matched-style: (stroke: orange + 2.5pt)
)

#figure(grid(columns: 3, gutter: 2em, d1, d2, d3), caption: [(a) A matching $M$ in $G$. (b) A matching $M'$, $|M'| > |M|$. (c) The graph $G_(M symdiff M')$.\ We see that there is a $M$-augmenting path from (c).])

This answers our first question. From an algorithmic perspective, we can start with the empty matching, and keep improving it until we get the maximum matching. The only missing step is that we need a procedure to *find an $M$-augmenting path* for some matching $M$ in $G$.

For finding a maximum matching:
- $M <- {}$
- #While $M$ is not a maximum matching
  - Find an $M$-augmenting path $p$
  - $M <-$ augment $M$ along $p$

= Bounding the size of the maximum matching

We will try to characterise, when does a perfect matching exist, or what is the size of the maximum matching. Let $G = (V, E)$ be a graph. Let $R subset.eq V$ be an arbitrary set of vertices in $G$. Let $G without R$ denote the induced subgraph of $G$ with the vertex set $V without R$.

Let $o(G without R)$ denote the number of components of odd cardinality in $G without R$. Any such component cannot be perfectly matched within itself, i.e. in any perfect matching $M$ of $G$, at least one vertex $v$ in such an odd component must be matched with some vertex outside this component. This other vertex must be in $R$ (why?).

So, for each odd component, at least one corresponding vertex must exist in $R$, for the possibility of a perfect matching to exist. Thus, we can state:

- If $|o(G without R)| > |R|$, then no perfect matching exists.

#figure(canvas({
  import draw: *
  line((0, 0), (-1, -2), (1, -2), close: true, name: "o1")
  line((0, -0.6), (-0.6, -1.8), mark: (symbol: "o"))
  translate((3, 0))
  line((0, 0), (-1, -2), (1, -2), close: true, name: "o2")
  line((0, -0.6), (-0.6, -1.8), mark: (symbol: "o"))
  translate((3, 0))
  line((0, 0), (-1, -2), (1, -2), close: true, name: "o3")
  line((0, -0.6), (-0.6, -1.8), mark: (symbol: "o"))
  translate((3, 0))
  line((0, 0), (-1, -2), (1, -2), close: true, name: "o4")
  line((0, -0.6), (-0.6, -1.8), mark: (symbol: "o"))
  translate((-8, -2.5))
  line((0, 0), (-2, 0), (-2, -2), (0, -2), close: true)
  line((-1.6, -0.4), (-1.6, -1.6), mark: (symbol: "o"))
  line((-0.4, -0.4), (-0.4, -1.6), mark: (symbol: "o"))
  translate((3, 0))
  line((0, 0), (-2, 0), (-2, -2), (0, -2), close: true)
  line((-1.6, -0.4), (-1.6, -1.6), mark: (symbol: "o"))
  line((-0.4, -0.4), (-0.4, -1.6), mark: (symbol: "o"))
  translate((3, 0))
  line((0, 0), (-2, 0), (-2, -2), (0, -2), close: true)
  line((-1.6, -0.4), (-1.6, -1.6), mark: (symbol: "o"))
  line((-0.4, -0.4), (-0.4, -1.6), mark: (symbol: "o"))
  translate((3, 0))
  line((0, 0), (-2, 0), (-2, -2), (0, -2), close: true)
  line((-1.6, -0.4), (-1.6, -1.6), mark: (symbol: "o"))
  line((-0.4, -0.4), (-0.4, -1.6), mark: (symbol: "o"))
  translate((-9, 0))
  circle((13, 0), radius: 1.2, name: "r")
  content((13, 0), text(1.2em)[$R$])

  line((rel: "o1", to: (0.2, -0.3)), "r", stroke: (dash: "dotted"), mark: (start: "o"))
  line((rel: "o2", to: (0.2, -0.3)), "r", stroke: (dash: "dotted"), mark: (start: "o"))
  line((rel: "o3", to: (0.2, -0.3)), "r", stroke: (dash: "dotted"), mark: (start: "o"))
  line((rel: "o4", to: (0.2, -0.3)), "r", stroke: (dash: "dotted"), mark: (start: "o"))
}, length: 0.6cm), caption: [Triangles depict odd components and squares depict even components of $G without R$. For a perfect matching to exist, at least one vertex in each odd component must be matched with a vertex in $R$.])


We can also bound the defect of a matching. For some $R subset.eq V$, at least $o(G without R) - |R|$ vertices must be unmatched. So,

$
  "min defect" >= max_(R subset.eq V) thick o(G without R) - |R|
$

If $d$ vertices in a matching are unmatched, then $n - d$ vertices are matched, which means the size of the matching is $1/2 (n - d)$. So, we have

#number[$
  "size of a max matching" &<= min_(R subset.eq V) 1/2 (n + |R| - |o(G without R)|)
$ <x>]

We will use this fact extensively while describing the algorithm. The celebrated Tutte-Berge theorem states that the above inequality is actually tight.

#theorem(title: "Theorem 2 (Tutte Berge Theorem)", numbered: false)[
  For any maximum matching $M$ of an undirected graph $G$, we have
  $
    |M| = min_(R subset.eq V) 1/2 (|V| + |R| - o(G without R))
  $
]

We will arrive at a proof of this theorem by describing the blossom algorithm.

= Alternating Trees

An *$M$-alternating tree* is a subgraph of $G$ with the following properties: the vertices of $T$ will be alternately colored blue and red.
- The root is colored blue.
- All leaves are colored blue.
- Every red vertex $r$ has exactly one child $s$, and the edge $(r, s)$ is in the matching.

#figure(
  graph-diagram(
    nodes: (
      "0": (7, -2), "1": (5, -4), "2": (7, -4), "3": (9, -4), "4": (5, -6), "5": (7, -6), "6": (9, -6), "7": (3, -8), "8": (5, -8), "9": (7, -8), "10": (9, -8), "11": (11, -8), "12": (3, -10), "13": (5, -10), "14": (7, -10), "15": (9, -10), "16": (11, -10), "17": (12, -12), "18": (12, -14), "e2": (2, -12), "e4": (6, -12), "e5": (6, -14)
    ),
    edges: (
      ("0",  "1"), ("0", "2"), ("0", "3"), ("1", "4"), ("2", "5"), ("3", "6"), ("4", "7"), ("4", "8"), ("5", "9"), ("6", "10"), ("6", "11"), ("7", "12"), ("8", "13"), ("9", "14"), ("10", "15"), ("11", "16"), ("16", "17"), ("17", "18"), ("12", "e2", (stroke: (dash: "dotted"))), ("9", "13", (stroke: (dash: "dotted"))), ("15", "18", (stroke: (dash: "dotted"))), ("14", "e4", (stroke: (dash: "dotted"))), ("e4", "e5")
    ),
    matched: (
      ("1", "4"), ("2", "5"), ("3", "6"), ("7", "12"), ("8", "13"), ("9", "14"), ("10", "15"), ("11", "16"), ("17", "18"), ("e4", "e5")
    ),
    exposed: ("0", "e2"),
    blue: ("0", "4", "5", "6", "12", "13", "14", "15", "16", "18"),
    red: ("1", "2", "3", "7", "8", "9", "10", "11", "17"),
    length: 0.6cm,
    annotate: () => {
      import draw: *
      content((2.5, -11), $e_1$, anchor: "south-east")
      content((6.5, -11), $e_2$, anchor: "south-east")
      content((6, -9), $e_3$, anchor: "south-east")
      content((10.5, -12), $e_4$, anchor: "north-east")
    }
  ),
  caption: [An $M$ alternating tree, which is a subgraph of $G$. There maybe other vertices and edges (matched or unmatched) present in $G$, not shown here. Dotted edges are not in the tree.]
)


For a $M$-alternating tree $T$, let us define some terms:

- $V(T) subset.eq V$: The set of vertices in the tree.
- $R(T)$: The set of red vertices in the tree; $B(T)$: the set of blue vertices in the tree. $R(T) union B(T) = V(T) subset.eq V$.
- Note that, by the structure of the tree, we always have: $|B(T)| = |R(T)| + 1$.
- For some vertex $v in V$, $N(v)$ denotes the neighbour set of vertex $v$, i.e. the set of vertices having an edge with $v$. (This considers all edges in the graph $G$, not just in the subgraph $T$.)

To proceed to find a $M$-augmenting path, suppose we have some $M$-alternating tree $T$. We will try to expand $T$. There are the following cases:

1. *Case 1:* There exists some neighbor of a blue node which is out of the tree: For some node $b in B(T)$, there exists $c in N(b)$ such that $c in.not V(T)$. Consider any such $(b, c)$ edge.
  #set enum(numbering: "a)")

  1. *Case 1a:* $c$ is $M$-exposed. This means, that the edge $(b, c)$ is similar to the edge $e_1$ in Figure 6. This means, we have found an $M$-augmenting path, which consists of the path from the root node to vertex $b$ in $T$, and the edge $(b, c)$. Clearly, both end points are $M$-exposed, and the path is alternating by virtue of being a tree path. So, we are done here (remember, our goal was to just find a $M$-augmenting path).
  2. *Case 1b:* $c$ is $M$-matched. Let $(c, d)$ be the edge which is in the matching $M$. So, the $(b, c)$ edge is similar to $e_2$ in Figure 6. Note that the vertex $d$ cannot be in the tree $T$ (why?). In this case, we can expand the tree to include the nodes $c$ and $d$. We color $c$ red, and $d$ blue. This maintains all our invariants for the tree $T$.

2. *Case 2:* All neighbors of blue nodes are in the tree: For all $b in B(T)$, for all $c in N(B)$, $c in V(T)$. We have already explored all edges from blue nodes. We call such a tree $T$ *stuck* (there are no more blue node edges to outside-the-tree nodes).
  #set enum(numbering: "a)")

  1. #[*Case 2a:* All neighbors of blue nodes are red nodes: For all $b in B(T)$, $N(b) subset.eq R(T)$. This means, all edges connected to blue nodes are tree edges, or non tree edges that connect to other red nodes in the tree, like edge $e_3$ in Figure 6. We call this tree $T$ *frustrated*. Observe, that this implies that the subgraph $T$ is locally 2-colorable (bipartite). In this case, we can claim that *no perfect matching exists*, i.e. the current subgraph is maximally matched.

    We can show this from Equation 1: Let $R = R(T)$. If we remove the set of vertices $R$ from $G$, then all blue vertices become isolated (there are no blue-blue edges in $G$). So, all these isolated blue vertices form odd-sized components in $G without R$. So, the $o(G without R) >= |B(T)|$. Then, the minimum defect is $>= o(G without R) - |R| >= |B(T)| - |R| = 1$. As the defect is at least 1, there cannot exist a perfect matching.
  ]

  2. #[
    *Case 2b:* The only other case, is that there exists a blue-blue edge: There exists $b, c in V$, $c in N(b)$. Edge $e_4$ in Figure 6 is an example of such an edge.

    Observe, that this implies we have found a cycle of odd length in $T$. We call this cycle a *blossom*.

    In this case, we *contract the blossom $C$* to obtain the *contracted graph* $G \/ C$. We remove all nodes in $C$ and replace it with a pseudovertex $v_C$. We retain all edges, while not keeping any parallel edges, i.e. add an edge $(v_C, u)$ if there exists an edge $(c, u), c in C$ in $G$. We color this pseudovertex blue.

    #figure(
      grid(columns: 2, gutter: 3em, align: horizon, graph-diagram(
        nodes: (
          "0": (-5, -4), "1": (-2, -5), "2": (-2, -8), "3": (-5, -9), "4": (-7, -6.5), "5": (-10, -6.5), "6": (-13, -6.5),
        ),
        edges: (
          ("0", "1"), ("1", "2"), ("2", "3"), ("3", "4"), ("4", "0"), ("4", "5"), ("5", "6")
        ),
        matched: (
          ("0", "1"), ("2", "3"), ("4", "5")
        ),
        exposed: ("6",),
        length: 0.5cm,
        blue: ("6", "4", "1", "2"),
        red: ("5", "3", "0"),
        annotate: () => {
          import draw: *
          content((-4, -6.5), $C$)
        }
      ),
      graph-diagram(
        nodes: (
          "0": (-6, -6.5), "5": (-10, -6.5), "6": (-13, -6.5),
        ),
        edges: (
          ("0", "5"), ("5", "6")
        ),
        matched: (
          ("0", "5"),
        ),
        exposed: ("6",),
        length: 0.5cm,
        node-styles: ("0": (radius: 0.6cm)),
        blue: ("0", "6"),
        red: ("5",),
        annotate: () => {
          import draw: *
          content("0", $v_C$)
        }
      )),
      caption: [(a) A _blossom_ $C$ (b) The graph $G \/ C$ after contracting $C$.]
    )

    In the contracted graph $G \/ C$, define the *contracted matching* $M'$ as the matching of $G \/ C$ corresponding to $M$. Let $T'$ be the *contracted tree* corresponding to $T$. Then we continue to expand the tree $T'$ in $G \/ C$.

  ]


Let's just recap what we have till now:
- We wish to find the maximum matching in a graph $G$, or determine whether $G$ has a perfect matching.
- We have the notion of $M$-augmenting paths, so we can start with the empty matching and keep augmenting by $M$-augmenting paths to reach the maximum matching. So our goal reduces to *just finding an $M$-augmenting path in a matching $M$.*
- To find an $M$-augmenting path, we traverse $G$ while building an $M$-alternating tree. While the tree is not stuck, we can explore blue-node edges which go outside the tree, if they go to an unmatched ($M$-exposed) vertex, we have found a $M$-augmenting path and we are done. If they go to a matched vertex, we simply grow the tree and continue our search.
- If the tree is stuck, then there are two possibilities, one is that all blue edges have been explored and no odd cycle has been found. Then, we claim that the root node cannot be matched, so no perfect matching can exist. The other possibility is that we find a *blossom* $C$ (an odd cycle), which we contract to $v_C$, and continue our search in the resultant graph.

We need to now justify this *contraction* step, and the validity of the other cases in the resultant graph as well. We do so via a series of Lemmas:

#lemma[After a blossom contraction, $M'$ is a matching of $G'$ and $T'$ is a $M'$-alternating tree.]

*Proof:* $M'$ is a matching in $G'$ as there are no two edges sharing the same vertex. The pseudo vertex can be matched to at most one other vertex (which must be in the tree). $T'$ follows the properties of an $M$-alternating tree, as the root is blue (either the old root or the psuedovertex); the leaves are blue, and the pseudovertex must be at an even distance from the root (since the LCA of the blue-blue edge that was found in $T$ must have been blue), so it is colored blue. Clearly any red vertex in $T'$ will have exactly one blue child, as it did in $T$.

#lemma[Let $T$ be the tree after a series of blossom contractions. Every pseudovertex $v_C$ represents a connected subgraph containing odd number of original vertices in $V$.]

*Proof:* Use induction. The base case is that $C$ only consists of simple original vertices. Then the size of $C$ is odd, so $v_C$ corresponds to an odd number of vertices in $V$. Inductively, some $C$ may consist of psuedovertices as well as normal vertices. Each of these represents an odd number of vertices in $V$. Since $C$ is an odd cycle, and the sum of an odd number of odd numbers must be odd, so $v_C$ corresponds to an odd number of original vertices in $V$.

#lemma[*(Lifting the augmenting path)* An $M$-augmenting path exists in $G$ iff an $M'$-augmenting path exists in $G \/ C$.]

*Proof:* Suppose we find a $M'$-augmenting path $p$. If $p$ does not pass through any pseudo vertex, then it is a $M$-augmenting path. Otherwise, suppose it passes through $v_C$. We replace $v_C$ with some path $u -> ... -> v$, internal to the blossom $C$, where $u$ and $v$ are the appropriate vertices which join with the rest of the path, and we take the even length subpath from $u$ to $v$ in the blossom $C$. This ensures, the resulting path is an $M$-augmenting path.

#figure(
  grid(gutter: 2em, graph-diagram(
    nodes: (
      "0": (0, 0), "1": (1, 0), "2": (2, 0), "3": (3, 0), "4": (4, 0), "5": (5, 0)
    ),
    edges: (("0", "1"), ("1", "2"), ("2", "3"), ("3", "4"), ("4", "5")),
    matched: (("1", "2"),("3", "4")),
    exposed: ("0", "5"),
    node-styles: ("2": (radius: 0.6cm)),
    blue: ("0", "2", "4"),
    red: ("1", "3"),
    length: 2cm,
    annotate: () => {
      import draw: *
      content("2", $v_C$)
      content((4, 0.3), [an $M'$-augmenting path])
    }
  ),
  graph-diagram(
    nodes: (
      "-2": (-4, -5), "-1": (-1, -5), "0": (5, -4), "1": (2, -5), "2": (2, -8), "3": (5, -9), "4": (7, -6.5), "5": (10, -6.5), "6": (13, -6.5), "7": (16, -6.5),
    ),
    edges: (("-1", "-2"), ("1", "-1"), ("0", "1"), ("1", "2"), ("2", "3"), ("3", "4"), ("4", "0"), ("4", "5"), ("5", "6"), ("6", "7")),
    matched: (("-1", "1"),("5", "6"), ("0", "4"), ("2", "3")),
    exposed: ("-2", "7"),
    blue: ("-2", "6"),
    red: ("-1", "5"),
    length: 0.5cm,
    annotate: () => {
      import draw: *
      content((4.5, -6.5), $C$)
      line((-4.5, -4), (2.5, -4), (5, -3), (7, -5.5), (17, -5.5), stroke: red)
      content((13, -5), [an $M$-augmenting path])
    }
  )),
  caption: [Lifting an $M'$-augmenting path to an $M$-augmenting path.]
)

#lemma[After a series of blossom contractions, if an alternating tree $T$ becomes frustrated (Case 2a), it contains exactly one unmatchable vertex, and $G$ does not have a perfect matching.]

We have already shown this for the case that $T$ does not contain any pseudo vertices. We just extend the proof: Take $R = R(T)$. Applying Equation 1 on $G$, the graph $G without R$ will have all blue vertices isolated. Each blue vertex in $G$ represents either a single original vertex, or an odd number of original vertices (Lemma 2). Thus, each blue vertex forms a odd component in $G without R$. The minimum defect is therefore $o(G without R) - |R| >= |B| - |R| = 1$. Since the minimum defect is at least $1$, $G$ does not have any perfect matching. #h(1fr) $qed$

#figure(
  grid(columns: 5, align: horizon, gutter: 1em,
    graph-diagram(
      nodes: (
        "0": (8, -2), "2": (7, -4), "3": (9, -4), "5": (7, -6), "6": (9, -6), "10": (9, -8), "11": (11, -8), "15": (9, -10), "16": (11, -10), "17": (12, -12), "18": (12, -14), "e": (13, -8)
      ),
      edges: (
        ("0", "2"), ("0", "3"), ("2", "5"), ("3", "6"), ("6", "10"), ("6", "11"), ("10", "15"), ("11", "16"), ("16", "17"), ("17", "18"), ("15", "18", (stroke: (dash: "dotted"))), ("11", "e", (stroke: (dash: "dotted")))
      ),
      matched: (
        ("1", "4"), ("2", "5"), ("3", "6"), ("7", "12"), ("8", "13"), ("10", "15"), ("11", "16"), ("17", "18"), ("e4", "e5")
      ),
      exposed: ("0", "e"),
      blue: ("0", "4", "5", "6", "12", "13", "14", "15", "16", "18"),
      red: ("1", "2", "3", "7", "8", "9", "10", "11", "17"),
      length: 0.6cm,
      annotate: () => {
        import draw: *
        content((10, -9), $C$)
      }
    ),
  canvas({
    import draw: *
    line((0, 0), (2, 0), mark: (end: ">", fill: black))
    content((1, 0), [contract $C$] + v(2mm), anchor: "south")
  }),
  graph-diagram(
    nodes: (
      "0": (8, -2), "2": (7, -4), "3": (9, -4), "5": (7, -6), "6": (9, -7), "e": (11, -10)
    ),
    edges: (
      ("0", "2"), ("0", "3"), ("2", "5"), ("3", "6"), ("6", "e", (stroke: (dash: "dotted")))
    ),
    matched: (
      ("1", "4"), ("2", "5"), ("3", "6"), ("7", "12"), ("8", "13"), ("10", "15"), ("11", "16"), ("17", "18"), ("e4", "e5")
    ),
    exposed: ("0", "e"),
    blue: ("0", "4", "5", "6", "12", "13", "14", "15", "16", "18"),
    red: ("1", "2", "3", "7", "8", "9", "10", "11", "17"),
    length: 0.6cm,
    node-styles: ("6": (radius: 0.4cm)),
    annotate: () => {
      import draw: *
      let t = (s) => (rel: s, to: (0.5, 0.5));
      content("6", $v_C$)
      line(t("0.center"), t("3.center"), t("6.center"), t("e.center"),  stroke: red)
      content((9, -12), [an $M'$-augmenting path])
    }
  ), canvas({
    import draw: *
    line((0, 0), (1.5, 0), mark: (end: ">", fill: black))
    content((0.75, 0),  [lift to $M$] + v(2mm), anchor: "south")
  }), graph-diagram(
    nodes: (
      "0": (8, -2), "2": (7, -4), "3": (9, -4), "5": (7, -6), "6": (9, -6), "10": (9, -8), "11": (11, -8), "15": (9, -10), "16": (11, -10), "17": (12, -12), "18": (12, -14), "e": (13, -8)
    ),
    edges: (
      ("0", "2"), ("0", "3"), ("2", "5"), ("3", "6"), ("6", "10"), ("6", "11"), ("10", "15"), ("11", "16"), ("16", "17"), ("17", "18"), ("15", "18"), ("11", "e", (stroke: (dash: "dotted")))
    ),
    matched: (
      ("1", "4"), ("2", "5"), ("3", "6"), ("7", "12"), ("8", "13"), ("10", "15"), ("11", "16"), ("17", "18"), ("e4", "e5")
    ),
    exposed: ("0", "e"),
    blue: ("0", "4", "5",),
    red: ("1", "2", "3", "7", "8", "9", ),
    length: 0.6cm,
    annotate: () => {
      import draw: *
      line((7.3, -2), (8.3, -4), (8.3, -10.5), (12.3, -15), (12.4, -11.5), (11.5, -10), (11.5, -8.4), (13, -8.4), stroke: red)
      content((12, -3),  [an $M$-augmenting path])
    }
  )),
  caption: [(a) We find a blossom $C$ and contract it. (b) In the contracted graph we find an $M'$-augmenting path. (c) We lift it to get an $M$-augmenting path.]
)


Thus, we have the following:
- If we get to case 1a, the augmenting path found can be lifted to an $M$ augmenting path, and we are done.
- If we get to case 1b, we simply grow the tree by adding two new vertices.
- If we get to case 2a, then we report that no perfect matching exists (Lemma 4).
- If we get to case 2b, we found a blossom $C$, then we contract the blossom $C$, and proceed working on the contracted tree $T'$.

Thus, we can formulate a traversal algorithm that finds $M$-augmenting paths, or reports that no perfect matching exists in $G$.



= What about maximum matching?

This solves the problem of determining whether a perfect matching exists or not, but our original goal was to find the maximum matching, even if no perfect matching exists. Then we need to do something else in Case 2a instead of stopping.

When we encounter Case 2a (a frustrated tree), we know from Lemma 4 that this specific subgraph is locally maximally matched; exactly one vertex (the root) cannot be matched. We have *accumulated one defect* (one unmatched vertex) in $T$.

If $T$ is frustrated, we leave it as it is, keep its root unmatched, and restart our search from another $M$-exposed vertex, to build a new alternating tree. We continue this until we find an $M$-augmenting path (of course), or till every $M$-exposed vertex has become the root of a frustrated tree.

If we did not find any $M$-augmenting path (in our search), then we have a forest $F$ of frustrated trees, and a total of $d = |F|$ vertices unmatched in $M$. We claim that at this point, $M$ is a maximum matching, or in other words, $d$ is the minimum defect attainable on  graph $G$.

Let $R_F$ denote the set of all red vertices in $F$, i.e. $R_F = union.big_(T in F) R(T)$, similarly $B_F = union.big_(T in F) B(T)$.

Consider the graph $G without R_F$. Every $b in B_F$ will become isolated, and by lemma 2, each of these represent odd-connected components in $G$. So,
$
  o(G without R_F) >= |B_F|
$

From our tree invariants, we know that for each tree, $B(T) = R(T) + 1$. Since there are $d$ frustrated trees, we can write
$
  |B_F| = |R_F| + d
$

Substituting this in the inequality, we get
$
  o(G without R_F) >= |R_F| + d\
  => d <= o(G without R_F) - |R_F|
$

Recall, that from Equation 1, we have, the minimum defect of any matching must be at least $o(G without R) - |R|$ for some $R subset.eq V$. (If we achive some defect $d$ which is equal to some $o(G without R) - |R|$, then we can not decrease it any further, that defect must be the minimal possible.) We know that our matching has a defect of $d$. But we just showd that $d$ can be at most the expression $o(G without R_F) - |R_F|$. Thus, the inequality must be tight:

$
  d = o(G without R_F) - |R_F|
$

Thus, $d$ must be the minimum defect attainable on $G$, hence $M$ is a maximum matching  of $G$. This also means $R_F$ is the set that attains the maximum obstruction to get a perfect matching, i.e. $R = R_F$ maximises the term $o(G without R) - |R|$.

Note that this (constructively) proves Theorem 2 (Tutte-Berge Theorem), as we have found a matching that achieves the bound in Equation 1:

$
  |M| = 1/2 (|V| - d) = 1/2 (|V| + |R_F| - o(G without R_F)) = min_(R subset.eq V) 1/2 (|V| + |R| - o(G without R))
$

= The algorithm

Finally, we bring everything together and specify the *Edmonds' Blossom Algorithm*:

We start with the empty matching $M$, and in each iteration, we try to find an $M$-augmenting path. If it exists, then we augment by the path, and continue. If no augmenting path exists, then $M$ is a maximum matching.

Given a matching $M$, we need to find an $M$-augmenting path. We find some $M$-exposed vertex $s$. (If none exist, $M$ is already a perfect matching). We will perform a modified BFS on $G$ to find an $M$-augmenting path. We will maintain a $M$-alternating tree $T$ (actually, a forest of such BFS trees). We first color $s$ blue, and enqueue $s$. Initially, only $s$ exists in our tree. In our BFS we maintain the invariant that the queue always only contains blue vertices. So we only ever explore edges from the blue nodes.

In the BFS iteration, we dequeue a blue node $u$. For each edge $(u, v)$ incident on $u$:
- *If $v$ is an out-of-tree vertex*:
  - *If $v$ is $M$-exposed*: We have found an augmenting path: from the root $s$ to $u$, and the edge $(u, v)$. Return this augmenting path (after lifting the path (Lemma 3) some number of times if required).
  - *If $v$ is $M$-matched*: Let $(v, r) in M$ be the matched edge, then add the edges $(u, v), (v, r)$ in the tree, color $v$ red and $r$ blue. Continue.
- Otherwise,
  - *If $v$ is a red vertex* (in the same tree, or a different tree), (similar to edge $e_3$ in Figure 6), we don't do anything, and continue.
  - *If $v$ is a blue vertex* (must be in the same tree, why?), then we have found an odd cycle $C$. Contract the cycle $C$ and continue searching on the contracted tree $T'$.

If at some point, our queue becomes empty (there are no more nodes to dequeue), then $T$ is a frustrated tree (as in Case 2a). Then, we keep $T$ as it is, and restart our BFS from a different $M$-exposed vertex.

Suppose we have exhausted all $M$-exposed vertices (and still not found any $M$-augmenting path). Then, $M$ is a maximum matching, and we are done.  (We have shown this in the previous section.)

#pagebreak(weak: true)

For completeness (and analysis), here is an informal pseudocode for the complete algorithm.


#algorithm("Edmonds-Blossom", params: ([$G$],))[
  #aline[$M <- phi$]
  #aline[#While #True]
  #aline(indent: 1)[$P <- call("Find-Augmenting-Path")(G, M)$]
  #aline(indent: 1)[#If $P$ is not *null*]
  #aline(indent: 2)[$M <- M$ augmented along $P$]
  #aline(indent: 1)[#Else]
  #aline(indent: 2)[#Return $M$]
]
#algorithm("Find-Augmenting-Path", params: ([$G$], [$M$]))[
  #aline[$F <- phi$ (the BFS forest)]
  #aline[#For each $M$-exposed vertex $s$ in $G$]
  #aline(indent: 1)[#If $s$ belongs to a previously frustrated tree]
  #aline(indent: 2)[#Continue]
  #aline(indent: 1)[$Q <-$ empty queue]
  #aline(indent: 1)[$"color"(s) <- $ blue; add to a new tree $T$]
  #aline(indent: 1)[*enqueue* $s$ into $Q$]
  #aline(indent: 1)[#While $Q$ is not empty]
  #aline(indent: 2)[$u <-$ *dequeue* a blue node from $Q$]
  #aline(indent: 2)[#For each edge $(u, v)$]
  #aline(indent: 3)[#If $v in.not F$]
  #aline(indent: 4)[#If $v$ is $M$-exposed]
  #aline(indent: 5)[$P <-$ path from root $s$ to $u$ in $T$ + edge $(u, v)$]
  #aline(indent: 5)[$P' <-$ lift $P$]
  #aline(indent: 5)[#Return $P'$]
  #aline(indent: 4)[#Else if $v$ is $M$-matched]
  #aline(indent: 5)[let $(v, r) in M$ be the matched edge]
  #aline(indent: 5)[add edges $(u, v)$ and $(v, r)$ to $T$]
  #aline(indent: 5)[$"color"(v) <-$ red; $"color"(r) <- $ blue]
  #aline(indent: 5)[*enqueue* $r$ into $Q$]
  #aline(indent: 3)[#Else]
  #aline(indent: 4)[#If $"color"(v) =$ red]
  #aline(indent: 5)[#Continue]
  #aline(indent: 4)[#Else #If $"color"(v) =$ blue]
  #aline(indent: 5)[contract the odd cycle (blossom) into a pseudovertex]
  #aline(indent: 5)[update $G$ and $T$ to the contracted graph and tree]
  #aline(indent: 5)[#Continue]
  #aline(indent: 1)[mark $T$ as a frustrated tree]
  #aline[#Return *null*]
]

#pagebreak(weak: true)

= Time Complexity

- Outer loop in #op("Edmonds-Blossom"): On each iteration, we improve the size of the matching by at least one. Since the size of the maximum matching is at most $V / 2$, so this loop runs at most $V / 2$ times.
- Inner BFS (#op("Find-Augmenting-Path")):
  - Other than blossoms, exploring the graph takes $O(E)$ time.
  - Each blossom contraction (line 24) reduces the total number of vertices in the graph by at least 2. So, there can be at most $O(V)$ contractions. Each contraction involves updating the graph, which can take $O(E)$ time. So in total, contracting vertices take $O(V E)$ time.
  - Path lifting (line 13) takes $O(V)$ time (expanding the pseudo vertices and routing the path through odd cycles). This happens at most once in one call of #op("Find-Augmenting-Path")
  - Every other operation unaccounted for in this function runs in constant time.

Therefore, in total the time complexity is bounded by $O(V) times O(V E) = O(V^2 E)$, which is polynomial time.


#v(3em)

#align(center, line(length: 40%))
