#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Intractability"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt
#let ss = text.with(font: "New Computer Modern Sans")
#let bu(x) = math.bold(math.upright(x))

#let pc = $bu(P)$
#let np = $bu("NP")$
#let coNP = $bu("co-NP")$
#let npc = $bu("NPC")$

#title[Intractability]

Till now in computational complexity, we have discussed complexity classes #pc, #np, #coNP, and the notion of NP-hardness and NP-completeness via polynomial time mapping reductions. We also looked at the Cook-Levin Theorem which stated that #ss("CIRCUIT-SAT") is NP-Complete. Using this as a starting point, here we will show many different problems to be NP-Complete, by reducing known NP-Complete problems to them.

#let red = $scripts(<=)_p^m$
#let bar = math.overline


= How to show a problem to be NP-Complete?

Just to recap, we discussed the following strategy to show some language $L$ to be NP-Complete:
1. Show that $L$ is NP.
2. Choose a problem $X$ which is known to be NP-Complete.
3. Prove that $X red L$. This involves describing a function $f$ which maps from every instance of $X$ to some instance of $L$, such that the YES instances of $X$ are mapped to YES instances of $L$, and vice versa. Also, $f$ should be computable in polynomial time.

= #ss("3CNF-SAT") is NP-Complete

We start our journey with the Boolean formula satisfiability problem. For now, we only know of one problem to be NP-Complete, #ss("CIRCUIT-SAT") (from the Cook-Levin Theorem). We use it to show that #ss("3CNF-SAT") (and therefore #ss("SAT")) is also NP-Complete.

A Boolean formula $phi$ is said to be in *3CNF* form (conjunctive normal form with each clause with 3 literals), if it is a conjunction of clauses:
$
  phi = c_1 and c_2 and ... and c_k
$
where each clause is a disjunction of 3 literals,
$
  c_i = (l_(i 1) or l_(i 2) or l_(i 3)).
$

A literal is a Boolean variable in its complemented or uncomplemented form: $l_j = x_i$, or $l_j = bar(x_i)$.

The problem #ss("3CNF-SAT") determines, given a Boolean formula $phi$ in 3CNF form over a set of $n$ Boolean variables, whether there exists a satisfying assignment of variables.

For example, an instance of a #ss("3CNF-SAT") instance is:
$
  phi = (x_1 or bar(x_2) or x_3) and (bar(x_1) or x_3 or bar(x_4)) and (x_2 or bar(x_3) or bar(x_4))
$
The above instance is satisfiable, an example of a satisfying assignment is $x_1 = 1, x_2 = 1, x_3 = 0, x_4 = 0$.

#let prob = ss("3CNF-SAT")

Notice that we are dealing with a very specific form of Boolean formulas. As we will show, determining satisfiability of a 3CNF-SAT instance is just as hard as determining satisfiability of any arbitrary Boolean circuit.#footnote[This equivalence does not hold for many other forms of writing a Boolean formula; see Problem 1.]

== #prob is in NP

Clearly, we can have a polynomial time verifier for #prob with a satisfying assignment as a witness. The verifier substitutes the value for the variables with their values and evaluates each clause. If every clause evaluates to true (i.e., at least one literal in each clause is true), it returns true. Then, a formula $phi$ is verifiable iff there exists a valid witness according to this verifier.

== #ss("CIRCUIT-SAT") $red$ #prob

Now we need to show a procedure to convert any arbitrary Boolean circuit $C$ in variables ${x_i}_(i=1)^n$ into a 3CNF formula $phi$, in such a way that 
#align(center)[
  $C$ is satisfiable if and only if $phi$ is satisfiable.
]
Furthermore, we should be able to perform this conversion in polynomial time, i.e. the time should be bounded by a polynomial in the size of the input circuit $C$.

First, WLOG let us assume that each internal $or$ and $and$ node in $C$ has a fan-in of 2. In general, there may be nodes with fan-in $> 2$, but they can be trivially converted into equivalent circuits with all nodes having two operands (e.g. $(a or b or c) equiv ((a or b) or c)$). This conversion only increases the size of the circuit polynomially. 

Introduce a new variable $y_i$ for every internal node in the circuit. Then, we can write the Boolean formula $phi$ as the AND of the root variable, and bi-implication clauses which indicate the operation of each internal node. For example, for a $and$ node labeled $y$ with two children labelled $a$ and $b$, we have the clause $(y <-> a and b)$. 


#let var(id, label, x) = (id: id, op: "var", label: label, x: x, ins: ())
#let gate(id, label, op, ..ins, x: auto) = (id: id, label: label, op: op, ins: ins.pos(), x: x)

#let g-not(id, label, a, x: auto) = gate(id, label, "not", a, x: x)
#let g-and(id, label, ..ins, x: auto) = gate(id, label, "and", ..ins, x: x)
#let g-or(id, label, ..ins, x: auto) = gate(id, label, "or", ..ins, x: x)
#let g-xor(id, label, ..ins, x: auto) = gate(id, label, "xor", ..ins, x: x)

#let gate-symbols = ("not": $not$, "and": $and$, "or": $or$, "xor": $xor$)

#let circuit(
  nodes,
  output: none,
  out-label: none,
  dx: 0.8,
  dy: 0.9,
  r: 0.3,
) = {
  import cetz.draw: *

  set-style(stroke: 0.6pt)

  let pos = (:)
  let lvl = (:)
  for n in nodes {
    if n.op == "var" {
      pos.insert(n.id, (n.x * dx, 0))
      lvl.insert(n.id, 0)
    } else {
      let ps = n.ins.map(i => pos.at(i))
      let l = calc.max(..n.ins.map(i => lvl.at(i))) + 1
      let x = if n.x == auto {
        ps.map(p => p.at(0)).sum() / ps.len()
      } else { n.x * dx }
      pos.insert(n.id, (x, l * dy))
      lvl.insert(n.id, l)
    }
  }

  for n in nodes {
    let p = pos.at(n.id)
    if n.op == "var" {
      content(p, n.label, anchor: "north", padding: 0.1, name: n.id)
    } else {
      for i in n.ins {
        let q = pos.at(i)
        let d = (p.at(0) - q.at(0), p.at(1) - q.at(1))
        let len = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
        let u = (d.at(0) / len, d.at(1) / len)
        let s = if lvl.at(i) == 0 { q } else {
          (q.at(0) + r * u.at(0), q.at(1) + r * u.at(1))
        }
        let e = (p.at(0) - r * u.at(0), p.at(1) - r * u.at(1))
        line(s, e)
      }
      circle(p, radius: r, fill: luma(240), stroke: 0.5pt, name: n.id)
      content(p, text(size: 9pt, gate-symbols.at(n.op)))
      content((rel: (0.5, 0.2), to: p), text(primary-color, size: 9pt, n.label))
    }
  }

  if output != none {
    let p = pos.at(output)
    let top = (p.at(0), p.at(1) + r + 0.4)
    line((p.at(0), p.at(1) + r), top)
    if out-label != none {
      content(top, out-label, anchor: "south", padding: 0.1)
    }
  }
}


#figure(grid(
  columns: 2, 
  align: horizon,
  gutter: 3em,
  cetz.canvas({
    circuit((
      var("x1", $x_1$, 0),
      var("x2", $x_2$, 2),
      var("x3", $x_3$, 4),
      var("x4", $x_4$, 6),
      g-and("y1", $y_1$, "x1", "x2", x: 1), g-not("y2", $y_2$, "x3", x: 3),
      g-or("y3", $y_3$, "x2", "x4", x: 5),
      g-or("y4", $y_4$, "y1", "y2", x: 2), g-and("y5", $y_5$, "y3", "y2", x: 4),
      g-and("y6", $y_6$, "y4", "y5", x: 3)
    ), output: "y6", dy: 1.2)
  }),
  $
    phi = quad quad &(y_1 <-> x_1 and x_2)\
    and &(y_2 <-> not x_3)\
    and &(y_3 <-> x_2 or x_4)\
    and &(y_4 <-> y_1 or y_2)\
    and &(y_5 <-> y_2 and y_3)\
    and &(y_6 <-> y_4 and y_5)\
    and &y_6
  $
), caption: [A Boolean circuit $C$ and its corresponding Boolean formula $phi$.], kind: image) <funct>

$phi$ is a conjunction of bi-implication clauses for each internal node, and a singleton clause for the root node. Clearly, the size of the formula is polynomial in the size of the circuit (in particular, the number of internal nodes in the circuit).

It is not in 3CNF form yet. To make it so, we can write each bi-implication clause by their equivalent CNF form by the truth table of the corresponding operation:

$
  (y <-> a and b) quad &equiv quad (bar(a) or bar(b) or y) and (bar(a) or b or bar(y)) and (a or bar(b) or bar(y)) and (a or b or bar(y))\
  (y <-> a or b) quad &equiv quad (bar(a) or bar(b) or y) and (bar(a) or b or y) and (a or bar(b) or y) and (a or b or bar(y))\
  (y <-> not a) quad &equiv quad (a or y) and (bar(a) or bar(y))  
$

Note that these transformations replace each original clause by at most 4 clauses, thus only increases the size of the formula polynomially.

By applying these transformations, we can finally write $phi$ as a CNF expression, where each clause has at most 3 literals. We need to do one final transformation so that every clause has exactly 3 distinct literals:
- If some clause $C_i$ has 3 distinct literals, keep it as it is.
- If some clause $C_i$ has 2 distinct literals, so $C_i = (l_1 or l_2)$, then add a new variable $p$, and write the clauses $(l_1 or l_2 or p) and (l_1 or l_2 or bar(p))$. Regardless of whether $p$ takes the value $0$ or $1$, one of the clauses will evaluate $l_1 or l_2$, and the other to $1$.
- If some clause $C_i$ has 1 distinct literal, so $C_i = l$, add new variables $q_1$ and $q_2$, and write the clauses $(l or q_1 or q_2) and (l or q_1 or bar(q_2)) and (l or bar(q_1) or q_2) and (l or bar(q_1) or bar(q_2))$. Again, regardless of what values $q_1$ and $q_2$ take, one of the new clauses will evaluate to $l$ and all others to 1, hence the equivalence.

Again this step only increases the size of the formula polynomially. Thus we have obtained a 3CNF expression for $phi$.

Now, we need to show that $C$ is satisfiable if and only if $phi$ is satisfiable.

$[=>]$ Suppose $C$ is satisfiable. Thus there exists an assignment of variables ${x_i}^n$ which makes the circuit evaluate to true. Then, one can simulate the circuit over this input and find the output of each internal node, labelled $y_i$. Keep the same assignment of $x_i$s, and for $y_i$s, assign them the value which the corresponding internal node outputs. (For other extra variables, assign them any value). This is a satisfying assignment for $phi$. If we think of the original bi-implication form of $phi$, then clearly the singleton root node clause is satisfied (since the root node of the circuit should be 1 as $C$ is satisfiable). Also, every other internal node's clause must be satisfied, because they simply represent the operation that happens on that node during the circuit's simulation. Hence, $phi$ is satisfiable.

$[arrow.double.l]$ Suppose $phi$ is satisfiable. Again, thinking of the original form, this means that each biimplication clause is satisfied, which essentially means that for any clause $y <-> a and b$, it is satisfied, so the assignment is such that $y = a and b$. Similarly this is true for other nodes as well. Furthermore, the singleton clause for the root node is also satisfied, this means that the root node of the circuit outputs $1$. Thus our formula $phi$ is simply simulating the circuit $C$ (the $y_i$ values must exactly take the outputs of the corresponding nodes when the circuit is simulated) and hence we have a satisfying assignment for $C$, which is simply the values for ${x_i}$ in $phi$'s satisfying assigment.

This proves that #prob is NP-Complete. #h(1fr)$qed$


#let prob = ss("CLIQUE")

