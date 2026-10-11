#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.5.2"


#show: project.with(
  subject: "Algorithms II",
  topic: "Order Statistics, Sorting Lower Bound"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Order Statistics]

We know that in an array of $n$ elements, we can find the maximum element (or the minimum element) in $O(n)$ time, by iterating through the array once. What if we want to find the median of the array, in what time complexity can we do so? What about finding the $i$th smallest element in the array?

= Selection Problem

We wish to find the median of an array $A$ of size $n$. Define the *median finding problem* as follows:

*Input:* An array $A$ of $n$ distinct numbers.

*Output:* The $display(floor((n + 1)/2))$_th_ smallest element in $A$.

Note that usually for even $n$ we define the lower median and upper median separately; but for simplicity, here we will use the term *median* to mean the lower median for even $n$, and simply the median for odd $n$.

We wish to solve the median finding problem for any input array $A$ as efficiently as possible. Firstly, we can establish *upper bounds* for this problem, by showing an algorithm for solving the problem. What algorithms can one think of that solve this problem?

- We know that finding the smallest element in an array of size $n$ can be done in $O(n)$. Similarly, we can find the next smallest element in $O(n)$. Continuing as so, the $k$th smallest element could be found in $k$ passes, taking $O(k n)$ time. For finding the median, this resolves into a $O(n^2)$ time algorithm.

- Obviously, we can do better. Recall, that we can sort the array $A$ in $O(n log n)$ time. Once sorted, we can simply extract the $k$th element ($k = floor((n + 1) / 2)$) to get the median.

Here, we will discuss a *deterministic worst-case linear time* algorithm to find the median of an array $A$.

This is one of the common situations in computer science, where solving a more general problem is often easier to solve#footnote[This phenomenon is often termed the #link("https://en.wikipedia.org/wiki/Inventor%27s_paradox")[Inventor's paradox.]]. So, we generalise the problem. Define the *selection problem* as follows:

*Input:* An array $A$ with $n$ distinct elements, and an integer $i$, $1 <= i <= n$.

*Output:* The $i$th smallest element in $A$.

We will actually solve the generalised selection problem in linear time.

= Recursive algorithm

Let $A$ be an array of size $n$. For some $x in A$, define $L_x = { y in A | y < x }$ be the left partition of $A$ with respect to $x$, and $R_x = { y in A | y > x }$ be the right partition of $A$ with respect to $x$.

An element $x in A$ is said to be an *approximate median*, if $lr(|L_x|) >= n/4$ and $lr(|R_x|) >= n / 4$. This means, that for an approximate median $x$, at least some constant fraction (here this fraction is $1/4$) of the elements in the array are larger than $x$ and smaller than $x$.

#figure(cetz.canvas({
  import cetz.draw: *

  set-style(stroke: 0.7pt)

  rect((2.5, 0), (7.5, 1), stroke: none, fill: primary-color.lighten(60%))
  rect((0, 0), (10, 1))

  rect((4.2, 0), (4.8, 1))
  content((4.5, 0.5), $x$)

  content((0, -0.4), $0$)
  content((2.5, -0.5), $n / 4$)
  content((7.5, -0.5), $(3 n) / 4$)
  content((10, -0.4), $n$)

  line((0, 1.2), (4.2, 1.2), mark: (symbol: ">", fill: black))
  content((2.1, 1.5), $L_x$)

  line((4.8, 1.2), (10, 1.2), mark: (symbol: ">", fill: black))
  content((7.4, 1.5), $R_x$)

}), caption: [Approximate median $x$, and $L_x$ and $R_x$, depicted in a sorted array.])


The main idea of the algorithm is as follows: Given an approximate median $x$, we can partition the array based on $x$, and recurse in the appropriate subpart of the array.

*Partitioning* an array $A$ about an element $x in A$ results in $x$ being moved at its correct position in the sorted array, and all elements less than $x$ ($L_x$) are placed on the left of $x$, and all elements greater than $x$ ($R_x$) are placed on the right of $x$. We know that we can partition the array in $O(n)$ time, as we do in *quicksort*. We will use the same #op("Partition") procedure here as well.

#let arr = (4, 1, 3, 9, 7, 5, 2, 8, 6, 10)
#let arr2 = (1, 3, 2, 4, 9, 7, 5, 8, 6, 10)

