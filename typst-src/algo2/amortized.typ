#import "template.typ": *
#import "algorithm.typ": *

#show: project.with(
  subject: "Algorithms II",
  topic: "Amortized Analysis"
)

#let op(x) = smallcaps[#x]

#let push = op[Push]
#let pop = op[Pop]
#let multipop = op[Multipop]
#let increment = op[Increment]


#title[Amortized Analysis]

Even though the worst case cost of a single operation is large, the average cost of an operation (averaged over a sequence of operations) can be small. Amortized analysis guarantees the average performance of each operation in the worst case.

= Aggregate Analysis

We show, for all $n$, a sequence of $n$ operations takes worst case $T(n)$ time in total. Then, the amortized cost per operation is $T(n) \/ n$.

== Stack Operations

- $push(S, x)$: $O(1)$
- $pop(S)$: $O(1)$
- $multipop(S, k)$: $O(min(s, k)) = O(n)$

By worst case analysis, we can say that the worst case complexity of any stack operation is $O(n)$, and thus, the worst case running time of $n$ operations will be $O(n^2)$. However, this is not a tight upper bound for the running time of $n$ operations.

By aggregate analysis, we can observe, that we can pop an object at most once, for each time we have pushed to the stack. Since there are $n$ operations, there can be at most $n$ pushes to the stack, so there can be at most $n$ pops from the stack (including those due to #multipop calls). Thus, the total running time can be bounded by $T(n) = O(n)$.

The average cost of an operation therefore, is $O(n) \/ n = O(1)$. So we say, all three stack operations have a constant amortized cost.

== What does this all mean?

Let $chevron.l "op"_1, "op"_2, ..., "op"_n chevron.r$ be a sequence of $n$ operations, with
- $c_i = $ actual cost of $"op"_i$
- $hat(c_i) = $ _amortized cost_ of $"op"_i$
- $T(n) = sum c_i = $ total running time of $n$ operations.

In *amortized analysis*, we assign values to $hat(c_i)$ such that the following inequality holds:

$
T(n) = sum_(i=1)^n c_i <= sum_(i=1)^n hat(c_i)
$

or in words: *For any sequence of $n$ operations, the total running time must be upper bounded by the sum of the amortized costs of the individual operations.*

For some operation $"op"_i$, $hat(c_i)$ is its _amortized cost_. Note that we do not make any claims about the running time of an individual operation. The actual running time of an operation ($c_i$) can be greater than the amortized cost ($hat(c_i)$). But the guarantee we do have, is that on performing $n$ operations, the total actual running time ($T(n)$) will be bounded by the total amortized costs.

In case of *aggregate analysis*, we assign $hat(c_i) = T(n) \/ n$. This is valid, because the inequality holds trivially: $sum_(i=1)^n hat(c_i) = n (T(n) \/ n) = T(n) >= T(n)$.

Note that, aggregate analysis assigns the same _amortized cost_ to all operations, even if there are operations of different types. Other methods of finding amortized cost may assign different costs to different types of operations, as we will see later.

== Incrementing a binary counter

Consider a $k$-bit binary counter that counts up from $0$, with the following #increment procedure:

#algorithm("Increment", params: ([$A$],))[
  #aline[$var("i") = 0$]
  #aline[#While $var("i") < A.var("length")$ #And $A[var("i")] == 1$]
  #aline(indent: 1)[$A[var("i")] = 0$]
  #aline(indent: 1)[$var("i") = var("i") + 1$]
  #aline[#If $var("i") < A.var("length")$]
  #aline(indent: 1)[$A[var("i")] = 1$]
]

The cost of an #increment operation is linear in the number of bits flipped. In the worst case, a single run of #increment can take $Theta(k)$ (when $A$ contains all 1s), so a sequence of $n$ #increment operations on an initially zero counter takes time $O(n k)$ in the worst case.

We can tighten our analysis to get a  worst case cost of $O(n)$ for a sequence of $n$ increment operations by observing a  pattern in when a bit flip occurs:

- $A[0]$ flips every time #increment is called.
- $A[1]$ flips every other call, so this bit will flip $floor(n \/ 2)$ times in a sequence of $n$ #increment calls.
- ...
- $A[i]$ will flip $floor(n \/ 2^i)$ times in a sequence of $n$ #increment calls.


So, the total number of bit flips that happen in $n$ #increment calls is:

$
sum_(i=0)^(k - 1) floor(n / 2^i) <= sum_(i=0)^oo n / 2^i = 2 n
$

Therefore, the worst case time for a sequence of $n$ increment operations  (on a initially 0 counter) is $O(n)$, so the amortized cost for each operation is $O(n) \/ n = O(1)$.

= Accounting Method

In this method, we assign differing charges to different operations, with some operations charged more/less than their actual cost. This hypothetical charge is called the *amortized cost*. The difference in an operation's amortized cost and actual cost is assigned as *credit* which can be used later when the amortized cost is less than the actual cost.