At this point, we know that #ss("SAT"), and also in particular, #ss("3CNF-SAT") are NP-Complete problems. Now, let us discuss some other problems which are of more practical interest.


= #prob is NP-Complete

In an undirected graph $G = (V, E)$, a *clique* is a subset of vertices $S subset.eq V$, such that every two vertices in $S$ are adjacent, i.e. $forall u, v in S, u != v, (u, v) in E$. In other words, the induced subgraph of $S$ in $G$ is a complete graph. The *size of the clique* is the cardinality of the set $S$.

The clique problem is the optimisation problem of finding a clique of maximum size in a graph. As a decision problem, we formulate #prob: Given a graph $G$ and an integer $k$, determine whether $G$ contains a clique of size $k$.

A naive algorithm for determining whether $G$ has a clique of size $k$ is to list all $k$-subsets of $V$, and check each one to see if it forms a clique. Since $k$ in general can be $Theta(n)$, this algorithm runs in superpolynomial time. We show that in fact, this problem is NP-Complete, implying that an efficient algorithm for this problem is unlikely to exist.

== #prob is in NP

For a given graph $G = (V, E)$, we use the subset $S$ of vertices in a clique as a witness for $G$. We can check $|S| = k$, and check if $S$ forms a clique in $G$ by checking whether for each pair of vertices $u, v in S$, the edge $(u, v)$ is present in $G$.

We now show a reduction from 3-satisfiability to the clique problem, thus showing #prob to be NP-hard. This seems unnatural, since both problems are of widely different types. One is about constraint satisfaction, while the other is a graph problem. We will need to show a mapping from any arbitrary instance of #ss("3CNF-SAT") into an instance of #prob such that their membership in the language is equivalent. Doing so illustrates the general principle for designing reductions between problems $A red B$: we build "gadgets" out of components in $B$, which encode the information in the instance, and represent what is going on in problem $A$.

== #ss("3CNF-SAT") $red$ #prob

Given an arbitrary 3CNF formula $phi$, we need to construct a graph $G$ and a parameter $k$, such that 
#align(center)[
  $phi$ is satisfiable if and only if $G$ has a clique of size $k$.
]

Let $phi = C_1 and C_2 and ... and C_k$ be the Boolean formula (set $k$ to be the number of clauses). Each clause $C_i$ has three distinct literals, $C_i = (l_(i 1) or l_(i 2) or l_(i 3))$.

We construct the graph $G$ as follows: For every clause $C_i = (l_(i 1) or l_(i 2) or l_(i 3))$, add three vertices corresponding to each of the three literals in $C_i$. Add an edge between two vertices corresponding to $l_(i r)$ and $l_(j s)$ if:
- $i != j$, i.e. they do not belong to the same clause, and
- the literals are consistent, so $l_(i r)$ and $l_(j s)$ are not negations of each other.

Clearly, this graph can be built in polynomial time. For example, if $phi = (x_1 or bar(x_2) or bar(x_3)) and (bar(x_1) or x_2 or x_3) and (x_1 or x_2 or x_3)$, then the corresponding graph is shown in @cliq.



#figure(cetz.canvas(length: 1.2cm, {
  import cetz.draw: *

  let dark = rgb("#e6e6e6")
  let light = primary-color.lighten(70%)

  let nodes = (
    (1, 1, false, -1.1, 3.6, dark),
    (1, 2, true,   0.0, 3.6, light),
    (1, 3, true,   1.1, 3.6, dark),
    (2, 1, true,  -2.5, 2.13, dark),
    (2, 2, false, -2.5, 1.06, dark),
    (2, 3, false, -2.5, 0.0, light),
    (3, 1, false,  2.5, 2.13, dark),
    (3, 2, false,  2.5, 1.06, dark),
    (3, 3, false,  2.5, 0.0, light),
  )

  for i in range(nodes.len()) {
    for j in range(i + 1, nodes.len()) {
      let a = nodes.at(i)
      let b = nodes.at(j)
      let different-clause = a.at(0) != b.at(0)
      let contradictory = a.at(1) == b.at(1) and a.at(2) != b.at(2)
      if different-clause and not contradictory {
        line((a.at(3), a.at(4)), (b.at(3), b.at(4)), stroke: 0.5pt)
      }
    }
  }

  for n in nodes {
    let label = if n.at(2) { $bar(x_#n.at(1))$ } else { $x_#n.at(1)$ }
    circle((n.at(3), n.at(4)), radius: 0.3, fill: n.at(5), stroke: 0.5pt)
    content((n.at(3), n.at(4)), text(9pt, label))
  }

  content((0, 4.4), text(10pt, $C_1 = (x_1 or bar(x_2) or bar(x_3))$))
  content((-4.3, 1.06), text(10pt, $C_2 = (bar(x_1) or x_2 or x_3)$))
  content((4.4, 1.06), text(10pt, $C_3 = (x_1 or x_2 or x_3)$))
}), caption: [Graph $G$ for $phi = (x_1 or bar(x_2) or bar(x_3)) and (bar(x_1) or x_2 or x_3) and (x_1 or x_2 or x_3)$ for the reduction #ss("3CNF-SAT") $red$ #prob. The subset $S$ (shaded purple) forms a clique in $G$.]) <cliq>

We now need to show, that $phi$ is satisfiable if and only if $G$ has a clique of size $k$.

$[=>]$ Suppose $phi$ is satisfiable. For some satisfying assignment, each clause is satisfied independently, thus each clause $C_i$ contains at least one literal $l_(i r)$ which is true. Pick one true literal from each clause. This gives a set $S$ of $k$ vertices in the graph. We claim that $S$ is a clique:
For any two vertices which correspond to $l_(i r)$ and $l_(j s)$ in $S$, clearly $i != j$ since we picked one vertex from each clause. Also, we know that these literals are true under our satisfying assignment. So it cannot be the case that they are negations of each other (both can't be true simultaneously). Thus, by our construction, there exists an edge between these two vertices in our graph $G$.

$[arrow.l.double]$ Suppose $G$ has a clique $S$ of size $k$. Note that from a single triplet of vertices, no more than one vertex may be chosen in $S$, this is because vertices within the same triplet don't share an edge. Since the size of the clique is $k$, exactly one vertex (corresponding to literal $l_(i r)$) must have been chosen from each clause $C_i$. Create an assignment of variables such that each of these chosen literals becomes true under this assignment.

- Firstly, this is a valid assignment. This is because no two literals can be inconsistent (negations of each other) since they won't have an edge between them in $G$. So we can get a consistent assignment which satisfies all the chosen literals.
- Next, this is a satisfying assignment for $phi$. This is because in each clause, the chosen literal is true, so each clause evaluates to true and thus the entire formula.

This completes the proof that #prob is  NP-complete. #h(1fr) $qed$

#let prob = ss("SUBSET-SUM")

= #prob is NP-Complete

Now we take a look at an arithmetic problem. In the *subset-sum* problem, we are given a list of positive integers $a_1, a_2, ..., a_n$, and a target integer $t > 0$. We wish to know whether there exists a subset of these numbers which add up to $t$. In other words, we want to find a subset $S subset.eq {1, 2, ..., n}$ such that $sum_(i in S) a_i = t$. (As usual, we assume all numbers are written in binary, so the input size is polynomial in $n$ and $log t$.)


This is where the encoding of numbers matters. A simple dynamic programming algorithm solves #prob in $O(n t)$ time, but this is not polynomial, since $t$ can be exponential in the number of bits used to write it. We show that, unless $#pc = #np$, no algorithm can be polynomial in the _bit length_ of the input.

== #prob is in NP

For an instance $(a_1, ..., a_n, t)$, we use the index set $S$ as a witness. The verifier computes $sum_(i in S) a_i$ and checks whether it equals $t$. This takes time polynomial in the bit length of the input, since we add at most $n$ numbers, each with polynomially many bits.

== #ss("3CNF-SAT") $red$ #prob

Given an arbitrary 3CNF formula $phi$, we need to construct a list of numbers and a target $t$, such that
#align(center)[
  $phi$ is satisfiable if and only if some subset of the numbers sums to $t$.
]

Let $phi$ be a formula over variables $x_1, ..., x_n$ with clauses $C_1, ..., C_k$. The idea is to build numbers whose digits act as counters. A subset of the numbers will encode a truth assignment, and the digits will tell us whether every clause has been satisfied.

We will write the numbers in base 10 (for construction) and they will have $n + k$ digits. The first $n$ digits are labelled by the variables $x_1, ..., x_n$, and the last $k$ digits by the clauses $C_1, ..., C_k$. We create $2n + 2k$ numbers:

- For every variable $x_i$, two numbers $y_i$ and $z_i$, corresponding to setting $x_i$ true and false respectively.
- For every clause $C_j$, two _slack_ numbers $g_j$ and $h_j$, required for padding purposes.

#let ci = box(circle(radius: 0.6em, stroke: 0.4pt, inset: 0pt, align(center + horizon)[$1$]))

#let y-lab = ($y_1$, $z_1$, $y_2$, $z_2$, $dots.v$, $y_n$, $z_n$)
#let g-lab = ($g_1$, $h_1$, $g_2$, $h_2$, $dots.v$, $g_k$, $h_k$)

// variable columns for the y/z block
#let var-side = (
  ($1$, $0$, $dots$, $0$), ($1$, $0$, $dots$, $0$),
  ($0$, $1$, $dots$, $0$), ($0$, $1$, $dots$, $0$),
  ($dots.v$, $dots.v$, $dots.down$, $dots.v$),
  ($0$, $0$, $dots$, $1$), ($0$, $0$, $dots$, $1$),
)
// clause columns for the y/z block (circled 1 = "1 if the literal is in the clause")
#let lit-side = (
  (ci, $$, $dots$, $$), 
  ($0$, $$, $dots$, $$),
  ($0$, $$, $dots$, $$), 
  (ci, $$, $dots$, $$),
  ($dots.v$, $dots.v$, $dots.down$, $dots.v$),
  ($0$, $$, $dots$, $$), 
  (ci, $$, $dots$, $$),
)
// clause columns for the slack block
#let slack-side = (
  ($1$, $0$, $dots$, $0$), ($1$, $0$, $dots$, $0$),
  ($0$, $1$, $dots$, $0$), ($0$, $1$, $dots$, $0$),
  ($dots.v$, $dots.v$, $dots.down$, $dots.v$),
  ($0$, $0$, $dots$, $1$), ($0$, $0$, $dots$, $1$),
)

#figure({ set text(10pt)
  table(
    columns: (auto,) + (2.2em,) * 8,
    align: center + horizon,
    stroke: none,
    inset: 4pt,
    table.vline(x: 1, stroke: 0.8pt),
    table.vline(x: 5, stroke: 0.5pt),
    [], $x_1$, $x_2$, $dots$, $x_n$, $C_1$, $C_2$, $dots$, $C_k$,
    table.hline(stroke: 0.8pt),
    ..range(7).map(i => (y-lab.at(i), ..var-side.at(i), ..lit-side.at(i))).flatten(),
    table.hline(stroke: 0.5pt),
    ..range(7).map(i => (
      g-lab.at(i),
      ..if i == 0 {
        (table.cell(rowspan: 7, colspan: 4, text(1.2em, $0$)),)
      } else { () },
      ..slack-side.at(i),
    )).flatten(),
    table.hline(stroke: 0.8pt),
    $t$, $1$, $1$, $dots$, $1$, $3$, $3$, $dots$, $3$,
  )},
  caption: [Constructing the list of numbers for the reduction #ss("3CNF-SAT") $red$ #ss("SUBSET-SUM"). Row $y_i$ stands for $x_i = 1$ and $z_i$ for $x_i = 0$. In the first $2n$ numbers, each clause column has 3 ones, corresponding to its three literals. The two slack rows $g_j, h_j$ both have a single $1$ in column $C_j$.],
  kind: image,
) <ss-general>