#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.7pt)

  let n = arr.len()

  for i in range(n) {
    rect((i, 0), (i + 1, 1), fill: if i == 0 { primary-color.lighten(60%) }  else { none })
    content((i + 0.5, 0.5), [#arr.at(i)])
  }

  line((5, -0.5), (5, -2), mark: (end: ">", fill: black))

  content((5.2, -1.1), [#smallcaps("Partition")], anchor: "west")

  content((0.5, -1.2), [pivot $x$])
  line((0.5, 0), (0.5, -0.9))

  translate((0, -3.5))

  for i in range(n) {
    rect((i, 0), (i + 1, 1), fill: if i == 3 { primary-color.lighten(60%) }  else { none })
    content((i + 0.5, 0.5), text(fill: if i != 3 { black.lighten(40%)} else { black })[#arr2.at(i)])
  }

  line((0, -0.2), (3, -0.2), mark: (symbol: ">", fill: black))
  content((1.5, -0.6), $L_x$)

  line((4, -.2), (10, -.2), mark: (symbol: ">", fill: black))
  content((7, -.6), $R_x$)

  content((3.5, -.4), $t$)


}, length: 0.8cm), caption: [Partitioning an array $A$ based on a pivot $x$.])


Then, we can write the informal pseudocode of the recursive #op("Select") procedure:

#algorithm("Select", params: ([$A$], [$l$], [$r$], [$i$]))[
  #comment[Finds the $i$th smallest element in the subarray $A[l..r]$]
  #aline[$x <-$ #call("Find-Approximate-Median");($A$, $l$, $r$)]
  #aline[$t <-$ #call("Partition");($A$, $l$, $r$, $x$) #comment[$t$ is the absolute position of the pivot $x$ after partitioning the array]]
  #aline[$j <- t - l + 1$ #h(5em) #comment[rank of $x$ within $A[l..r]$]]
  #aline[#If $i = j$]
  #aline(indent: 1)[#Return $x$]
  #aline[#Else #If $i < j$]
  #aline(indent: 1)[#Return #call("Select");($A$, $l$, $t - 1$, $i$)]
  #aline[#Else]
  #aline(indent: 1)[#Return #call("Select");($A$, $t + 1$, $r$, $i - j$)]
]

First we start with considering $x in A$ to be some approximate median in $A$. (We will come to how we find this later.) Then, considering this element $x$ as a pivot, we partition the array $A$. Let the position of $x$ in the partitioned array be $t$, and let $j$ be its relative rank in the $l..r$ subarray. If $i = j$, that is we want to find the $j$'th element in $A$, we already know that is $x$, so we return it.

Otherwise, if $i < j$ then we know that the element we are searching for is less than $x$, and therefore must be in the left partition of this array. So, we recurse into left part of the array ($A[l..t - 1]$), and find the $i$th smallest element in this subarray. Otherwise, $i > j$, so the element being searched for is on the right of $x$. We recurse into the right partition ($A[t + 1..r]$), and in this, we want to find the $(i - j)$th smallest element; (since it will be the $i$th smallest element in the full array $A[l..r]$).

#let arr = (10, 3, 9, 1, 4, 2, 6, 5, 7, 8)

#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.7pt)

  content((0, 1.5), [#op("Select");($A$, $l$, $r$, $i$)], anchor: "west")
  content((10, 1.5), [pivot = $x$], anchor: "east")

  translate((0, -0.6))


  line((0.3, 1.2), (4.5, 1.2), mark: (symbol: ">", fill: black))
  content((2.4, 1.5), $j$)
  content((-0.2, 0.5), $A[l..r] =$, anchor: "east")

  rect((0, 0), (10, 1))

  content((0.3, -0.3), $l$)
  content((9.7, -0.3), $r$)

  line((4.2, 0), (4.2, 1))
  line((4.8, 0), (4.8, 1))
  content((4.5, 0.5), $x$)

  content((4.5, -0.3), $t$)

  content((2.1, 0.5), $L_x$)
  content((7.4, 0.5), $R_x$)

  line((0, 0), (-2, -3.2), stroke: (dash: "dotted"))
  line((4.2, 0), (2, -3.2), stroke: (dash: "dotted"))

  line((4.8, 0), (7, -3.2), stroke: (dash: "dotted"))
  line((10, 0), (12, -3.2), stroke: (dash: "dotted"))

  translate((0, -0.2))

  line((3, -0.3), (1, -2.3), mark: (end: "stealth", fill: black))
  line((7, -0.3), (9, -2.3), mark: (end: "stealth", fill: black))

  content((1.7, -1.2), $i < j$, angle: 45deg)
  content((8.3, -1.2), $i > j$, angle: -45deg)

  line((4.6, -0.5), (4.6, -2.7), mark: (end: "stealth", fill: black))
  content((4.4, -1.75), $i = j$, anchor: "east")

  content((4.6, -3.5), text(primary-color, $bold(x)$))
  circle((4.6, -3.5), radius: 0.4)

  translate((-2, -4))

  content((2, 0.5), $A[l..t-1]$)

  rect((0, 0), (4, 1))

  content((0.3, -0.3), $l$)
  content((3.7, -0.3), $t-1$)

  line((0.2, 1.2), (2.3, 1.2), mark: (symbol: ">", fill: black))
  content((1.25, 1.5), $i$)

  content((2, -1), text(primary-color, weight: "bold")[#op("Select");($A$, $l$, $t - 1$, $i$)])

  translate((9, 0))

  content((2.5, 0.5), $A[t + 1..r]$)

  rect((0, 0), (5, 1))

  content((0.3, -0.3), $t + 1$)
  content((4.7, -0.3), $r$)

  line((0.2, 1.2), (2.3, 1.2), mark: (symbol: ">", fill: black))
  content((1.25, 1.5), $i-j$)

  content((2.5, -1), text(primary-color, weight: "bold")[#op("Select");($A$, $t + 1$, $r$, $i - j$)])

}), caption: [The recursive #op("Select") procedure])

= Finding the pivot

Now, we need to actually find a pivot $x$ which is an approximate median, i.e. at least a constant fraction of the array is to its left and right. By choosing such an element as a pivot, we ensure that some constant fraction of the array is always discarded on each recursive call, thus achieving our desired time complexity (as we will see).

To find such a pivot, we will find the _median of medians_ of groups of the array $A$, which we will show to be an approximate median.

To find an approximate median $x$ in an array $A$:
1. Divide the $n$ elements in $A$ into $floor(n \/ k)$ groups of $k$ elements each, and at most one group of the remaining elements.
2. Find the median of each of the $ceil(n \/ k)$ groups by fully sorting each list and picking the middle element. Call this list of medians $M$.
3. Call #op("Select") recursively on $M$, to find the median of the $ceil(n \/ k)$ medians found above. This element thus found is $x$, the pivot for our algorithm.


For our analysis, let us choose $k = 5$ (as depicted in @medmed). We will justify this choice later.

For this choice of $x$ (the median of medians of the groups), let us try to get a bound on $|L_x|$ and $|R_x|$. We will use it when showing the time complexity of the overall algorithm.



#[
#show math.equation.where(block: false): math.display

Let $m = ceil(n/ 5)$ be the total number of groups.



#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.5pt)
  rect((-0.5, 1.6), (9.5, 2.4), radius: 0.2, fill: primary-color.lighten(70%), stroke: none)
  for i in range(6) {
    for j in range(5) {
      circle((i * 1.5, j), radius: if i == 3 and j == 2 { 0.3 } else { 0.16 }, fill: if i == 3 and j == 2 { green } else if i >= 3 and j <= 2 { red.lighten(60%) } else if i <= 3 and j >=2 { blue.lighten(60%) } else { white })
      if j != 4 { content((i * 1.5, j + 0.45), $hat$) }
    }
    content((i * 1.5 + 0.75, 2), $<$)
  }
  circle((9, 1), radius: 0.16, fill: red.lighten(60%))
  content((9, 1.45), $hat$)
  circle((9, 2), radius: 0.16, fill: red.lighten(60%))
  content((9, 2.45), $hat$)
  circle((9, 3), radius: 0.16)

  content((10, 2), $M$)

  content((4.5, 2), $x$)

  line((-0.7, -0.2), (-0.7, 4.2), mark: (symbol: ">", fill: black))
  content((-0.9, 2), $k = 5$, anchor: "east")

  line((-0.3, -0.5), (9.3, -0.5), mark: (symbol: ">", fill: black))
  content((4.5, -0.8), $m$)


}, length: 1.1cm), caption: [Choosing a pivot $x$ by finding the median of medians. All blue elements are smaller than $x$ and red elements are larger than $x$.]) <medmed>

Observe, that at least $floor((m - 1) / 2)$ medians are smaller than $x$. Consider any such group. Each such full group has at least 3 elements which are necessarily less than $x$, we color these blue. At most one of these groups may be a partial group so let us discard it. Then, we have the following bound on the number of blue elements (which is a subset of $L_x$):

$
  m >= n / 5 => floor((m - 1) / 2) >= n / 10 - 1 \ \
  |L_x| >= 3 (n / 10 - 2) = (3n) / 10 - 6
$

Similarly, the same argument also applies to $R_x$ (elements greater than $x$ are colored red in @medmed).

So, we have the bounds that $|L_x| >= (3n) / 10 - 6$ and $|R_x| >= (3n) / 10 - 6$. Note that for $n >= 140$, we have $|L_x| >= n/4$ and $|R_x| >= n/4$, so $x$ is an _approximate median_.
]

= Time Complexity

#algorithm("Select", params: ([$A$], [$l$], [$r$], [$i$]))[
  #aline[$x <-$ #call("Find-Approximate-Median");($A$, $l$, $r$)]
  #aline[$t <-$ #call("Partition");($A$, $l$, $r$, $x$)]
  #aline[$j <- t - l + 1$ #h(5em)]
  #aline[#If $i = j$]
  #aline(indent: 1)[#Return $x$]
  #aline[#Else #If $i < j$]
  #aline(indent: 1)[#Return #call("Select");($A$, $l$, $t - 1$, $i$)]
  #aline[#Else]
  #aline(indent: 1)[#Return #call("Select");($A$, $t + 1$, $r$, $i - j$)]
]

Let us denote the time complexity of #op("Select") on a subarray of size $n$ as $T(n)$. We can divide the procedure into two steps,
1. finding the pivot (line 1), say it takes $T_1 (n)$ time
2. partitioning and making recursive calls based on the pivot, say it takes $T_2 (n)$ time.

Then, we have the following relations:

$
  T(n) = T_1 (n) + T_2 (n)
$

For finding the pivot, let us write the time complexity:
1. Sorting each group: $ceil(n \/ k) times O(k^2) = O(n)$ (for $k = 5$)
2. Collecting all medians into $M$: $O(n)$
3. Finding the median of $M$: $T(ceil(n \/ k)) = T(ceil(n \/ 5))$

So,

$
  T_1 (n) = T(ceil(n/5)) + O(n)
$

For the rest of the procedure:
1. Partitioning $A$ over $x$: $O(n)$
2. Recursing over one half of the array: $T(max(|L_x|, |R_x|))$

Since we have shown that $|L_x| >= (3n) / 10 - 6$, thus $|R_x| <= (7n)/10 + 6$, and the same upper bound also applies to $|L_x|$. So, in the worst case we will recurse on an array of size $(7n)/10 + 6$ and not any larger.

So,
$
  T_2 (n) <= T((7n) / 10 + 6) + O(n)
$

Thus, we get the overall recurrence relation:

$
  T(n) <= T(ceil(n / 5)) + T((7n) / 10 + 6) + O(n)
$
(for sufficiently large $n$.)

We state a lemma (without proof) which we can directly apply here to get the $O$-bound for $T(n)$.

#theorem(title: [Recursing into parts less than the whole], numbered: false)[
  Let $T(n)$ be a nonnegative function, and suppose there are constants $c, b, n_0$ such that $T(n) <= b$ for $n < n_0$, and for all $n >= n_0$
  $ T(n) <= T(s_1) + dots.c + T(s_ell) + c n, $
  where $ell$ is a constant, each $s_j < n$, and $s_1 + dots.c + s_ell <= beta n$ for some $beta < 1$. Then $T(n) = O(n)$.
]
This can be proved by induction, or by using a recurrence tree, or even by applying theorems for solving recurrence relations.

For small $n$, we should simply sort the entire array and select the $i$th element. For large enough $n$ ($n > 70$), we have,
$
  ceil(n / 5) + (7n) / 10 + 6 <= n/5 + 1 + (7n) / 10 + 6 <= (9n)/10 + 7 < n
$

By applying the above lemma on our recurrence, for an appropriate choice of $n_0$, we get that $T(n) = O(n)$, i.e. our selection algorithm runs in *deterministic worst case linear time*.#footnote[For a more rigorous treatment of solving this recurrence relation, see CLRS topic 9.3.]


#disc-box[
  *Why $k = 5$?*

  Let us perform a simplified analysis for the general case, where the group size is $k$. (Also let us assume $k$ is odd; this leads to symmetric bounds for $L_x$ and $R_x$.)

  Let $m = ceil(n \/k )$ be the number of groups. Then, at least $floor((m - 1) \/ 2)$ group medians are less than $x$ (and greater than $x$). Both counts are at least
  $ floor((m - 1) / 2) >= (m - 2) / 2 >= n / (2k) - 1. $
  At most one group is partial, so discarding it leaves at least $n \/ 2k - 2$ full groups whose median is smaller than $x$. In each such group, at least $(k + 1)\/2$ elements are smaller than $x$. The groups are disjoint, so
  $ |L_x| >= (k + 1) / 2 dot (n / (2k) - 2) = n / 4 + n / (4k) - (k + 1) >= n / 4, $
  where the last step holds for large $n$ (when $n >= 4k(k + 1)$). The bound for $|R_x|$ is symmetric.

  Therefore, $x$ is an approximate median.

  Then, our final recurrence can be written as 

  $
    T(n) = T(n / k) + T((3 n) / 4) + O(n)
  $

  If we pick $k = 3$, then 
  $
    n / 3 + (3n) / 4 = (13n)/12 > n
  $
  so this analysis no longer gives us a linear bound.
  
  The smallest odd $k$ value for which $T(n)$ is linear, is $k = 5$ (since $n / 5 + (3 n)/4 = (19n)/20<n$).
]