We require, that the following relation holds for any sequence of $n$ operations:

$
sum_(i=1)^n hat(c_i) >= sum_(i=1)^n c_i
$

or in other words, the total credit stored in the data structure must be non negative at all times.

This ensures that our sum of amortized costs does bound the total running time of $n$ operations, thus our assigned amortized costs are valid.

== Stack Operations

Recall that the actual costs of the operations are (in terms of number of elementary operations)
- #push: 1
- #pop: 1
- #multipop: $min(s, k)$

Consider a sequence of $n$ stack operations. We need to assign $hat(c_i)$ values to each type of operation, so that $sum_(i=1)^n hat(c_i) - sum_(i=1)^n c_i$ is *always* nonnegative.

We may use the following observation: Any element that has been pushed can be popped at most once (either by the #pop or the #multipop call). So, the total actual cost can never be more than twice the number of #push calls in the sequence.

So, we assign these amortized costs:

- #push: 2
- #pop: 0
- #multipop: 0

We can show that we can pay for any sequence of stack operations by charging these amortized costs. We start with an empty stack. Whenever we push an element we charge $2$ units, we pay $1$ unit to pay for the push, and we are left with $1$ unit of credit. So every element in the stack holds $1$ unit of credit which serves as the cost for popping it later.

When we execute a #pop operation, we don't need to charge anything, and pay for the pop by using the credit associated to that element on the stack. Similarly for multipop, its actual cost is the number of elements removed, which we pay using the credits on those elements. Therefore, we have always charged enough to pay for any sequence of $n$ operations, hence the total amortized cost is an upper bound on the total actual cost. 

Thus we can conclude, that #push, #pop, #multipop have an $O(1)$ amortized cost.


== Incrementing a binary counter

We only have one type of operation (#increment). We need to assign some amortized cost to this operation, so that any sequence of $n$ operations can be paid for, by charging the amortized cost.

Initially the counter is 0. The cost of an operation is linear in the number of bits flipped. Observe, that if a bit is being flipped from $1 -> 0$, then it must have been flipped from $0 -> 1$ before at some point. So, let's charge 2 units for every $0 -> 1$ flip, and 0 units for every $1 -> 0$ flip. By doing so, every $1 -> 0$ flip can be paid for by the credit stored due to its preceding $0 -> 1$ flip.

In each operation, observe that there is at most 1 flip which turns a $0$ to a $1$. So we can assign an amortized cost of $2$ units for each operation. By doing so, a sequence of $n$ operations can be paid for as

- We charge 2 units for each operation, 1 unit is used for the bit flip from 0 to 1, and 1 unit is stored as a credit.
- Each 1 bit in the counter holds 1 unit of credit. (invariant)
- Any 1 to 0 bit flips are paid for by the credits held by the corresponding bit.

Therefore, we conclude that the cost of #increment is $O(1)$ amortized.


= Potential Method

In this method, we associate the state of the data structure $D_i$ with a value $Phi(D_i)$ known as its *potential*, and $Phi$ is called the *potential function*.

Consider a sequence of $n$ operations, the $i$th operation has cost $c_i$. Let the state of the data structure be $D_i$ after the $i$th operation, and its initial state be $D_0$. We define the amortized cost $hat(c_i)$ values as follows:

$
hat(c_i) &= c_i + Phi(D_i) - Phi(D_(i - 1))\
&= c_i + Delta Phi(D_i) 
$

We need,

$
sum_(i=1)^n hat(c_i) &>= sum_(i=1)^n c_i\
=> sum_(i=1)^n (hat(c_i) - c_i) &>= 0\
=> sum_(i=1)^n Delta Phi(D_i) &>= 0\
=> Phi(D_n) &>= Phi(D_0)
$

WLOG we can take $Phi(D_0) = 0$. Since we require that for any sequence of $n$ operations, the sum of amortized costs should be at least the sum of total costs, so we can establish a stronger condition:

$
Phi(D_i) >= 0 "(for all" i")"
$

Intuitively, if the potential difference $Delta Phi(D_i)$ of the $i$th operation is positive, then the amortized cost $hat(c_i)$ represents a overcharge. If the potential difference is negative, amortized cost represents a undercharge, and the change in potential pays for the actual cost of the operation.

== Stack operations

Define the potential of a stack to be the number of elements in the stack. For the empty stack $D_0$, we have $Phi(D_0) = 0$ naturally. Since the number of elements in the stack is always non negative, we have $Phi(D_i) >= 0$ for all $i$.



We can now compute the amortized costs of each operation.

- #push:
  $
  hat(c_i) &= c_i + Phi(D_i) - Phi(D_(i - 1))\
  &= 1 + 1 = 2
  $

- #pop:

  $
  hat(c_i) &= c_i + Phi(D_i) - Phi(D_(i - 1))\
  &= 1 - 1 = 0
  $

- #multipop:
  $
  hat(c_i) &= c_i + Phi(D_i) - Phi(D_(i - 1))\
  &= k - k = 0
  $

So the amortized costs of all the operations are constant, and the worst case cost of $n$ operations is therefore $O(n)$.

This choice of potential is apt, because when we perform an expensive operation (#multipop), the change in potential is negative (number of elements in the stack decrease), and the decrease in potential pays for the operation (cost of the operation is covered by the decreased potential).

== Incrementing a binary counter

In this case, let us define the potential function $Phi(D_i)$ to be the number of 1s in the counter, $b_i$. This is always nonnegative, and for the starting state, $Phi(D_0) = b_0 = 0$.

To calculate the amortized cost of an increment operation, say that the number of trailing 1s in the current counter is $t_i$, then total bit flips is $1 + t_i$. Also note that $b_(i - 1) - b_i = t_i - 1$ (the change in the number of 1s by the $i$th operation is 1 less than the number of trailing ones).

Then,

$
hat(c_i) &= c_i + Phi(D_i) - Phi(D_(i - 1))\
&<= 1 + t_i - (t_i - 1) = 2
$

So, each #increment operation is amortized constant time, and a sequence of $n$ operations is $O(n)$ worst case.

We can also analyse this situation if the initial state is not $0$. In this case, our constraint that $Phi(D_i) >= Phi(D_0)$ may not hold, but still, we have the following equality (even if the counter doesn't start at 0! Why?):

$
sum_(i=1)^n c_i &= sum_(i=1)^n hat(c_i) - Phi(D_n) + Phi(D_0)\
=> sum_(i=1)^n c_i &<= 2 n - b_n + b_0
$

So, given that $k = O(n)$, the total actual cost is $O(n)$.



= Dynamic Tables

A dynamic table is a data structure which is a dynamically expanding and contracting memory block. Using amortized analysis, we can show such a data structure can have amortized constant time insertions and deletions, even though the actual costs of these operations can be large when an expansion or a contraction is triggered.

We define $alpha(T)$ (load factor) of an non empty table as:

$
alpha(T) = n / m = "number of items stored" / "total slots"
$

Define the load factor of an empty table to be $1$.

Our dynamic table supports the following operations:

#let table-insert = op("Table-Insert")
#let table-delete = op("Table-Delete")

- #table-insert: inserts an item into the table, which occupies one slot.
- #table-delete: removes an item from the table, freeing a slot.

== Expansion

Consider a dynamic table which only supports #table-insert calls. Assume that memory for a table is allocated as an array, and when all slots are used up, we need to *expand* the table by reallocating memory. Heuristically, we choose to double the size of the table upon expansion; this ensures that the amount of unused space never exceeds half of the total space in the table.

We can reason about the complexity of #table-insert by the number of elementary insertions required.

Consider a sequence of $n$ #table-insert operations. What is the cost $c_i$ of the $i$th operation? If the current table has room for the new item, then $c_i = 1$. Else, expansion occurs and $c_i = i$. The worst case cost of an operation is $O(n)$, so the total running time of $n$ operations is bounded by $O(n^2)$.

We can get a tighter bound by using aggregate analysis. Observe that the $i$th operation causes an expansion only when $i - 1$ is a power of 2. Thus,
$
c_i = cases(i quad &i - 1 "is a power of "2, 1 quad &"otherwise")
$

Therefore, the total cost of $n$ #table-insert operations is 

$
T(n) = sum_(i=1)^n c_i <= n + sum_(j=0)^floor(lg n) 2&j < n + 2n = 3 n
$

Thus, the amortized cost for each operation is at most 3.

We can justify this cost by the accounting method: Consider we charge 3 units per #table-insert operation. Each item pays for 3 elementary insertions: one unit for itself, one unit for moving it when the table needs to be expanded, and one for those elements which have already exhausted their credits (in the first half of the table).

We can also use the potential method to analyse a sequence of $n$ #table-insert operations. We define a potential fuction that is 0 immediately after expansion, but is equal to the table size when it is full.

- When the table is full, that's when the next operation is the expensive operation, so we need to have high potential (so that the drop in potential can pay for the expensive operation).
- Suppose the current size of the table is $m$ and it is full. Then, the next operation costs $m$ units for expansion, and $1$ more unit for adding the new element. So the drop in potential must at least pay for $m$. And at the point when we are exactly half full, we don't need to keep any additional credits (next insertions will be paid for by their charges), so we can take the potential of the half-filled table to be 0.
- Naturally, the potential of a full table of size $m$ must be $m$.

This leads to the following definition of the potential:

$
Phi(T) = 2 dot T."num" - T."size"
$

Since the load factor of the table is $>= 1/2$, this ensures that the potential is always positive. Thus the sum of amortized costs of $n$ #table-insert operations will give an upper bound for the sum of actual costs.

If  the $i$th operation does not trigger an expansion, then

$
hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
&= 1 + 2 dot "num"_i  - "size"_i - 2 dot ("num"_i - 1) + "size"_i\
&= 3
$

If the $i$th operation does trigger an expansion, then

$
hat(c_i) &= c_i + Phi_i - Phi_(i - 1) \
&= "num"_i + 2 dot "num"_i - "size"_i - 2 dot ("num"_i - 1) + "size"_i / 2\
&= "num"_i + 2 dot "num"_i - 2 dot ("num"_i - 1) - 2 dot ("num"_i - 1) + "num"_i - 1\
&= 3
$

So, all operations have an amortized cost of 3, and the total cost is bounded by $O(n)$.

== Expansion and Contraction

To implement #table-delete, we may simply remove the element from the table, and still we have all amortized constant time operations. However, we may wish to limit the unused space by contracting the table when the load factor becomes too small. We can achieve this by ensuring that the load factor is bounded below by a constant, and the amortized costs of the operations are constant time.

Suppose we say, that in addition to expanding the table whenever it is full, we also contract the table (to half its size) whenever the table becomes less than half full. However, this causes the amortized cost to be large. We can consider a scenario where the table is one more than half full, and then we do the following sequence operations:

$
"delete", bold("delete"), "insert", bold("insert"), "delete", bold("delete"), "insert", bold("insert"), ...
$

In this case, we can notice that every other operation (bolded) will trigger an expansion or a contraction which is an expensive operation, and takes $O(n)$ actual cost. So, the total cost of the sequence of operations will be at least $n^2 \/ 4 = Omega(n^2)$, which cannot be bounded by a linear function. Thus, the amortized costs are strictly worse than constant time.

We can improve upon this strategy by not immediately contracting, but waiting until the load factor drops below some other threshold. Say, we half the table whenever the table becomes less than a quarter full. Then, the load factor of the table is bounded below by $1\/4$.

We need to come up with a suitable potential function for this situation.

- The expensive operations are expansion and contraction, which happen when the load factor is 1 and 1/4 respectively. The actual costs of the expensive operations is $"num"_i$ in both cases.

- After performing an expansion/contraction, the table is exactly half full. So this is the state of minimum potential.

- During expansion, we need the potential drop to pay for the cost of the expansion ($"num"_i$). So when the table is completely full, the potential should be at least $"size"_i = "num"_i$.

- During contraction, we need the potential drop to pay for the cost of the contraction ($"num"_i$). So when the table is a quarter full, the potential should be at least $"size"_i\/4 = "num"_i$.

These observations lead us to the following potential function:

$
Phi(T) = cases(
  2 dot "num"_i - "size"_i quad &"if" alpha_i >= 1\/2,
  "size"_i \/ 2 - "num"_i quad &"if" alpha_i < 1\/2
)
$


The potential of an empty table is 0, and the potential function is always nonnegative; thus the sum of amortized costs of the function give an upper bound for the worst case actual cost of the sequence of $n$ operations.


Consider a sequence of $n$ operations. Let us compute the amortized costs of the operations.

1. #[The $i$th operation is #table-insert.

If $alpha_(i - 1) >= 1\/2$ (the table was at least half full before this insertion), then the next insertion may or may not trigger an expansion. The computation of $hat(c_i)$ is exactly the same as done in the expansion-only case. So we know that the $hat(c_i)$s are constant.

If $alpha_(i - 1) < 1\/2$ (the table was less than half full before this insertion), then this insertion couldn't have triggered an expansion.

- If $alpha_i >= 1\/2$, then $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1) \ &= 1 + (2 dot "num"_i - "size"_i) - ("size"_i / 2 - "num"_i + 1)\
  &= 3 dot "num"_i - 3/2 "size"_i\
  &= 3 + 3 dot "num"_(i - 1) - 3/2 "size"_(i - 1)\
  &= 3 + 3 alpha_(i - 1) "size"_(i - 1) - 3/2 "size"_(i - 1)\
  &< 3 + 3/2 "size"_(i - 1) - 3/2 "size"_(i - 1) = 3
  
  $

- If $alpha_i < 1\/2$, then

  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
  &= 1 + "size"_i / 2 - "num"_i - ("size"_i / 2 - "num"_i + 1) = 0
  $

Again, $hat(c_i)$ is bounded by a constant. Hence, #table-insert runs in amortized constant time.

]

2. #[The $i$th operation is #table-delete.

If $alpha_(i - 1) < 1\/2$ (the table was less than half full before this deletion), then the next deletion may or may not trigger an contraction. 

- No contraction ($"size"_i = "size"_(i - 1)$, $"num"_i = "num"_(i - 1) - 1$)

  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1) \
  &= 1 + "size"_i / 2 - "num"_i - ("size"_i / 2 - "num"_i - 1) = 2
  $

- Contraction ($"size"_i = "size"_(i - 1) \/ 2$, $"num"_i = "num"_(i - 1) - 1$, $"num"_i <= "size"_(i - 1) \/ 4 = "size"_i \/ 2$)

  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1) \
  &= "num"_i + "size"_i / 2 - "num"_i - ("size"_i - "num"_i - 1)\
  &= 1 + "num"_i - "size"_i / 2\
  &<= 1
  $

