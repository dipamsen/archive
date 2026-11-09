#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Approximation Algorithms"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt
#let ss = text.with(font: "New Computer Modern Sans")
#let bu(x) = math.bold(math.upright(x))

#let pc = $bu(P)$
#let np = $bu("NP")$
#let coNP = $bu("co-NP")$
#let npc = $bu("NPC")$
#let red = $scripts(<=)_p^m$


#title[Approximation Algorithms]

While we have good algorithms for many optimisation problems, in the real world, the unfortunate reality is that many important practical problems turn out to be NP-hard. What can we do? Given an NP-hard problem $P$, we could _try_ to design an efficient algorithm for it. Whether we succeed or not is another issue (if we do succeed, other than having solved $P$, we also get another benefit of being able to claim a million dollars from the Clay Mathematics Institute for proving $pc = np$). So probably that is too far-fetched. More reasonably, if we assume $pc != np$, we can't expect a polynomial time algorithm for $P$. What's the next best thing? Can we get a polynomial time algorithm for $P$ that may not produce the optimal solution, but produce a solution that is _good-enough_?

= Definitions

#let opt = $"OPT"$
#let alg = $"ALG"$

For an optimisation problem, we call an algorithm which returns a near-optimal solution, an *approximation algorithm*.

Given some optimisation problem with optimal solution value #opt, and an algorithm which produces a feasible solution with value #alg, we say that the algorithm is an approximation algorithm with an *approximation ratio* $rho(n)$. It is also called a $rho$-approximation algorithm.

For a *minimisation problem*, we define the approximation ratio as
$
  rho(n) = max_(|I|<= n) alg(I) / opt(I)
$

In other words, if an approximation algorithm has an approximation ratio of $rho$, then for any instance $I$, we have
$
  alg / opt <= rho.
$
Note that $rho >= 1$.

For a *maximisation problem* we define $rho$ to (lower) bound the same ratio $alg / opt$, so we get $0 < rho <= 1$. In some texts, a different convention is used, where the reciprocal ratio is used for defining $rho$, to consistently have $rho >= 1$.

Ideally, for a _good_ approximation algorithm, we would want our approximation ratio $rho(n)$ to be a constant value (independent of $n$). This indicates, that how far the two values $alg$ and $opt$ are does not grow with the size of the input, i.e. the approximation does not become worse for larger inputs.


= A general strategy to find a $rho$-approximation algorithm

Suppose we are given a minimisation problem $Q$. Since we cannot compute #opt in polynomial time (otherwise we could decide the NP-hard decision version), we cannot compare the value of our solution against #opt directly. The usual way around this is to compare against some easy-to-compute quantity which is guaranteed to be no larger than #opt. This gives a two-step recipe.

*Step 1: Find a lower bound.* For instances of $Q$, find a quantity $L(I)$ which can be computed in polynomial time, such that
$
opt(I) >= L(I).
$

*Step 2: Convert the lower bound into a solution.* Using the structure which gave us $L(I)$, construct in polynomial time a feasible solution of $Q$ with value #alg satisfying
$
alg(I) <= rho dot L(I).
$

Putting these together,
$
alg(I) <= rho dot L(I) <= rho dot opt(I) quad ==> quad alg(I) / opt(I) <= rho,
$
so the algorithm is a $rho$-approximation algorithm.

#let prob = ss("MIN-VERTEX-COVER")

= Approximating #prob

For the optimisation problem #prob, we need to find a minimum size subset of vertices, such that every edge is incident on at least one vertex in the set.

We will show a 2-approximation algorithm for #prob. This means, $alg <= 2 opt$, so the vertex cover produced by our algorithm will be no more than twice the size of the actual optimum.

To find a lower bound on $opt$, we use a _maximal matching_. A *matching* in $G = (V, E)$ is a set of edges $M subset.eq E$ such that no two edges in $M$ share an endpoint. A matching is *maximal* if it is not a strict subset of any other matching.#footnote[This is different from a _maximum_ matching.] A maximal matching can be found in polynomial time greedily: pick any edge in the graph, add the edge to $M$ and remove all its neighbouring edges; and repeat until the graph is empty.