We fill the digits as follows:
- For each variable $x_i$, the corresponding digit in the numbers $y_i$ and $z_i$ is set to 1, and $0$ in all the other numbers.
- In the column of each clause $C_j$, ones are set corresponding to the $y_i$ or $z_i$ rows which correspond to the literals in $C_j$, $y_i$ representing $x_i$ and $z_i$ representing $bar(x_i)$. So in each column for a clause $C_j$, exactly 3 ones will be present in the $y_i$/$z_i$ rows.
- We add the slack numbers, where the digits corresponding to each variable are 0, and we have 2 more ones in each clause column, in the corresponding slack numbers.
The target $t$ has digit $1$ in each of the $n$ variable columns, and digit $3$ in each of the $k$ clause columns. This is illustrated in @ss-general. This construction takes polynomial time to create the $2(n + k)$ numbers having $n + k$ digits each.

Now we need to show that $phi$ is satisfiable if and only if some subset of these numbers add up to $t$.

$[=>]$ Suppose $phi$ is satisfiable. According to its satisfying assignment, for each $i$ choose either $y_i$ or $z_i$ (choose $y_i$ if $x_i = 1$, choose $z_i$ otherwise.) Clearly, for the first $n$ digits the sums match (1 in each column, since exactly one of $y_i$ or $z_i$ has been chosen). In the last $k$ digits, in each column there must be at least one 1 that is chosen. This is because, since $phi$ is satisfied, thus each clause $C_j$ must be satisfied, so at least one of its literal must be true, and we have chosen the rows corresponding to all true literals. Then, the sum of the chosen numbers in the column for clause $C_j$ can be $1, 2$ or $3$ (depending on how many of the clause's literals become true under the chosen assignment). If we are below 3, we can use the slack numbers $g_j$ and $h_j$, choosing one or two of them to get that column's sum to exactly 3. Therefore, our chosen set of numbers exactly sums to the target $t$.

#let ss-table(rows, target, selected: ()) = {
  set text(9pt)
  let cols = ($x_1$, $x_2$, $x_3$, $C_1$, $C_2$, $C_3$, $C_4$)
  let n = rows.len()
  table(
    columns: (auto, auto) + (2em,) * 7,
    align: center + horizon,
    stroke: none,
    inset: 4pt,
    fill: (x, y) => if y >= 1 and y <= n and selected.contains(y - 1) {
      primary-color.lighten(70%)
    },
    table.vline(x: 5, stroke: 0.8pt),
    table.header([], [], ..cols, table.hline(y: 1)),
    ..rows.map(r => (r.at(0), $=$, ..r.at(1).map(v => [#if v == 1 { v }]))).flatten(),
    table.hline(y: 7, stroke: 0.5pt),
    table.hline(y: n + 1, stroke: 0.8pt),
    $t$, $=$, ..target.map(v => [#v]),
  )
}

#let ss-rows = (
  ($y_1$, (1, 0, 0, 1, 0, 0, 1)),
  ($z_1$, (1, 0, 0, 0, 1, 1, 0)),
  ($y_2$, (0, 1, 0, 0, 0, 0, 1)),
  ($z_2$, (0, 1, 0, 1, 1, 1, 0)),
  ($y_3$, (0, 0, 1, 0, 0, 1, 1)),
  ($z_3$, (0, 0, 1, 1, 1, 0, 0)),
  ($g_1$, (0, 0, 0, 1, 0, 0, 0)),
  ($h_1$, (0, 0, 0, 1, 0, 0, 0)),
  ($g_2$, (0, 0, 0, 0, 1, 0, 0)),
  ($h_2$, (0, 0, 0, 0, 1, 0, 0)),
  ($g_3$, (0, 0, 0, 0, 0, 1, 0)),
  ($h_3$, (0, 0, 0, 0, 0, 1, 0)),
  ($g_4$, (0, 0, 0, 0, 0, 0, 1)),
  ($h_4$, (0, 0, 0, 0, 0, 0, 1)),
)

#figure(
  ss-table(ss-rows, (1, 1, 1, 3, 3, 3, 3), selected: (0, 3, 5, 8, 10, 11, 12, 13)),
  caption: [The instance for $phi = (x_1 or bar(x_2) or bar(x_3)) and (bar(x_1) or bar(x_2) or bar(x_3)) and (bar(x_1) or bar(x_2) or x_3) and (x_1 or x_2 or x_3)$. The shaded rows are the subset corresponding to the satisfying assignment $x_1 = 1, x_2 = 0, x_3 = 0$. (Zeroes are not shown for clarity.)],
  kind: image,
) <ss-example>


$[arrow.l.double]$ Suppose there exists a subset of numbers which add up to $t$. First, notice that there cannot be any carrying addition that takes place. This is because in each column the total sum of digits never exceeds 5. So every column adds up to the target's digit independently. The first $n$ digits of the target are all 1, so this means that for each $i$, exactly one of $y_i$ or $z_i$ has been chosen in our subset. (If none are, or both are, then they don't sum to 1.) Construct the corresponding assignment based on which of $y_i$ or $z_i$ has been chosen: If $y_i$ is chosen, set $x_i = 1$, otherwise, set $x_i = 0$. We claim this is a satisfying assignment.

Firstly, this assignment is clearly valid because for no $i$ can both $y_i$ and $z_i$ be chosen so there are no inconsistencies. Next, consider the column corresponding to some clause $C_j$. Clearly, the chosen numbers in that column sum to 3. If we remove the slack rows (which can contribute at most 2 to the sum), and only consider the first $2n$ rows, then we see that the chosen numbers in this column must add up to at least 1. This means, that out of the 3 1s we placed for $C_j$ corresponding to each of its literals, at least one of them has been chosen in the subset, and this means that literal is true in our assignment. If one literal is true in a clause, the clause becomes true. So, every clause $C_j$ is true, hence $phi$ is satisfiable.

This proves that #prob is NP-Complete. #h(1fr) $qed$


#let prob = ss("VERTEX-COVER")

= #prob is NP-Complete

A *vertex-cover* of an undirected graph $G = (V, E)$ is a subset $S subset.eq V$ of vertices such that if $(u, v) in E$ then $u in S$ or $v in S$ (or both). In other words, a vertex cover is a set of vertices that "covers" every edge in the graph. The *size* of a vertex-cover is the number of vertices in it.

The vertex-cover problem is to find a vertex-cover of minimum size in a given graph. As a decision problem, #prob asks to determine whether a graph $G$ has a vertex cover of size $k$.

== #prob is in NP

Given a graph $G = (V, E)$ and an integer $k$, we can use the vertex cover $S subset.eq V$ itself as the witness. The verifier affirms that $|S| = k$, and that for each edge $(u, v) in E$, at least one of ${u, v}$ is in $S$. This clearly happens in polynomial time.

== #ss("CLIQUE") $red$ #prob

Given a graph $G$ and an integer $k$, we need to produce a graph $G'$ and an integer $k'$ such that 
#align(center)[
  $G$ has a clique of size $k$ if and only if $G'$ has a vertex cover of size $k'$.
]

Now this reduction is quite simple to describe since the problems are of the same kind. We first need to define the *complement* of a graph:

Given an undirected graph $G = (V, E)$, define the *complement* of $G$ as $bar(G) = (V, bar(E))$, where $bar(E) = {(u, v) | (u, v) in.not E, u != v}$. In other words, $bar(G)$ is the graph $G$ containing the edges which are not in $G$.

The reduction algorithm takes an input instance $chevron.l G, k chevron.r$ and computes the complement graph $bar(G)$. The output of the reduction algorithm is simply $G' = bar(G)$ and $k' = n - k$ (where $n = |V|$).

Now we need to show, that $G$ has a clique of size $k$ if and only if $bar(G)$ has a vertex-cover of size $n - k$.

$[=>]$ Suppose $G$ has a clique $S$ of size $k$. Then, consider the subset $V without S$. We claim that this is a vertex cover of $bar(G)$, so it covers every edge in $bar(E)$. Suppose for contradiction that it doesn't, i.e. there exists an edge $(u, v) in bar(E)$ such that $u in.not V without S$ and $v in.not V without S$. This means $u in S$ and $v in S$, but since $S$ was a clique in $G$, we need $(u, v) in E => (u, v) in.not bar(E)$, a contradiction. So, $V without S$ is indeed a vertex cover of $bar(G)$.

$[arrow.l.double]$ Suppose $bar(G)$ has a vertex cover $V without S$ of size $n - k$. Then, consider the subset $S$, we claim this is a clique in $G$. Suppose it is not, so there is some pair of vertices $u, v in S$ such that $(u, v) in.not E => (u, v) in bar(E)$. We know that $V without S$ is a vertex cover of $bar(G)$ so at least one of $u, v$ should be in $V without S$, which is a contradiction. So $S$ is a clique of $G$.

Hence, #prob is NP-Complete. #h(1fr) $qed$

#let prob = ss("INDEPENDENT-SET")

= #prob is NP-Complete

An *independent set* in an undirected graph $G = (V, E)$ is a subset $S subset.eq V$ such that no two vertices in $S$ are adjacent, i.e. $forall u, v in S, u != v, (u, v) in.not E$. As a decision problem, #prob asks: given a graph $G$ and an integer $k$, does $G$ contain an independent set of size $k$?

== #prob is in NP

The witness is the set $S$. The verifier checks that $|S| = k$ and that no pair $u, v in S$ has $(u, v) in E$. This takes polynomial time.

== #ss("CLIQUE") $red$ #prob

The reduction is the same complement construction used for #ss("CLIQUE") $red$ #ss("VERTEX-COVER"). Given $chevron.l G, k chevron.r$, output $G' = bar(G)$ and $k' = k$. Computing the complement can be done in polynomial time.

We show that $G$ has a clique of size $k$ if and only if $bar(G)$ has an independent set of size $k$. In fact, we will actually show for every $S subset.eq V$,
#align(center)[
  $S$ is a clique in $G$ if and only if $S$ is an independent set in $bar(G)$.
]

$[=>]$ Let $S$ be a clique in $G$. Take any distinct $u, v in S$. Since $S$ is a clique, $(u, v) in E$, so $(u, v) in.not bar(E)$ by definition of the complement. Hence no two vertices of $S$ are adjacent in $bar(G)$, so $S$ is an independent set in $bar(G)$.

$[arrow.l.double]$ Let $S$ be an independent set in $bar(G)$. Take any distinct $u, v in S$. Then $(u, v) in.not bar(E)$, which means $(u, v) in E$. So every two vertices of $S$ are adjacent in $G$, and $S$ is a clique in $G$.

Since the sizes of $S$ agree, $G$ has a clique of size $k$ if and only if $bar(G)$ has an independent set of size $k$. This proves that #prob is NP-Complete. #h(1fr) $qed$

#let prob = ss("HAMCYCLE")

= #prob is NP-Complete

In a graph $G = (V, E)$, a *Hamiltonian Cycle* is a cycle which goes through every vertex $v in V$ exactly once. The problem #prob is of determining whether there exists a Hamiltonian Cycle in a given graph $G$.

== #prob is in NP

The witness is the Hamiltonian cycle $C$. The verifier checks that $C$ visits every vertex exactly once and that it is a valid cycle in $G$.

== #ss("VERTEX-COVER") $red$ #prob

We now reduce an arbitrary instance of the Vertex-Cover problem to an instance of the Hamiltonian Cycle Problem, showing it to be NP-hard.

Given a graph $G = (V, E)$ and a parameter $k$, construct a graph $G' = (V', E')$ such that
#align(center)[
  $G$ has a vertex cover of size $k$ if and only if $G'$ has a Hamiltonian Cycle.
]