So, the amortized cost is bounded by a constant in this case.

If $alpha_(i - 1) >= 1\/2$ (the table was at least half full before this deletion), then this deletion couldn't have triggered a contraction.

- If $alpha_i >= 1\/2$, then $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1) \ &= 1 + (2 dot "num"_i - "size"_i) - (2 dot ("num"_i + 1) - "size"_i)\
  &= -1
  
  $

- If $alpha_i < 1\/2$, then

  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
  &= 1 + ("size"_i / 2 - "num"_i) - (2 dot ("num"_i + 1) - "size"_i)\
  &= 3/ 2 dot "size"_i - 3 dot "num"_i - 1\
  &= 3/ 2 dot "size"_(i - 1) - 3 dot "num"_(i - 1) + 2\
  &= 3/ 2 dot "size"_(i - 1) - 3 dot alpha_(i - 1) "size"_(i - 1) + 2\
  &<= 3/ 2 dot "size"_(i - 1) - 3/2 dot "size"_(i - 1) + 2 = 2\
  $

Again, $hat(c_i)$ is bounded by a constant. Hence, #table-delete runs in amortized constant time.

]

#v(3em)

#align(center, line(length: 40%))


#pagebreak()

= Problems

1. Recall the dynamic table data structure discussed in class. Suppose that instead of contracting a table by halving its size when its load factor drops below $1/4$, we contract it by multiplying its size by $2/3$ when its load factor drops below $1/3$. Show that insert and delete operations take $O(1)$ amortized time.

