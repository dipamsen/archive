#import "template.typ": project
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz:0.5.0"

#counter("example").update(1)

#show figure.caption.where(body: []): it => it.supplement + [ ] + context it.counter.display()


#let alg(body, title: "") = {
// show figure: set align(left)
figure(body, kind: "algorithm", supplement: [Pseudocode], caption: if title == "" [] else [#title])
}

#show: project.with(
title: "Programming Paradigms for Computation",
// author: "Dipam Sen",
// date: "15 December 2024",
abstract: [
  
]
)

= Solving some Problems


== Eg 1: Finding the largest number from $n$ distinct integers.

#let f2 = figure({
let nums = (4, 5, 8, 1, 6, 3, 2, 7)

let levels = (
  nums,
  (5, 8, 6, 7),
  (8, 7),
  (8,)
)

diagram(
  ..for (l, numbers) in levels.enumerate() {
    let size = numbers.len()
    for i in range(size) {
      let val = numbers.at(i)
      let pair = if calc.even(i) { calc.floor(i/2) * 2 + 1 } else {
         calc.floor(i/2) * 2
      }
      let lost = if calc.even(numbers.len()) { val < numbers.at(pair) } else { false }
      (
        if l > 0 { 
          edge(
            (8/size * i + 8/size/4, (l - 1) * 0.5),
            (8/size * i + 8/size/2, l * 0.5)
          )
        },
        if l > 0 {
          edge(
            (8/size * i + 3*8/size/4, (l - 1) * 0.5),
            (8/size * i + 8/size/2, l * 0.5)
          )
        },
        node(
          (i* 8/size + 4/size, l * 0.5), 
          stroke: if size == 1 { 1pt },
          fill: if size == 1 { none } else if lost { red.lighten(50%) } else { green.lighten(50%) },
          // shape: if size == nums.len() { rect },
          if lost { $cancel(#[#val])$ } else { $#val$ }
          // $#val$
        ),
      )
    }
  },
)
}, caption: [Pairwise comparisons])


+ #[
*Find maximum of $n$ elements.*

#alg(````js
maximum(A, n) {
  max = A[1]
  for i = 2 to n:
    if max < A[i]:
      max = A[i]
  return max
}
````)

=== Correctness Proof

To prove the algorithm's correctness, we need to establish the _invariants_ in our algorithm.

1. If $n = 1$, our algorithm never goes into the `for` loop, and (correctly) returns `A[1]`.
2. Inside an iteration of the loop, before the `if` block, `max` stores the value of the maximum of previously processed $i - 1$ elements.
3. After the `if` block, `max` stores the value of the maximum of the $i$ elements processed.

This can be proved by a simple inductive setup:

Assume that at the $k$th iteration of the loop, max holds the maximum value of the elements $A[1], A[2], ..., A[k]$.

During the $(k+1)$th iteration, the algorithm compares `max` with $A[k+1]$:

- If `max < A[k+1]`, then `max` gets updated to `A[k+1]`, which is indeed the maximum of $A[1], A[2], ..., A[k+1]$.
- Otherwise, `max` remains unchanged, still retaining the maximum value in $A[1], A[2], ..., A[k+1]$.

Thus, the loop invariant is maintained.

=== Algorithm Efficiency

The algorithm makes $n-1$ comparisons, and in the worst case $(n-1) + 1 = n$ assignments to `max`.

Let us use the number of comparisons as a way to gauge the time complexity of an algorithm.

Can we show that $n-1$ comparisons is the most optimal in solving this problem?

Notice that each comparison eliminates one candidate for being the maximum. To reduce $n$ candidates to 1 maximum, we need exactly $n -1$ comparisons. So, it is the lower bound for comparisons for an algorithm.

Example: Let the array be $[4, 5, 8, 1, 6, 3, 2, 7]$.

Comparisons in Algorithm 1 can be shown by the following tree diagram.

#figure({
let nums = (4, 5, 8, 1, 6, 3, 2, 7)

let pos(n) = {
  (0.8 * (n), 0.5 + calc.log(n))
}
let lost = (true, false, false, true, true, true, true, true)
let lost2 = (true, false, false, false, false, false)