We directly state the construction used: For each edge $(u, v)$ in the graph $G$, create an *edge gadget* $W_(u v)$ (@hc-gadget (a)) having 12 vertices; two "rails" of six vertices each arranged parallelly. We label the vertices in the first rail as $chevron.l u, v, 1 chevron.r$ through $chevron.l u, v, 6 chevron.r$, and similarly for the other rail as $chevron.l v, u, 1 chevron.r$ through $chevron.l v, u, 6 chevron.r$.

In our construction, we will ensure that external edges that connect the gadget $W_(u v)$ to the rest of the graph can only be connected through one of the four corner vertices in the gadget (i.e. the 1st or 6th vertex of any rail). Then, we have the following property: any Hamiltonian Cycle of $G'$ should traverse $W_(u v)$ in one of the ways shown in @hc-gadget (b)-(d). 


#let hc-widget(o, dx: 1.5, dy: 0.55, paths: (), tails: (), stubs: true,
               labels: none, name: none, r: 0.14) = {
  import cetz.draw: *
  let P(s, i) = (o.at(0) + s * dx, o.at(1) - (i - 1) * dy)
  let stub(s, i) = {
    let p = P(s, i)
    (p.at(0) + if s == 0 { -0.5 } else { 0.5 }, p.at(1) + if i == 1 { 0.5 } else { -0.5 })
  }
  let shade = (paint: primary-color.lighten(70%), thickness: 4.5pt, cap: "round", join: "round")

  for p in paths { line(..p.map(v => P(v.at(0), v.at(1))), stroke: shade) }
  for t in tails { line(stub(t.at(0), t.at(1)), P(t.at(0), t.at(1)), stroke: shade) }

  for s in (0, 1) { line(P(s, 1), P(s, 6), stroke: 0.5pt) }
  line(P(0, 1), P(1, 3), stroke: 0.5pt)
  line(P(1, 1), P(0, 3), stroke: 0.5pt)
  line(P(0, 4), P(1, 6), stroke: 0.5pt)
  line(P(1, 4), P(0, 6), stroke: 0.5pt)
  if stubs {
    for (s, i) in ((0, 1), (1, 1), (0, 6), (1, 6)) {
      line(stub(s, i), P(s, i), stroke: 0.5pt)
    }
  }
  for s in (0, 1) {
    for i in range(1, 7) {
      circle(P(s, i), radius: r, fill: white, stroke: 0.5pt)
    }
  }
  if labels != none {
    let (lu, lv) = labels
    for i in range(1, 7, step: 5) {
      content(P(0, i), anchor: "east", padding: 0.25, text(8pt, $chevron.l #lu, #lv, #i chevron.r$))
      content(P(1, i), anchor: "west", padding: 0.25, text(8pt, $chevron.l #lv, #lu, #i chevron.r$))
    }
  }
  if name != none {
    content((o.at(0) + dx / 2, o.at(1) - 2.5 * dy), text(9pt, name))
  }
}

#let hc-col(s) = range(1, 7).map(i => (s, i))
#let hc-mode-u = ((0, 1), (0, 2), (0, 3), (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (0, 4), (0, 5), (0, 6))
#let hc-mode-v = ((1, 1), (1, 2), (1, 3), (0, 1), (0, 2), (0, 3), (0, 4), (0, 5), (0, 6), (1, 4), (1, 5), (1, 6))

#figure(cetz.canvas(length: 1cm, {
  import cetz.draw: *
  hc-widget((1.4, 0), labels: ($u$, $v$), stubs: false, name: $W_(u v)$)
  hc-widget((6.2, 0), paths: (hc-mode-u,), tails: ((0, 1), (0, 6)), name: $W_(u v)$)
  hc-widget((9.6, 0), paths: (hc-col(0), hc-col(1)), tails: ((0, 1), (0, 6), (1, 1), (1, 6)), name: $W_(u v)$)
  hc-widget((13.0, 0), paths: (hc-mode-v,), tails: ((1, 1), (1, 6)), name: $W_(u v)$)
  for (x, l) in ((2.15, "(a)"), (6.95, "(b)"), (10.35, "(c)"), (13.75, "(d)")) {
    content((x, -3.9), text(9pt, l))
  }
  content((1.4, -3.3), text(9pt, [$[u,v]$-rail]))
  content((2.9, -3.3), text(9pt, [$[v,u]$-rail]))
}), caption: [The gadget $W_(u v)$ for an edge $(u, v)$ of $G$. (a) The gadget with its vertices labelled. (b)--(d) The shaded paths are the only possible ones through the gadget that can be a part of a Hamiltonian Cycle.], kind: image) <hc-gadget>


Other than the widgets, there are $k$ more vertices in $G'$, which are called *selector vertices* labelled $s_1, s_2, ..., s_k$ ($k$ is the size of the vertex cover in the Vertex Cover instance).

We add edges in $G'$ as follows: First, for each $v in V$, fix an arbitrary ordering of its adjacent vertices: $v'_1, v'_2, ..., v'_p$ where let $p$ be the degree of $v$. (This means, ${(v, v'_i) | i = 1, 2, ..., p} subset.eq E$.) Then, we add edges to connect the $[v, v'_i]$ rails sequentially, and the first and the last rail to the selector vertices. In other words, we may schematically represent the edges added as

#let dd = math.class("binary", sym.dash.em)
$
  s_j dd [v, v'_1] dd [v, v'_2] dd ... dd [v, v'_p] dd s_j.
$

Formally, for each vertex $v in V$, we add the edges ${(chevron.l v, v'_i, 6 chevron.r, chevron.l v, v'_(i + 1), 1) | 1 <= i <= p}$ in $G'$ to connect the rails amongst themselves; and the edges ${(s_j, chevron.l v, v'_1, 1 chevron.r) | 1 <= j <= k} union {(s_j, chevron.l v, v'_p, 6 chevron.r) | 1 <= j <= k}$ for connecting the selector vertices at the ends.


It can be shown that the size of $G'$ is polynomial in the size of $G$. In particular, the number of vertices is at most $12 |E| + |V|$, and the number of edges is no more than $16 |E| + 2 |V|^2$. Thus, the construction of $G'$ takes place in polynomial time.

Now we need to prove the correctess of our reduction.

$[=>]$ Suppose $G$ has a vertex cover $S subset.eq V$, $|S| = k$. Let $S = {v_1, v_2, ..., v_k}$. For each $i$, let the neighbours of $v_i$ in the fixed ordering be $w_1, w_2, ..., w_p$ (where $p$ is the degree of $v_i$). We define a path $P_i$ in $G'$ that walks through the rails $[v_i, w_1], ..., [v_i, w_p]$ in this order. In the gadget $W_(v_i w_j)$ it behaves as follows:
- If $v_i in S, w_j in.not S$, then $P_i$ traverses the _whole_ gadget, entering at $chevron.l v_i, w_j, 1 chevron.r$, visiting all 12 vertices, and leaving at $chevron.l v_i, w_j, 6 chevron.r$. This is the path shown in @hc-gadget (b) or (d), depending on which side is $v_i$'s rail.
- If $v_i in S, w_j in S$, then $P_i$ goes straight down the rail of $v_i$, from $chevron.l v_i, w_j, 1 chevron.r$ to $chevron.l v_i, w_j, 6 chevron.r$. (The other rail of the gadget is handled by the path $P$ of $w_j$, as in @hc-gadget (c).)

Between consecutive gadgets, $P_i$ uses the edge $(chevron.l v_i, w_j, 6 chevron.r, chevron.l v_i, w_(j+1), 1 chevron.r)$. Thus $P_i$ is a path from $chevron.l v_i, w_1, 1 chevron.r$ to $chevron.l v_i, w_p, 6 chevron.r$. Now consider the cycle
$
  s_1 dd P_1 dd s_2 dd P_2 dd ... dd s_k dd P_k dd s_1.
$
This is a valid cycle in $G'$, since every selector vertex is adjacent to the first and last vertices of the rails of every $v in V$. We claim that it is a Hamiltonian cycle.

- Each selector vertex $s_j$ appears exactly once.
- Consider any edge $(u, v) in E$ and its gadget $W_(u v)$. Since $S$ is a vertex cover, at least one of $u, v$ is in $S$.
  - If exactly one of them is in $S$, say $u$, then the path $P$ of $u$ visits all 12 vertices of the gadget, and the path of $v$ does not exist, so each vertex is visited exactly once.
  - If both are in $S$, then the path of $u$ visits the rail $chevron.l u, v, * chevron.r$ and the path of $v$ visits the rail $chevron.l v, u, * chevron.r$. These are disjoint and together cover all 12 vertices.

Since every vertex is visited exactly once, so $G'$ has a Hamiltonian cycle.

$[arrow.l.double]$ Suppose $G'$ has a Hamiltonian cycle $H$. We first make an observation about how $H$ behaves inside gadgets. By the property stated above, $H$ restricted to $W_(u v)$ is one of the three ways in @hc-gadget (b)-(d). In all three, a path of $H$ which enters the gadget at $chevron.l u, v, 1 chevron.r$ leaves at $chevron.l u, v, 6 chevron.r$ (and vice versa), and likewise for $v$'s rail.  //So $H$ never crosses from one rail of a gadget to the other _through the outside_; it only leaves the gadget through the other end of the same rail.

Now delete the $k$ selector vertices from $H$. No two selector vertices are adjacent in $G'$, so this splits $H$ into exactly $k$ non-empty paths $P_1, ..., P_k$, which are vertex-disjoint and together contain all the non-selector vertices of $G'$. Each $P_i$ starts and ends at a first or last vertex of the rails of some $v in V$.

Consider the path $P_i$ and say it starts at $chevron.l v, v'_1, 1 chevron.r$ (the case where it starts at a last vertex $chevron.l v, v'_p, 6 chevron.r$ is symmetric, reading the path backwards). By the observation, it enters $W_(v v'_1)$ through this rail, so it must leave through $chevron.l v, v'_1, 6 chevron.r$. The only edges at this vertex leaving the gadget go to $chevron.l v, v'_2, 1 chevron.r$ (if $p > 1$) or to selector vertices (if $p = 1$). Repeating this argument, $P_i$ must walk through the rails $[v, v'_1], [v, v'_2], ..., [v, v'_p]$ in order, and it can only stop when it reaches $chevron.l v, v'_p, 6 chevron.r$ and moves to a selector vertex. So each $P_i$ is a path which passes through the rails of exactly one vertex $v_i in V$, in order. Since the paths $P_i$ are vertex-disjoint, the vertices $v_1, ..., v_k$ are distinct. Let $S = {v_1, ..., v_k}$, so $|S| = k$.

We claim $S$ is a vertex cover of $G$. Let $(u, v) in E$. The cycle $H$ visits every vertex of $W_(u v)$. Each such vertex lies on some $P_i$, but $P_i$ simply goes through the rails of $v_i$, so $P_i$ can only visit $W_(u v)$ if $v_i = u$ or $v_i = v$. Hence $u in S$ or $v in S$. So $S$ covers every edge of $G$, and $G$ has a vertex cover of size $k$.

This completes the reduction. Thus, #prob is NP-complete. #h(1fr) $qed$

#pagebreak()

= Summary

Starting from #ss("CIRCUIT-SAT") $in npc$ from the Cook-Levin theorem, we use reductions to prove unknown problems to be NP-Complete. Once we complete a reduction proof, the target problems get added to our pool of NP-Complete problems which we may use in the future to prove a new problem NP-Complete.

#let rn(pos, label, unv: false) = node(pos, text(size: 11pt, ss(label)), stroke: (dash: if unv { "dashed" } else { auto }), fill: if not unv { primary-color.lighten(80%) })
#let sol(a, b, ..args) = edge(a, b, "-|>", ..args)
#let dot(a, b, ..args) = edge(a, b, "-|>", stroke: (dash: "dashed"), ..args)

#figure(
  scale(90%, reflow: true, diagram(
    node-stroke: 0.5pt,
    node-inset: 6pt,
    node-corner-radius: 3pt,
    spacing: (0em, 3em),
    edge-stroke: 0.6pt,

    rn((0, 0), "CIRCUIT-SAT"),

    rn((0, 1), "3CNF-SAT"),

    rn((-2.5, 2), "3-COLORABILITY", unv: true),
    rn((-1.5, 2), "CLIQUE"),
    rn((0, 2), "SUBSET-SUM"),
    rn((4, 2), "3D-MATCHING", unv: true),

    rn((-3.5, 3), "SUBGRAPH-ISO", unv: true),
    rn((-2, 3), "INDEPENDENT-SET"),
    rn((-1, 3), "VERTEX-COVER"),
    rn((0, 3), "PARTITION", unv: true),
    rn((1, 3), "KNAPSACK", unv: true),
    rn((4, 3), "SET-COVER", unv: true),

    rn((0, 4), "HAM-CYCLE"),
    rn((-2, 4), "HITTING-SET", unv: true),
    rn((-1, 4), "DOMINATING-SET", unv: true),

    rn((0, 5), "HAM-PATH", unv: true),
    rn((1, 5), "TSP", unv: true),

    sol((0, 0), (0, 1)),
    sol((0, 1), (-1.5, 2)),
    sol((0, 1), (0, 2)),
    sol((-1.5, 2), (-1, 3)),
    sol((-1.5, 2), (-2, 3)),

    dot((0, 1), (-2.5, 2)),           // 14, 21: 3SAT -> 3-Colorability
    dot((0, 1), (4, 2)),            // 21: 3SAT -> 3D Matching
    dot((0, 1), (-1, 3), bend: -15deg), // 4: 3SAT -> Vertex Cover
    dot((-1, 3), (0, 2)),           // 7:  Vertex Cover -> Subset Sum
    dot((0, 2), (0, 3)),            // 8:  Subset Sum -> Partition
    dot((0, 2), (1, 3)),            // 15: Subset Sum -> Knapsack
    dot((-1, 3), (-2, 4)),          // 9:  Vertex Cover -> Hitting Set
    sol((-1, 3), (0, 4)),            // 21: Vertex Cover -> Hamiltonian Cycle
    dot((-1, 3), (-1, 4)),          // 20: Vertex Cover -> Dominating Set
    dot((4, 2), (4, 3)),            // 11: 3DM -> Set Cover
    dot((-1.5, 2), (-3.5, 3)), // 19: Clique -> Subgraph Isomorphism
    dot((0, 4), (0, 5), bend: 20deg),   // 17: Ham Cycle -> Ham Path
    dot((0, 5), (0, 4), bend: 20deg),   // 18: Ham Path -> Ham Cycle
    dot((0, 4), (1, 5)),            // 13: Ham Cycle -> TSP
  )),
  caption: [The zoo of NP-Complete problems. An arrow from $A$ to $B$ indicates a reduction $A red B$. Solid edges show reductions which we have shown, and dotted edges denote reductions asked in the problems.],
  kind: image,
) <reductions>

All the problems shown in @reductions are actually NP-Complete. As of now, we have only proven the highlighted problems to be NP-Complete via the reductions drawn in solid lines. As we have seen, the common pattern to come up with these reductions is to build gadgets in the target problem that encode the choices and constraints of the source problem. The reductions shown in dotted lines are asked in the problems.


#pagebreak()

= Problems and Solution Sketches

#let clrs = "https://www.cs.mcgill.ca/~akroit/math/compsci/Cormen%20Introduction%20to%20Algorithms.pdf"
#let kt = "https://dl.icdst.org/pdfs/files3/9ce98c127c79e548ebea18966f526ae9.pdf"

For standard reductions, refer to the course textbooks CLRS 3e (#link(clrs)[link]) Chapter 34 and KT (#link(kt)[link]) Chapter 8.

1. Design a polynomial-time algorithm for each of the following problems: 2SAT, Eulerian Cycle, 2-Colorability of Graphs, DNF Satisfiability, and Minimum Edge Cover.

#soln-box[

*2SAT*: Given a Boolean formula $phi$ in 2CNF form (conjunction of clauses with exactly two literals), determine whether a satisfying assignment exists.

Suppose $phi$ is over $n$ variables $x_1, x_2, ..., x_n$ and has $k$ clauses: $C_1 and C_2 and ... and C_k$.
1. First, break each clause into implication clauses as follows:
$
  (a or b) quad equiv quad (bar(a) -> b) and (bar(b) -> a)
$
2. Draw the *implication graph*: Draw two vertices corresponding to each variable $x$ (one for its uncomplemented literal $x$ and one for its complemented literal $bar(x)$). Draw a directed edge from $l_1$ to $l_2$ if there is an implication clause of the form $(l_1 -> l_2)$.
3. Condense the implication graph into its strongly connected components (by using a polynomial time algorithm like Tarjan or Kosaraju).
4. For any variable $x_i$, if the literals $x_i$ and $bar(x_i)$ lie in the same component, then $phi$ is NOT satisfiable. Otherwise, $phi$ is satisfiable.

The algorithm runs in polynomial time.

We now show that $phi$ is satisfiable if and only if no variable has both its literals in the same SCC.

First, we have the following observation:
- Under any satisfying assignment, if there is an edge $u -> v$ and $u$ is true, then $v$ is true. (Otherwise $bar(u) or v$ would be false, but this is exactly the clause the edge came from.) By induction along a path, if there is a path from $p$ to $q$ and $p$ is true, then $q$ must be true.

$[=>]$ Suppose $phi$ is satisfiable, with satisfying assignment $alpha$, and suppose for contradiction that some $x$ has $x$ and $bar(x)$ in the same SCC. Then there are paths $x arrow.squiggly bar(x)$ and $bar(x) arrow.squiggly x$. If $alpha$ sets $x$ true, then by the observation, $bar(x)$ is true, which is impossible. If $alpha$ sets $x$ false, then $bar(x)$ is true, and so $x$ is true by the second path, again impossible. This is a contradiction, so no such $x$ exists.

$[arrow.l.double]$ Suppose that for every variable, $x_i$ and $bar(x_i)$ lie in different SCCs. Let $"SCC"(l)$ denote the strongly connected component containing literal $l$. Topologically sort the SCCs in the condensation graph. In the ordering, for each variable $x$, if $"SCC"(x)$ occurs before $"SCC"(bar(x))$, assign $x = 0, bar(x) = 1$. Otherwise, assign $x = 1, bar(x) = 0$. We claim that this is a satisfying assignment.

Consider any clause $(a or b)$, and suppose for contradiction that it is false, so $a$ and $b$ are both false. Then $bar(a)$ and $bar(b)$ are true. By our construction, $"SCC"(a)$ occurs before $"SCC"(bar(a))$, and $"SCC"(b)$ occurs before $"SCC"(bar(b))$. The clause gives the edges $bar(a) -> b$ and $bar(b) -> a$, so in the topological order
$
"SCC"(bar(a)) lt.eq "SCC"(b) quad "and" quad "SCC"(bar(b)) lt.eq "SCC"(a).
$
Chaining this with the other inequalities gives us
$
"SCC"(a) < "SCC"(bar(a)) lt.eq "SCC"(b) < "SCC"(bar(b)) lt.eq "SCC"(a),
$
so $"SCC"(a) < "SCC"(a)$, a contradiction. Hence every clause is satisfied.

Thus we have shown a polynomial time algorithm for 2SAT. #h(1fr) $qed$

] #soln-box[

*Eulerian Cycle*: Given an undirected graph $G = (V, E)$, determine whether there exists an Eulerian Cycle: a path which starts and ends on the same vertex, and visits every edge exactly once.

(For this discussion, we assume a 'path' and a 'cycle' can have repeated vertices, but not repeated edges.)

Algorithm:
1. If $G$ is disconnected and has multiple connected components (ignoring isolated vertices), then $G$ does not have an Eulerian cycle.
2. Find the degree of every vertex. If the degree of every vertex is even, then $G$ has an Eulerian cycle. Otherwise, it does not.

Clearly this runs in $O(m + n)$ i.e. polynomial time.

We show that a connected graph $G$ has an Eulerian cycle if and only if every vertex has even degree.

$[=>]$ Suppose $G$ has an Eulerian cycle $C$. For any vertex $v$, all its incident edges appear once in $C$. Each time $C$ passes through $v$, it must enter through one edge and exit through another. Thus, it is necessary that $v$ has an even number of incident edges, so degree of $v$ must be even.

$[arrow.double.l]$ (Rough sketch) Show the other side of the proof, i.e. if every vertex has even degree, then $G$ has an Eulerian cycle. This can be done by first showing:
- Lemma: In a graph $G$, if every vertex has even degree, then any (non isolated) vertex $v$ lies on some cycle. (One can construct such a cycle by repeatedly taking some edge from the current vertex, at some point we reach the starting vertex again.)
Now, to prove the original statement, we make a contradiction argument. Suppose $C$ is the largest cycle in $G$ (largest by number of edges in the cycle). If $C$ uses all edges in $G$, it is an Eulerian cycle and we are done. Otherwise, we consider the subgraph $G without C$. In this subgraph, all vertices will have even degree (why?). Also, there is some vertex $v$ which was a part of $C$ and still has some edge left (why?). Applying the lemma on this vertex in $G without C$, we obtain a new cycle $C'$. Since both cycles $C$ and $C'$ in $G$ go through $v$, we could 'merge' the two cycles into one bigger cycle (how?), thus contradicting maximality of $C$. So $C$ must be a Eulerian cycle.

Thus Eulerian cycle can be determined in polynomial time. #h(1fr) $qed$

] #soln-box[

*2-COLOR*: Given an undirected graph $G = (V, E)$, determine whether it is 2-colorable.

A graph $G = (V, E)$ is said to be *2-colorable* if there exists a coloring $c : V -> {0, 1}$, such that for any edge $(u, v) in E$, the two vertices have a different color, i.e. $c(u) != c(v)$.

Algorithm:
Perform DFS on $G$. Arbitrarily color the first vertex (of each new component). For each edge $(u, v)$ being explored,
- If $v$ hasn't been visited yet, color it the opposite color of $u$.
- If $v$ has been explored, and $c(u) = c(v)$, report $G$ is NOT 2-colorable. Continue otherwise.
If we successfully complete the DFS then report $G$ is 2-colorable.

The time complexity of this algorithm is linear in the size of the graph, so it runs in polynomial time.


First, we *claim*: If our algorithm reports that $G$ is not 2-colorable, then $G$ has a cycle of odd length. Say $(u, v)$ is the edge where our algorithm gets stuck, so $c(u) = c(v)$. Consider the unique path from $u$ to $v$ in the DFS tree. By our coloring strategy, this path must be alternately colored. Since both $u$ and $v$ are colored same, the path should have an even number of edges. Then consider the cycle comprising of this path and the edge $(u, v)$, this is an odd cycle.

We now show that $G$ is 2-colorable if and only if the algorithm reports so.

$[=>]$ Let $G$ be 2-colorable. Suppose our algorithm claims otherwise. Then, $G$ has an odd cycle, say it is $chevron.l v_1, v_2, ..., v_(2k+1), v_1 chevron.r$. Since the graph is 2-colorable, $G$ can be colored with 2 colors such that all adjacent pairs of vertices are differently colored. 

WLOG, let $c(v_1) = 0$. Then, we have,
$
c(v_1) = 0 &=> c(v_2) = 1
&=> c(v_3) = 0
&=> dots
&=> c(v_(2k)) = 1
&=> c(v_(2k + 1)) = 0 $
But, $c(v_(2k + 1)) = 0$ and $c(v_1) = 0$ while $(v_(2k + 1), v_1) in E$, which is a contradiction. Thus $G$ cannot contain a cycle of odd length. So our algorithm must report correctly, that $G$ is 2-colorable.

$[arrow.double.l]$ Suppose our algorithm reports that $G$ is 2-colorable. This means that it managed to complete the DFS and 2-color the entire graph. Since during the DFS we iterate over all edges, and successful exit implies endpoints of all edges are differently colored, this means the algorithm has found a valid 2-coloring of $G$, thus $G$ must be 2-colorable.

Therefore, 2-colorability is polynomial-time solvable. #h(1fr) $qed$

] #soln-box[
*DNF Satisfiability*: Given a Boolean formula $phi$ in DNF (disjunctive normal form), i.e. an OR of one or more clauses where each clause is an AND of one or more literals; determine whether $phi$ is satisfiable.