#soln-box[

Here, expansion happens when the table is full ($alpha = 1$), and contraction happens when the table is a third full ($alpha = 1/3$). After expansion/contraction, we reach a situation where the table is exactly half full. So we need to find a potential function which is $0$ when $"num"_i = "size"_i \/ 2$; $"num"_i$ when the table is full; and $"num"_i$ when $"num"_i = "size"_i \/ 3$.

So, we can use the following potential function:

$
Phi(T) &= cases(
  2 dot "num"_i - "size"_i quad &"if" alpha >= 1\/2,
  "size"_i - 2 dot "num"_i quad &"if" alpha < 1\/2
)\
&= lr(|2 dot "num"_i - "size"_i|)
$

Clearly, the potential function is non negative everywhere, so the sum of amortized costs of a sequence of operations upper bounds the sum of actual costs.

Let us calculate the amortized costs for the operations.

#table-insert:
- If $alpha_(i - 1) >= 1\/2$,
  - If an expansion took place,  
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= "num"_i + (2 dot "num"_i - "size"_i) -  (2 dot "num"_(i - 1) - "size"_(i - 1))\
    &= "num"_(i - 1) + 1 + (2 dot "num"_(i - 1) + 2 - 2 dot "size"_(i - 1)) -  (2 dot "num"_(i - 1) - "size"_(i - 1))\
    &= 3 + "num"_(i - 1) - "size"_(i - 1)\
    &= 3
    $
  - If no expansion took place,
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + (2 dot "num"_i - "size"_i) - (2 dot ("num"_i - 1) - "size"_i)\
    &= 3
    $