diagram(
  ..nums.enumerate().map(((i, n)) => node(
    (i, 0), 
    // stroke: 1pt,
    // shape: fletcher.shapes.rect,
    fill: if lost.at(i) { red.lighten(50%) } else { green.lighten(50%) },
    if lost.at(i) {
      $cancel(#[#n])$
    } else {
      $#n$
    }
  )),
  ..nums.enumerate().slice(1).map(
    ((i, n)) => node(
      pos(i), 
      stroke: if i == nums.len() - 1 { 1pt },
      fill: if i == nums.len() - 1 { none } else if lost2.at(i - 1) { red.lighten(50%) } else { green.lighten(50%) },
      if lost2.at(i - 1, default: false) {
        $cancel(#[#calc.max(..nums.slice(0, i+1))])$        
      } else { 
        $#calc.max(..nums.slice(0, i+1))$
      }
    )
  ),
  ..nums.enumerate().slice(0, -1).map(((i, n)) => {
    edge(if i > 0 { pos(i) } else { (0, 0) }, pos(i+1))
  }),
  ..nums.enumerate().slice(0, -1).map(((i, n)) => {
    edge((i + 1, 0), pos(i+1))
  })
)
}, caption: [Sequential comparisons])

There are other ways to find the maximum, such as by doing the comparison in pairs.

#f2

In any such elimination-style algorithm, we will need $n - 1$ comparisons to find the maximum.

]

+ #[
*Find the largest and smallest number of $n$ elements*.

We can have the same algorithm, which also calculates the minimum along the way: 

#alg(````js
maxmin(A, n) {
  max = A[1]
  min = A[1]
  for i = 2 to n:
    if max < A[i]:  max = A[i]
    if min > A[i]:  min = A[i]
  return max, min
}
````)

and its correctness can be proved by a similar setup.

Algorithm 2 takes $2(n-1)$ comparisons to find the maximum and minimum values, essentially solving both the problems separately ($n-1$ comparisons for each). Can we do any better?

We can use the calculations we are doing for finding the maximum to our advantage. In particular, we can observe that the smallest number will be out of the ones which has been eliminated in the first round while finding the maximum!

What this means is instead of finding the minimum of $n$ elements, we now need to find minimum of $m$ elements, where $m$ is the number of elements which got eliminated in the first round. Then, the total number of comparisons for this algorithm would be $n - 1 + m - 1$.

Clearly, we want to find minimum possible value for $m$. How can we minimize the number of elements that get eliminated in the first round? Equivalently, we need to minimize the number of comparisons happening in the first round.

Clearly, this is possible if we pair up the elements and have $n/2$ comparisons in the first round, as shown in Figure 2. By doing so, only half of the elements (that got eliminated in the first round) are the ones which have to be checked to find the minimum.

So, the optimal number of comparisons is $n - 1 + n \/ 2 - 1 = 3n\/2 - 1$.
]

+ #[*Find the largest, and second largest element of $n$ elements*.

Continuing like previously, we need to limit the search space for finding the second largest element, to find a more efficient algorithm that $2(n-1)$ comparisons.

The key observation here is that the second largest element will be present in the set of elements which lost to the winner (maximum element) during the eliminations!

Here's the justification: Let the largest element be $a_k$ and the second largest element be $a_l$.
- Clearly, $a_l$ has been eliminated at least once (otherwise, it would have been the winner).
- The only matchup to which $a_l$ loses is against $a_k$ itself. So it is necessary that there was one comparison between $a_l$ and $a_k$, in which $a_l$ got eliminated.

Now, we know that the second largest element is present in the set of elements that get eliminated against the maximum element. To minimize the size of this set, we want to minimize the height of the decision tree, which once again occurs when we do binary tree-style pairings.

#f2

The number of elements that face up against the maximum element in the tournament is $log_2 n$.

Thus, the most optimal algorithm has $n - 1 + log_2(n) - 1 = n + log_2(n) - 2$ comparisons, to find both the largest and the second largest element.
]

The above method can be extended to sort any array. In particular, we can find the #box[$k$#super[th]] largest element in at most $log_2 n$ comparisons, so the array can be sorted in $n log_2 n$ comparisons.