= Worked Example

*Example.* Let us find the median ($i = 18$) of the following array of size $n = 35$.


#let draw-array(row) = cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.5pt)

  let w = 0.45    // cell width
  let h = 0.5     // cell height
  let gap = 1.3   // vertical distance between rows

  let y = 0
  for (j, v) in row.arr.enumerate() {
    let kind = if row.t != none and j == row.t {
      "pivot"
    } else if j < row.lo or j > row.hi {
      "old"
    } else if row.go == "left" and j < row.t {
      "next"
    } else if row.go == "right" and j > row.t {
      "next"
    } else if row.go == "base" {
      "next"
    } else {
      "plain"
    }
    let f = if kind == "pivot" { black } else if kind == "next" { luma(230) } else { white }
    let c = if kind == "pivot" { white } else if kind == "old" { luma(150) } else { black }
    rect((j * w, y), ((j + 1) * w, y - h), fill: f)
    content(((j + 0.5) * w, y - h / 2), text(size: 9pt, fill: c)[#v])
  }
})

#let rows = (
  (
    arr: (34, 23, 3, 30, 20, 27, 24, 18, 33, 11, 12, 19, 6, 2, 10, 32, 35, 29, 22, 14, 26, 1, 28, 4, 7, 13, 21, 31, 15, 25, 16, 8, 17, 5, 9),
    lo: 0, hi: 34, t: none, go: none,
  ),
  (
    arr: (3, 20, 18, 11, 12, 19, 6, 2, 10, 14, 1, 4, 7, 13, 15, 16, 8, 17, 5, 9, 21, 34, 23, 30, 27, 24, 33, 32, 35, 29, 22, 26, 28, 31, 25),
    lo: 0, hi: 34, t: 20, go: "left",
  ),
  (
    arr: (3, 6, 2, 1, 4, 7, 8, 5, 9, 20, 18, 11, 12, 19, 10, 14, 13, 15, 16, 17, 21, 34, 23, 30, 27, 24, 33, 32, 35, 29, 22, 26, 28, 31, 25),
    lo: 0, hi: 19, t: 8, go: "right",
  ),
  (
    arr: (3, 6, 2, 1, 4, 7, 8, 5, 9, 11, 12, 10, 14, 13, 15, 16, 17, 20, 18, 19, 21, 34, 23, 30, 27, 24, 33, 32, 35, 29, 22, 26, 28, 31, 25),
    lo: 9, hi: 19, t: 16, go: "right",
  ),
  (
    arr: (3, 6, 2, 1, 4, 7, 8, 5, 9, 11, 12, 10, 14, 13, 15, 16, 17, 18, 19, 20, 21, 34, 23, 30, 27, 24, 33, 32, 35, 29, 22, 26, 28, 31, 25),
    lo: 17, hi: 19, t: 17, go: "base",
  ),
)