Algorithm: If there exists some clause $C_i = l_1 and l_2 and ... and l_m$ where no two literals are complements of each other, then $phi$ is satisfiable. Otherwise, it is not.

We show $phi$ is satisfiable if and only if there is some clause where no complementary pair of literals occur.

$[=>]$ Suppose $phi$ is satisfiable, then under a satisfying assignment, at least one clause $C_i$ must be satisfied. For this to happen, all literals in $C_i$ must become true. Then, $C_i$ cannot contain any complementary pair of literals, since they both can't be true at the same time.

$[arrow.double.l]$ Suppose $C_i$ is a clause where there is no complementary pair of literals, so all literals are 'consistent'. Then, assign each of these literals to 1. (Any variable that does not appear can be arbitrarily assigned). This assignment is well defined because no complementary pair of literals appear in $C_i$. This is a satisfying assignment because this makes all literals in $C_i$ to be true, so $C_i$ is satisfied, thus $phi$ is satisfied.

Thus, DNF Satisfiability can be determined in polynomial time. #h(1fr) $qed$

] #soln-box[

*Minimum Edge Cover*: Given an undirected graph $G$, find a minimum edge cover of $G$.

In an undirected graph $G = (V, E)$, an *edge cover* is a set of edges $S subset.eq E$ such that every vertex $v in V$ is an endpoint of some edge $e in S$.