Let $M$ be a maximal matching of $G$. We claim that
$
opt >= |M|.
$
Take an optimal vertex cover $S^*$. It must contain at least one endpoint of every edge in $M$. Since the edges of $M$ share no endpoints, these endpoints are all different vertices, so $S^*$ contains at least $|M|$ vertices. Now, to use $M$ to get a feasible solution with value $alg$, such that $alg <= 2 |M|$, we will simply pick both endpoints of each edge in $M$.

Then, we can describe our approximation algorithm as follows.
+ Compute a maximal matching $M$ of $G$.
+ Output $C$, the set of all endpoints of edges in $M$.

We claim that $C$ is a vertex cover. Suppose it is not. Then there is an edge $(u, v) in E$ with $u in.not C$ and $v in.not C$. This means that no edge of $M$ is incident on $u$ or $v$, so $M union {(u, v)}$ is also a matching, which contradicts the maximality of $M$. Hence every edge has an endpoint in $C$.

Every edge of $M$ contributes exactly two vertices to $C$, and these are all distinct (since $M$ is a matching), so $|C| = 2|M|$. Thus, we have
$
alg = |C| = 2|M| <= 2 dot opt.
$
Therefore the algorithm is a 2-approximation algorithm for #prob.




#figure(cetz.canvas(length: 1cm, {
  import cetz.draw: *

  let pos = (a: (0, 2), c: (2, 2), e: (4, 2), g: (5.5, 1), b: (0, 0), d: (2, 0), f: (4, 0))
  let edges = (("a", "b"), ("a", "c"), ("c", "e"), ("c", "d"), ("d", "e"), ("e", "f"), ("e", "g"), ("d", "f"))
  let matching = (("a", "b"), ("d", "e"))
  let optimum = ("a", "d", "e")
  let hi = primary-color.lighten(70%)

  // all edges, then the matching M drawn thick
  for (u, v) in edges { line(pos.at(u), pos.at(v), stroke: 0.6pt) }
  for (u, v) in matching { line(pos.at(u), pos.at(v), stroke: (paint: primary-color, thickness: 2.4pt)) }

  // vertices: shaded if they are an endpoint of M (the output C)
  let matched = matching.flatten()
  for (name, p) in pos {
    if optimum.contains(name) {
      circle(p, radius: 0.44, stroke: (dash: "dashed", thickness: 0.7pt))
    }
    circle(p, radius: 0.32, fill: if matched.contains(name) { hi } else { white }, stroke: 0.6pt)
    content(p, text(10pt, name))
  }
}), caption: [A run of the 2-approximation algorithm on a graph with 7 vertices. A maximal matching $M = {(a, b), (d, e)}$ is found, and the highlighted vertices form the output $C = {a, b, d, e}$, so $alg = |C| = 4$. An optimal vertex cover is ${a, d, e}$, so $opt = 3$; thus we have $alg <= 2 opt$.], kind: image) <vc-approx>


#let tsp = ss("TSP")
#let mtsp = ss("METRIC-TSP")

= The Traveling Salesman Problem