- If $alpha_(i - 1) < 1\/2$,
  - If $alpha_i < 1\/2$,
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + ("size"_i - 2 dot "num"_i) - ("size"_i - 2 dot ("num"_i - 1))\
    &= -1
    $
  - If $alpha_i >= 1\/2$,
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + (2 dot "num"_i - "size"_i) - ("size"_i - 2 dot ("num"_i - 1))\
    &= 1 + 2 dot "num"_i - "size"_i - "size"_i + 2 dot "num"_i - 2\
    &= 4 dot "num"_i - 2 dot "size"_i - 1\
    &= 4 dot "num"_(i - 1) - 2 dot "size"_(i - 1) + 3\
    &= 4 alpha_(i - 1) "size"_(i - 1) - 2 dot "size"_(i - 1) + 3\
    &< 2 dot "size"_(i - 1) - 2 dot "size"_(i - 1) + 3 = 3
    $
Thus, in all cases, the amortized costs is bounded by a constant. So, #table-insert is $O(1)$ amortized.

#table-delete:

- If $alpha_(i - 1) < 1\/2$
  - If contraction takes place
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= "num"_i + ("size"_i - 2 dot "num"_i) - ("size"_(i - 1) - 2 dot "num"_(i - 1))\
    &= "num"_(i - 1) - 1 + 2 / 3 dot "size"_(i - 1) - 2 dot "num"_(i - 1) + 2 - "size"_(i - 1) + 2 dot "num"_(i - 1)\
    &= 1 + "num"_(i - 1) - 1/3 dot "size"_(i - 1)\
    &= 2 + "num"_(i) - 1/3 dot "size"_(i - 1)\
    &<= 2
    $
  - If no contraction takes place
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + ("size"_i - 2 dot "num"_i) - ("size"_(i - 1) - 2 dot "num"_(i - 1))\
    &= 1 + ("size"_i - 2 dot "num"_i) - ("size"_(i) - 2 dot "num"_(i) - 2)\
    &= 3
    $
