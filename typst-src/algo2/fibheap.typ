#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/cetz:0.5.2"


#show: project.with(
  subject: "Algorithms II",
  topic: "Fibonacci Heap"
)

#let op(x) = smallcaps[#x]



#title[Fibonacci Heap]

/**

fibheap ka jis flow me padhaya tha kya ye sahi hai
* heap -> insert, extract min, decrease key, all log n operations, reqd for dijkstra/prims, n and m
* we wish to make decrease key fast
* binomial heap: store as many binomial min-trees + min pointer, merge as needed, insert is amortized constant, analogous to binary counter. decrease key works like normal bubbling up, o(height) = o(lg n). extract min works by removing the min node, freeing its children, and 'meld'ing the two heaps, o(lg n)
* to make decrease key fast, let us say we won't bubble up  but instead break the tree at that point. But, the issue is 

*/

#let insert = op("Insert")
#let extract-min = op("Extract-Min")
#let decrease-key = op("Decrease-Key")

A priority queue is an abstract data type, which supports the following operations:

- $insert(H, x)$: insert the key $x$ to the heap
- $#extract-min;(H)$: remove the minimum-key element from the heap and return it
- $#decrease-key;(H, x, k)$: update the key of the element $x$ to $k$, which is assumed to be no greater than the original key value.

Such a data structure is useful in many algorithms, most notably in Dijkstra's algorithm for finding Single Source Shortest Paths on a directed graph, as well as in Prim's algorithm for finding the Minimum Spanning Tree of a graph. In both of these algorithms, assuming we have a graph with $n$ nodes and $m$ edges, we make a total of $n$ #extract-min operations, and $m$ #decrease-key operations.

Usually, we implement a priority queue using a Binary Heap, which is a simple data structure, which can be implemented by an array. It supports all three operations in worst case $O(log n)$ time.

A Fibonacci Heap is a data structure which implements the priority queue operations with better amortized costs. In particular, it supports $O(1)$ #insert, $O(1)$ #decrease-key and $O(log n)$ #extract-min operations (amortized). Theoretically, this provides an asymptotic improvement to the running times of Dijkstra's and Prim's algorithms (as compared to using a binary heap) from $O(n log m + m log n)$ to $O(n log m + m)$. (This is a strict improvement when $m in.not O(n)$, i.e. the graph is dense.) Let us try to build up this data structure from the ground up.

= Binomial Heaps

Let us consider an intermediate data structure called a binomial heap, and try to implement a priority queue using it.

A *Binomial Tree* of order $k$, $B_k$, is defined recursively:
- $B_0$ is a tree with a single node.
- $B_k$ is defined as two $B_(k - 1)$ trees joined such that the root of one is the leftmost child of the root of the other.

#let node-radius = 0.2
#let level-height = 0.9
#let unit = 0.8

#let draw-binomial-tree(k, x, y) = {
  import cetz.draw: *
  let child-orders = range(k - 1, -1, step: -1)
  let weights = child-orders.map(x => if x == 0 { 1 } else { calc.pow(2, x - 1) })
  let total-weight = calc.pow(2, k - 1)
  let total-span = total-weight * unit
  let start-x = x - total-span

  let cursor = start-x
  for (i, order) in child-orders.enumerate() {
    let w = weights.at(i) * unit
    let child-x = cursor + w
    let child-y = y - level-height

    line((x, y), (child-x, child-y))

    draw-binomial-tree(order, child-x, child-y)

    cursor += w
  }
  circle((x, y), radius: node-radius, fill: luma(120), stroke: black, z-index: 2)
}

#let bt(o) = cetz.canvas({
  import cetz.draw: *
  draw-binomial-tree(o, 0, 0)
})

#let b0 = bt(0)
#let b1 = bt(1)
#let b2 = bt(2)
#let b3 = bt(3)
#let b4 = bt(4)

#figure(caption: "Binomial trees of orders 0 through 4", grid(
  columns: 5,
  column-gutter: 2.5em,
  b0, b1, b2, b3, b4,
  $B_0$, $B_1$, $B_2$, $B_3$, $B_4$,
  [#v(1em)]
))

These trees have some special properties which we can prove easily by induction: 

1. In the tree $B_k$, there are exactly $2^k$ nodes.
2. The height of tree $B_k$ is $k$.
3. There are exactly $binom(k, i)$ nodes at depth $i$, $i = 0, 1, 2,...$.
4. The order of the tree $k$ is the degree of the root element, i.e. the root node of $B_k$ has $k$ children.
5. Each child of the root is itself a binomial tree. In particular, the $i$ th child (from the right; as drawn in the figures, $i = 0, 1, 2, ..., k - 1$) is $B_i$.
6. By extension, subtree of any node in a binomial tree is itself a binomial tree.


#figure(cetz.canvas({
  import cetz.draw: *
  rect((-6, -0.5), (-2.8, -4), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%), name: "b3")
  rect((-2.7, -0.5), (-1.2, -3.2), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%), name: "b2")
  rect((-1.1, -0.5), (-0.4, -2.3), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%), name: "b1")
  rect((-0.3, -0.5), (0.3, -1.3), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%), name: "b0")
  draw-binomial-tree(4, 0, 0)

  content("b3.south", v(2em) + $B_3$)
  content("b2.south", v(2em) + $B_2$)
  content("b1.south", v(2em) + $B_1$)
  content("b0.south", v(2em) + $B_0$)

}), caption: [The children of $B_4$ are themselves binomial trees, $B_0$, $B_1$, $B_2$ and $B_3$ from right to left.])



A *Binomial Heap* $H$ is a set of binomial trees with the following properties:
1. Each node has a key.
2. Each binomial tree follows the min-heap property.
3. There may be at most one binomial tree of order $k$, for all $k = 0, 1, 2, ...$.

Observe, that this definition leads to a unique structural representation for a binary heap containing $n$ elements. Since each $B_i$ contains $2^i$ nodes, and each $B_i$ can occur at most once, there is a unique set of $B_i$s that need to be chosen to get exactly $n$ nodes. In particular, this corresponds to the unique binary representation of $n$:

$
n = sum_(i = 0)^oo b_i 2^i
$

The set of binomial trees that we use exactly correspond to $i$s such that $b_i = 1$, i.e. the positions of the one bits in the binary representation of $n$.



#let draw-binomial-tree(k, x, y, elts, dot: false, hl: -1) = {
  import cetz.draw: *
  let child-orders = range(k - 1, -1, step: -1)
  let weights = child-orders.map(x => if x == 0 { 1 } else { calc.pow(2, x - 1) })
  let total-weight = calc.pow(2, k - 1)
  let total-span = total-weight * unit
  let start-x = x - total-span/2

  let cursor = start-x
  let ptr = 1
  for (i, order) in child-orders.enumerate() {
    let w = weights.at(i) * unit
    let child-x = cursor + w/2
    let child-y = y - level-height

    line((x, y), (child-x, child-y), stroke: (dash: if dot { "dotted" }))

    draw-binomial-tree(order, child-x, child-y, elts.slice(ptr, ptr + calc.pow(2, order)), hl: hl)
    ptr = ptr + calc.pow(2, order)
    cursor += w
  }
  circle((x, y), radius: 0.3, stroke: (dash: if dot { "dotted" }, paint: black), fill: if hl == elts.first() { yellow } else {white})
  content((x, y), $elts.at(#0)$)
}

#figure(cetz.canvas({
  import cetz.draw: *
  line((0, 0), (3, 0))
  line((3, 0), (5, 0))
  
  draw-binomial-tree(3, 0, 0, (5, 11, 17, 33, 21, 38, 45, 50))
  draw-binomial-tree(1, 3, 0, (8, 27))
  draw-binomial-tree(0, 5, 0, (14,))
}), caption: [A binomial heap with $n = 11$ nodes, represented by a set of binomial trees $B_3, B_1$ and $B_0$])