#let arr = (34,23,3,30,20,27,24,18,33,11,12,19,6,2,10,32,35,29,22,14, 26,1,28,4,7,13,21,31,15,25,16,8,17,5,9)

#draw-array(rows.at(0))

We can arrange the array in groups of 5 as follows:

#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.7pt)

  let cols = arr.chunks(5)
  let dx = 1.1
  let dy = 0.8
  let pos(c, r) = (c * dx, -r * dy)

  for c in range(7) {
    for r in range(5) {
      let v = cols.at(c).at(r)
      content(pos(c, r), [#v])
    }
  }

}), caption: [The array $A$ arranged into groups of 5])

*Round 1* ($n = 35$, $i = 18$). Sorting each group and taking its median gives $M = (23, 24, 10, 29, 7, 21, 9)$. The median of $M$ is its $4$th smallest element, so $x = 21$.

#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.7pt)

  let cols = arr.chunks(5).map(x => x.sorted())
  let dx = 1.1
  let dy = 0.8
  let pos(c, r) = (c * dx, -r * dy)

  for c in range(7) {
    for r in range(5) {
      let v = cols.at(c).at(r)
      content(pos(c, r), if r == 2 { strong[#v] } else { [#v] })
    }
  }

  rect(pos(-0.5, 1.5), pos(6.5, 2.5), stroke: (dash: "dashed"))

  content(pos(-0.7, 2), [medians], anchor: "east")

  line(pos(6.6, 2), pos(8, 2), mark: (end: ">", fill: black))

  content(pos(8.2, 2), align(center)[median of medians\ $x = 21$], anchor: "west")

}), caption: [Each group is sorted, and the medians are computed. We recursively find the median of the medians.])