Algorithm:
1. If $G$ has any isolated vertices, no edge cover exists.
2. Find a maximum matching $M$ in $G$ (Edmonds' Blossom algorithm).
3. For each unmatched vertex $v$, pick one of its incident edges. Call this set $U$. Since $M$ matches $2|M|$ vertices, $n - 2|M|$ vertices are unmatched. So $|U| = n - 2|M|$. 
4. Output $S = M union U$ as the minimum edge cover. Its size is $|M| + (n - 2 |M|) = n - |M|$.

(This is Gallai's theorem: If $alpha'(G)$ is the size of a maximum matching in $G$, and $beta'(G)$ is the size of a minimum edge cover, then we have $beta'(G) = n - alpha'(G)$.)

We now show that $S$ is indeed a minimum edge cover.

1. *Every vertex is covered.* For any vertex $v$, if $v$ is matched by $M$, then it is covered by an edge in $M$, so it is clearly covered. If $v$ is unmatched in $M$, then we have added an edge incident on $v$ in $U$, so it is also covered.

2. *Minimality of $S$.* Suppose we have an edge cover $S'$ such that $|S'| < |S| = n - |M|$. Consider the graph with vertices of $G$ and only edges in $S'$. Suppose this graph has $k$ connected components. (There will be no isolated vertices in this graph, by virtue of $S'$ being an edge cover.) Then, in each connected component of size $c$, the number of edges in it will be at least $c - 1$. Adding this across all the components, we see that $|S'| >= n - k$, so $n - k < n - |M| => k > |M|$.\* Now, we can create a set $M'$ by choosing one edge in $S'$ for each of the $k$ connected components. $M'$ is a matching in $G$, since clearly no two edges can be incident on the same vertex (we have chosen one edge from each connected component). But, $|M'| = k > |M|$, contradicting the maximality of $M$.

\* (What this means is that originally $S$ had $|M|$ connected components, now when we have a smaller edge cover $S'$, it partitions $G$ into more ($k > |M|$) connected components.)

Thus we have shown a polynomial time algorithm to find the minimum edge cover in a graph $G$. #h(1fr) $qed$

]

2. Give an example of a problem which is NP-hard but unlikely to be NP-complete.

#soln-box[
The Halting Problem is NP-hard, but not in NP (in fact, it is _undecidable_).

*Halting Problem*: Given a machine $M$ and an input $x$, determine whether $M$ halts on $x$.

Proof of NP-hardness: We can show #ss("SAT") $red$ #ss("HP"). This proves #ss("HP") is at least as hard as #ss("SAT"), so it is at least as hard as every NP problem, so it is NP-hard.

Given an arbitrary Boolean formula $phi$, we can construct a machine $M$ which halts, if and only if $phi$ is satisfiable.

Machine $M$ works as follows:
1. It tries out every possible assignment of variables to check whether it satisfies $phi$.
2. If some satisfying assignment is found, the machine halts.
3. If all assignments are exhausted and no satisfying assignment exists, the machine goes into an infinite loop.

Construction of this machine can be done in polynomial time in the size of the instance $phi$.

Thus, #ss("HP") is NP-hard.

]

3. Show that CNF-SAT many-to-one reduces to 3SAT.

#soln-box[
  #ss("CNF-SAT") $red$ #ss("3SAT"):  #link("https://cse.iitkgp.ac.in/~palash/2018AlgoDesignAnalysis/SAT-3SAT.pdf")[link]

]

4. Show that 3SAT many-to-one reduces to Vertex Cover.