We can thus claim, that a binomial heap having $n$ nodes can have at most $floor(lg n) + 1 = O(log n)$ binomial trees.  

Let us try to implement the three operations on our binomial heap data structure.

#let merge = op("Link")
#let meld = op("Meld")

== #insert
#[

  We need to add a new element to the binomial heap. Let us consider, we add it as a single node ($B_0$) to the root list. Now, if there was no other order 0 tree in the heap before this insertion, then we are done, the resulting structure is still a binomial heap.

  Otherwise, we are violating the unique order constraint on the trees. Since we have 2 trees of the same order, we can _link_ them; which is a constant time operation:

  #algorithm("Link", params: ([$T_1$, $T_2$],))[
    #aline[check that $"order"(T_1) = "order"(T_2)$]
    #aline[#If $T_1.var("root") < T_2.var("root")$]
    #aline(indent: 1)[add $T_2$ as the leftmost child of $T_1$]
    #aline(indent: 1)[remove $T_2$ from the root list]
    #aline[#Else]
    #aline(indent: 1)[add $T_1$ as the leftmost child of $T_2$]
    #aline(indent: 1)[remove $T_1$ from the root list]
  ]

  We need to continue merging trees of same degree until all our trees have unique degrees.

  #figure(cetz.canvas({
    import cetz.draw: *
    line((0, 0), (3, 0))
    line((3, 0), (5, 0))
    line((5, 0), (7, 0), stroke: (dash: "dotted"))
    
    draw-binomial-tree(3, 0, 0, (5, 11, 17, 33, 21, 38, 45, 50))
    draw-binomial-tree(1, 3, 0, (8, 27))
    draw-binomial-tree(0, 5, 0, (14,))
    draw-binomial-tree(0, 7, 0, (3,))

    translate((1, -4))
    
    line((0, 0), (3, 0))
    line((3, 0), (5, 0), stroke: (dash: "dotted"))
    
    draw-binomial-tree(3, 0, 0, (5, 11, 17, 33, 21, 38, 45, 50))
    draw-binomial-tree(1, 3, 0, (8, 27))
    draw-binomial-tree(1, 5, 0, (3, 14))

    translate((1, -4))
    
    line((0, 0), (3, 0))
    
    draw-binomial-tree(3, 0, 0, (5, 11, 17, 33, 21, 38, 45, 50))
    draw-binomial-tree(2, 3, 0, (3, 8, 27, 14))

    
  }), caption: [Insertion of a new node $3$ to the binomial heap. The resulting heap is of size $n = 12$.])


  Observe that in the worst case, inserting into a $n$-size binomial heap will take $log n$ #merge operations, so the worst case time complexity of #insert is $O(log n)$.

  Notice, that this operation is actually analogous to incrementing a binary counter. Since a binomial heap of $n$ elements is represented by trees corresponding to the set bits in the binary representation of $n$, and after the insertion there are $n + 1$ nodes, the #merge operations being carried out correspond one-to-one to the resetting of trailing ones in a  binary counter to zeroes while incrementing. This is another justification of the worst case cost of this operation being $O(log n)$.

  We can actually extend the analogy for computing the amortized cost for this operation. Recall, that we can show that the increment operation on a binary counter is amortized $O(1)$ by considering a potential function to be the number of set bits in the counter. This works, because during an expensive increment operation, the drop in potential is the number of trailing ones become zeroes, which exactly pays for the operation itself.

  Similarly, in this case, define
  $
  Phi(H) = t(H) = "number of trees in" H.
  $

  Denote by $b_n$ the number of set bits in the binary representation of $n$, and $t_n$ the number of trailing ones in the binary representation of $n$. We have, $b_(i - 1) - b_i = t_(i - 1) - 1$.

  Then, 
  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
  &= (t_(i - 1) + 1) + b_i - b_(i - 1)\
  &= (t_(i - 1) + 1) - (t_(i - 1) - 1)\
  &= 2
  $

  Thus, #insert is amortized constant time.
]

== #extract-min

Since each tree follows the min-heap property, we know that the overall minimum element in the heap must be one of the root elements. We can find this element in $O(log n)$. (Alternatively, we could maintain a min pointer to always point to the minimum element in the heap, in which case this step can be done in $O(1)$).


Now, if we remove this node from the heap, all its children become free and form binomial trees themselves. In particular, if the deleted node is a root of a $B_i$ tree, after deletion, we have new $B_0, B_1, ..., B_(i - 1)$ trees. 

At this stage, we have two (valid) binomial heaps, one consisting of all the trees originally other than the one whose root got deleted, and the other one consisting of the children of the deleted root tree. 


#figure(cetz.canvas({
  import cetz.draw: *
  line((0, 0), (3, 0))
  line((3, 0), (5, 0))
  
  draw-binomial-tree(3, 0, 0, (5, 11, 17, 33, 21, 38, 45, 50), dot: true)
  draw-binomial-tree(1, 3, 0, (8, 27))
  draw-binomial-tree(0, 5, 0, (14,))

  translate((-2, -4))

  line((0, 0), (3, 0))

  draw-binomial-tree(2, 0, 0, (11, 17, 33, 21))
  draw-binomial-tree(1, 1.8, 0, (38, 45))
  draw-binomial-tree(0, 3, 0, (50,))

  content((4.5, -0.8), text(size: 2em)[+])

  line((6, 0), (7.5, 0))
  
  draw-binomial-tree(1, 6, 0, (8, 27))
  draw-binomial-tree(0, 7.5, 0, (14,))

}), caption: [Deletion of the min key node (5) from the binomial heap])

We need to _meld_ these two binomial heaps into a single valid binomial heap. 

Observe that just like inserting one element is analogous to incrementing a binary number, similarly, _melding_ two binomial heaps is analogous to addition of two binary numbers (the sizes of the two heaps). We start from the smallest order (the lowest bit), if there are two trees of that order (both set bits), we link them (push a carry to the next bit). Then we go to the next order (next bit). 

For any order $k$, there can be at most 3 trees of that order, if there are at least 2 trees, we link them and continue.

Thus, we can formulate the meld operation (simplified; assuming we keep track of nodes with next pointers as the root list):

#algorithm("Meld", params: ([$H_1$, $H_2$],))[
  #aline[$H = $ merge root lists of $H_1$ and  $H_2$ by non-decreasing orders]
  #aline[#If $H."head" == $ #Nil]
  #aline(indent: 1)[#Return $H$]
  #aline[$x = H."head"$]
  #aline[$"next" = x."next"$]
  #aline[#While $"next" != $ #Nil]
  #aline(indent: 1)[#If $x."order" != "next"."order"$ #Or ($"next"."next" != $ #Nil #And $"next"."next"."order" == x."order"$)]
  #aline(indent: 2)[$x = "next"$]
  #aline(indent: 1)[#Else]
  #aline(indent: 2)[$x =$ #merge;($x, "next"$)]
  #aline(indent: 1)[$"next" = x."next"$]
  #aline[#Return $H$]
]

By analogy to binary addition, this operation also works in worst case $O(log n)$ time.