Partitioning the original array by $x = 21$ gives the position of the pivot as $j = 21$. Since $i = 18$, we recurse into the left subarray:

#draw-array(rows.at(1))

*Round 2* ($n = 20$, $i = 18$). The array is now $L_x$, in its original order. Its groups have medians $M = (12, 10, 7, 9)$. The median of medians is thus $x = 9$. Partitioning by $x$ gives the position of pivot to be $k = 9$. As $i = 18 > k$, we recurse on $R_x$ with $i <- i - j = 9$.
#draw-array(rows.at(2))


*Round 3* ($n = 11$, $i = 9$). The groups are $(20, 18, 11, 12, 19)$, $(10, 14, 13, 15, 16)$ and the partial group $(17)$, with medians $M = (18, 14, 17)$, so the median of medians $x = 17$. Partitioning gives the position of pivot to be $j = 8$. As $i = 9 > j$, we recurse on $R_x = (20, 18, 19)$ with $i <- 9 - 8 = 1$.
#draw-array(rows.at(3))

*Base case* ($n = 3$, $i = 1$). Sorting $(20, 18, 19)$ gives $(18, 19, 20)$, whose $1$st smallest element is $18$. Hence the median of the array is $bold(18)$.

#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.7pt)

  let u = 0.26    // width of one element
  let h = 0.6     // bar height
  let gap = 2.4   // vertical distance between rounds
  let rounds = (
    (x0: 0,  nl: 20, nr: 14, piv: 21, n: 35, i: 18, go: "left"),
    (x0: 0,  nl: 8,  nr: 11, piv: 9,  n: 20, i: 18, go: "right"),
    (x0: 9,  nl: 7,  nr: 3,  piv: 17, n: 11, i: 9,  go: "right"),
  )

  for (idx, r) in rounds.enumerate() {
    let y = -idx * gap
    let xl = r.x0 * u
    let xp = xl + r.nl * u
    let xr = xp + u
    let xe = xr + r.nr * u
    let k = r.nl + 1

    rect((xl, y), (xp, y - h), fill: if r.go == "left" { luma(230) } else { white })
    rect((xp, y), (xr, y - h), fill: black)
    rect((xr, y), (xe, y - h), fill: if r.go == "right" { luma(230) } else { white })

    content(((xl + xp) / 2, y - h / 2), [#r.nl])
    content(((xr + xe) / 2, y - h / 2), [#r.nr])
    content(((xp + xr) / 2, y + 0.1), [$x = #r.piv$], anchor: "south")
    content((-0.2, y - h / 2), [$n = #r.n, quad i = #r.i$], anchor: "east")

    let ax = (if r.go == "left" { xl } else { xr }) + 0.3
    line((ax, y - h), (ax, y - gap), mark: (end: "stealth", fill: black))
    content(
      (ax + 0.15, y - h - 0.9),
      if r.go == "right" { [$i > j = #k$: go right, $i <- i - j = #(r.i - k)$] } else { [$i < j = #k$: go left, same $i$] },
      anchor: "west",
    )
  }

  // base case
  let y4 = -3 * gap
  rect((17 * u, y4), (20 * u, y4 - h), fill: luma(230))
  content((-0.2, y4 - h / 2), [$n = 3, quad i = 1$], anchor: "east")
  content((20 * u + 0.2, y4 - h / 2), [sort $(20, 18, 19)$: the $1$st smallest is $bold(18)$], anchor: "west")
}, y: 0.9), caption: [The recursion in the worked example. The black cell is the pivot $x$, the numbers are $|L_x|$ and $|R_x|$, and the shaded part is the subarray which is recursed into.])


= Summary

We have shown a deterministic algorithm, which runs in worst case $O(n)$ time. Note that this statement talks about asymptotic behaviour, i.e. for large $n$. Also, there are hidden constants associated with the time complexity. In this case, the constant is very large, due to the multiple recursive calls being made.

In practice, randomised quickselect (choosing the pivot uniformly at random) is usually much faster. Though it has a worst case time complexity of $O(n^2)$, the probability of hitting the worst case is very low, and its expected running time is $O(n)$ with a small constant. Thus, median of medians is generally not used in practice.

This algorithm is of theoretical importance, as it _guarantees_ linear time in the worst case. This can be useful for safety-critical systems where a probabilistic guarantee of the running time is not enough.

Theoretically, the algorithm also shows that selection is $Theta(n)$, since $Omega(n)$ is needed to even read the input.

#pagebreak()

#title[Sorting Lower Bound]

We know about many sorting algorithms, such as insertion sort, bubble sort, quick sort, merge sort and heap sort. All these algorithms use only comparisons between the elements in the array to determine the final sorted order. These algorithms are called *comparison-based sorts*.

Out of the algorithms listed above, insertion sort and bubble sort run in $O(n^2)$ time, quicksort runs in $O(n^2)$ in the worst case and in $O(n log n)$ on average. Merge sort and heap sort run in $O(n log n)$ in the worst case.

But, can we do any better than $O(n log n)$?

= Lower Bound of a problem

Let $P$ be a computational problem. Let $n$ be the size of an input instance to $P$.

- $O(f(n))$ is said to be an *upper bound* of $P$, if there exists an algorithm $A$ that solves $P$ in $O(f(n))$ time in the worst case. Showing an upper bound involves coming up with an algorithm for $P$ which runs in the required time.

- $Omega(g(n))$ is said to be the *lower bound* of $P$, if it can be shown, that for any algorithm $A$ that solves $P$, it must take at least $Omega(g(n))$ time in the worst case. A lower bound defines a fundamental limit  on the best algorithm that solves the problem $P$.

For any problem, advances in algorithm design gradually lowers its upper bound by coming up with better algorithms with lower worst case time complexities. On the other hand, proving a lower bound is a theoretical exercise of proving the inherent difficulty of a problem. By proving a better lower bound, the gap between the best upper and lower bounds of a problem reduces.

The central goal of algorithm design is to close the gap between the two bounds. An algorithm $A$ is considered *asymptotically optimal* for $P$, if its upper bound matches the problem's lower bound. If $A$ has a cost of $O(f(n))$ in the worst case, and $Omega(f(n))$ is a theoretical lower bound for $P$, then $A$ is optimal. Thus the two bounds converge, and the complexity of $P$ is established to be $Theta(f(n))$.

For our discussion, this means that $O(n log n)$ is an upper bound for comparison-based sorts. Here, we will prove that *the lower bound for comparison-based sorts is $Omega(n log n)$*, thus showing the optimality of merge sort and heap sort.

= The proof

Without loss of generality, assume the input array $A$ has $n$ distinct elements. For a comparison-based sort, we assume that it only gains information about the elements of the array by checking for comparisons between two indices in the array, $a_i$ and $a_j$. By performing a sequence of such comparisons, the algorithm comes up with the correct sorted order for the array.

Under this model, any comparison-based sort may be represented as a *decision tree*. A decision tree is a full binary tree (every node having 0 or 2 children), where the non-leaf nodes represent comparison between two elements $a_i$ and $a_j$, and the leaf nodes represent the final sorted sequence.

Then, the execution of the sorting algorithm on some input array $A$ is nothing but a path from the root to a leaf of the decision tree, where at each internal node, the choice of which child to go to is based on the outcome of the corresponding comparison. The final output of the algorithm is the sorted sequence, represented by the leaf node.

#cetz.canvas({

})

#figure(cetz.canvas({
  import cetz.draw: *
  set-style(stroke: 0.7pt)

  line((4.5, 6), (1.5, 4), stroke: primary-color + 2pt)
  line((4.5, 6), (7.5, 4))
  line((1.5, 4), (0, 2))
  line((1.5, 4), (3, 2), stroke: primary-color + 2pt)
  line((3, 2), (2, 0), stroke: primary-color + 2pt)
  line((3, 2), (4, 0))
  line((7.5, 4), (6, 2))
  line((7.5, 4), (9, 2))
  line((9, 2), (8, 0))
  line((9, 2), (10, 0))

  let lab(pos, body) = content(pos, body, padding: 0.06, anchor: if body == $>$ { "south-west" } else { "south-east" })
  lab((3, 5), $<$);       lab((6, 5), $>$)
  lab((0.75, 3), $<$);    lab((2.25, 3), $>$)
  lab((2.5, 1), $<$);     lab((3.5, 1), $>$)
  lab((6.75, 3), $<$);    lab((8.25, 3), $>$)
  lab((8.5, 1), $<$);     lab((9.5, 1), $>$)

  let cmp(pos, body) = content(pos, body, frame: "rect", fill: white, padding: 0.15)
  cmp((4.5, 6), $a_1 : a_2$)
  cmp((1.5, 4), $a_2 : a_3$)
  cmp((7.5, 4), $a_1 : a_3$)
  cmp((3, 2), $a_1 : a_3$)
  cmp((9, 2), $a_2 : a_3$)

  let leaf(pos, body) = content(pos, body, frame: "rect", fill: luma(230), padding: 0.15)
  leaf((0, 2), $chevron.l a_1, a_2, a_3 chevron.r$)
  leaf((1.5, 0), $chevron.l a_1, a_3, a_2 chevron.r$)
  leaf((4.5, 0), $chevron.l a_3, a_1, a_2 chevron.r$)
  leaf((6, 2), $chevron.l a_2, a_1, a_3 chevron.r$)
  leaf((7.5, 0), $chevron.l a_2, a_3, a_1 chevron.r$)
  leaf((10.5, 0), $chevron.l a_3, a_2, a_1 chevron.r$)
}), caption: [Decision tree of a comparison sort on $[a_1, a_2, a_3]$. Each internal node compares $a_i : a_j$, taking the left edge if $a_i < a_j$ and the right edge otherwise.]) <dec>


For example, suppose there exists some comparison sort $S$ which is represented by the decision tree in @dec (for $n = 3$). Let the input array $A = [2, 8, 6]$. The first comparison made is represented by the root of the tree, i.e. $a_1 < a_2$. Indeed, $2 < 8$, so we take the left branch of the tree. The next comparison is $a_2 < a_3$. Here, $8 > 6$, so we will take the right branch. The final comparison is $a_1 < a_3$ which is again true as $2 < 6$, so we take the left branch and reach the leaf node $chevron.l a_1, a_3, a_2 chevron.r$. This represents that our final sorted sequence is $[2, 6, 8]$.


We make a few observations. Firstly, the output of the sorting algorithm is just a permutation of the input elements. This is obvious, since sorting an array is nothing but selecting the permutation in which every consecutive elements are in the correct order.

Secondly, if $S$ is a correct sorting algorithm, then all $n!$ permutations of $[a_1, ..., a_n]$ must be present as one of the leaf nodes in its decision tree. This is because, any correct sorting algorithm must be able to produce each permutation of its input as the actual sorted sequence.

Therefore, we require that the decision tree has at least $n!$ leaves.

Now, what is the worst case time complexity of this sorting algorithm $S$? Since it is a comparison-based sort, we can count the number of comparisons made as its running time. In the decision tree model, this corresponds to the depth of the corresponding leaf node which represents the final sorted sequence.

Therefore, the worst case time complexity of the algorithm must be the height of the tree, $h$. So, we just need to get a lower bound on this height.

We know that in a binary tree of height $h$, the number of leaves it can have is at most $2^h$. Let $l$ be the number of leaves in the decision tree. Then, we have

$
  l <= 2^h
$

We have also shown that

$
  l >= n!
$

Thus, this implies

$
  n! &<= 2^h\
  => h &>= lg n!\
  &= Omega (n lg n)
$

where the bound of $lg n!$ can be obtained from the Stirling's approximation for $n!$, or using other ways as well.#footnote[See _Algorithms I: Asymptotic Bounds_, Problem 1.4.5.]


Since the height of the decision tree is lower bounded by $Omega(n lg n)$, this proves   that $Omega(n lg n)$ is a lower bound for comparison-based sorts.

As a corollary, this also shows that *heapsort and mergesort are asymptotically optimal comparison sorts*.


#pagebreak()

= Problems

1. Prove that the randomized quick sort algorithm makes #highlight[expected] $O(n log n)$ comparisons for every input.

#soln-box[
  Let $A = [a_1, a_2, ..., a_n]$ be the array which is to be sorted.
  Let $a^((i))$ denote the $i$th smallest element in $A$, so $a^((1))$ is the min element, whereas $a^((n))$ is the max element.

  Since we are taking the expectation over the random pivot choices, the pivot $x$ to be chosen is equally likely to be any of $a^((1)), a^((2)), ..., a^((n))$. If the pivot chosen is $a^((i))$, then $|L_x| = i - 1$ and $|R_x| = n - i$.

  Let the number of comparisons taken by quicksort be $T(n)$, then we have the recurrence

  $
    T(n) = T(|L_x|) + T(|R_x|) + O(n)
  $

  for some specific choice of pivot $x$.

  Taking expectation over all choices (from here, $T(n)$ denotes the expected number of comparisons), we have
  $
    T(n) &= 1/n sum_(i = 1)^n (T(i - 1) + T(n - i)) + c n\
&= 2/n sum_(i=0)^(n - 1) T(i) + c n
  $

  Multiply this equation by $n$.
  $
    n T(n) &= 2 sum_(i = 0)^(n - 1) T(i) + c n^2
  $
  Similarly,
  $
    (n - 1) T(n - 1) &= 2 sum_(i = 0)^(n - 2) T(i) + c (n - 1)^2
  $
  Subtracting the two equations, we have
  $
    n T(n) - (n - 1) T(n - 1)  = 2 T(n - 1) + 2 c n - c   $$
    => n T(n) &<= (n + 1) T(n - 1) + 2 c n\
    => T(n) / (n + 1) &<= T(n - 1) / n + (2 c) / (n + 1)
  $
  Repeatedly expanding this recurrence, one gets
  $
    T(n) / (n + 1) <= 2 c sum_(k = 2)^(n + 1) 1/k = 2 c (H_(n + 1) - 1)
  $

  We know, that $H_n = O(ln n)$, so 
  $
    T(n) / (n + 1) = O(log n) => T(n) = O(n log n)
  $
]

2. [CLRS] Design an algorithm to compute the second smallest of $n$ elements with $(n + ceil(log_2 n) - 2)$ comparisons in the worst case.

#soln-box[
  Consider a comparison-based algorithm that computes the smallest element in $A$. Initially, any element may be potentially the smallest element. Let set $S$ denote this set of elements which are possibly the minimum at this point. 

  Upon every comparison (of two elements in $S$), we can eliminate the larger of the two elements from $S$ since it cannot be the minimum. Finally, we want to get to one element remaining in $S$, so this will take $n - 1$ comparisons.

  The execution of any such algorithm to find the smallest element may be represented as a *tournament tree*, where the top level nodes are the initial set $S$ (all elements in the array), and each comparison is represented by a new node coming from the two nodes being compared, and the value of the new node is the smaller of the two parent nodes.

  Consider the second smallest element in the array (call it $x$). It is only larger than one other element in $A$, which is the smallest element itself. Clearly, $x$ was eliminated from $S$ at some point. The only possible comparison that could have led to the removal of $x$ must have been with the smallest element itself. This implies, that $x$ must have been compared with the smallest element at some point.

  Define $P$ as the candidate set of second smallest elements; these are all the elements which were compared with the overall smallest element when we were finding the minimum element. Clearly, the second smallest element is just the smallest element in $P$. We can find this using $|P| - 1$ comparisons. 

  So the total number of comparisons we take to find the second smallest element is $n + |P| - 2$.

  #figure(cetz.canvas({
    import cetz.draw: *
    set-style(stroke: 0.7pt)

    let vals = ((4, 5, 8, 1, 6, 3, 2, 7), (4, 1, 3, 2), (1, 2), (1,))
    let xs = ((0, 1.5, 3, 4.5, 6, 7.5, 9, 10.5), (0.75, 3.75, 6.75, 9.75), (2.25, 8.25), (5.25,))
    let ys = (0, -1.6, -3.2, -4.8)
    let on-path = ((0, 3), (1, 1), (2, 0))
    let cand = ((0, 2), (1, 0), (2, 1))

    for lvl in range(3) {
      for j in range(xs.at(lvl).len()) {
        let w = if (lvl, j) in on-path { 1.6pt + primary-color } else { 0.7pt }
        line(
          (xs.at(lvl).at(j), ys.at(lvl)),
          (xs.at(lvl + 1).at(calc.floor(j / 2)), ys.at(lvl + 1)),
          stroke: w,
        )
      }
    }

    for lvl in range(4) {
      for j in range(xs.at(lvl).len()) {
        let f = if (lvl, j) in cand { luma(200) } else { white }
        content(
          (xs.at(lvl).at(j), ys.at(lvl)), [#vals.at(lvl).at(j)],
          frame: "rect", fill: f, padding: 0.15,
        )
      }
    }
  }, length: 0.7cm, y: 0.9), caption: [Tournament tree with minimal height. Shaded nodes represent $P$.]) <tmt>

  Now, how small can we make $|P|$? Observe, that we can consider the top nodes of the tournament tree as its leaves and the final smallest node as the root, then the tournament tree is an inverted full binary tree with $n$ leaves. Then, we know that its height must be $>= ceil(log_2 n)$. (We can achieve this height by comparing elements pairwise at each level, as shown in @tmt.) We have, $|P| <=$ height of the tree.

  Thus, the total number of comparisons required to find the second smallest element in $A$ is $n + ceil(log_2 n) - 2$.
]