Heap sort is such an algorithm.
#let draw-heap(nums, style: (idx) => none, edges: ()) = figure({
  let create-tree-nodes(idx, x, depth) = {
    let nodes = ()
    if idx * 2 <= nums.len() {
      nodes = (..nodes, ..create-tree-nodes(idx * 2, x - 1.6/depth, depth + 1), edge((x, depth), (x - 2/depth, depth + 1)), if edges.contains(idx * 2) {
        edge((x, depth), (x - 2/depth, depth + 1), bend: 20deg, "->", stroke: (dash: "dotted"), shift: 2pt)
        edge((x - 2/depth, depth + 1), (x, depth), bend: 20deg, "->", stroke: (dash: "dotted"), shift: 2pt)
      })
    }
    nodes.push(node((x, depth), $nums.at(#(idx - 1))$, stroke: 1pt, ..style(idx)))
    if idx * 2 + 1 <= nums.len() {
      nodes = (..nodes, ..create-tree-nodes(idx * 2 + 1, x+2/depth, depth + 1), edge((x, depth), (x + 2/depth, depth + 1)), if edges.contains(idx * 2+1) {
        edge((x, depth), (x + 2/depth, depth + 1), bend: 20deg, "->", stroke: (dash: "dotted"), shift: 2pt)
        edge((x + 2/depth, depth + 1), (x, depth), bend: 20deg, "->", stroke: (dash: "dotted"), shift: 2pt)
      })
    }
    return nodes
  }
  
  diagram(
    spacing: 0.5cm,
    ..create-tree-nodes(1, 0, 1)
  )
})

- Array representation of binary tree is done by taking $a_1$ as the root node, and $a_(2n)$ and $a_(2n+1)$ as left and right child nodes of $a_n$.
- A complete binary tree is one which has all its nodes filled except the last level, where elements must be filled from left to right.
- A max (min) heap is a complete binary tree such that value of every node is greater (smaller) than all its descendants.
- #[Inserting into a max heap:
- Add the element as a leaf node.
- Continually move the element up if it is greater than its parent.

#figure(grid(
  columns: (1fr, 1fr), 
  draw-heap((50, 30, 45, 10, 15, 16, 8, 40), style: idx => {
    if idx == 8 {
      arguments(stroke: (dash: "dashed"), fill: green.lighten(50%))
    }
  }, edges: (8, 4)), 
  draw-heap((50, 40, 45, 30, 15, 16, 8, 10), style: idx => {
    if idx == 2 { arguments(fill: green.lighten(50%), stroke: none) }
    if idx == 4 or idx == 8 { arguments(fill: blue.lighten(70%), stroke: none) }
  })
), caption: [Insertion into a max heap])
Requires $floor(log_2(n+1))$ operations in the worst case.
]

- #[Deleting the maximum element from a max heap: 
- Remove the element and replace with a leaf node
- Continually move the element down if it is smaller than its child (choose the larger child)
#figure(grid(
  columns: (1fr, 1fr), 
  draw-heap((10, 40, 45, 30, 15, 16, 8, 10), style: idx => {
    if idx == 1 { arguments(fill: yellow.lighten(50%), stroke: none, shape: circle)}
    if idx == 8 { arguments(stroke: (dash: "dashed")) }
  }, edges: (3, 6)), 
  draw-heap((45, 40, 16, 30, 15, 10, 8), style: idx => {
    if idx == 1 or idx == 3 or idx == 6 { arguments(fill: blue.lighten(70%), stroke: none) }
  })
), caption: [Removal of max element from a max heap])
Requires $floor(log_2(n-1))$ operations in the worst case.
]

By repeatedly removing the max element, we can sort the array in $n log n$ time complexity.

== Eg 2: *Find $F(n)$ for $n>2$, if $F(n) = F(n-1) +F(n-2)$, $F(0) = 0$, $F(1) = 1$*.

The Fibonacci series can be generated by an algorithm. Due to its recursive definition, we can define it recursively, as follows:

#alg[
  ````
  fib(n) {
    if n <= 1: return n
    return fib(n-1) + fib(n-2)
  }
  ````
]

However, the issue with this algorithm is that it does a lot of redundant computations.