#figure(cetz.canvas({
  import cetz.draw: *

  line((0, 0), (3, 0))

  draw-binomial-tree(2, 0, 0, (11, 17, 33, 21))
  draw-binomial-tree(1, 1.8, 0, (38, 45))
  draw-binomial-tree(0, 3, 0, (50,))

  content((4.5, -0.8), text(size: 2em)[+])

  line((6, 0), (7.5, 0))
  
  draw-binomial-tree(1, 6, 0, (8, 27))
  draw-binomial-tree(0, 7.5, 0, (14,))

  translate((-3, -3))
  
  line((0, 0), (6, 0), stroke: (dash: "dotted"))

  rect((4, -0.5), (6.5, 0.5), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%))
  
  draw-binomial-tree(2, 0, 0, (11, 17, 33, 21))
  draw-binomial-tree(1, 1.5, 0, (38, 45))
  draw-binomial-tree(1, 3, 0, (8, 27))
  draw-binomial-tree(0, 4.5, 0, (50,))
  draw-binomial-tree(0, 6, 0, (14,))


  translate((8, 0))
  
  line((0, 0), (4.5, 0), stroke: (dash: "dotted"))

  rect((1, -1.5), (3.5, 0.5), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%))

  draw-binomial-tree(2, 0, 0, (11, 17, 33, 21))
  draw-binomial-tree(1, 1.5, 0, (38, 45))
  draw-binomial-tree(1, 3, 0, (8, 27))
  draw-binomial-tree(1, 4.5, 0, (14,50))

  translate((-7, -3))
  
  line((0, 0), (4, 0), stroke: (dash: "dotted"))

  rect((-1, -2.5), (3, 0.5), radius: 10pt, stroke: none, fill: primary-color.transparentize(80%))
  

  draw-binomial-tree(2, 0, 0, (11, 17, 33, 21))
  draw-binomial-tree(2, 2, 0, (8, 38, 45, 27))
  draw-binomial-tree(1, 4, 0, (14,50))

 translate((7, 0))
  
  line((0, 0), (3, 0))

  draw-binomial-tree(3, 0, 0, (8, 11, 17, 33, 21, 38, 45, 27))
  draw-binomial-tree(1, 3, 0, (14,50))

}), caption: [Union of two binomial heaps])

== #decrease-key

This is simple to implement in this case. Assuming we have the pointer to the node, we can decrease the key of that node. Since we don't change any number of nodes anywhere, the only property to ensure is that trees must follow the min-heap property. So, after decreasing the key of the node, we can bubble it up to its appropriate position, to restore the min-heap property of that tree (exactly as is done in a binary heap). This operation runs in $O(log n)$ worst case.


To summarize, here are the time complexities of the operations implemented:

#figure(table(
  columns: 3,
  stroke: none,
  align: (right, center, center),
  table.cell(stroke: none)[], table.vline(), [*Amortized*], table.vline(), [*Worst case*],
  table.hline(),
  [#insert], [$O(1)$], [$O(log n)$],
  [#decrease-key], [$O(log n)$], [$O(log n)$],
  [#extract-min], [$O(log n)$], [$O(log n)$],
), caption: [Complexities of operations on a binomial heap])


= Towards our goal

As stated in the introduction, we want to reach a data structure which can support amortized constant time #decrease-key operations, so we can obtain an improvement in the asymptotic complexity of some graph algorithms.

First, let's affirm that we can never get a data structure which supports all three operations in amortized constant time. This is because, such a data structure could be used to give a $O(n)$ generic sorting algorithm, which we know is not possible.

So for our target data structure, the amortized costs will be $O(1)$ #insert, $O(1)$ #decrease-key and $O(log n)$ #extract-min operations.

Let us think of how we can improve the cost of #decrease-key from what we have in the binomial heap. The worst case $log n$ time comes from the bubbling up which is required after decreasing the key to maintain the min-heap property. Also, we don't have any hope of making it constant amortized, since the user chooses which node to decrease-key from, so they may always choose a deep node which triggers the worst case. Nor can we bound the height of the tree any better than $O(log n)$. So, we need to change the implementation itself.

== Let's be lazy

To achieve $O(1)$ #decrease-key, let us relax some of the restrictions on the structure of our heap.

For decreasing the key of an element, instead of bubbling it up the tree, let's chop it off the tree it is a part of, update the key, and add it as a new tree in the root list. 

Clearly this is $O(1)$ (worst case)! But we have lost a lot of structure by doing this:
- The tree from which a subtree was severed is no longer a binomial tree.
- There may be more than one tree of the same degree after this operation.

Here, we refer to the degree of a root node of the tree as the degree of that tree. (We omit the usage of 'order' from here since the trees are no longer binomial trees).

While we're at it, since we are allowing multiple same-degree trees, we can make our #insert operation worst case $O(1)$ as well; we simply add a new node to the root list, and don't bother about the merging steps.

#let parse-tree(spec) = {
  if type(spec) == array {
    (
      value: spec.first(),
      children: spec.slice(1).map(parse-tree),
    )
  } else if type(spec) == int {
    (value: spec, children: ())
  } else {
    spec
  }
}

#let tree-width(node) = {
  if node.children.len() == 0 {
    1
  } else {
    node.children.map(tree-width).sum()
  }
}

#let draw-tree(spec, x, y, dot: false, hl: (), mark-nodes: ()) = {
  import cetz.draw: *
  let node = parse-tree(spec)

  if type(hl) == int {
    hl = (hl,)
  }

  let widths = node.children.map(tree-width)
  let total-weight = widths.sum(default: 0)
  let total-span = total-weight * unit
  let start-x = x - total-span / 2
  let cursor = start-x

  for (i, child) in node.children.enumerate() {
    let w = widths.at(i) * unit
    let child-x = cursor + w / 2
    let child-y = y - level-height
    line((x, y), (child-x, child-y), stroke: (dash: if dot { "dotted" }))
    draw-tree(child, child-x, child-y, mark-nodes: mark-nodes, hl: hl)
    cursor += w
  }

  circle((x, y), radius: 0.3, stroke: (dash: if dot { "dotted" }, paint: black), fill: if mark-nodes.contains(node.value) { luma(0) } else if hl.contains(node.value) {yellow } else { white })
  content((x, y), {
    set text(white) if mark-nodes.contains(node.value)
    if mark-nodes.contains(node.value) {
      $bold(#str(node.value))$
    } else {
      $node.value$
    }
  })
}

The following figure shows the newly designed operations #decrease-key;(17, 10) and #insert;(2) performed sequentially on our original heap.

#figure(cetz.canvas({
  import cetz.draw: *
  line((0, 0), (3, 0))
  
  draw-binomial-tree(3, 0, 0, (5, 11, 17, 33, 21, 38, 45, 50), hl: 17)
  draw-binomial-tree(1, 2, 0, (8, 27))
  draw-binomial-tree(0, 3, 0, (14,))


  line((6,0), (10, 0))
  
  draw-tree(
    (5, 
      (11, (21,)), 
      (38, (45,)), 
      (50,)
    ), 6, 0, hl: 8)

  draw-tree(
    (10, 38),
    8, 0, hl: 10
  )

  draw-tree((8, 27), 9, 0)
  draw-tree((14,), 10, 0)

  translate((-4, -3))

  line((6, 0), (11, 0))

  draw-tree(
    (5, 
      (11, (21,)), 
      (38, (45,)), 
      (50,)
    ), 6, 0)

  draw-tree(
    (10, 38),
    8, 0
  )

  draw-tree((8, 27), 9, 0)
  draw-tree((14,), 10, 0)
  draw-tree((2,), 11, 0, hl: 2)
  
}), caption: [1) #decrease-key;(17, 10) operation performed.\ 2) #insert;(2) operation performed.\ The resulting trees are not binomial trees, also there are multiple trees of the same degree.])


Alright, we seem to have both #decrease-key and #insert in $O(1)$ worst case time. Of course not for free, in return, we have completely destroyed any semblance of structure in the heap. We have pushed all the hard work to the #extract-min, it needs to 'fix' our heap along with removing the minimum element.

Can we fit all the work that #extract-min needs to do to restore structure in the heap, in $O(log n)$ amortized time?

== Restoring Structure

We want to restore the property that there is at most one tree of degree $k$ for all $k$. How do we do this? We can do the following:

- While there are more than one tree of some degree $k$, link them.


What is the maximum degree a tree can be in our heap of $n$ elements? In case of a binomial heap, this was clearly $log n$, but that is not the case now. Let us call this maximum degree $D(n)$.

Formally, this is the high level algorithm we use to restore the one-tree property of our heap.

#let consolidate = op("Consolidate")

