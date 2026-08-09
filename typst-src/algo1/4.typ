#import "template.typ": project, infobox
#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2": plot, chart
#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "algorithmic.typ"
#import algorithmic: style-algorithm, algorithm-figure
#show: style-algorithm

#show: project.with(
  title: "Assignment 4",
  subtitle: "Graph Algorithms"
)

#let high1 = text.with(fill: rgb("#8c0000"))

#set enum(numbering: "(a)")

#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$),
)

#let hl(color: rgb("#f9e5cc"), text) = {
  box(text, fill: color, outset: (y: 2pt, x: 2pt), radius: 2pt)
}

#let quest(number, body) = {
  show strong: high1
  grid(columns: (3em, 1fr), strong[#high1(number)], body)
}

#let high2 = text.with(fill: blue)

#let ans(body) = grid(columns: (3em, 1fr), strong(high2[Sol.]), body)
  #let accent = rgb("#b9b9a1")

#set math.mat(delim: "[")
#set math.vec(delim: "[")

#show math.equation.where(block: false): math.display

// #show strong: high1
#let bigO = scr("O")
#let thereexists = $exists thick$
#let forall = $forall thick$
#let st = "such that"

#let num(body) = {
  set math.equation(numbering: x => [(1.#x)])
  body
}

#let algorithm-figure = algorithm-figure.with(style: strong, vstroke: 1pt + luma(200))

#let adj = "adj"

#let path(..args) = $lr(chevron.l #args.pos().join($,$) chevron.r)$

#quest[1.][
  An undirected graph $G = (V,E)$ is called *bipartite* if its vertex set $V$ can be partitioned into two subsets $V_1$ and $V_2$, such that every edge in $E$ has one endpoint in $V_1$ and the other in $V_2$. Equivalently, $G$ is bipartite if its vertices can be colored using two colors so that no two adjacent vertices receive the same color.

  Prove that an undirected graph $G$ is bipartite if and only if it contains no cycle of odd length.
]

#ans[

  $=>$ : Let $G$ be a bipartite graph. Assume that it contains a cycle of odd length, $path(v_1, v_2, ..., v_(2k+1), v_1)$. This means that ${(v_1, v_2), (v_2, v_3), (v_3, v_4), ..., (v_(2k+1), v_1)} subset.eq E$ are edges in the graph. Since the graph is bipartite, $V$ can be partitioned into $V_1$ and $V_2$ such that all edges have one vertex from each subset. 

  WLOG, let $v_1 in V_1$. Then, we have,
  $
  v_1 in V_1 &=> v_2 in V_2
  &=> v_3 in V_1
  &=> dots
  &=> v_(2k) in V_2
  &=> v_(2k + 1) in V_1  $
  But, $v_(2k + 1) in V_1$ and $v_1 in V_1$ while $(v_(2k + 1), v_1) in E$, which is a contradiction. Thus $G$ cannot contain a cycle of odd length.

  $arrow.double.l$ : Let $G$ be an undirected graph which does not contain any odd length cycles. Then, let us try to find a 2-coloring of the graph. Call an edge *well-colored*, if both its endpoints are differently colored. We need to show that there exists some coloring strategy by which every edge in the graph will become well-colored.
  
  Perform depth first search on the graph, coloring each node such that two adjacent vertices will have different colors. This ensures that all edges which are a part of the DFS forest are well-colored.

  Consider any non-tree edge $(v_1, v_2)$. Note that this must necessarily be an edge connecting two vertices which are the part of the same DFS tree. Then, consider the (unique) path $P$ from $v_1$ to $v_2$ in the DFS tree, having all well-colored edges. Now, there also exists the edge between $v_1$ and $v_2$, which makes $P + (v_2, v_1)$ a cycle. This cycle must have even length (by assumption), thus, in the tree path from $v_1$ to $v_2$ there must be an even number of intermediate vertices.

  Since we know that the path from $v_1$ to $v_2$ is a well-colored path, and it has even number of intermediate vertices, it follows that $v_1$ and $v_2$ must be differently colored; using similar reasoning as above. Thus, $(v_1, v_2)$ is a well-colored edge, which completes the proof.
]
#line(length: 100%, stroke: 0.5pt)
#pagebreak(weak: true)

#quest[2.][
  Given an undirected graph $G = (V, E)$, design an algorithm to determine whether $G$ is bipartite.
]