#figure({
  let n = 5
  let tree(n, offset: (0, 0), level: 1) = {
    if n <= 1 {
      return (node(offset,$F(#n)$),)
    }
    return (
      node(offset, $F(#n)$),
      edge(),
      ..tree(
        n - 2, 
        offset: (offset.at(0) + 2/calc.pow(2, level), offset.at(1) + 0.5), 
        level: level + 1
      ),
      edge(offset, (offset.at(0) - 2/calc.pow(2, level), offset.at(1) + 0.5)),
      ..tree(
        n - 1,
        offset: (offset.at(0) - 2/calc.pow(2, level), offset.at(1) + 0.5), 
        level: level + 1
      ),
    )
  }
  diagram(
    spacing: 10mm,
    // debug: true,
    node((0, 0), $F(#n)$),
    edge((2, 0.5)),
    edge((-2, 0.5)),
    ..tree(n - 2, offset: (2, 0.5), level: 1),
    ..tree(n - 1, offset: (-2, 0.5), level: 1),
    render: (grid, nodes, edges, options) => {
      import fletcher: cetz
      cetz.canvas({
        fletcher.draw-diagram(grid, nodes, edges, debug: options.debug)
        import cetz.draw: *

        rect((0.5, 0), (4.5, 2.4), stroke: none, fill: blue.transparentize(80%))
        rect((10, 0.8), (17, 3.3), stroke: none, fill: blue.transparentize(80%))
      })
    }
  )
}, caption: [Recursive implementation of Fibonacci Series])

As we can see, many of the calculations are computed more than once, for instance, we are having to calculate $F(3)$ twice in the recursion to find $F(5)$.

How many addition operations do we perform? That is given by the following recurrence relation:

$
T_n &= 1 + T_(n-1) + T_(n-2)\
T_0 &= T_1 = 0\
=> T_n &= F(n) - 1
$

To remove the redundancies we can use an iterative solution, which does not branch out recursively, preventing this issue.

#alg[
  ````
  fib(n) {
    if n <= 1: return n
    a, b = 0, 1
    for i = 2 to n {
       a, b = b, a + b
    }
    return b
  }
  ````
]

This has a linear complexity, as only $n - 2$ additions take place.

However, not all such problems have a nice iterative solution. Consider:

$
R(n) = cases(R(2n + 2) + R(n/2) quad &"if" n "is odd", R(n/3 - 4) + R(n/10  -12) quad &"if" n "is even", 1 &"if "n<=0, 10 &"if" n>=10^8)
$

To solve this iteratively would mean to find the values of $R(k)$ for all $k = 1, 2, ..., n$, which doesn't seem to be a great idea.

How can we solve the problem of redundant computations in the recursive solution? The answer is to _remember past solutions_.

#alg(title: "Memoization")[
  ````
  results = []
  R(n) {
    if n <= 0:     return 0
    if n >= 1e8:   return 10
    if results[n]: return results[n]
    if n % 2 == 1 {
      ans = R(2*n + 2) + R(n/2)
    } else {
      ans = R(n/3 - 4) + R(n/10 - 12)
    }
    results[n] = ans
    return ans
  }
  ````
]

This ensures we do not compute the value of $R$ at the same $n$ twice. This technique is usually termed as *Dynamic Programming*.

There is one final issue, which is that there may be cyclic dependencies in the definition of $R$. That is, it is possible that the following happens:

#figure({
  let edge = edge.with("->")
  diagram(
    spacing: 15pt,
    node((0, 0), $R(12)$),
    edge(),
    node((1, 1), $R(42)$),
    edge(),
    node((0, 2), $R(54)$),
    edge(),
    node((-1, 1), $R(23)$),
    edge((0, 0))
  )
}, caption: [Cyclic Dependency])

To detect such a cyclic dependencies, we need to store some more information, for each $n$, which of the following state we are in:
+ never encountered
+ encountered and entered into recursion
+ encountered and computed (value is available)
Now, at the beginning of $R(n)$ we can check which state we are in, and if we are in state (b), we can report a cyclic dependency.


== Eg 3: *Multiply two $n$-bit binary numbers.*

// #{
//   set text(1.2em)
//   cetz.canvas({
//     import cetz.draw: *
//     content((0, 0), $1010$)
//     content((0, -1em), $1101$, name: "b")
//     content((rel: (-5mm, 0), to: "b.west"), $times$, name: "op")
//     line((to: "op.south", rel: (-2mm, -1mm)), (rel: (1.8cm, 0)))
//   })
// }
#figure({
  set text(1.2em)
  grid(
    columns: 8,
    align: right,
    inset: 1mm,
    [], [], [], [], .."1010".clusters().map(it => $it$),
    grid.cell(colspan: 2, align: left)[$times$], [], [], .."1101".clusters().map(it => $it$),
    grid.hline(),
    [], [], [], [], .."1010".clusters().map(it => $it$),
    [], [], [], .."0000".clusters().map(it => $it$), [],
    [], [], .."1010".clusters().map(it => $it$), [], [],
    [], .."1010".clusters().map(it => $it$), [], [], [],
    grid.hline(),
    .."10000010".clusters().map(it => $it$)
  )
}, caption: [Long Multiplication for $n$-bit binary numbers])