In the *traveling salesman problem* (#tsp), we are given a complete undirected graph $G = (V, E)$ on $n$ vertices (the "cities") with a non-negative weight $d(u, v)$ on every edge. A *tour* is a Hamiltonian cycle of $G$, and its weight is the sum of the weights of its edges. We want to find a tour of minimum weight. We write $w(H)$ for the total weight of a set of edges $H$, and #opt for the weight of an optimal tour.

The decision version of #tsp is NP-complete, so we do not expect an exact polynomial-time algorithm for finding an optimal tour. Unfortunately, in the general case even approximating TSP is hard (see Problem 1). Thus we work with a special case of the problem which is more applicable in the real world.

== Metric #tsp

An instance of #tsp is *metric* if the weights satisfy the *triangle inequality*: for all vertices $i, j, k$,
$
d(i, k) <= d(i, j) + d(j, k).
$
In words, going directly from $i$ to $k$ is never worse than going through an intermediate city. This holds for distances in the plane, or shortest-path distances in any graph. Graphs which represent real world scenarios will usually obey the triangle inequality, so this is a reasonable special case to work with.

It turns out, even this special case is still NP-Complete. But now we will see that at least we can have constant-factor approximations for this problem.

== A 2-approximation algorithm for #mtsp

First we need a useful lower bound for the tour size. Let $H$ be an optimal tour with weight $opt$. Delete any one edge from this to get a Hamiltonian path in $G$. In fact, it is a spanning tree of $G$.

Let $T$ be a minimum spanning tree of $G$. Then it follows, that this is a lower bound,  $w(T) <= opt$.

We need the algorithm to use the minimum spanning tree and construct a tour whose weight is no larger than twice the weight of the spanning tree itself.

*Algorithm.*

- Compute a minimum spanning tree $T$ of $G$.
- Consider a Euler tour of the tree $T$, this is a walk $W$ on the tree which starts and ends at the first vertex and traverses every edge in the tree twice. Clearly $w(W) = 2 w(T)$.
- The walk $W$ visits some vertices more than once. Traverse $W$ and _shortcut_ it: whenever we are at a vertex that will be visited again later, skip it and go straight to the next vertex on the walk that is being visited for the last time. Equivalently, output the vertices of $T$ in the order in which a depth-first traversal last visits them (a _postorder_ traversal). The resulting sequence of vertices, closed up at the start, is a tour $H$.

Shortcutting replaces a part $x -> y_1 -> ... -> y_m -> z$ of the walk by the single edge $(x, z)$. By repeated application of the triangle inequality, $d(x, z) <= d(x, y_1) + ... + d(y_m, z)$, so shortcutting never increases the weight. Therefore,
$alg = w(H) <= w(W) = 2 w(T) <= 2 opt.$
So this is a 2-approximation algorithm for #mtsp, and it runs in polynomial time.

// ---------- helpers (put once in the preamble) ----------
#let tsp-pts = (A: (0.5, 3), B: (2, 1.5), C: (0, 0.5), D: (3, 0.5), E: (4.5, 1), F: (4, 2))

// one panel: `layers` is an array of (edges, stroke, offset) triples;
// a nonzero offset draws each edge twice, shifted to both sides (for the doubled tree)
#let tsp-panel(o, layers, shaded: (), label: none) = {
  import cetz.draw: *
  let P(n) = (o.at(0) + tsp-pts.at(n).at(0), o.at(1) + tsp-pts.at(n).at(1))
  let r = 0.24 
  for (edges, stroke, off) in layers {
    for (u, v) in edges {
      let p = P(u)
      let q = P(v)
      
      if off == 0 {
        line(p, q, stroke: stroke)
      } else {
        let px = p.at(0)
        let py = p.at(1)
        let qx = q.at(0)
        let qy = q.at(1)
        
        let dx = qx - px
        let dy = qy - py
        let l = calc.sqrt(dx * dx + dy * dy)
        
        let nx = -dy / l * off
        let ny = dx / l * off
        
        let d = calc.sqrt(r * r - off * off)
        let sx = (dx / l) * d
        let sy = (dy / l) * d
        
        line(
          (px + nx + sx, py + ny + sy), 
          (qx + nx - sx, qy + ny - sy), 
          stroke: stroke, mark: (start: ">", fill: black, scale: 0.5)
        )
        
        line(
          (px - nx + sx, py - ny + sy), 
          (qx - nx - sx, qy - ny - sy), 
          stroke: stroke, mark: (end: ">", fill: black, scale: 0.5)
        )
      }
    }
  }
  
  for (n, _) in tsp-pts {
    circle(P(n), radius: r, fill: if shaded.contains(n) { primary-color.lighten(70%) } else { white }, stroke: 0.6pt)
    content(P(n), text(9pt, n))
  }
  
  if label != none { content((o.at(0) + 2.25, o.at(1) - 0.55), text(9pt, label)) }
}

#let tsp-tree = (("A", "B"), ("B", "C"), ("B", "D"), ("D", "E"), ("E", "F"))
#let tsp-thin = 0.6pt
#let tsp-thick = (paint: primary-color, thickness: 1.8pt)
#let tsp-faint = (paint: luma(190), thickness: 0.6pt, dash: "dotted")