#algorithm("Consolidate", params: ([$H$],))[
  #aline[let $A[0..D(n)]$ be a new array]
  #aline[#For each node $w$ in the root list]
  #aline(indent: 1)[$x = w$, $d = x.d$]
  #aline(indent: 1)[#While $A[d] != Nil$]
  #aline(indent: 2)[$y = A[d]$]
  #aline(indent: 2)[$x = merge(x, y)$]
  #aline(indent: 2)[$A[d] = Nil$]
  #aline(indent: 2)[$d = d + 1$]
  #aline(indent: 1)[$A[d] = x$]
  #aline[recreate the root list of $H$ with the trees in $A$, update the $H.var("min")$ pointer]
]

We allocate an array of size $D(n)$ which is the maximum possible degree of a tree. At the end of the consolidation, there can be at most $D(n) + 1$ trees, each with a unique degree. We go through the root list, if we find a tree with degree $d$ and also some other tree with degree $d$ stored in the array, we link them (continuously till the array $d$ slot is empty). If not, we just store that tree at $A[d]$.

This is how the #extract-min procedure will work: 

#algorithm("Extract-Min", params: ([$H$],))[
  #aline[remove the minimum node from the rootlist]
  #aline[add all its children to the root list]
  #aline[#consolidate;(H)]
]

#figure(cetz.canvas({
  import cetz.draw: *
  line((6, 0), (13, 0))

  draw-tree(
    (3, 
      (18, (39,)), 
      (52,), 
      (38,(41,))
    ), 6, 0, dot: true)

  draw-tree(
    (24, (26, 35), 46),
    8.5, 0
  )

  draw-tree((17, 30), 10, 0)
  draw-tree((23,), 11, 0)
  draw-tree((7,), 12, 0, hl: 2)
  draw-tree((21,), 13, 0, hl: 2)

  content((6, 0.6), $arrow.b$)
  content((6, 1), $var("min")$)

  translate((0, -3))

  line((5, 0), (13, 0), stroke: (dash: "dotted"))
  
  draw-tree((18, (39,)), 5, 0) 
  draw-tree((52,), 6, 0)
  draw-tree((38,(41,)), 7, 0)

  draw-tree(
    (24, (26, 35), 46),
    8.5, 0
  )

  draw-tree((17, 30), 10, 0)
  draw-tree((23,), 11, 0)
  draw-tree((7,), 12, 0, hl: 2)
  draw-tree((21,), 13, 0, hl: 2)

  translate((0, -3.5))

  line((7, 0), (12, 0))

  draw-tree(
    (7, (24, (26, 35), 46), (17, 30), 23),
    7, 0
  )

  draw-tree(
    (18, (21, 52), 39),
    10, 0
  )

  draw-tree((38, 41), 12, 0)

  content((7, 0.6), $arrow.b$)
  content((7, 1), $var("min")$)

  
}), caption: [#extract-min operation performed on a heap. Top: Initial state. Middle: State just after removing the minimum node. Bottom: Final heap after #consolidate. (For detailed steps of consolidation, see Figure 19.4, CLRS)])
// todo: worked example of extract-min

We need to find the time complexity of #consolidate. We will show that #consolidate runs in $O(D(n) + t(H))$ time. Firstly, lines $1$ and $10$ clearly run in $O(D(n))$ time.  Note that when we call #consolidate, the number of nodes in the root list is bounded by $t(H) + D(n) - 1$. (originally $t(H)$ nodes in the root list, the min node removed, and all its children added to the root list).


Every time through the #While loop, one of the root list nodes is linked with another. So, the total number of times the #While loop can run is bounded by $t(H) + D(n)$. Therefore the actual running time of #consolidate is $O(t(H) + D(n))$.


Before talking about $D(n)$ let us consider $t(H)$. In case of a binomial heap, the maximum number of trees in a heap of $n$ elements was $log n$. In this case it is not true, in fact in the worst case we can have $O(n)$ trees, e.g. after $n$ #insert operations. Then the worst case cost of this operation becomes $O(n)$ which is undesirable.


Can we get a better amortized bound?

Consider the potential function $Phi(H) = t(H)$. Here the expensive operation is #extract-min which decreases the number of trees. And the cost of this operation is compensated by the drop in the potential (i.e. decrease in the number of trees!).

Formally,

$
hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
&= t(H) + D(n) + D(n) - t(H)\
&= O(D(n))
$

So, our #extract-min function is $O(D(n))$ amortized!

== Almost there...

If we can somehow show $D(n) = O(log n)$, we are done. But, as per our current structure, we can't claim this.

One can give a sequence of operations which leaves us with a 'wide' and 'short' tree, in which the max degree of the tree can become $O(n)$.


#figure(cetz.canvas({
  import cetz.draw: *

  draw-tree(
    (1, 
      2, 3, 4, 5, 6, 7
    ), 0, 0)

  draw-tree(
    (1, (2, 5, 6), (3, 7), (4,)),
    5, 0
  )
  
}), caption: [Left: a 'wide' and 'short' tree. Right: a 'deep' and 'bushy' tree])

How can we add some structural property to our trees to prevent them from becoming wide and short due to excessive node removals? Since we want to bound the degree of the tree to be logarithmic on the number of nodes, equivalently, we need to ensure that the *number of nodes in the tree is exponential in its degree*.

Recall, in a binomial tree we had the property that the $i$th child had a degree of $i - 1$, (1-indexed). Inductively, this property ensures that the number of nodes in $B_k$ is exponential in $k$ (specifically, $2^k$). Clearly, we don't have this property now as we allow severing nodes from anywhere in the tree. 

Let's instead require that in our new version of the heap (which we will see to be the Fibonacci Heap), the $i$th child must have degree *at least* $i - 2$, i.e. one less that that in a binomial heap.

This means we need to enforce the following: 
- from any node, at most one child can be deleted.

To ensure this, whenever we have already removed a child from a node, we *'mark'* it. When we try to remove another child from a marked node, we also sever the marked node itself from its parent and add it to the root list. *This ensures our $i - 2$ property! (Why?)*

// todo: some diagram related to the i - 2 property

Now, due to the $i - 2$ property, the number of nodes in a tree is exponential to its degree, which means the maximum degree of the heap is logarithmic in $n$, i.e. $D(n) = O(log n)$. (We show this formally later.)

Now we have gotten our $O(log n)$ amortized bound for #extract-min operations! Are we done? Not just yet... We need to reanalyse our #decrease-key function since we may need to do additional cuts to ensure the $i - 2$ property. Let's bring everything together and complete our analysis.

#pagebreak(weak: true)

= Fibonacci Heaps!

A Fibonacci Heap is a collection of rooted trees that follow the *min-heap property*, and a $var("min")$ pointer which points to the minimum node in the root list. Each node's _degree_ is defined as the number of children of that node. Also, each node has a boolean property _marked_, which represents whether any (direct) child of that node has been removed or not.

#figure(cetz.canvas({
  import cetz.draw: *
  
  line((1, 0), (7.5, 0))
  
  draw-tree((23, ), 1, 0)
  draw-tree((7, ), 2, 0)
  draw-tree((3, (18, 39), 52, (38, 41)), 4, 0, mark-nodes: (18, 39))
  draw-tree((17, 30), 6, 0)
  draw-tree((24, (26, 35), 46), 7.5, 0, mark-nodes: (26,))

  
  content((4, 0.6), $arrow.b$)
  content((4, 1), $var("min")$)
  
}), caption: [A fibonacci heap. Marked nodes are indicated with a dark background.])

Let us look at each operation one by one.

== #insert$(x)$

Pretty simple -- a new node is added to the root list of the heap, update the min pointer if required. Worst case $O(1)$ cost.