3. Design an algorithm to compute the smallest and largest of $n$ elements with $3 floor(n \/ 2)$ comparisons in the worst case.

4. [CLRS] Prove the lower bound of $(ceil(3 n \/ 2) - 2)$ comparisons in the worst case to find both the maximum and minimum of $n$ numbers.

#disc-box[
  #let MAX = $"MAX"$
  #let MIN = $"MIN"$
  _Solution sketch._ Initially, all $n$ numbers are potentially either the maximum or minimum. Let $MAX$ be the set of numbers which are potentially the maximum and $MIN$ denote the set of numbers which are potentially the minimum. Say we compare two elements $a$ and $b$. If $a ⩽ b$, we can remove $a$ from $MAX$ and remove $b$ from $MIN$, so we reduce the counts of both sets by $1$. If we compare two elements in $MIN$, we reduce the size of $MIN$ by $1$, and if we compare two elements in $MAX$, we can reduce the size of $MAX$ by $1$. Thus, the first type of comparison is optimal. There are $ceil(n \/ 2)$ such comparisons which can be made until $MIN$ and $MAX$ are disjoint, and the sets will have sizes $ceil(n\/2)$ and $floor(n\/2)$. Within each of these, only the second and third types of comparisons can be made, each reducing the set size by 1, so we require a total of $ceil(n\/2) - 1 + floor(n\/2) − 1 = n − 2$ comparisons. Adding this to initial $ceil(n\/2)$ comparisons gives $(ceil(3n\/2) − 2$).
]