#figure(cetz.canvas(length: 0.85cm, {
  tsp-panel((0, 0), ((tsp-tree, tsp-thin, 0),), label: [(a) the MST $T$])
  tsp-panel((6, 0), ((tsp-tree, tsp-thin, 0.07),), label: [(b) the Eulerian walk $W$])
  tsp-panel((12, 0), ((tsp-tree, tsp-faint, 0), ((("A", "C"), ("C", "B"), ("B", "D"), ("D", "E"), ("E", "F"), ("F", "A")), tsp-thick, 0)), label: [(c) the final tour $H$])
}), caption: [The 2-approximation on an instance of metric TSP with 6 vertices.], kind: image) <tsp-2approx>


== A 1.5-approximation algorithm

In the above algorithm, we essentially doubled the edges of $T$ to get a Euler tour of the graph. It turns out we can get a better bound by considering the even and odd degree vertices separately.

*Algorithm.*
+ Compute a minimum spanning tree $T$ of $G$.
+ Let $O$ be the set of vertices of odd degree in $T$. (The sum of degrees in any graph is even, so $|O|$ is even.)
+ Compute a *minimum weight perfect matching* $M$ on $O$ in the complete graph on $O$. This can be done in polynomial time#footnote[There exist generalisations of the Edmonds' Blossom algorithm which can compute the optimum matchings with maximum/minimum weights in polynomial time.].
+ In the multigraph $T union M$, every vertex has even degree (vertices of $O$ gain one edge from $M$), and it is connected since it contains $T$. So it has an Eulerian cycle $W$.
+ Shortcut $W$ as before to obtain a tour $H$.

The key claim is that the matching found has a low weight:
$
w(M) <= 1/2 opt.
$
To see this, take an optimal tour of $G$ and shortcut it so that it visits only the vertices of $O$ (odd degree subgraph), skipping all the others. By the triangle inequality, this gives a cycle $C'$ on $O$ with $w(C') <= opt$. The cycle $C'$ has an even number of edges, since it has $|O|$ edges, so we can split its edges into two perfect matchings $M_1$ and $M_2$ of $O$ by taking alternate edges. Then $w(M_1) + w(M_2) = w(C') <= opt$, so one of them has weight at most $opt / 2$. Since $M$ is a minimum weight perfect matching of $O$, $w(M) <= min(w(M_1), w(M_2)) <= opt / 2$.

Then the Eulerian cycle $W$ has weight $w(W) = w(T) + w(M)$, and using $w(T) <= opt$ from before,
$
alg = w(H) <= w(W) = w(T) + w(M) <= opt + 1/2 opt = 3/2 opt.
$
So this is a $3 / 2$-approximation algorithm for #mtsp.


#figure(cetz.canvas(length: 0.85cm, {
  tsp-panel((0, 0), ((tsp-tree, tsp-thin, 0),), shaded: ("A", "B", "C", "F"), label: [(a) $T$ and its odd vertices])
  tsp-panel((6, 0), ((tsp-tree, tsp-thin, 0), ((("A", "C"), ("B", "F")), (paint: primary-color, thickness: 1.4pt, dash: "dashed"), 0)), shaded: ("A", "B", "C", "F"), label: [(b) the matching $M$ (dashed)])
  tsp-panel((12, 0), ((tsp-tree, tsp-faint, 0), ((("A", "C"), ("C", "D"), ("D", "E"), ("E", "F"), ("F", "B"), ("B", "A")), tsp-thick, 0)), label: [(c) the tour $H$])
}), caption: [The 1.5-approximation algorithm for Metric TSP on the same graph as in @tsp-2approx.], kind: image) <tsp-christofides>

#let prob = ss("MAX-E3SAT")

= Approximating #prob

In the #ss("MAX-E3SAT") (_exactly-3 SAT_) problem, we are given a 3CNF formula $phi$ with clauses $C_1, ..., C_m$, where every clause has exactly three literals over three distinct variables. (A clause that contains both $x$ and $overline(x)$ is always satisfied, so we may discard it.) We want to find an assignment of the variables which satisfies as many clauses as possible. This is a maximisation problem, and it is NP-hard, since deciding whether *all* the clauses can be satisfied is exactly #ss("E3SAT") (which is NP-Complete).