#figure(cetz.canvas({
  import cetz.draw: *
  
  line((1, 0), (6.5, 0))
  
  draw-tree((23, ), 1, 0)
  draw-tree((7, ), 2, 0)
  draw-tree((3, (18, 39), 52, (38, 41)), 3.5, 0, mark-nodes: (18, 39))
  draw-tree((17, 30), 5, 0)
  draw-tree((24, (26, 35), 46), 6.5, 0, mark-nodes: (26,))

  
  content((3.5, 0.6), $arrow.b$)
  content((3.5, 1), $var("min")$)

  translate((8, 0))
  
  line((0, 0), (6.5, 0))
  
  draw-tree((23, ), 0, 0)
  draw-tree((7, ), 1, 0)
  draw-tree((21, ), 2, 0, hl: 21)
  draw-tree((3, (18, 39), 52, (38, 41)), 3.5, 0, mark-nodes: (18, 39))
  draw-tree((17, 30), 5, 0)
  draw-tree((24, (26, 35), 46), 6.5, 0, mark-nodes: (26,))

  
  content((3.5, 0.6), $arrow.b$)
  content((3.5, 1), $var("min")$)
  
}), caption: [Running $insert(21)$ on the Fibonacci heap.])

== #decrease-key$(x, k)$

1. If we can decrease the key without violating the min-heap property, we do so.
2. Otherwise, we decrease the key, and cut the node from the tree, and add it to the root list. (Set _marked_ for this node to be false.)
3. If the (non-root) parent was unmarked, then mark it. Else, cut the parent from the tree, add it to the root list, unmark it. Repeat Step 3.

#let dk = algorithm("Decrease-Key", params: ([$H$, $x$, $k$],))[
  #aline[ensure $k > x.var("key")$]
  #aline[$x.var("key") = k$]
  #aline[$y = x.var("parent")$]
  #aline[#If $y !=$ #Nil and $x.var("key") < y.var("key")$]
  #aline(indent: 1)[#call[Cut];($H, x, y$)]
  #aline(indent: 1)[#call[Cascading-Cut];($H, y$)]
  #aline[#If $x.var("key") < H."min".var("key")$]
  #aline(indent: 1)[$H."min" = x$]
]

#let cut = algorithm("Cut", params: ([$H$, $x$, $y$],))[
  #aline[remove $x$ from child list of $y$]
  #aline[add $x$ to the root list of $H$]
  #aline[set $x.$_marked_ to false]
]

#let ccut = algorithm("Cascading-Cut", params: ([$H$, $y$],))[
  #aline[#If $y$ is a root node #Return]
  #aline[$z = y.var("parent")$]
  #aline[#If #Not $y."marked"$]
  #aline(indent: 1)[$y."marked" =$ #True]
  #aline[#Else]
  #aline(indent: 1)[#call("Cut");$(H, y, z)$]
  #aline(indent: 1)[#call("Cascading-Cut");$(H, z)$]
]

#grid(
  columns: 2,
  dk, [
    #cut
    #ccut
  ]
)


#let dkfig-a = cetz.canvas({
  import cetz.draw: *

  line((0, 0), (5, 0))
  
  draw-tree(
    (7, (24, (26, 35), 46), (17, 30), 23),
    0, 0,
    mark-nodes: (26,)
  )

  draw-tree(
    (18, (21, 52), 39), 
    3, 0,
    mark-nodes: (18, 39)
  )

  draw-tree(
    (38, 41),
    5, 0,
  )

  content((0, 0.6), $arrow.b$)
  content((0, 1), $var("min")$)
})

// ---------- (b) ----------
#let dkfig-b = cetz.canvas({
  import cetz.draw: *
  line((-1.5, 0), (5, 0))

  draw-tree(15, -1.5, 0)
  draw-tree(
    (7, (24, (26, 35)), (17, 30), 23),
    0, 0,
    mark-nodes: (24, 26)
  )
  draw-tree(
    (18, (21, 52), 39),
    3, 0,
    mark-nodes: (18, 39)
  )
  draw-tree((38, 41), 5, 0)

  content((0, 0.6), $arrow.b$)
  content((0, 1), $var("min")$)
})

// ---------- (c) ----------
#let dkfig-c = cetz.canvas({
  import cetz.draw: *
  line((-3, 0), (5, 0), stroke: (dash: "dotted"))

  draw-tree(15, -3, 0)
  draw-tree(5, -2, 0)
  draw-tree(
    (7, (24, 26), (17, 30), 23),
    0, 0,
    mark-nodes: (24, 26)
  )
  draw-tree(
    (18, (21, 52), 39),
    3, 0,
    mark-nodes: (18, 39)
  )
  draw-tree((38, 41), 5, 0)

  content((0, 0.6), $arrow.b$)
  content((0, 1), $(var("min"))$)
})


// ---------- (d) ----------
#let dkfig-d = cetz.canvas({
  import cetz.draw: *
  line((-4, 0), (5, 0), stroke: (dash: "dotted"))

  draw-tree(15, -4, 0)
  draw-tree(5, -3, 0)
  draw-tree(26, -2, 0)
  draw-tree(
    (7, 24, (17, 30), 23),
    0, 0,
    mark-nodes: (24,)
  )
  draw-tree(
    (18, (21, 52), 39),
    3, 0,
    mark-nodes: (18, 39)
  )
  draw-tree((38, 41), 5, 0)

  content((0, 0.6), $arrow.b$)
  content((0, 1), $(var("min"))$)
})

// ---------- (e) ----------
#let dkfig-e = cetz.canvas({
  import cetz.draw: *
  line((-5, 0), (4, 0))

  draw-tree(15, -5, 0)
  draw-tree(5, -4, 0)
  draw-tree(26, -3, 0)
  draw-tree(24, -2, 0)
  draw-tree(
    (7, (17, 30), 23),
    0, 0,
  )
  draw-tree(
    (18, (21, 52), 39),
    2, 0,
    mark-nodes: (18, 39)
  )
  draw-tree((38, 41), 4, 0)

  content((-4, 0.6), $arrow.b$)
  content((-4, 1), $var("min")$)
})

The following figures show the operations $#decrease-key;(46, 15)$ (a-b) and $#decrease-key;(35, 5)$ (b-c-d-e).


#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0.65em,
    dkfig-a, dkfig-b,
    [(a)], [(b)],
    grid.cell(colspan: 2, dkfig-c),
    grid.cell(colspan: 2, [(c)]),
    grid.cell(colspan: 2, dkfig-d),
    grid.cell(colspan: 2, [(d)]),
    grid.cell(colspan: 2, dkfig-e),
    grid.cell(colspan: 2, [(e)]),
  ),
  caption: [Two #decrease-key operations performed on a Fibonacci Heap.\ $b->c->d->e$ shows how the cuts are cascaded when we have a chain of marked nodes.]
)

What is the time complexity of this operation? It is proportional to the number of cascading cuts, which is bounded by the height of the tree. But, the height of the tree can be $O(n)$ in the worst case (See Problem 4). Therefore the worst case time complexity for #decrease-key is $O(n)$.

How do we amortize the cost down to $O(1)$?

Earlier, for analysing the #extract-min operation we had used the potential function $Phi(H) = t(H)$. However this doesn't work here. Instead of the potential decreasing, it _increases_ (as there are new trees being added to the root list). In fact, it increases by the number of cuts that were done.

If our potential function was $m(H) = $ number of marked nodes in $H$, then this will work, since the decrease in the number of marked nodes is exactly the number of cascading cuts that took place, which is the actual cost of the operation.

So, to support all operations, let us choose this potential function:

$
Phi(H) = t(H) + 2 m(H)
$

During an expensive #decrease-key operation, the number of trees increases, but the number of marked nodes decreases (by the same amount), and this decrease in potential pays for the actual cost of the operation. 


Consider a #decrease-key operation where $c$ cuts take place. Then

$
hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
&<= c + (t(H) + c) + 2 (m(H) - c + 2) - t(H) - 2 m(H) \ &= 4
$

So, #decrease-key is $O(1)$ amortized.

== #extract-min

The algorithm is already discussed above, which involves removing the min element, and running #consolidate. After running this operation, our heap will have at most one tree per degree.