- If $alpha_(i - 1) >= 1\/2$,
  - If $alpha_i >= 1\/2$
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + (2 dot "num"_i - "size"_i) - (2 dot "num"_(i - 1) - "size"_(i - 1))\
    &= 1 + (2 dot "num"_i - "size"_i) - (2 dot "num"_(i) + 2 - "size"_(i))\
    &= - 1
    $
  - If $alpha_i < 1\/2$
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1) \
    &= 1 + ("size"_i - 2 dot "num"_i) - (2 dot "num"_(i - 1) - "size"_(i - 1))\
    &= 1 + ("size"_i - 2 dot "num"_i) - (2 dot "num"_(i) + 2 - "size"_(i))\
    &= 2 dot "size"_i - 4 dot "num"_i - 1\
    &= 2 dot "size"_(i - 1) - 4 dot "num"_(i - 1) + 3\
    &= 2 dot "size"_(i - 1) - 4 alpha_(i - 1) dot "size"_(i - 1) + 3\
    &<= 2 dot "size"_(i - 1) - 2 dot "size"_(i - 1) + 3 = 3
    $

Again, in all cases the amortized cost is upper bounded by a constant.

Thus, the amortized costs for both insertions and deletions is $O(1)$.

]

#let insert = op("Insert")
#let delete-larger-half = op("Delete-Larger-Half")


2. Design a data structure to support the following operations for a dynamic multiset $S$ of integers, which allows duplicate values:
  - $insert(S, x)$: inserts $x$ into $S$.
  - $#delete-larger-half;(S)$: deletes the largest $ceil(lr(|S|)\/2)$ elements from $S$.
  Explain how to implement this data structure so that the amortized time complexity of #insert and #delete-larger-half is $O(1)$.

#soln-box[

We use a linked list/array as the underlying data structure for storing the elements, to support $O(1)$ insertions.

- $insert(S, x)$: Insert $x$ to the linked list. ($O(1)$, actual cost: 1)
- $#delete-larger-half;(S)$: ($O(n)$, actual cost bounded by: $k n$ (say)) 
  1. Find the element at rank $ceil(n\/2)$ by using linear time selection (quickselect / median of medians).
  2. Delete all elements that are greater than or equal to this pivot.

Consider any sequence of $n$ operations. Let us assign the following charges to each operation:

- #insert: $hat(c_i) = 1 + 2 k$
- #delete-larger-half: $hat(c_i) = 0$

We can show that by charging these amounts for each operation, we can pay for all operations while keeping a nonnegative credit.

For each element stored in the data structure, we keep $2k$ credit per item. When we have a #delete-larger-half call, we can use up the $ceil(n \/ 2) times 2 k >= n k$ credits of the deleted nodes to perform the deletion itself. The total credits always is nonnegative since number of elements in the array is nonnegative.

Hence, both operations are amortized constant time.
]
#let extract-min = op("Extract-Min")

3. Consider an ordinary binary min-heap data structure with $n$ elements supporting the instructions #insert and #extract-min in $O(log n)$ worst case time. Show that the amortized cost of #insert is $O(log n)$ and #extract-min is $O(1)$ time.

#soln-box[
Since every #extract-min operation corresponds to an #insert operation, we can charge $2 log n$ units for each #insert operation, so that each element present in the heap holds enough credits, to pay for the corresp\onding #extract-min operation. Thus, we can assign the following amortized costs:
- #insert: $2 log n$
- #extract-min: $0$

Since the total credits present is always nonnegative, the sum of the amortized costs upper bounds the total actual cost for any sequence of operations. Therefore, the amortized cost of #insert is $O(log n)$ and #extract-min is $O(1)$.
]
4. What is the total cost of executing $n$ stack operations #push, #pop and #multipop, assuming that the stack begins with $s_0$ objects and ends with $s_n$ objects?

#soln-box[
Let us take the potential function $Phi(D_i) = s_i$ to be the number of elements in the stack. We have amortized costs:
- #push: 2
- #pop: 0
- #multipop: 0

Then, we have the relation:

$
sum_(i=1)^n hat(c_i) = sum_(i =1)^n c_i + s_n - s_0\
=>sum_(i=1)^n c_i <= 2 n + s_0 - s_n
$

So, the total cost is bounded by $2n + s_0 - s_n$, or $O(n + s_0)$

]

#let decrement = op("Decrement")