The above is naive multiplication, which has a time complexity of $O(n^2)$. It can be implemented by shifting and adding binary numbers appropriately.

#pagebreak()

= Count number of occurences of substring in given string

Given two strings P and Q, find number of occurences of Q in P including overlaps.

The naive solution uses a total of $m(n-m+1)$ character comparisons in the worst case.

#set enum(numbering: "1.")
== KMP (Knuth-Morris-Pratt) Algorithm

#let prefix(str) = {
  for i in range(str.len()) {
    let count = 0
    for j in range(1, i + 1) {
      if (str.slice(0, j) == str.slice(i - j + 1, i + 1)) { count = j }
    }
    (count,)
  }
}

#let draw-prefix(str, sz: 1.4em, ..args) = cetz.canvas({
  import cetz.draw: *
  let lps = prefix(str)
  for i in range(str.len()) {
    rect((i, 0), (i+1, 1))
    content((i + 0.5, 0.5), [#set text(sz);#str.at(i, default: "")])
    content((i + 0.5, -0.3), [#lps.at(i, default: "")])
  }
}, ..args)

1. Define $pi(s)$ (prefix function / longest prefix-suffix) where $pi[i]$ = longest proper prefix of $s[class("normal",:)i]$ which is also a suffix.
   #figure(draw-prefix("abcabdabcd"), caption: [Prefix array])
   #figure(draw-prefix("aaaaaaa"))

2. Consider the string Q\#P. Find its prefix function.

   #figure(draw-prefix("py#python", length: 0.8cm, sz: 1.2em))
   #figure(draw-prefix("abab#abcdababab", length: 0.8cm, sz: 1.2em))

   Observe, that the number of occurences of $m$ (length of $Q$) in the prefix array in the last $n$ positions, gives the number of occurences of the substring $Q$ in $P$. If we can compute $pi(s)$ in $O(n)$, then this problem can be solved in $O(m + n)$.

Alternatively, compute $pi(Q)$. Iterate over P and Q using 2 pointers, incrementing $i$ and moving $j$ to $pi[j]$ if they don't match, and incrementing both if they do.

   
=== Computing $pi(s)$

1. Set $pi[0] = 0$.
2. For some $i > 0$, set $j = pi[i-1]$. 
3. Check whether $s[i] = s[j]$. If so, set $pi[i] = j + 1$, continue for next $i$. Otherwise, set $j =pi[j-1]$ and repeat.
4. If $j = 0$, set $pi[i] = 0$.

```py
def prefix(s):
  pi = [0] * len(s)
  for i in range(1, len(s)):
    j = pi[i-1]
    while j > 0 and s[i] != s[j]: j = pi[j-1]
    if s[i] == s[j]: j += 1
    pi[i] = j
  return pi
```


#pagebreak()

= Proofs

+ #[
  *Insertion sort can be suitably developed to work in $O(n log n)$ time*.

  What is insertion sort?
]

+ #[
  No.


  Counter example:

  $
  S_1 = \""pqarbsct"\"\
  S_2 = \""abcpqrst"\"\
  S_3 = \""lmnopabc"\"\
  $

  Here, $"LCS"(S_1, S_2) = \""pqrst"\"$ and $"LCS"(\""pqrst"\", S_3) = \""p"\"$ which is not $"LCS"(S_1, S_2, S_3) = \""abc"\"$
]