See Figure 19.4, CLRS for a demonstration of the working of #extract-min and #consolidate.

Let $D(n)$ denote the maximum possible degree of a tree in a Fibonacci heap containing $n$ elements.

We know that the actual running time of #extract-min is $O(D(n) + t(H))$. By the potential defined above ($Phi(H) = t(H) + 2 m(H)$), we can find the amortized cost of #extract-min:

$
hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
&<= (D(n) + t(H)) + (D(n) - 2 m(H)) - (t(H) - 2 m(H))\
&= O(D(n))
$

== Bounding $D(n)$

*Lemma 1:* Let $x$ be a node in a Fibonacci heap with degree $k$ and children $y_1, y_2, ..., y_k$ (in order in which they were linked to $x$). Then, the degree of $y_i$ is at least $i - 2$.

*Proof:* When $y_i$ was linked to $x$, then $"degree"(x)$ was $i - 1$. We know that two trees can be linked only if they have the same degree, so at that time $y_i$ also must have had $i - 1$ degree. By the structural property of the Fibonacci heap, we know that $y_i$ cannot have lost more than one of its direct children, otherwise it would have been cut off from $x$. Therefore, $"degree"(y_i) >= i - 2$.

*Lemma 2:* Let $x$ be a node in a Fibonacci heap with degree $k$. Then, $"size"(x) >= F_(k + 2)$, where $F_i$ is the $i$th Fibonacci number.

*Proof:* Let $s_k$ denote the minimum possible size of any node with degree $k$ in a Fibonacci heap. $(s_0 = 1, s_1 = 2)$. Clearly, $s_k$ is monotonically increasing.

If we are forming a minimal tree of degree $k$, its children must follow Lemma 1, so the $i$th child itself must be a minimal tree of degree $i - 2$. Based on this observation, we can write the recurrence:

#let node-r = 0.2
#let ux = 0.8   // horizontal unit
#let uy = 0.9   // vertical spacing per level

#let w(d) = {
  if d == 0 { 1 } else {
    range(d).map(w).fold(0, (a, b) => a + b)
  }
}

#let draw-node(x, y, real) = {
  import cetz.draw: *
  if real {
    circle((x * ux, y * uy), radius: node-r, fill: black, stroke: black)
  } else {
    circle((x * ux, y * uy), radius: node-r, fill: white,
      stroke: (dash: "dotted"))
  }
}

#let draw-edge(x1, y1, x2, y2, real) = {
  import cetz.draw: *
  let a = (x1 * ux, y1 * uy)
  let b = (x2 * ux, y2 * uy)
  if real {
    line(a, b)
  } else {
    line(a, b,
      stroke: (dash: "dotted"))
  }
}

#let draw-ghost(x, y, d) = {
  draw-node(x, y, false)
  if d > 0 {
    let widths = range(d).map(w)
    let total = widths.fold(0, (a, b) => a + b)
    let cx = x - total / 2
    for i in range(d) {
      let cw = widths.at(i)
      let childx = cx + cw / 2
      draw-edge(x, y, childx, y - 1, false)
      draw-ghost(childx, y - 1, i)
      cx += cw
    }
  }
}

#let draw-real(x, y, m, r) = {
  draw-node(x, y, true)
  if m > 0 {
    let widths = range(m).map(w)
    let total = widths.fold(0, (a, b) => a + b)
    let cx = x - total / 2
    for i in range(m) {
      let cw = widths.at(i)
      let childx = cx + cw / 2
      if i < r {
        draw-edge(x, y, childx, y - 1, true)
        draw-real(childx, y - 1, i, calc.max(0, i - 1))
      } else {
        draw-edge(x, y, childx, y - 1, false)
        draw-ghost(childx, y - 1, i)
      }
      cx += cw
    }
  }
}

#figure(cetz.canvas({
  import cetz.draw: *
  let gap = 0.8
  let x = 0
  for k in (1, 2, 3, 4) {
    let half = w(k) / 2
    x += half
    draw-real(x, 0, k, k)
    content((x * ux, 0.7), $S_#k$)
    x += half + gap
  }
}), caption: [Minimal node trees of different degrees in a Fibonacci heap])

$
s_k = 1 + sum_(i = 1)^k  s_(i - 2)
$

which can be rewritten as
$
s_k = s_(k - 1) + s_(k - 2)
$

Along with $s_0 = 1$ and $s_1 = 2$, we have $s_k = F_(k + 2)$, i.e. the $(k + 2)$th Fibonacci number.

Thus, $"size"(x) >= s_k = F_(k + 2)$, which completes the proof.

#let phi = sym.phi.alt

*Lemma 3:* $F_(k + 2) >= phi^k$. (Can be proven by induction.)

So together, we have the property that for any node $x$ with degree $k$, $"size"(x) >= phi^k$.

*Corollary:* The maximum degree $D(n)$ of any node in a $n$ element Fibonacci heap is $O(log n)$.

*Proof:* Let $x$ be a node in the Fibonacci heap of degree $k$. Clearly, $n >= "size"(x) >= phi^k => k <= log_phi n$. Therefore the maximum degree $D(n)$ is $O(log n)$.

Now that we have established that $D(n)$ is $O(log n)$, it follows that the amortized cost of #extract-min is $O(log n)$.

To summarize, these are the costs of the different operations that we defined for the Fibonacci Heap:


#figure(table(
  columns: 3,
  stroke: none,
  align: (right, center, center),
  table.cell(stroke: none)[], table.vline(), [*Amortized*], table.vline(), [*Worst case*],
  table.hline(),
  [#insert], [$O(1)$], [$O(1)$],
  [#decrease-key], [$O(1)$], [$O(n)$],
  [#extract-min], [$O(log n)$], [$O(n)$],
), caption: [Complexities of operations on a Fibonacci heap])


#v(3em)

#align(center, line(length: 40%))

#pagebreak(weak: true)
= Problems

1. Analyse the running time of the Dijkstra's algorithm for single source shortest path and Prim's algorithm for computing a minimum spanning tree in a graph when the priority queue being used in a Fibonacci Heap instead of a Binary Heap. Assume that the number of vertices in the graph is $n$ and the number of edges $m$.

#soln-box[
  Dijkstra's and Prim's algorithms require $n$ #extract-min operations and $m$ #decrease-key operations. Since their amortized costs are $O(log m)$ and $O(1)$ respectively, the total running time of the algorithm is bounded by $O(n log m + m)$.
]


#let increase-key = op("Increase-Key")

2. Suppose in the Fibonacci Heap, we allowed an operation #increase-key, which takes as input the pointer to a node in a Fibonacci Heap $H$ and a new key value $k$, and changes $x."key"$ to $k$. Note that $k$ could be larger than, equal to, or less than the current key value. Design an efficient algorithm to perform this operation so that the amortised time complexity of this operation is $O(log n)$ without changing the amortised complexity of other heap operations.

#soln-box[
  If the new key is greater than the current key, we can perform the following sequence of operations:

  - #decrease-key;$(H, x, -oo)$ ($O(1)$ amortized)
  - #extract-min;$(H)$ ($O(log n)$ amortized)
  - #insert;$(H, x, k)$ ($O(1)$ amortized)

  which runs in amortized $O(log n)$ time.
]


3. Suppose that we generalise the cascading-cut rule to cut a node $x$ from its parent as soon as it loses its $k$th child, for some integer constant $k$. For what value of $k$, we have $D(n) = O(log n)$? What are the running times of the standard operations on Fibonacci heaps with this new definition? Give an argument with the accounting method for the amortized costs of each operation.