5. Show that if a #decrement operation is included in the $k$-bit counter example, $n$ operations can cost as much as $Theta(n k)$ time.

#soln-box[
Consider the following sequence of $n = 2^k$ operations: A series of $2^(k-1)$ #increment operations, followed by an alternating sequence of $2^(k - 1)$ #decrement and #increment operations.

The initial sequence of #increment operations bring the counter to the value $2^(k - 1)$. This takes $O(n)$ time, since each #increment is amortized constant time.

Then, we are followed by pairs of #decrement and #increment operations. Both of them run in $Theta(k)$ (actual cost), since both these operations need to change all $k$ bits of the number. Since we have $n/2$ such operations, the total cost is $Theta(n k)$.

Therefore, the total cost of all $n$ operations takes $O(n) + Theta(n k) = Theta(n k)$ time.

]
#let multipush = op("Multipush")

6. If the set of stack operations includes a #multipush operation, which pushes $k$ items onto the stack, does the $O(1)$ bound on the amortized cost of stack operations continue to hold?

#soln-box[

No. Similar to the previous problem, we can have an alternating sequence $n$ of $multipush(S, k)$ and $multipop(S, k)$ operations, whose actual running time will be $Theta(n k)$. Thus, the $O(1)$ bound on the amortized costs don't hold.
]
7. You perform a sequence of #push and #pop operations on a stack whose size never exceeds $k$. After every $k$ operations, a copy of the entire stack is made automatically, for backup purposes. Show that the cost of $n$ stack operations, including copying the stack, is $O(n)$ by assigning suitable amortized costs to the various stack operations.

#soln-box[

Assign the following charges to the operations:

- #push: 2
- #pop: 2
- Backup: 0

Then, we know that each push and pop operation costs 1 unit, and the other unit of cost accumulates as credit. Each backup operation costs $k$ units, but that can be paid for by the $k$ credits from the last $k$ operations. Thus, the sum of amortized costs upper bounds the total running time of $n$ operations, hence, the total cost is $O(n)$.
]


#let reset = op("Reset")

8. You wish not only to increment a counter but also to reset it to 0 (i.e., make all bits in it 0). Counting the time to examine or modify a bit as $Theta(1)$, show how to implement a counter as an array of bits so that any sequence of n #increment and #reset operations takes $O(1)$ time on an initially zero counter.


#soln-box[
We know that charging 2 units per operation is enough to pay for $n$ increment operations. Now, we also need to account for #reset operations, which can be $O(k)$ in the worst case.

Firstly, for it to not always take $O(k)$, we should maintain an index `max_bit` to know the highest order bit that needs to be reset; all higher order bits are zero and thus don't need to be modified.

After the $i$th operation, let $b_i$ be the number of 1s in the counter, and $k_i$ be the index of the highest $1$ bit.

Define the potential function as:
$
Phi(D_i) = b_i + k_i
$

Justification:

- An expensive increment operation should be compensated by the drop in potential. The cost of the increment operation is $b_(i - 1) - b_i + 2$ which is covered by the drop in first term of the potential ($b_(i - 1) -> b_i)$.

- A reset operation should be compensated by the change in potential. The cost of the reset operation is $k_(i - 1)$. The drop in the second term of the potential covers this cost ($k_(i - 1) -> 0$).

Since the potential is always nonnegative, the sum of amortized costs gives a bound on the total running time of $n$ operations.

Amortized costs:

- #increment

  $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= b_(i - 1) - b_i + 2 + b_i - b_(i - 1) + k_i - k_(i - 1)\
    &= 2+ k_i - k_(i - 1)\
    &<= 3
  $
- #reset

  $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= k_(i - 1) + b_i - b_(i - 1) + k_i - k_(i - 1)\
    &= - b_(i - 1)\
    &<= 0
  $

Thus, both #increment and #reset work in amortized $O(1)$ cost.

]

9. *[Queue using two stacks]* A queue is implemented using two stacks:
  - Stack $S_1$ stores newly enqueued elements.
  - Stack $S_2$ is used for deletions.
  - If $S_2$ is empty during dequeue, all elements of $S_1$ are moved to $S_2$.

  + What is the worst case cost of one dequeue? Answer in $Theta$ notation and justify.
  + Prove that both enqueue and dequeue have an amortized cost of $O(1)$.

#let enqueue = op("Enqueue")
#let dequeue = op("Dequeue")

#soln-box[

Let us consider elementary push and pop operations on each stack to cost 1 unit.

Suppose the queue contains $n$ elements. For a #dequeue operation, the worst case is when $S_2$ is empty and all $n$ elements are stored in $S_1$. Then, first we need to move all elements from $S_1$ to $S_2$ and then pop out the top element in $S_2$ to delete the earliest inserted element. This runs in $Theta(n)$ time (worst case time for #dequeue).

For amortized analysis, let us define a potential function on the state of the two stacks. Here, the expensive operation is the worst case dequeue operation, i.e. a dequeue that takes place when $S_2$ is empty. In this case, we need to move all elements from $S_1$ and then pop one element from $S_2$, so the cost of this operation is $2n + 1$.