#soln-box[
  #ss("3SAT") $red$ #ss("VERTEX-COVER")

  Given an arbitrary 3CNF formula $phi$, we need to construct a graph $G$ and a parameter $k$, such that
  #align(center)[
    $phi$ is satisfiable if and only if $G$ has a vertex cover of size $k$.
  ]

  Let $phi = C_1 and C_2 and ... and C_l$ contain $n$ variables $x_1, ..., x_n$ and $l$ clauses, where each clause $C_j = (l_(j 1) or l_(j 2) or l_(j 3))$ has three distinct literals. Set $k = n + 2l$. We construct a graph $G$ with $2n + 3l$ vertices.

  - *Variable gadget.* For every variable $x_i$, add two vertices labelled $x_i$ and $bar(x_i)$, joined by an edge.
  - *Clause gadget.* For every clause $C_j$, add a triangle with three vertices labelled by the literals $l_(j 1), l_(j 2), l_(j 3)$.
  - Add *connection edges*: Join each vertex of a clause gadget to the vertex of the variable gadget carrying the same literal. For example, the clause vertex labelled $bar(x_2)$ is joined to the vertex $bar(x_2)$ of the gadget for $x_2$.

  #figure(grid(
    columns: 2,
    align: horizon,
    gutter: 4em,
    cetz.canvas(length: 0.8cm, {
      import cetz.draw: *
      line((0, 0), (1.8, 0), stroke: 0.6pt)
      circle((0, 0), radius: 0.35, fill: white, stroke: 0.5pt)
      circle((1.8, 0), radius: 0.35, fill: white, stroke: 0.5pt)
      content((0, 0), text(9pt, $x_i$))
      content((1.8, 0), text(9pt, $bar(x_i)$))
      // dashed stubs: connections going to the clause gadgets
      line((0, 0.35), (-0.4, 1.2), stroke: (dash: "dashed", thickness: 0.5pt))
      line((0, 0.35), (0.1, 1.2), stroke: (dash: "dashed", thickness: 0.5pt))
      line((1.8, 0.35), (1.7, 1.2), stroke: (dash: "dashed", thickness: 0.5pt))
      line((1.8, 0.35), (2.2, 1.2), stroke: (dash: "dashed", thickness: 0.5pt))
      content((0.9, -1), text(9pt)[variable gadget for $x_i$])
    }),
    cetz.canvas(length: 0.8cm, {
      import cetz.draw: *
      let p = ((-1, 0), (1, 0), (0, 1.7))
      line(p.at(0), p.at(1), p.at(2), close: true, stroke: 0.6pt)
      line((-1, -0), (-1.6, -1), stroke: (dash: "dashed", thickness: 0.5pt))
      line((1, -0), (1.6, -1), stroke: (dash: "dashed", thickness: 0.5pt))
      line((0, 2.05), (0, 2.8), stroke: (dash: "dashed", thickness: 0.5pt))
      for (i, q) in p.enumerate() {
        circle(q, radius: 0.35, fill: white, stroke: 0.5pt)
        content(q, text(9pt, $l_(j #(i + 1))$))
      }
      content((0, -1.5), text(9pt)[clause gadget for $C_j$])
    }),
  ), caption: [The gadgets for the reduction #ss("3SAT") $red$ #ss("VERTEX-COVER").]) <vc-gadgets>

  Clearly, this graph can be built in polynomial time.

  #figure(cetz.canvas(length: 1cm, {
    import cetz.draw: *

    let hi = primary-color.lighten(70%)
    let lo = white

    let clauses = (
      ((1, false), (2, true), (3, true)),
      ((1, true), (2, false), (3, false)),
      ((1, false), (2, false), (3, false)),
    )
    // the assignment x1 = 1, x2 = 0, x3 = 1, and the vertex left out of each triangle
    let assign = (true, false, true)
    let left-out = (0, 2, 0)

    let vpos(i, neg) = ((2 * (i - 1) + if neg { 1 } else { 0 }) * 1.6 - 4, 6)
    let is-true(i, neg) = assign.at(i - 1) != neg
    let cx = (-4, 0, 4)
    let tpos(j, r) = {
      let c = cx.at(j)
      ((c - 0.9, 3.2), (c + 0.9, 3.2), (c, 4.4)).at(r)
    }

    // variable edges
    for i in range(1, 4) {
      line(vpos(i, false), vpos(i, true), stroke: 0.6pt)
    }
    // triangle edges and connection edges
    for (j, cl) in clauses.enumerate() {
      for (a, b) in ((0, 1), (1, 2), (0, 2)) {
        line(tpos(j, a), tpos(j, b), stroke: 0.6pt)
      }
      for (r, lit) in cl.enumerate() {
        line(tpos(j, r), vpos(lit.at(0), lit.at(1)), stroke: 0.4pt)
      }
    }

    let label(i, neg) = if neg { $bar(x_#i)$ } else { $x_#i$ }
    for i in range(1, 4) {
      for neg in (false, true) {
        circle(vpos(i, neg), radius: 0.3, fill: if is-true(i, neg) { hi } else { lo }, stroke: 0.5pt)
        content(vpos(i, neg), text(9pt, label(i, neg)))
      }
    }
    for (j, cl) in clauses.enumerate() {
      for (r, lit) in cl.enumerate() {
        circle(tpos(j, r), radius: 0.3, fill: if r != left-out.at(j) { hi } else { lo }, stroke: 0.5pt)
        content(tpos(j, r), text(9pt, label(lit.at(0), lit.at(1))))
      }
      content((cx.at(j), 2.6), text(10pt, $C_#(j + 1)$))
    }
  }), caption: [Graph $G$ for $phi = (x_1 or bar(x_2) or bar(x_3)) and (bar(x_1) or x_2 or x_3) and (x_1 or x_2 or x_3)$ for the reduction #ss("3SAT") $red$ #ss("VERTEX-COVER").]) <vc-example>

  We now need to show that $phi$ is satisfiable if and only if $G$ has a vertex cover of size $k = n + 2l$.

  $[=>]$ Suppose $phi$ is satisfiable, and fix a satisfying assignment. Build a set $S$ as follows:
  - From each variable gadget, pick the vertex whose literal is true. This gives $n$ vertices.
  - Each clause $C_j$ contains at least one true literal. Pick one such triangle vertex and call it the _left-out_ vertex. Pick the other two vertices of the triangle in $S$. This gives $2l$ vertices.

  So $|S| = n + 2l = k$. We claim that $S$ is a vertex cover, so every edge needs to be covered.
  - *Variable edge $(x_i, bar(x_i))$:* exactly one of the two literals is in $S$, so this edge is covered.
  - *Clause edges:* two of the three vertices of every triangle are in $S$, so every triangle edge is covered.
  - *Connection edges:* if the clause endpoint is in $S$, the edge is covered. Otherwise the clause endpoint is the left-out vertex, whose literal is true by our choice. Then its other endpoint, the variable-gadget vertex of this literal, is in $S$, so this edge is covered.

  $[arrow.l.double]$ Suppose $G$ has a vertex cover $S$ of size $n + 2l$. The $n$ variable gadgets and the $l$ clause gadgets are pairwise vertex-disjoint. To cover a variable edge we need at least $1$ of its vertices, and to cover the clause gadget edges we need at least $2$ of its vertices. So $S$ has at least $n + 2l$ vertices. Since $|S| = n + 2l$, we require: $S$ contains *exactly one* vertex from each variable gadget, and *exactly two* vertices from each clause gadget. Create an assignment as follows: set $x_i = 1$ if the variable gadget vertex $x_i$ is in $S$, and $x_i = 0$ if the variable gadget vertex $bar(x_i)$ is in $S$.

  - Firstly, this is a valid assignment, since exactly one of $x_i, bar(x_i)$ is in $S$, so there are no inconsistencies.
  - Next, this is a satisfying assignment for $phi$. Consider a clause $C_j$. Exactly one vertex $v$ of its triangle is not in $S$. The connection edge from $v$ to its variable-gadget vertex $w$ must be covered, and $v in.not S$, so $w in S$. Thus the literal of $v$ is true under our assignment, and so $C_j$ is satisfied. This holds for every clause, so $phi$ is satisfied.

  This completes the reduction. #h(1fr) $qed$
]

5. Show that 3SAT many-to-one reduces to Exact-3SAT.

#soln-box[
  Say #ss("3SAT") instances can have at most 3 distinct literals per clause, and #ss("EXACT-3SAT") is a satisfiability problem where the instance $phi$ is in CNF form and it must have *exactly* 3 distinct literals per clause.

  The reduction can be shown simply by using the transformations given on page 2--3 to convert any clause with at most 3 literals, to clauses with exactly 3 literals, by adding new variables.

]

6. Show that Directed Hamiltonian Cycle many-to-one reduces to Directed Hamiltonian Path.

#soln-box[
  Given a directed graph $G$, we need to construct a directed graph $G'$, such that
  #align(center)[$G$ has a Hamiltonian Cycle if and only if $G'$ has a Hamiltonian Path.]

  To construct $G'$,
  - In $G$, pick any vertex $v$.
  - Remove the vertex $v$. Add two new vertices $v_"in"$ and $v_"out"$ in $G'$. If there was a directed edge from $u$ to $v$ in $G$, add an edge $u -> v_"in"$ in $G'$. If there was a directed edge from $v$ to $w$ in $G$, add an edge $v_"out" -> w$ in $G'$.


  #let d1 = diagram(
    node-shape: circle,
    node-stroke: 0.7pt,
    mark-scale: 1.5,
    node-fill: white,
  {

    node((0, 0), $v$, name: "v")
    edge((-1, -1), (0, 0), "-|>",  label-sep: 0pt)
    edge((-1.5, 0), (0, 0), "-|>")
    edge((-1, 1), (0, 0), "-|>",  label-sep: 0pt)

    edge((0, 0), (1, -1), "-|>",  label-sep: 0pt)
    edge((0, 0), (1.5, 0), "-|>")
    edge((0, 0), (1, 1), "-|>", label-sep: 0pt)
  }, spacing: 0.8cm)

  #let d2 = diagram(
    node-shape: circle,
    node-stroke: 0.7pt,
    mark-scale: 1.5,
    node-fill: white,
  {

    node((0, 0), $v_"i"$, name: "vin")
    node((1, 0), $v_"o"$, name: "vout")
    edge((-1, -1), (0, 0), "-|>", label-sep: 0pt)
    edge((-1.5, 0), (0, 0), "-|>",)
    edge((-1, 1), (0, 0), "-|>", label-sep: 0pt)
    edge((1, 0), (2, -1), "-|>",  label-sep: 0pt)
    edge((1, 0), (2.5, 0), "-|>")
    edge((1, 0), (2, 1), "-|>", label-sep: 0pt)
  }, spacing: 0.8cm)

  #figure(
    grid(columns: 2, gutter: 3em, d1, d2),
    caption: [Construction of $G'$ for the reduction #ss("DIRHAMCYCLE") $red$ #ss("DIRHAMPATH").]
  )

  $[=>]$ Let the Hamiltonian Cycle in $G$ be $C = chevron.l v, v_1, v_2, ..., v_k, v chevron.r$ (we can arbitrarily start the cycle at any point, say we do it at $v$). Then, $P = chevron.l v_"out", v_1, v_2, ..., v_k, v_"in" chevron.r$ is a Hamiltonian Path in $G'$. It clearly passes through every vertex in $G'$, and all edges it uses are valid edges in $G'$.

  $[arrow.double.l]$ Let $P$ be a Hamiltonian path in $G'$. Now, $v_"out"$ does not have any incoming edge in $G'$, but it must be in the path $P$, so it must be the starting vertex of the path. Similarly, $v_"in"$ does not have any outgoing edge but it should be in $P$, so it must be the last vertex. So, $P = chevron.l v_"out", v_1, v_2, ..., v_k, v_"in" chevron.r$. Then $C = chevron.l v, v_1, v_2, ..., v_k, v chevron.r$ is a Hamiltonian Cycle in $G$. It passes through all vertices in $G$, and all edges are valid edges in $G$. #h(1fr) $qed$


]

7. Show that Vertex Cover many-to-one reduces to Subset Sum.

#soln-box[
  #ss("VERTEX-COVER") $red$ #ss("SUBSET-SUM")

  Given a graph $G = (V, E)$ and an integer $k$, we need to construct a list of numbers and a target $t$, such that
  #align(center)[
    $G$ has a vertex cover of size $k$ if and only if some subset of the numbers sums to $t$.
  ]

  Let $V = {v_1, ..., v_n}$ and $E = {e_1, ..., e_m}$ (we assume $G$ has no self-loops and $k <= n$). We need to create a list of numbers, such that a subset of the numbers will encode a set of vertices, and the digits should tell us whether it has the right size and covers every edge.

  Say we write the numbers in base 10, with $m + 1$ digits. The leading digit is a *dummy* column $D$, which counts the number of chosen vertices, and the remaining $m$ digits are labelled by the edges $e_1, ..., e_m$. We create $n + m$ numbers:

  - For every vertex $v_i$, a number $a_i$ with digit $1$ in the dummy column, and digit $1$ in the column of every edge $e_j$ incident to $v_i$. All other digits are $0$. (For each edge column, among the vertex numbers, the only two numbers which have a digit 1 will correspond to the two endpoints of that edge.)
  - For every edge $e_j$, a _slack_ number $b_j$ with digit $0$ in the dummy column, and digit $1$ in the column of $e_j$ only. All other digits are $0$.

  The target $t$ has digit $k$ in the dummy column, and digit $2$ in each of the $m$ edge columns. (Note that $k$ may not be a valid digit in base 10, essentially the number is $t = k times 10^m + 2 sum_(j = 0)^(m - 1) 10^j$; symbolically we represent it as a digit $k$ in the dummy column). It creates $n + m$ numbers with $m + 1$ digits each, so it takes polynomial time.

  #figure({
    set text(10pt)
    table(
      columns: (auto, 3.2em) + (2.2em,) * 4,
      align: center + horizon,
      stroke: none,
      inset: 4pt,
      table.vline(x: 1, stroke: 0.8pt),
      table.vline(x: 2, stroke: 0.5pt),
      [], $D$, $e_1$, $e_2$, $dots$, $e_m$,
      table.hline(stroke: 0.8pt),
      $a_1$, $1$, [1], [1], [], [],
      $a_2$, $1$, [1], [], [], [],
      $dots.v$, $dots.v$, [], [], [], [],
      $a_n$, $1$, [], [1], [], [],
      table.hline(stroke: 0.5pt),
      $b_1$, $0$, $1$, $0$, $dots$, $0$,
      $b_2$, $0$, $0$, $1$, $dots$, $0$,
      $dots.v$, $dots.v$, $dots.v$, $dots.v$, $dots.down$, $dots.v$,
      $b_m$, $0$, $0$, $0$, $dots$, $1$,
      table.hline(stroke: 0.8pt),
      $t$, $k$, $2$, $2$, $dots$, $2$,
    )},
    caption: [Constructing the list of numbers for the reduction #ss("VERTEX-COVER") $red$ #ss("SUBSET-SUM").],
    kind: image,
  ) <vc-ss-general>

  #let vc-table(rows, target, selected: ()) = {
    set text(9pt)
    let cols = ($D$, $e_1$, $e_2$, $e_3$, $e_4$)
    let n = rows.len()
    table(
      columns: (auto, auto) + (2em,) * 5,
      align: center + horizon,
      stroke: none,
      inset: 4pt,
      fill: (x, y) => if y >= 1 and y <= n and selected.contains(y - 1) {
        primary-color.lighten(70%)
      },
      table.vline(x: 3, stroke: 0.8pt),
      table.header([], [], ..cols, table.hline(y: 1)),
      ..rows.map(r => (r.at(0), $=$, ..r.at(1).map(v => [#if v == 1 { v }]))).flatten(),
      table.hline(y: 5, stroke: 0.5pt),
      table.hline(y: n + 1, stroke: 0.8pt),
      $t$, $=$, ..target.map(v => [#v]),
    )
  }

  #let vc-rows = (
    ($a_1$, (1, 1, 1, 0, 0)),
    ($a_2$, (1, 1, 0, 1, 0)),
    ($a_3$, (1, 0, 1, 1, 1)),
    ($a_4$, (1, 0, 0, 0, 1)),
    ($b_1$, (0, 1, 0, 0, 0)),
    ($b_2$, (0, 0, 1, 0, 0)),
    ($b_3$, (0, 0, 0, 1, 0)),
    ($b_4$, (0, 0, 0, 0, 1)),
  )

  #figure(
    grid(columns: 2, gutter: 3em, align: horizon, cetz.canvas(length: 1cm, {
      import cetz.draw: *

      let hi = primary-color.lighten(70%)
      let lo = white

      let v = ((0, 0), (1.5, 1.5), (3, 0), (4.5, 0))
      let cover = (0, 2)  // v1 and v3

      // edges e1..e4
      let edges = ((0, 1), (0, 2), (1, 2), (3, 2))
      for (a, b) in edges {
        line(v.at(a), v.at(b), stroke: 0.6pt)
      }

      // edge labels, offset from the midpoints
      content((0.55, 0.95), text(9pt, primary-color, $e_1$))
      content((1.5, -0.35), text(9pt, primary-color, $e_2$))
      content((2.45, 0.95), text(9pt, primary-color, $e_3$))
      content((3.75, -0.35), text(9pt, primary-color, $e_4$))

      // vertices
      for (i, p) in v.enumerate() {
        circle(p, radius: 0.3, fill: if cover.contains(i) { hi } else { lo }, stroke: 0.5pt)
        content(p, text(9pt, $v_#(i + 1)$))
      }
    }), vc-table(vc-rows, (2, 2, 2, 2, 2), selected: (0, 2, 4, 6, 7))),
    caption: [A graph $G$ with its vertex cover, and the corresponding instance of Subset-Sum. (Zeroes not shown for clarity.)],
    kind: image,
  ) <vc-ss-example>

  Now we need to show that $G$ has a vertex cover of size $k$ if and only if some subset of these numbers adds up to $t$.

  $[=>]$ Suppose $G$ has a vertex cover $C$ with $|C| = k$. Choose the numbers $a_i$ for all $v_i in C$. The dummy column has sum $k$, as required. Consider the column of an edge $e_j = (u, v)$. Since $C$ is a vertex cover, at least one of $u, v$ is in $C$, so the chosen vertex numbers contribute $1$ or $2$ to this column. If the sum is $2$, we are done. If it is $1$ (exactly one endpoint is in $C$), also choose the slack number $b_j$, which brings the column to exactly $2$. Therefore, our chosen set of numbers sums to the target $t$ in every column.

  $[arrow.l.double]$ Suppose there exists a subset of numbers which add up to $t$. First, notice that carrying can only matter in the dummy column. In each edge column the total sum of digits never exceeds $3$. The dummy column is the leading digit, so a carry out of it does not affect the others. So the dummy column adds up to $k$, and every edge column adds up to $2$ independently.

  Let $S$ be the set of vertices whose numbers were chosen. The dummy column says exactly that $|S| = k$. We claim $S$ is a vertex cover. Consider an edge $e_j$. Its column sums to $2$, and the slack number $b_j$ is the only non-vertex number that can contribute to it, adding at most $1$. So the chosen vertex numbers contribute at least $1$ to this column, which means that at least one endpoint of $e_j$ is in $S$. Since this holds for every edge, $S$ is a vertex cover of size $k$.

  This completes the reduction. #h(1fr) $qed$

]

8. Show that Subset Sum many-to-one reduces to Partition.

#soln-box[
  #ss("PARTITION"): Given a list of numbers $a_1, a_2, ..., a_n$, determine if there exists an equal partition: $S subset.eq {1, 2, ..., n}$ such that $sum_(i in S) a_i = sum_(i in.not S\ i in [n]) a_i$.

  #ss("SUBSET-SUM") $red$ #ss("PARTITION")

  Given a list of numbers $a_1, a_2, ..., a_n$ and a target $t$, we need to construct another list of numbers, such that
  #align(center)[There exists a subset of ${a_i}$ that sums to $t$, if and only if there exists an equipartition of the new list.]

  Let $A = sum_(i) a_i$. Assume $t <= A$. 
  
  
  To the list of numbers, just add two new numbers, namely $2 A - t$ and $A + t$. The sum of the new list of numbers is $4 A$.

  $[=>]$ We have $S subset.eq [n]$ such that $sum_(i in S) a_i = t$. Then, in the new list consider the subset $S$ along with the new number $2 A - t$. Sum of all these numbers is $t + 2 A - t = 2 A$, thus this is an equipartition of the new list of numbers.

  $[arrow.double.l]$ First note that the two newly added numbers can't be in the same side of the partition since $2 A - t + A + t = 3A > 2A$. Then they must be in different partitions. Consider the subset which includes $2A - t$. Since the entire subset adds up to $2A$, all other numbers in this subset (other than $2A - t$) must sum to $t$. Thus we have found our required subset.

]

9. Show that Vertex Cover many-to-one reduces to Hitting Set.

#soln-box[
  #ss("HITTING-SET"): Given sets $S_1, S_2, ..., S_m$ and a universe $U$ ($S_i subset.eq U$), a subset $T subset.eq U$, such that $T inter S_i != emptyset$ for all $i$, is called a *hitting set*. Does there exist a hitting set of size $k$?

  Given a graph $G = (V, E)$ and a parameter $k$, we need to create sets $S_1, S_2, ..., S_m$, $U$ and a parameter $k'$ such that
  #align(center)[
    $G$ has a vertex cover of size $k$ if and only if our instance has a hitting set of size $k'$.
  ]

  Take $k' = k$. Let $U = V$, and $m = |E|$. For each edge $e_i = (u_i, v_i)$, make the set $S_i = {u_i, v_i}$.

  $[=>]$ Let $C$ be a vertex cover of $G$ with $|C| = k$. Then $C$ is also a hitting set of size $k$ in our instance. This is because it 'hits' every set, as each set represents an edge, and each edge is covered by $C$, so at least one endpoint of the edge must be in $C$. (At least one element in $S_i$ must be in $C$.)

  $[arrow.double.l]$ Let $H$ be a hitting set. Then, for each $S_i = {u_i, v_i}$, one of $u_i$ or $v_i$ must be in $H$. Therefore, for each edge $e_i$, one of its endpoints is in $H$. Thus $H$ is a vertex cover.

]

10. Show that CNF-SAT many-to-one reduces to 3SAT.

#soln-box[Same as 3.]

11. Show that 3 Dimensional Matching many-to-one reduces to Set Cover.

#soln-box[
  #ss("3D-MATCHING"): Given disjoint sets $X$, $Y$ and $Z$, each of size $n$, and given a set $T subset.eq X times Y times Z$ of ordered triples, does there exist a set of $n$ triples in $T$ so that each element of $X union Y union Z$ is contained in exactly one of these triples?

  #ss("SET-COVER"): Given a set $U$ of $n$ elements, a collection $S_1, ..., S_m$ of subsets of $U$, and a number $k$, does there exist a collection of at most $k$ of these sets whose union is equal to all of $U$?

  Given an instance of 3D-matching, construct an instance of Set-Cover such that 
  #align(center)[
    There exists a perfect 3D-matching, if and only if there exists a set cover of size at most $k$.
  ]

  Let $U = X union Y union Z$, and for each triple $(u, v, w) in T$, define a set $S_i = {u, v, w}$. Let $k = n$.

  $[=>]$ Let $M$ be a perfect 3D matching, then pick the sets corresponding to each triple in $M$. This collection of sets covers every element in $U$ (by definition of 3D matching).

  $[arrow.double.l]$ Let $C$ be a set cover of size at most $n$. Since it covers $3n$ elements, its size must be exactly $n$. Define $M$ as the set of triples corresponding to each set in $C$. Since $C$ covers $U$, every element of $X union Y union Z$ is contained in at least one triple. Also each triple must be disjoint since otherwise $3n$ elements can't be covered by $n$ triples. So $M$ is a perfect 3D matching.
]