In the *weighted* version, Weighted #ss("MAX-E3SAT"), each clause $C_j$ also has a weight $w_j > 0$, and we want to maximise the total weight of satisfied clauses. The unweighted problem is simply the special case with all $w_j = 1$.

== A randomised $7 / 8$-approximation

The algorithm is as simple as possible: *set every variable to true or false independently with probability $1 / 2$.* Let $W = sum_j w_j$ be the total weight of all clauses, and for each clause $C_j$ define the indicator variable
$
Z_j = cases(1 quad & "if" C_j "is satisfied by the random assignment", 0 & "otherwise").
$
Then the weight of the clauses satisfied by the assignment is the random variable $alg = sum_j w_j Z_j$.

*Claim.* For every clause $C_j$, $E[Z_j] = 7 / 8$.

_Proof._ A clause is a disjunction of three literals over three distinct variables, so it is false only if all three of its literals are false. Since the variables are set independently, each literal is false with probability $1 / 2$, independently of the others. Thus
$
Pr[C_j "is not satisfied"] = (1 / 2)^3 = 1 / 8,
$
and $E[Z_j] = Pr[C_j "is satisfied"] = 7 / 8$. #h(1fr) $qed$

By linearity of expectation (note that $Z_j$s are not independent),
$
E[alg] = sum_j w_j E[Z_j] = 7 / 8 W.
$
Finally, no assignment can satisfy more than all the clauses, so $opt <= W$. Hence
$
E[alg] = 7 / 8 W >= 7 / 8 opt.
$
This is a *randomised $7 / 8$-approximation algorithm* for #prob: its output has _expected_ value within a factor of $7 / 8$ of the optimum.



By virtue of being a randomised algorithm, it doesn't always guarantee the lower bound of the approximation factor, it is only in _expectation_ that the value will be at least $7/8$ times the optimal value. As we will see in Problem 5, we can get a deterministic algorithm that always finds such an assignment by *derandomisation* of our algorithm.


#pagebreak() 

= Problems and Solution Sketches

1. Prove that, for every constant $c$, if there exists a polynomial-time $c^n$ factor approximation algorithm for the Travelling Salesman Problem (TSP), then $pc = np$.

#soln-box[


  We will reduce #ss("HAMCYCLE") to a $c^n$ factor approximation for TSP to show this. In other words, if there exists a polynomial time $c^n$ factor approximation algorithm $A$ for #ss("TSP"), then we will show that it can be used to solve #ss("HAMCYCLE") in polynomial time. Since #ss("HAMCYCLE") is NP-complete, this would imply $pc = np$.

  Suppose there exists a $c^n$ factor approximation algorithm $A$ for #ss("TSP"). This means, for an instance $G = (V, E)$ (taking $n = |V|$), the algorithm $A$ returns a tour whose cost is no more than $c^n$ times the cost of the optimal tour.

  Let $G = (V, E)$ be an instance of #ss("HAMCYCLE"), and let $n = |V|$. We will construct an instance of #ss("TSP") by creating a complete graph $G' = (V, E')$ on $V$ ($E' = {(u, v) | u, v in V, u != v}$), and assign the following weights:
  $
    d(u, v) = cases(1 quad quad &"if" (u, v) in E, c^n dot n + 1 quad quad &"otherwise.")
  $

  Crucially, this construction of $G'$ can be done in polynomial time. Notice that the value $c^n dot n + 1$ requires $O(n log c + log n)$ bits to represent, which is polynomial in the size of the input graph $G$.

  Now, if $G$ has a Hamiltonian cycle, then $G'$ has the same Hamiltonian cycle, each edge having a weight of 1. Thus, the optimal tour in $G'$ is simply this cycle itself, and it has an optimal cost of $n$.

  If $G$ does not have a Hamiltonian cycle, then any tour in $G'$ must necessarily go through some edge not in $E$. Then, the total cost of such a tour will be at least $(c^n dot n + 1) + (n - 1) = c^n dot n + n > c^n dot n$

  Then, apply the algorithm $A$ on the constructed graph $G'$. It returns a tour with some cost $alg$.
  - If $G$ contains a Hamiltonian cycle, the optimal cost is $n$, so $A$ must return a tour with cost of at most $alg <= c^n dot n$.
  - If $G$ does not contain a Hamiltonian cycle, whatever tour it returns, its cost will be $alg > c^n dot n$.

  Thus, by checking whether the cost of the returned tour is at most $c^n dot n$, we can determine if $G$ has a Hamiltonian cycle in polynomial time. Thus, $pc = np$.
]