5. [CLRS] In the algorithm #op("Select"), the input elements are divided into groups of 5. Will the algorithm work in linear time if they are divided into groups of 7? Argue that #op("Select") does not run in linear time if groups of 3 are used.

#soln-box[
  DIY (See pg 6)
]

6. [CLRS] Suppose that you have a “black-box” worst-case linear-time median subroutine. Give a linear-time algorithm that solves the selection problem for an arbitrary order statistic.

#soln-box[
  The median is the best pivot element that can be chosen for the #op("Select") procedure, since it divides the input array into equal partitions, so the part which we recurse into is of size at most $n \/ 2$. So, we modify the #op("Select") procedure, to use the 'black-box' median subroutine to find the pivot $x$. The rest of the procedure remains the same.

  Suppose the time complexity of this algorithm is $T(n)$, then it is decomposed into
  1. Invoking the median subroutine: $O(n)$
  2. Partitioning the array: $O(n)$
  3. Recursively calling on one of the partitions: $T(n / 2)$

  Thus, we have the recurrence:
  $
    T(n) <= T(n / 2) + c n
  $
  which clearly solves to $T(n) = O(n)$ (inductively prove $T(n) <= 2 c n$ for all $n$).
]


7. [CLRS] The $k$-th quantiles of an $n$-element set are the $k - 1$ order statistics that divide the sorted set into $k$ equal-sized sets (to within 1). Give an $O(n log k)$-time algorithm to list the $k$-th quantiles of a set.