#soln-box[
  Let $s_m$ denote the minimum possible size of a node in a heap with degree $m$ (assuming the generalised cascading-cut rule). Clearly, $s_m$ is monotonically nondecreasing. ($s_0 = 1, s_1 = 2$)

  *Lemma:* For a node $x$ with degree $m$, its $i$th child (in order of linking) must have at least $i - k$ children.\
  *Proof:* Let its children be $y_1, y_2, ..., y_m$. When $y_i$ was linked to $x$, it must have had $i - 1$ children. By the generalised cascading rule, after linking, $y_i$ can have lost at most $k - 1$ of its direct children. So, it has at least $i - k$ children. (The rank of $y_i$ among the children of $x$ (in order of linking) can change, it can decrease, but it can never exceed $i$, so the bound still holds.)

  Then, a minimal size node with degree $m$'s $i$th child must itself be a minimal size node of degree $i - k$. Thus we form the following recurrence:

  $
  s_m = 1 + sum_(i = 1)^m s_(i - k)
  $
  (Take $s_i = 1$ for $i <= 0$, since $"size"(z) >= 1$ for any node.)

  So,
  $
  s_m - s_(m - 1) = s_(m - k)
  $

  The characteristic equation is
  $
  x^k - x^(k - 1) - 1 = 0
  $
  There exists a real root $omega, 1 < omega <= 2$. So, $s_m = Omega(omega^m)$. Clearly, $n >= s_m = Omega(omega^m)$, thus $m = O(log n)$.

  So, for any $k > 1$, we have $D(n) = O(log n)$.

  ($k = 1$ does not work as #decrease-key won't be amortized constant time anymore, since every #decrease-key operation will trigger long cascading cuts.)

  *Accounting for amortized costs:* For each non-root node $v$, let $ell(v) in {0, 1, ..., k-1}$ be the number of children $v$ has lost since becoming a child of its current parent; $v$ is cut from its parent (and rejoins the root list with $ell(v)$ reset to $0$) as soon as $ell(v)$ would reach $k$. Let $L(H) = sum_v ell(v)$ over non-root nodes, and $t(H)$ the number of root-list trees. Maintain credits so that the total stored credit always equals
  $
  Phi(H) = t(H) + 2/(k-1) L(H).
  $
  (Credits stored are 1 credit on each root node, and $2 ell \/ (k - 1)$ credits on each non root node.)
  

  - #insert: charge $2$ units. $1$ pays for the cost of insertion, plus $1$ credit stored on the new root.
  - #decrease-key: charge at most $2 + 2/(k - 1)$ units.\ Suppose the operation triggers $c$ cascading cuts beyond the mandatory cut of $x$. Actual cost is $1 + c$. Each cascaded node had $ell = k-1$ just before being cut and resets to $0$ (so they stored 2 credits each, one credit pays for the cut, the other stays as the credit for the new root node).  \
    Out of the $2 + 2/(k - 1)$ units charged, 1 unit pays for the cut of $x$ ($x$ may not hold any credits), $1$ unit for the credit of the new root node ($x$), and $2/(k-1)$ to be stored as credit on the node whose $ell$ was increased by 1 (if any). 
  
  - #extract-min: charge $2D(n) + 1 = O(log n)$ units.\ #consolidate requires $D(n) + t(H)$ actual cost, which is paid for by $D(n)$ from the charge, and $t(H)$ from credits stored on the root nodes. After this operation, the total number of trees is at most $D(n) + 1$, the credits on these root nodes are restored by the remaining units charged ($D(n) + 1$). 

  Since we store $1$ unit of credit on each root node, and fractional credits ($2 ell \/ (k - 1)$) on each non root node, the total credits is always nonnegative. Hence, these charges suffice to pay for a sequence of $n$ operations.
  
  So for any constant $k >= 2$, the generalized Fibonacci heap has exactly the same amortized complexities as the standard heap: $O(1)$ #insert, $O(1)$ #decrease-key, $O(log n)$ #extract-min.
]

4. Show that the height of a tree in an $n$-node Fibonacci heap could be $n − 1$.

#soln-box[
  We show, by induction on $m$, that there is a sequence of Fibonacci-heap operations producing a heap consisting of exactly one tree, a chain with $m$ nodes (height $m - 1$).

  *Base case:* $C_1$ requires a single #insert. For $C_2$, #insert two nodes $p, q$. Insert a dummy node with key $-oo$, and call #extract-min. #consolidate links $p$ and $q$ into a chain of two nodes.

  *Inductive step ($C_m -> C_(m+1)$):* Suppose $C_m$ is a chain with root equal to $c$.

  1. Insert two new nodes $p, q$ with keys smaller than $c$ ($p < q < c$), then insert a dummy node with key $-oo$ and call #extract-min: #consolidate links $p, q$ (both degree $0$) into a $2$-node chain $P$ (root $p$, child $q$).
  2. Insert another dummy node with key $-oo$ and call #extract-min again: #consolidate now links $P$ (degree $1$) with $C_m$ (degree $1$). Since $p$ has the smallest key overall, $p$ becomes the new root, with two children: its old child $q$, and the root of $C_m$.
  3. Call #decrease-key;$(q, -infinity)$ and #extract-min. This removes node $q$ from the heap.

  The heap is now exactly $C_(m+1)$: a linear chain of $m+1$ nodes. 

  Thus for any $n >= 0$ we can form a Fibonacci heap with $n$ nodes with height $n -1$.

  #figure(cetz.canvas({
    import cetz.draw: *
    line((0, 0), (2, 0))
    draw-tree(
      ($C_3$, ([], ([],))),
      0, 0
    )
    draw-tree(($p$,), 1, 0)
    draw-tree(($q$,), 2, 0)

    translate((3, 0))
    
    line((0, 0), (1, 0))
    draw-tree(
      ($C_3$, ([], ([],))),
      0, 0
    )
    draw-tree(($p$, ($q$,)), 1, 0)

    translate((3, 0))
    draw-tree(
      ($p$, ($C_3$, ([], ([],))), ($q$,)),
      0, 0
    )

    translate((2, 0))
    draw-tree(
      ($p$, ($C_3$, ([], ([],)))),
      0, 0
    )
  }), caption: [Inductive construction of $C_4$ from $C_3$])
]

5. What is the maximum possible degree of an $n$-node Fibonacci heap? Given any natural number $n$, provide an example of a sequence of operations so that the Fibonacci heap has $n$ nodes after this sequence of operations and there is a node of the maximum possible degree of an $n$-node Fibonacci heap. Prove your claim.