2. Consider the task of scheduling $n$ jobs into $m$ identical machines. Each job $i$ needs to run $t_i$ time in any machine to complete. A job once started to run in a machine cannot be stopped midway. A schedule is an assignment $A : [n] -> [m]$. The load $ell_j$ of machine $j$ in a schedule $A$ is $sum_(i in A^(-1) (j)) t_i$. The *makespan* of a schedule $A$ is $max_(j in [m]) ell_j$. Show that computing a schedule that achieves the minimum makespan is NP-complete. Design a simple 2 factor approximation algorithm for this problem. Change the algorithm suitably to improve the approximation guarantee to $3/2$.

#soln-box[
  *Hardness*:
  - The decision version of the problem (#ss("MAKESPAN"): does there exist a schedule with makespan $<= B$?) is in NP, since given a schedule (assignment of jobs to machines), its makespan can be computed in polynomial time.
  - #[We can show the reduction #ss("PARTITION") $red$ #ss("MAKESPAN"). (Recall, #ss("PARTITION") asks for a partitioning of a set into two equal sum subsets.) Given numbers $a_1, ..., a_n$ with sum $S$, make $n$ jobs with $t_i = a_i$, and let there be $m = 2$ machines. Then, an equipartition of ${a_i}$ exists if and only if a schedule with makespan at most $S/2$ exists.
  ]
  Thus, #ss("MAKESPAN") is NP-Complete.

  *2 factor approximation algorithm*: Process jobs in any order, and greedily assign the current job to the machine with the smallest load currently.

  Let #opt be the optimal makespan, and #alg be the makespan for the greedy scheduling. Let $T = sum_i t_i$. First, we have the following lower bounds:
  $
    opt >= max_i t_i "and" opt >= T/m,
  $
  where the first inequality is because at least one machine will have to take the longest job, and the second because the maximum cannot be less than the average.

  Let the $j$th machine have the most load. Then, $alg = ell_j$. Let the last job assigned to this machine be job $i$. Before assigning it, machine $j$ must have been the least loaded machine; let's call its load $ell'_j$. Then, $ell'_j$ cannot exceed $opt$ (why?). Also, we know that $opt >= t_i$.

  So, we have
  $
    alg = ell_j = ell'_j + t_i <= opt + opt = 2 opt.
  $
  Thus, this is a 2-factor approximation algorithm for finding the minimum makespan schedule.

  *1.5 factor approximation algorithm*: Sort the jobs by decreasing processing time, so $t_1 >= t_2 >= ... >= t_n$. For each job, greedily assign it to the machine which is currently least loaded.

  If $n <= m$, then every job gets its own machine, so the schedule is optimal. Otherwise, consider the $m + 1$ largest jobs. By pigeonhole principle, in the optimal schedule, some machine must be assigned to at least two of these jobs. So,
  $
    opt >= 2 t_(m +1).
  $

  Again let $j$ be the most loaded machine, and $i$ be the last job scheduled to it. Then, if $i <= m$, then by our algorithm it must be that before this scheduling, machine $j$ was empty. Then, $alg = t_i <= opt$. Otherwise, $i >= m + 1$, so $t_i <= t_(m + 1) <= opt / 2$. Then we gets
  $
    alg = ell_j = ell'_j + t_i <= opt + opt / 2 = 3/2 opt
  $
  Thus this is a 1.5 factor approximation algorithm for finding the minimum makespan schedule.
]

3. Design a randomized $1/2$ factor approximation algorithm for the Max-Cut problem for weighted graphs. Use this to prove that, in every unweighted graph with 15 edges, there exists a cut with at least 8 cut edges.