#soln-box[
  Let $i_j = ceil(j n \/ k)$ for $j = 1, dots, k - 1$. The $k$th quantiles are the elements of ranks $i_1 < dots < i_(k-1)$.

  Define the procedure $#op("Quantiles");(A, I)$ which takes an array $A$ and a list $I$ of ranks relative to $A$:
  + If $I$ is empty, return.
  + Let $r$ be the middle element of $I$ (the $ceil(|I| \/ 2)$th), i.e. the median rank.
  + Find the element $x$ of rank $r$ in $A$ using the worst-case linear-time #op("Select"), and partition $A$ around $x$. Now $x$ is in position $r$.
  + Recurse on the subarray left of $x$ with the ranks of $I$ smaller than $r$.
  + Recurse on the subarray right of $x$ with the ranks of $I$ larger than $r$, by decreasing each rank by $r$.

  Initially we call the procedure with $#op("Quantiles");(A, (i_1, dots, i_(k-1)))$. When it returns, $A[i_1], dots, A[i_(k-1)]$ are the quantiles, as required.

  *Time complexity*: The recursion always splits the array into two disjoint parts and recurses into both. The non recursion time complexity is $O(n)$. Therefore, in the recursion tree, each level contributes $O(n)$ time complexity. At each level, the rank list halves in size. The base case is hit if the  rank list is empty. Thus, the total number of levels in the recursion tree is $O(log k)$. So, the total time complexity is $O(n log k)$.
]