#soln-box[
  The maximum possible degree of an $n$-node Fibonacci heap is $D(n) = floor(log_phi n)$; this upper bound was shown in the Corollary above. We now show a construction to achieve it.

  For each $k >= 0$ we construct a tree $S_k$ with *exactly* $F_(k+2)$ nodes whose root has degree $k$:

  1. Build a binomial tree ($B_k$) of degree $k$ by a sequence of #insert and #extract-min operations. ($star.filled$)
  2. From every non root node, select its highest degree child. On all these selected nodes, run #decrease-key;$(x, -oo)$ and #extract-min.

  We *claim* that the resulting heap $S_k$ has exactly $F_(k + 2)$ nodes with degree $k$. We can prove it as follows:

  *Lemma:* Let $B_m$ be a non root node with degree $m$ before Step 2. After Step 2, $B_m$ has exactly $F_(m + 1)$ nodes.

  Proof by strong induction on $m$:

  *Base:* 
  - $k = 0$: $B_0$ is a single node, $F_1 = 0$.
  - $k = 1$: $B_1$ has two nodes, after removing its largest child, it is left with one. $F_2 = 1$.

  *Step:* $m >= 2$\
  Originally, the children of $B_m$ were $B_(m - 1), B_(m - 2), ..., B_0$. In step 2, we remove its largest degree child, $B_(m - 1)$. All the other children $B_j$ get transformed by Step 2, and are finally left with $F_(j + 1)$ nodes. (Inductive Hypothesis)

  Then, $B_m$ is left with $1 + sum_(j = 0)^(m - 2) F_(j + 1) = 1 + sum_(i = 0)^(m - 1) F_i = F_(m + 1)$ nodes. #h(1fr) $qed$

  *Proof of claim:* Originally the root node was $B_k$ with children $B_(k - 1), ..., B_0$. After Step 2, they have nodes $F_(k), ..., F_1$. So total nodes in $S_k$ is
  $
  1 + sum_(i = 1)^(k) F_i = 1 + sum_(i = 0)^(k) F_i = F_(k + 2) 
  $

  #figure(cetz.canvas({
    import cetz.draw: *

    draw-tree(
      (1, (2,),(3,(6,)), (4, (7,),(8,(12,))), (5, (9,),(10,(13,)), (11, (14,),(15,(16,))))),
      0, 0,
      hl: (6, 8, 11, 13)
    )

    draw-tree(
      (1, (2,),(3,), (4, (7,),), (5, (9,),(10,), )),
      6, 0,
      mark-nodes: (3, 4, 5, 10)
    )
  }), caption: [Transformation of $B_4$ into $S_4$ with $F_6 = 8$ nodes by Step 2])

  Given $n$, let $k = floor(log_phi n)$, the largest $k$ with $F_(k+2) <= n$. Build $S_k$ as above, then perform $n - F_(k + 2)$ #insert operations. We get an $n$-node Fibonacci heap containing a node of degree $k = D(n)$. 

  #line(length: 100%, stroke: luma(127) + 0.5pt)

  Construction for $star.filled$:\ 
  - $k = 0$: #insert
  - $k = 1$: #insert, #insert, #insert;$(-oo)$, #extract-min
  - $k >= 2$: Build($B_(k - 1)$), Build($B_(k - 1)$),  #insert;$(-oo)$, #extract-min. (#consolidate will link the two $B_(k - 1)$s to form a $B_k$).
]

6. Prove that every node of degree k has at least $F_(k+2)$ nodes in the subtree rooted at that node. Here, $F_n$ denotes the $n$-th Fibonacci number ($F_0 = 0, F_1 = 1$).

#soln-box[
  Let $x$ be a node of degree $k$ with children $y_1, ..., y_k$ in the order they were linked to $x$, and let $s_k$ denote the minimum possible size (number of nodes in the subtree, including the root) of any degree-$k$ node in a Fibonacci heap, so $s_0 = 1$, $s_1 = 2$, and $s_k$ is monotonically nondecreasing in $k$.

  By Lemma 1, $"degree"(y_i) >= i - 2$. Since $s$ is monotonic, $"size"(y_i) >= s_(i-2)$ (taking $s_j = 1$ for $j <= 0$). Counting $x$ itself,
  $
  s_k = 1 + sum_(i=1)^k s_(i-2).
  $
  Subtracting the same relation for $s_(k-1)$ gives $s_k - s_(k-1) = s_(k-2)$, i.e. $s_k = s_(k-1) + s_(k-2)$, the Fibonacci recurrence. Together with $s_0 = 1 = F_2$ and $s_1 = 2 = F_3$, this gives $s_k = F_(k+2)$ for all $k >= 0$.

  Since any degree-$k$ node $x$ has $"size"(x) >= s_k$ by definition of $s_k$ as the minimum, we conclude $"size"(x) >= F_(k+2)$.
]

7. What is the maximum number of cascading cuts possible in a single decrease key operation on any $n$-node Fibonacci heap? Given any natural number $n$, provide an example of a sequence of operations with the last operation of the sequence being a decrease key operation and that decrease key operation performs the maximum number of cascading cuts possible on any $n$-node Fibonacci heap. Prove your claim.

#soln-box[
  Assuming that we don't count the base cut as a cascading cut.
  
  *Claim:* The maximum number of cuts in a single #decrease-key call on an $n$-node heap is $n - 2$.

  Let $d$ be the depth of $x$, so $d <= n - 1$. #call("Cascading-Cut") walks up the ancestor chain $p_1 = y, p_2, ..., p_d = "root"$: it cuts $p_i$ only if $p_i$ is marked (and not a root), and stops once it reaches the root. So at most $p_1, ..., p_(d-1)$ can be cut, i.e. $d - 1 <= n - 2$ cascading cuts.

  To achieve this bound we need to construct a linear chain of $n$ nodes where all nodes except the root and the leaf node are marked.

  Let us inductively construct a tree $C_m$ which has a degree of 2, one of its children is a linear chain of $m - 1$ marked nodes and one leaf node. The other child is a extra node $e_m$ with key $oo$.

  *Base:*\
  $C_1$: #insert;($p$), #insert;($q$) ($p < q$), #insert;($-oo$), #extract-min. We have a chain of $p -> q$. Now #insert;($oo$), #insert;($-oo$), #extract-min. Our root node is $p$ and it has two children, $q$ and $oo$. It has $1 - 1 = 0$ marked nodes.

  *Step:* Let the key of the root of $C_(m - 1)$ be $c$.
  - #insert;($p$), $p < c$, #insert;($e_m = oo$). Add a dummy node with key $-oo$, then #extract-min to link $p$ and $e$. 
  - #insert;($q$), $q > p$, #insert;($e' = oo$). Add a dummy node with key $-oo$, then #extract-min to link $q$ and $e'$.
  - Again add a dummy node with key $-oo$ and #extract-min to link $p$ and $q$.
  - Both trees rooted at $p$ and $C_(m - 1)$ have degree 2. So trigger a linking by adding a $-oo$ node and calling #extract-min. $C_(m - 1)$ will be linked to $p$.
  - #decrease-key;($e_(m - 1)$, $-oo$), #extract-min. This marks the original root of $C_(m - 1)$.
  - #decrease-key;($q$, $-oo$), #extract-min to cleanup and remove the additional $q$ node.
  Thus we have formed $C_m$.
  
  #figure(cetz.canvas({
    import cetz.draw: *


    line((3, 0), (5.5, 0))
    draw-tree(
      (0, (1, (2, (3,))), ($oo$, )),
      3, 0,
      mark-nodes: (2, 1)
    )
    draw-tree(($p$,($oo$,)), 4.5, 0)
    draw-tree(($q$,($oo$,)), 5.5, 0)

    translate((5, 0))
    
    line((3, 0), (4.5, 0))
    draw-tree(
      (0, (1, (2, (3,))), ($oo$, )),
      3, 0,
      mark-nodes: (2, 1)
    )
    draw-tree(($p$, ($q$,($oo$,)),($oo$,)), 4.5, 0)

    translate((1, 0))

    draw-tree(
      ($p$, (0, (1, (2, (3,))), ($oo$, )), ($q$, ($oo$,)), ($oo$,)),
      6.5, 0,
      mark-nodes: (1, 2)
    )

    draw-tree(
      ($p$, (0, (1, (2, (3,)))), ($oo$,)),
      9, 0,
      mark-nodes: (0, 1, 2)
    )
  }), caption: [Inductive construction of a chain of marked nodes])

  To obtain the final tree from $C_n$, call #decrease-key;($e_n$, $-oo$) and then #extract-min. Then, we will be left with a single linear chain of $n$ nodes where all but two nodes are marked. In this tree, calling #decrease-key on the leaf node will trigger $n - 2$ cascading cuts, completely breaking down the tree into individual nodes.
]

8. What is the maximum number of root nodes possible in an $n$-node Fibonacci heap at any point in time? What is the maximum number of root nodes possible in an $n$-node Fibonacci heap immediately after the #extract-min operation? Justify your answers.

#soln-box[
  At any point in time, the maximum number of root nodes possible is $n$, which can be achieved by simply performing a sequence of $n$ #insert operations.

  Immediately after an #extract-min operation, the maximum number of root nodes possible is $D(n) + 1 = floor(log_phi n) + 1$. This is because,
  1. After the #consolidate operation, there is at most one root node with degree $k$ for any $k$.
  2. $D(n)$ is the maximum possible degree, which can be at most $floor(log_phi n)$.
]


#align(center, line(length: 40%))