#ans[
  Perform a DFS on the graph. Arbitrarily color the first unvisited vertex, and hence for each edge $(u, v)$
  - If $v$ hasn't been visited yet, color it the opposite color of $u$.
  - If $v$ has already been visited, and its color is the same as that of $u$, then report $G$ is not bipartite. Continue otherwise.
  If we succeed in visiting all vertices, we report that $G$ is bipartite.

  *Correctness*

  Success: Since we have successfully 2-colored the graph, $G$ must be bipartite. (We have ensured all tree-edges and non-tree edges to be well-colored.)

  Non-success: We break at a certain point when we find that by our coloring we have found a non well-colored edge, i.e. an edge with both vertices colored the same. Let this edge have endpoints $v_1$ and $v_2$. Consider the unique path $P$ from $v_1$ to $v_2$ in the DFS tree. Note that this is a well-colored path (by our coloring strategy). Since $v_1$ and $v_2$ have the same color, this means there must be an odd number of intermediate vertices in this path.  Consider the cycle $P + (v_2, v_1)$, this is a cycle of odd length, thus $G$ is not bipartite (from 1).

  *Time Complexity*: $O(|V| + |E|)$
]

#line(length: 100%, stroke: 0.5pt)
#pagebreak(weak: true)
#quest[3.][
  Given an undirected graph $G = (V, E)$, define its *square* $G^2 = (V, E^2)$ such that  $(u, v) in E^2$ if and only if there exists a path in $G$ from $u$ to $v$ with #high1[at most two edges]. Design efficient algorithms to compute $G^2$ from $G$ for both:
  + Adjacency list representation
  + Adjacency matrix representation
  Analyze the time complexity of both algorithms---as  functions of $|V|$, $|E|$ and $Delta$, where:
  $
  Delta := max_(v in V) "deg"^+ (v), quad quad "deg"^+ (u) := "number of outgoing edges from" u 
  $

  Which one is better between (a) and (b), and when? Justify.
]

#ans[
  The key observation is that $G^2$ will have an edge between $u$ and $v$ iff there exists a path of length 1 between them (an edge), or if there exists a path of length 2 $path(u, k, v)$ between them.
  + #[
    Observe that the adjacency list of $G^2$ will contain the edge $(u, v)$ if 
    #set enum(numbering: "(i)")
    + $(u, v) in E$, or
    + $(u, k) in E$ and $(k, v) in E$ for some $k$

    This leads to the following algorithm:

    #algorithm-figure(
      [Find  $G^2$ from Adjacency List],
    {
      import algorithmic: *
      Procedure(
        "Find-Square-List",
        ($G$),
        {
          LineComment(For([$u$ in $V$], {
            For([$v$ in $adj[u]$], {
              Assign[$"adj2"[u]$][append $v$]
            })
          }), "1")
          LineComment(For([$u$ in $V$], {
            For([$k$ in $adj[u]$], {  
              For([$v$ in $adj[k]$], {
                If($u!=v$, {
                  Assign[$"adj2"[u]$][append $v$]
                })
              })
            })
          }), "2")
          Return[$"adj2"$]
        }
      )
    }
  )


  *Time Complexity:* $O(|E|  +|V| Delta^2) equiv O(|E| + |E| Delta) = O(|E| Delta)$
  ]

  + #[
    Let $A$ be the adjacency matrix representation of $G$ and $A^*$ be the adjacency matrix representation of $G^2$.

    Observe that $A^*[i, j] = 1$ iff at least one of the following is true:
    #set enum(numbering: "(i)")
    + $A[i, j] = 1$
    + There exists $k$ such that $A[i, k] = 1 and A[k, j] = 1$
    Equivalently, $A^*[i, j] = 0$ iff $A[i, j] = 0$ and $A[i, k] and A[k, j] = 0 quad forall k in V$.

    Consider the matrix $B = A times A = A^2$. By definition, $B[i, j] = sum_(k=1)^n A[i, k]A[k, j]$. In particular, $B[i, j] = 0$ if and only if $A[i, k]A[k, j] = 0$ for all $k in V$.  (This is due to the fact that $A[i, j] in {0, 1}$ for all $i, j in V$.)

    $B[i, j]$ is non zero otherwise. i.e., $B[i, j]$ is non zero if there exists $k$ such that $A[i, k] A[k, j] > 0$. Note that this is the same as condition (ii) above.

    Thus, we can construct $A^*$ from $B$ in this way:
    - $A^* [i, j] = 1$ if $B[i, j] > 0$ or $A[i, j] = 1$
    - $A^* [i, j] = 0$ otherwise

    To find $B$, we take the matrix multiplication of $A$ with itself.

    1. Compute the matrix $A^2$
    2. Compute the matrix $A^*$ as per:

    $
    A^*_(i j) = cases(1 quad &"if" A^2_(i j) > 0 "or" A_(i j) = 1, 0 &"otherwise")
    $

    *Time Complexity:* $O(|V|^3 + |V|^2) = O(|V|^3)$
  ]
  *Comparison*
  - For *sparse graphs*, $|E| << |V|^2$, (a) is a much better choice. Since (a) operates on the adjacency list, it exploits the sparsity of the graph by only iterating over the valid edges in the graph.
  - For *dense graphs*, $|E| approx |V|^2$, and we have $Delta = O(|V|)$, so both (a) and (b) are asymptotically equivalent in their time complexity, $O(|V|^3)$.  
]