#soln-box[
Let $G = (V, E)$ have non-negative edge weights $w_e$, and let $W = sum_e w_e$. The weight of a cut $(S, V without S)$ is the total weight of the edges with exactly one endpoint in $S$.

  *Algorithm.* Put each vertex into $S$ independently with probability $1 / 2$.

  *Analysis.* For an edge $e = (u, v)$, it is cut exactly when $u$ and $v$ are on different sides, which happens with probability $2 dot 1 / 2 dot 1 / 2 = 1 / 2$. By linearity of expectation, the expected weight of the cut is
  $
  E[alg] = sum_e w_e Pr[e "is cut"] = W / 2 >= opt / 2,
  $
  since no cut has weight more than $W$. So this is a randomised $1 / 2$-approximation algorithm.

  *Unweighted graphs with 15 edges.* Take all weights equal to $1$, so $W = 15$. The expected number of cut edges is $15 / 2 = 7.5$. A random variable cannot always be below its expectation, so some cut has at least $7.5$ cut edges, and since the number of cut edges is an integer, some cut has at least $8$ edges.
]

4. Design a greedy $1/2$ factor deterministic approximation algorithm for the maximum cut problem on edge-weighted graphs. (Note that this is also called 2 factor approximation algorithm.) 

#soln-box[
  Let $G = (V, E)$ have non-negative edge weights $w_e$, and let $W = sum_e w_e$. Maintain two sets $S$, $overline(S)$.

  *Algorithm.* Order the vertices as $v_1, ..., v_n$ and start with $S = overline(S) = emptyset$. For $i = 1, ..., n$, place $v_i$ as follows. Let
  - $a_i$ be the total weight of the edges between $v_i$ and the vertices among $v_1, ..., v_(i-1)$ that are already in $S$, and
  - $b_i$ be the total weight of the edges between $v_i$ and the vertices among $v_1, ..., v_(i-1)$ that are already in $overline(S)$.

  If $a_i >= b_i$, put $v_i$ in $overline(S)$, so that the edges counted in $a_i$ are cut. Otherwise, put $v_i$ in $S$, so that the edges counted in $b_i$ are cut. In both cases, the edges which get cut have total weight $max(a_i, b_i)$.

  *Analysis.* Every edge $(v_k, v_i)$ with $k < i$ is counted in exactly one of $a_i$ or $b_i$ and in no other step, because it is only examined when its later endpoint $v_i$ is placed, and at that moment its other endpoint is already placed on exactly one side. So the weights of all edges may be written as:
  $
  W = sum_(i = 1)^n (a_i + b_i).
  $
  The final cut consists exactly of those edges which were cut at the step of their later endpoint, since a placed vertex never moves, so the weight of the cut is
  $
  alg = sum_(i = 1)^n max(a_i, b_i) >= sum_(i = 1)^n (a_i + b_i) / 2 = W / 2.
  $
  Since no cut can contain more than the total weight, $opt <= W$, and hence $alg >= W / 2 >= opt / 2$. So this is a deterministic $1 / 2$-approximation algorithm. Using appropriate data structures, this can be implemented in $O(n + m)$.

  (This is just the method of derandomisation using conditional expectation applied to the randomized algorithm from Problem 3; see box below.)
]

5. Design a $7/8$ factor deterministic approximation algorithm for the weighted Max E3SAT problem. In the E3SAT problem, every clause has exactly three distinct literals. _Hint: You can use the method of conditional expectation to derandomized the randomized $7/8$ factor approximation algorithm for the weighted Max E3SAT problem._