12. Show that Clique many-to-one reduces to Vertex Cover.

#soln-box[
  Given in notes.
]

13. Prove that the Traveling Salesman problem is NP-complete.

#soln-box[
  #ss("TSP"): Given a set of distances on $n$ cities, and a bound $k$, is there a tour of length at most $k$?

  #ss("TSP") is in NP, since we can use a tour itself as the witness. The verifier checks if the total cost of the tour is at most $k$ and the tour visits every city.

  #ss("HAMCYCLE") $red$ #ss("TSP"): See CLRS Theorem 34.14 (p1096) or KT Theorem 8.18 (p479).
]

14. Show that 3SAT many-to-one reduces to 3-Colorability of graphs.

#soln-box[
  See KT Theorem 8.22 (p487), or CLRS Problem 34-3 (p1103).
]

15. Show that Subset Sum many-to-one reduces to Knapsack.

#soln-box[
  (Rough sketch) We can create a knapsack instance by taking same weight and value of each item, $w_i = v_i = a_i$, capacity $W = t$, and target value $V = t$. A subset of items with total value $>= V$ and total weight $<= W$ is just a subset with sum $t$.
]

16. Show that Subset Sum many-to-one reduces to Partition.

#soln-box[Same as 8.]

17. Show that Hamiltonian Cycle many-to-one reduces to Hamiltonian Path.

#soln-box[
  Here we consider the undirected versions of the problems.

  (Rough sketch) We make the following changes in the graph $G$. Choose any vertex $v$, duplicate it to $v'$. Add the same edges as $v$ to $v'$. Add two new vertices $s$ and $t$, add edges $(s, v)$ and $(v', t)$. Cutting a Hamiltonian cycle of $G$ at $v$ and adding $s$ and $t$ at the ends gives us a Hamiltonian Path in $G'$. Conversely, a Hamiltonian path in $G'$ must start at $s$ and end at $t$, so it goes from $v$ to $v'$ which can be closed into a Hamiltonian cycle in $G$. 
]

18. Show that Hamiltonian Path many-to-one reduces to Hamiltonian Cycle.

#soln-box[
  (Rough sketch) Simply add a new vertex $p$ and add edges from $p$ to all other vertices in $G$. A Hamiltonian path $chevron.l v_1, ..., v_k chevron.r$ can be extended with $p$ to get a Hamiltonian cycle in $G'$. Similarly, removing $p$ from a Hamiltonian cycle in $G'$ gives a Hamiltonian path in $G$.

]

19. Show that Subgraph Isomorphism is NP-complete.

#soln-box[
  #ss("SUBGRAPH-ISO"): Given two graphs $G$ and $H$, does there exist a subgraph $S$ of $G$ such that $S$ and $H$ are isomorphic?

  This is in NP by taking the subgraph and the vertex bijection as a witness.

  This problem is just a generalisation of #ss("CLIQUE"), in particular, #ss("CLIQUE") is a special case of #ss("SUBGRAPH-ISO"), where $H$ is a complete graph of size $k$.

  #ss("CLIQUE") $red$ #ss("SUBGRAPH-ISO")

  Given a graph $G$ and a parameter $k$, we need to give graphs $G'$ and $H$ such that
  #align(center)[
    $G$ has a clique of size $k$ if and only if some subgraph of $G'$ is isomorphic to $H$.
  ]

  Simply take $G' = G$ and $H = K_k$ where $K_k$ denotes the complete graph with $k$ vertices. It is obvious that $G$ has a clique of size $k$ if and only if some $k$-sized subgraph of $G$ is a complete graph (by definition of a clique).
]

20. Show that dominating set is NP-complete.

#soln-box[
  #ss("DOMINATING-SET"): Does there exist a dominating set of size $k$ in a graph $G$?

  In a graph $G = (V, E)$, a set $S subset.eq V$ is called a *dominating set* if every vertex $v in V$ is either in $S$ or adjacent to some vertex in $S$.

  #ss("VERTEX-COVER") $red$ #ss("DOMINATING-SET")


  Given $G$ and $k$, construct $G'$ and $k'$ such that
  #align(center)[
    $G$ has a vertex cover of size $k$ if and only if $G'$ has a dominating set of size $k'$.
  ]
  Take $k' = k$.
  
  (WLOG, assume the graph $G$ doesn't have any isolated vertices.)

  To construct $G'$, for each edge $(u, v)$  in $G$, add a vertex $w_(u v)$, and add edges $(u, w_(u v))$ and $(v, w_(u v))$. Keep all other vertices and edges intact.

  $[=>]$ Let $S$ be a vertex cover of $G$. Then $S$ is a dominating set of $G'$. This is because for every original edge $(u, v)$, one of $u$ or $v$ must have been chosen in $S$. This vertex covers all three vertices $u$, $v$ and $w_(u v)$. Since there are no isolated vertices, we have covered all vertices so this is a dominating set.

  $[arrow.double.l]$ Let $S$ be a dominating set of $G'$. First, WLOG we can assume $S$ does not contain any newly added vertices. If it does contain some $w_(u v)$, we can replace it with $u$ or $v$, or if both $u$ and $v$ are already in $S$, just remove $w_(u v)$. By doing so, $S$ still remains a dominating set. 
  
  Then, we claim that $S$ is a vertex cover. Suppose it doesn't cover some edge $(u, v)$, that means both $u$ and $v$ are not in this dominating set. Then, $w_(u v)$ is not in the dominating set, nor adjacent to any vertex in it, which is a contradiction.

]

21. Prove the following problems to be NP-complete: Hamiltonian Cycle, 3-Dimensional Matching, 3-Colorability of graphs.

#soln-box[
  *Hamiltonian Cycle*: #ss("VERTEX-COVER") $red$ #ss("HAMCYCLE"): given in notes.

  *3D Matching*: #ss("3SAT") $red$ #ss("3D-MATCHING"): KT book, Theorem 8.20 (p482)

  *3-Colorability*: Same as 14.
]