#line(length: 100%, stroke: 0.5pt)
#pagebreak(weak: true)

#quest[4.][
  Show how to determine whether a directed graph $G$ contains a *universal sink* --- a vertex with in-degree $|V| - 1$ and out-degree $0$ --- in time $O(|V|)$, given the adjacency matrix $A[1...n][1...n]$ of $G$.
]

#ans[
  Note that if a graph $G$ has a universal sink $s$, then its adjacency matrix will have the property: $A[s, j] = 0$ and $A[j, s] = 1$ for all $j != s$.

  On the adjacency matrix, for any $i != j$, if $A[i, j] = 0$, then $j$ cannot be a universal sink (as there is no edge from $i$ to $j$). If $A[i, j] = 1$, then $i$ cannot be a universal sink (since there is an outgoing edge from $i$). Thus we can eliminate one vertex from being a universal sink by using a single access from the adjacency matrix. 

  By using this observation we can arrive at the following algorithm:

  #algorithm-figure(
    "Find Universal Sink",
    {
      import algorithmic: *
      Procedure(
        "Find-Sink",
        ("A"),
        {
          Assign[$i,j$][$1, n$]
          While($i < j$, {
            IfElseChain($A[i, j] = 0$, Assign[$j$][$j - 1$], Assign[$i$][$i + 1$])
          })
          Comment[Check if $i$ is a universal sink]
          For($k <- 1 "to" n$, {
            If($k != i and (A[i, k] = 1 or A[k, i] = 0)$, Return(smallcaps("nil")))
          })
          Return[$i$]
        }
      )
    }
  ) <sink>

  
  #let gridd = (
    (0, 1, 0, 1, 1, 0, 1),
    (0, 0, 0, 0, 1, 0, 0),
    (0, 1, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 1, 0, 0),
    (0, 0, 0, 1, 1, 0, 0)
  )
  #let pts = ((1, 7), (2, 7), (2, 6), (2, 5), (3, 5), (4, 5))

  #let figa = table(
    columns: (auto, ) + (1.5em, ) * 7,
    rows: (1.5em, ) * 8,
    align: horizon + center,
    stroke: none,
    ..for i in range(7) {
      for j in range(7) {
        let cover = if i == 4 and j == 4 { circle.with(radius: 0.75em) } else { it => it }
        (table.cell(x: j + 1, y: i + 1, cover[#gridd.at(i).at(j)], stroke: 0.5pt, fill: if i == j { blue.lighten(80%) } + if (i + 1, j + 1) in pts { yellow }),)
      }
    },
    table.cell(x: 0, y: 0, align: right, high1[$j = $]),
    ..for i in range(7) {
      (table.cell(x: i + 1, y: 0, high1[#(i + 1)]),)
    },
    table.cell(x: 0, y: 1, align: right, high1[$i = 1$]),
    ..for i in range(1, 7) {
      (table.cell(x: 0, y: i + 1, high1[#(i + 1)], align: right),)
    }
  )

  #let figb = table(
    columns: 3,
    inset: (x: 1em),
    stroke: (_, y) => if y > 0 { (top: 0.8pt) },
    [$i = 1, j = 7$], [$A[i, j] = A[1, 7] = 1$], [$i <- i + 1$],
    [$i = 2, j = 7$], [$A[i, j] = A[2, 7] = 0$], [$j <-j - 1$],
    [$i = 2, j = 6$], [$A[i, j] = A[2, 6] = 0$], [$j <- j - 1$],
    [$i = 2, j = 5$], [$A[i, j] = A[2, 5] = 1$], [$i <- i + 1$],
    [$i = 3, j = 5$], [$A[i, j] = A[3, 5] = 1$], [$i <- i + 1$],
    [$i = 4, j = 5$], [$A[i, j] = A[4, 5] = 1$], [$i <- i + 1$],
    high2[$i = 5, j = 5$], [-]
  )


  #figure(
    grid(columns: 2, gutter: 2em, align: horizon, figa, figb),
    kind: image,
    caption: [Demonstration of working of @sink on a directed graph with universal sink $s = 5$.]
  )
  
  *Correctness:*

  We claim that the following invariance holds before and after each iteration of the loop: 
  - If $s$ is a universal sink in $G$, then $s in S = {i, i + 1, ..., j}$.

  We inductively prove this invariance.

  #high1[[Basis]] Before the loop, $S = {1, 2, ..., n} = V$, clearly if $s$ is a universal sink, $s in V$.

  #high1[[Step]] Assume that $s in S = {i, i + 1, ..., j}$. We check the value of $A[i, j]$.
  - If $A[i, j] = 1$, then vertex $i$ has an outgoing edge. This means $i$ cannot be a universal sink. Thus, if $s$ is a universal sink, then $s in S' = {i + 1, ..., j}$
  - If $A[i, j] = 0$, then vertex $j$ has no incoming edge from $i$. This means $j$ cannot be a universal sink. Thus, if $s$ is a universal sink, then  $s in S'' = {i, ..., j - 1}$
  In either case, the property holds at the end of the body of the loop. This proves that the condition is indeed an invariance.

  Thus, it must hold even after the loop. After the loop exits, $i = j$, so $S = {i}$. By the invariance, it follows that if $s$ is a universal sink in $G$, then $s  =i$. Hence the given algorithm correctly finds the universal sink if it exists.

  *Time Complexity*: At each iteration the value of $j - i$ decreases by 1. At the beginning of the program, $j - i = n -1$ and the loop exits when $i = j$. Thus the main loop runs in $O(n)$. The verification loop also runs in $O(n)$, so the overall time complexity is $O(n) = O(|V|)$.

]

#line(length: 100%, stroke: 0.5pt)
#pagebreak(weak: true)

#quest[5.][
  An undirected weighted graph is given as input in terms of adjacency matrix. Provide an implementation of Prim's algorithm that runs in $O(V^2)$ time.
]

#ans[
  By convention, for $u != v$, $A[u, v] = w(u, v)$ if $(u, v) in E$, and $A[u, v] = oo$ otherwise.
  
  #algorithm-figure(
    "Minimum Spanning Tree using Prim's Algorithm using Adjacency Matrix",
    {
      import algorithmic: *
      Procedure(
        "MST-Prim",
        ($A$),
        {
          For([$u = 1$ to $n$], {
            LineComment(Assign[$"visited"[u]$][$0$], [whether a vertex has been added to the MST])
            LineComment(Assign[$"key"[u]$][$oo$], [weight of minimal crossing edge to $u$])
            Assign[$pi[u]$][#smallcaps[nil]]
          })
          Assign[$"key"[1]$][$0$]
          For([$i = 1$ to $n$], {
            LineComment(Assign([$u$],CallInline("Get-Min-Key-Vertex",())), [add $u$ to the MST])
            Assign[$"visited"[u]$][$1$]
            
            LineComment(For([$v <- 1$ to $n$], {
              If([$(not "visited"[v]) and (A[u, v] < oo) and ("key"[v] > A[u, v]) $], {
                Assign[$"key"[v]$][$A[u, v]$]
                Assign[$pi[v]$][$u$]
              })
            }), [update info for adjacent nodes])
          })
        }
      )
      LineBreak
      Function(
        "Get-Min-Key-Vertex",
        (), 
        {
          Assign[$"min-v"$][#smallcaps[nil]]
          Assign[$"best"$][$oo$]
          For([$v = 1$ to $n$], {
            If($not "visited"[v] and "best" > "key"[v]$, {
              Assign[$"best"$][$"key"[v]$]
              Assign[$"min-v"$][$v$]
            })
          })
          Return[$"min-v"$]
        }
      )
    }
  )

  The MST can be constructed by using the $pi$ values.

  *Time Complexity:*
  - Initialisation: $O(n)$
  - Inside the loop ($n$ iterations)
    - #smallcaps[Get-Min-Key-Vertex]: $O(n)$
    - Update $"key"$ and $pi$ for adjacent nodes: $O(n)$

  Thus, the overall complexity of the above implementation is $O(n^2) = O(V^2)$
]

#line(length: 100%, stroke: 0.5pt)
#pagebreak(weak: true)
#v(0pt)

#quest[6.][
  Let $G = (V, E)$ be a weighted, directed graph with a nonnegative weight function $w: E -> {0, 1, ..., k}$ for some integer $k > 0$. Modify Dijkstra's algorithm to compute the shortest paths from a given source vertex $s$ in $O(k V + E)$ time.
]

#ans[
  Consider the simple version of Dijkstra's algorithm which uses arrays to store the vertices $Q = V - S$  ($S$ denotes the set of vertices whose shortest path weights have been determined). The complexity of this version is $O(V^2 + E)$, owing to the total $O(V^2)$ computation in all the #smallcaps[Extract-Min] operations, which finds the vertex with the minimum $d[v]$ value out of all the vertices in $Q$.

  In our modified version of the problem, we have $0 <= w(e) <= k quad forall e in E$. This gives a bound on the shortest path weights themselves. The weight of any shortest path $P$ is bounded by $ 0 <= w(P) <= k (n - 1) < k n $ This is because any shortest path can have at most $n - 1$ edges, and each edge can have weight at most $k$.

  By using this observation, we have to make our #smallcaps[Extract-Min] operations more efficient, so that all of them can be done in $O(k V)$ time. We can do so by storing the vertices in $Q = V - S$ in a bucket-list: Let $B$ be an array of linked lists, where $B[d]$ stores the vertices $v$ with tentative distance $d[v] = d$. In other words, for all $v in Q, v in B[d[v]]$. $B$ will need to store at most $k (n - 1)$ lists.

  #algorithm-figure(
    "Dijkstra's algorithm optimised for small edge weights",
    {
      import algorithmic: *
      Procedure(
        "Modified-Dijkstra",
        ($G$, $s$),
        {
          For([$v = 1$ to $n$], {
            Assign[$d[v]$][$oo$]
            Assign[$pi[v]$][#smallcaps[nil]]
          })
          Assign[$d[s]$][$0$]
          Assign[$B[0]$][insert $s$]
          Assign[$"curr"$][$0$]
          Assign[$"count"$][$0$]
          While([$"count" < n$], {
            While([$B["curr"]$ is empty], {
              Assign[$"curr"$][$"curr" + 1$]
            })
            Assign([$u$], [$B["curr"]$.pop()])
            If($"curr" != d[u]$, smallcaps("continue"))
            Assign[$"count"$][$"count" + 1$]
            For($v "in" adj[u]$, {
              If([$d[v] > d[u] + w(u, v)$], {
                Assign[$d[v]$][$d[u] + w(u, v)$]
                Assign[$pi[v]$][$u$]
                Assign[$B[d[v]]$][insert $v$]
              })
            })
          })
        }
      )
    }
  )

  *Correctness:*

  We need to show that this is equivalent to the original Dijkstra's algorithm. In particular, we need to show that #high2[(i)] in each iteration of the loop of line 10, we find the vertex with minimum tentative distance from $V - S$ in the variable $u$. Also, we need to show that #high2[(ii)] in the relaxation step, we update our data structures properly.

  #high2[(i)] As described earlier, the vertices in $V - S$ are stored in the array of lists $B$, such that $v in B[d[v]]$ for all $v in V - S$. Also, the vertex $u$ that was moved to $S$ (removed from $B$) in the last iteration had $d[u] = "curr"$. Let $v^*$ be a vertex in $V - S$ with minimum tentative distance. We claim that for vertex $v^*$, $d[v^*] >= d[u] = "curr"$ (Claim 1). Thus, to find $v^*$, we increment $"curr"$ until $B["curr"]$ is non empty, and take an element from $B["curr"]$. This ensures we correctly find the minimum-distance unexplored vertex.

  Proof of *Claim 1*: We always remove vertices from $V - S$ in non increasing order of $d[]$ values. This is because while removing, we always remove the minimal element. Also, after a vertex $u$ is removed, some edges will be relaxed, which will update $d[]$ values for some vertices in $V - S$, ($d[v] = d[u] + w(u, v)$) but even after the updates, all the $d[]$ values of vertices in $V - S$ will have $d[v] >= d[u]$, since all edges have non negative weights.

  #high2[(ii)] Let's look at the relaxation step. Let the current vertex being processed be $u$. For all $(u, v) in E$, we relax the edge $(u, v)$, and if it can be relaxed, update $d[v]$ to $d[u] + w(u, v)$ and set $pi[v] = u$. Let the value of $d[v]$ before relaxing be $d_1$ and after relaxing be $d_2$. ($d_2 < d_1$) 
  
  Note that in $B$, we store the vertices $v in V - S$ according to their $d[v]$ values. Now since we changed the $d[v]$ value for vertex $v$ from $d_1$ to $d_2$, we would need to remove $v$ from $B[d_1]$ and insert $v$ to $B[d_2]$. However, removing an arbitrary element from a linked list will increase the complexity. Instead, we retain the outdated copy of $v$ in $B[d_1]$, just insert $v$ in $B[d_2]$. Whenever we pop an item from $B$, we can check if it is outdated, i.e. if the $d[]$ value of the vertex does not match the index of $B$ from where we popped the vertex. If so, we ignore it.


  #let small(shit) = {
    set text(0.8em)
    shit
  }

  #let graph(stage) = scale(85%, diagram({
    node((0, 0), $1$, shape: circle, stroke: 1pt, extrude: if stage >= 0 { (0, -3) })
    node((1, -1), $2$, shape: circle, stroke: 1pt, extrude: if stage >= 1 { (0, -3) } else { (0, 0) })
    node((2, 0), $3$, shape: circle, stroke: 1pt, extrude: if stage >= 2 { (0, -3) } else { (0, 0) })
    edge((0, 0), (1, -1), "-|>", $2$, stroke: 1pt + if stage >= 1 { blue })
    edge((0, 0), (2, 0), "-|>", $5$, stroke: 1pt)
    edge((1, -1), (2, 0), "-|>", $1$, stroke: 1pt + if stage >= 2 { blue })

    node((0, 0.4), small[$d=0$])
    if stage >= 0 { node((1, -1.5), small[$d=2\ pi=1$]) }
    if stage == 0 { node((2, .5), small[$d=5\ pi=1$]) }
    if stage >= 1 { node((2, .5), small[$d=3\ pi=2$]) }
  }))

  #let transpose(..args) = {
    let cnt = args.pos().chunks(2).len()
    table(columns: (0.7cm, ) * cnt, 
    stroke: (x, y) => if y == 0 { (bottom: 0.5pt)} + if x < 5 { (right: 0.5pt) }, 
    ..array.zip(..args.pos().chunks(2)).flatten())
  }

  #figure(grid(
    columns: 3,
    align: center,
    graph(0), graph(1), graph(2),
    // table(columns: 2, [$d$], $B[d]$, $0$, [${high1(bold(1))}$]),
    transpose($0$, [$[cancel(1)]$], [1], [$[]$], [2], [$[2]$], [3], [$[]$], [4], [$[]$], [5], [$[3]$]),
    transpose($0$, [$[]$], [1], [$[]$], [2], [$[cancel(2)]$], [3], [$[3]$], [4], [$[]$], [5], [$[text(#gray,bold(3))]$]),
    transpose($0$, [$[]$], [1], [$[]$], [2], [$[]$], [3], [$[cancel(3)]$], [4], [$[]$], [5], [$[text(#gray,bold(3))]$]),
  ),
  kind: image,
  caption: [Working out of #smallcaps[Modified-Dijkstra] on a small example graph. The table shows values stored by $B[d]$ for different values of $d$. The vertex that was removed in this iteration is striked out. An outdated copy of a vertex is shown in grey. (The initial stage is not shown, when $d[v] = oo forall v != s, d[s] = 0$)] 
)
  
  
  *Time Complexity:* 
  #set enum(numbering: "1.")
  1. Lines 11-12: We increment $"curr"$; since shortest path distances can only go up to $k |V|$, $"curr" <= k |V|$, so all the increments run in $O(k V)$.
  2. Lines 14-17: We pop from $B$. There will be at most $|E|$ elements in $B$ (Claim 2), so this runs in $O(E)$.
  3. Lines 19-23: Since this loops over the adjacency list of all vertices, the loop will run $|E|$ times. This runs in $O(E)$.

  Proof of *Claim 2:* Since the loop in lines 19-23 runs $|E|$ times, and we only ever insert into $B$ once in this loop every iterations, there will be at most $|E|$ elements in $B$.

  Thus, the overall time complexity of this algorithm is $O(k V + E)$.

  
]

#v(2em)

#align(center, line(length: 10cm, stroke: 2pt))