#disc-box[
  *Derandomisation using Conditional Expectation.* Suppose we have a randomised algorithm $A$ for a maximisation problem $Pi$ which uses $k$ random bits $X_1, X_2, ..., X_k$, and we have shown that it is an $alpha$-approximation in expectation, i.e. $E[alg(X_1, ..., X_k)] >= alpha dot opt$. The *method of conditional expectation* is a general framework to turn $A$ into a deterministic polynomial-time algorithm with the same guarantee.

  Say $X_1 tilde "Ber"(p_1)$. Then
  $
  E[alg(X_1, ..., X_k)] = p_1 E[alg | X_1 = 1] + (1 - p_1) E[alg | X_1 = 0],
  $
  so, since an average is at most the larger of its terms (the _averaging principle_),
  $
  E[alg(X_1, ..., X_k)] <= max(E[alg | X_1 = 1], E[alg | X_1 = 0]).
  $
  The deterministic algorithm fixes the bits one at a time, always taking the better choice. Suppose it has already fixed $X_1 = x_1, ..., X_(i-1) = x_(i-1)$. It sets $x_i = 1$ if
  $
  E[alg | X_1 = x_1, ..., X_(i-1) = x_(i-1), X_i = 1] >= E[alg | X_1 = x_1, ..., X_(i-1) = x_(i-1), X_i = 0],
  $
  and $x_i = 0$ otherwise. By the averaging principle applied at every step, the conditional expectation never decreases:
  $
  E[alg] <= E[alg | X_1 = x_1] <= E[alg | X_1 = x_1, X_2 = x_2] <=\  ... <= E[alg | X_1 = x_1, ..., X_k = x_k] = alg_"det".
  $
  Hence $alg_"det" >= E[alg] >= alpha dot opt$: if the randomised algorithm is an $alpha$-approximation, so is the deterministic one. (For a minimisation problem, pick the _smaller_ conditional expectation instead, and all the inequalities reverse.)

  The only requirement is that we must be able to compute each conditional expectation $E[alg | X_1 = x_1, ..., X_(i-1) = x_(i-1), X_i = x_i]$ in polynomial time, which is not always straightforward.
]


#soln-box[
  We apply the method of conditional expectation to the randomised algorithm for weighted Max-E3SAT, which sets each variable independently to true or false with probability $1 / 2$. Here the random bits are the $n$ variables $x_1, ..., x_n$, and we know $E[alg] = 7 / 8 W$, where $W = sum_j w_j$ is the total weight of all clauses.

  *Algorithm.* For $i = 1, ..., n$, having fixed $x_1 = b_1, ..., x_(i-1) = b_(i-1)$, compute
  $
  E[alg | x_1 = b_1, ..., x_(i-1) = b_(i-1), x_i = 1] quad "and" quad E[alg | x_1 = b_1, ..., x_(i-1) = b_(i-1), x_i = 0],
  $
  and set $b_i$ to the value with the larger conditional expectation.

  *Computing the conditional expectations.* Fix a partial assignment, and let the remaining variables be uniformly random. By linearity of expectation,
  $
  E[alg | "partial assignment"] = sum_j w_j Pr[C_j "is satisfied" | "partial assignment"].
  $
  For a clause $C_j$, if one of its literals is already true then this probability is $1$. Otherwise, the clause is satisfied unless all of its remaining literals are false. If $r$ of its literals have variables which are still unset (the others being false), each of these is false independently with probability $1 / 2$, so the probability is $1 - 2^(-r)$. So the conditional expectation can be computed in $O(m)$ time (by finding $m$ probabilities for the $m$ clauses).

  Clearly, the conditional expectation never decreases along the algorithm, so the final assignment has weight
  $
  alg_"det" >= E[alg] = 7 / 8 W >= 7 / 8 opt,
  $
  since $opt <= W$. The algorithm makes $2n$ evaluations of $O(m)$ time each, so it runs in $O(n m)$ time, and is a deterministic $7 / 8$-approximation algorithm.
]

6. Show that every E3SAT problem instance with at most 7 clauses is always satisfiable.


// ---------- Problem 6 ----------
#soln-box[
  Let $phi$ be an E3SAT formula with $m <= 7$ clauses, and choose an assignment uniformly at random. Each clause has three distinct variables, so it is unsatisfied with probability $1 / 8$. By linearity of expectation, the expected number of unsatisfied clauses is $m / 8 <= 7 / 8 < 1$. A non-negative integer valued random variable with expectation less than $1$ must take the value $0$ with positive probability, so some assignment leaves $0$ clauses unsatisfied. Hence $phi$ is satisfiable.
]