Cost of enqueue operation, and a non expensive dequeue operation is $1$. So, to show that all operations are amortized $O(1)$, we need to choose our potential function, such that the drop in potential due to an expensive pays for the operation's cost.

Let us choose the potential function:

$
Phi(Q) = 2|S_1|
$
i.e. twice the number of elements in the stack $S_1$.

Clearly, the potential function is always nonnegative, and the starting potential is 0 (both stacks are empty). Thus, the sum of amortized costs will bound the total running time of $n$ operations.

Let us calculate the amortized costs.

- #enqueue:
  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
  &= 1 + 2 = 3
  $
- Inexpensive #dequeue:
  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
  &= c_i\
  &= 1
  $

- Expensive #dequeue:
  $
  hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
  &= 2n + 1 + 0 - 2n\
  &= 1
  $

So, we assign the following amortized costs:
- #enqueue: 3
- #dequeue: 1

Therefore, both the operations run in amortized constant time.

We can also give an intuitive justification for these costs by the accounting method. With every enqueue we push an element to stack $S_1$, we charge 3 units, out of which 1 unit is paid for the push, and 2 units are stored as credit for that element.

Whenever we perform a dequeue operation, we only charge 1 unit, which is used for the final pop operation on $S_2$. Before that, we may need to move every element from $S_1$ to $S_2$. This will be paid for by the 2 units of credits stored on each element in $S_1$. Since all operations can be performed with the total credits staying non negative, both operations have an amortized $O(1)$ cost.

]


10. *[Dynamic Table]* Consider the dynamic table data structure discussed in class. Suppose we double the table size when the table becomes $3/4$th full and half the table when it becomes $1/4$th full. Prove that the amortized time complexity of both #table-insert and #table-delete is $O(1)$.

#soln-box[
In this case, expansion happens when $alpha = 3/4$. Immediately after the expansion, $alpha = 3/8$. Contraction happens when $alpha = 1/4$, and just after contraction, $alpha = 1/2$.

We can require the potential function to be $"num"_i$ at the extreme points of the load factor, i.e. when $"num"_i = "size"_i dot 3 / 4$ and $"num"_i = "size"_i dot 1/4$, and $0$ right after expansion/contraction ($"num"_i / "size"_i = 3/8$ and $1/2$) so that the drop in potentials  during the expensive operations pay for their actual costs.

Let us choose the following potential function:

$
Phi(D_i) = cases(
  3/4 "size"_i - 2 "num"_i quad &"if" alpha <= 3/8,
  0 quad &"if" 3/8 < alpha <= 1/2,
  3 "num"_i - 3/2 "size"_i quad &"if" alpha > 1/2
)
$

We can verify:

- at $alpha = 3/4$, $Phi =3/4 "size"_i = "num"_i$

- at $alpha = 1/4$, $Phi = 1/4 "size"_i = "num"_i$
- at $alpha = 3/8$, $Phi = 0$
- at $alpha = 1/2$, $Phi = 0$


Since the potential is always non negative, sum of amortized costs of $n$ operations will upper bound their total actual costs. To compute the amortized costs:


#table-insert:
- If $alpha_(i - 1) > 1\/2$,
  - If an expansion took place,  
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= "num"_i + 0 - (3 dot "num"_(i - 1) - 3/2 dot "size"_(i - 1))\
    &= 4
    $
  - If no expansion took place,
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + (3 dot "num"_i - 3/2 dot "size"_i) - (3 dot ("num"_i - 1) - 3/2 dot "size"_i)\
    &= 4
    $
- Standard processing applies for configurations where $alpha_(i - 1) <= 1\/2$, e.g.
    $
    hat(c_i) &<= 1 + (3/4 dot "size"_i - 2 dot "num"_i) - (3/4 dot "size"_i - 2 dot ("num"_i - 1)) = -1
    $

#table-delete:

- If $alpha_(i - 1) <= 3\/8$,
  - If contraction takes place,
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= "num"_i + 0 - (3/4 dot "size"_(i - 1) - 2 dot "num"_(i - 1))\
    &= 2
    $
  - If no contraction takes place,
    $
    hat(c_i) &= c_i + Phi_i - Phi_(i - 1)\
    &= 1 + (3/4 dot "size"_i - 2 dot "num"_i) - (3/4 dot "size"_i - 2 dot ("num"_i + 1))\
    &= 3
    $
- Standard processing applies for configurations where $alpha_(i - 1) > 3\/8$, e.g.
    $
    hat(c_i) &<= 1 + (3 dot "num"_i - 3/2 dot "size"_i) - (3 dot ("num"_i + 1) - 3/2 dot "size"_i) = -2
    $

Therefore, both operations are of amortized $O(1)$ complexity.
]



#align(center, line(length: 40%))
