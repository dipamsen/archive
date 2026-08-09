#import "template.typ": project, infobox
#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2": plot, chart
#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "algorithmic.typ"
#import algorithmic: style-algorithm, algorithm-figure
#show: style-algorithm

#show: project.with(
  title: "Assignment 3",
  subtitle: "Algorithmic Paradigms"
)

#let high1 = text.with(fill: rgb("#8c0000"))

#set enum(numbering: it => [#strong(high1([#it.]))])

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

#let algorithm-figure = algorithm-figure.with(style: strong)


#let dp = "dp"

Note: Sets and arrays are assumed to be 1-indexed, unless otherwise mentioned.

#quest[3.6.1][
  *(Heaviest Sparse Set)* Let $S$ be an #high1[ordered set] of $n$ elements, with each one having a positive weight. A subset $S' subset.eq S$ is called a *sparse set* if it contains no two consecutive elements of $S$; its weight is defined as the sum of the weights of its elements.\ 
  Design an algorithm to compute the weight of a heaviest sparse subset of $S$. Prove its correctness, and analyze its time and space complexities. Show a demonstration of your algorithm to obtain the output for the input set $S = {1, 5, 3, 3, 5, 7, 3}$. 
]
#ans[
  Denote the weights of elements of $S$ as $w_1, w_2, ..., w_n$.
  
  *Optimal Substructure:* Consider $S'$ to be a heaviest sparse set of $S[1..i]$. This subset either contains the $i$th element, or it doesn't.

  - If $i$th element is contained in it, then the $(i-1)$th element cannot be contained in it. Other than the $i$th element, the remaining elements form a subset of $S[1..i-2]$. This must be a heaviest sparse set of $S[1..i-2]$. (Otherwise, we could use a heavier sparse set of $S[1..i-2]$ to get a heavier sparse set of $S[1..i]$, a contradiction).
  - If $i$th element is not contained in it, the set $S'$ is a subset of elements of $S[1..i-1]$. Then $S'$ must be a heaviest sparse set of $S[1..i-1]$. (Otherwise, we could use a heavier sparse set of $S[1..i-1]$ to get a heavier sparse set of $S[1..i]$, a contradiction).

  Denote the weight of a  heaviest sparse set of $S[1..i]$ as $f[i]$. Then,

  $
  f[i] &= max(f[i - 1], f[i - 2] + w_i) quad quad &i >= 2\
  &= w_1 &i = 1\
  &= 0 &i = 0
  $

  We can compute $f[i]$ using bottom-up DP:

  #algorithm-figure(
  "Heaviest Sparse Set",
  vstroke: 1pt + luma(200),
  {
    import algorithmic: *
    Procedure(
      "Heaviest-Sparse-Set",
      ("S"),
      {
        // Comment[Initialize the search range]
        Assign[$f[0]$][$0$]
        Assign[$f[1]$][$S[0]$]
        LineBreak
        Assign[$i$][$2$]
        For(
          $i <= n$,
          {
            Assign[$f[i]$][$max(f[i - 1], f[i - 2] + S[i])$]
          }
        )
        Return[$f[n]$]
      },
    )
  }
)

  *Proof of Correctness:* We can inductively prove correctness of the algorithm.

  #high1[[Basis]] 

  - For $n = 1$, there is only one element so the weight of the heaviest sparse set is the weight of the element itself. Our algorithm gives the correct result since it defines $f[1] = w_1$.
  - For $n = 2$, there are two elements, but they cannot be simultaneously be present in a sparse set. Thus the weight of the heaviest sparse set is $max(w_1, w_2)$. Our algorithm will give $f[2] = max(f[1], f[0] + w_2) = max(w_1, w_2)$, which is correct.

  #high1[[Inductive Step]] Assume the algorithm is correct for $n = i - 1$, $i - 2$. By the optimal substructure property, we know the optimal value for $n = i$ is $max(f[i - 1] ,f[i - 2] + w_i)$, which matches our algorithm.

  *Time and Space Complexity*

  #high1[Time complexity:] $O(n)$, since we loop once through $n$, each iteration taking constant time.

  #high1[Space complexity:] $O(n)$, for storing $f$. 

  Since we don't need the entire array for computation, we may only store the last two elements of the array. Then we only need $O(1)$ additional space.

  *Demonstration*

  Consider $S = {1, 5, 3, 3, 5, 7, 3}$.


    #figure(table(
      columns: (2em, 40pt, 60pt, 45pt, 50pt, 45pt, auto),
      align: (x, y) => if x == 2 and y != 0 { left } else { horizon + center },
      stroke: (x, y) => if y > 0 { (top: if calc.even(y) and y != 2 { 0pt } else { 0.7pt }) } + if x > 0 { (left: 0.5pt )},
      [$i$], [$S[i]$], $f[i]$, [$S'$], [$W(S')$], [$S^*$], [$W(S^*) = f[i]$],
      table.hline(stroke: 1pt),
      [0], [], [0], [${}$], [0], [${}$], [0],
      [1], [1], [1], [${1}$], [1], [${1}$], [1],
      table.cell(rowspan:2)[2], table.cell(rowspan:2)[5], 
      [$f[1]$], [${1}$], [1], table.cell(rowspan:2)[${5}$], table.cell(rowspan:2)[5], 
      table.hline(stroke: 0.7pt + accent),
      [$f[0] + 5$], [${5}$], [5],
      table.cell(rowspan:2)[3], table.cell(rowspan:2)[3], [$f[2]$], [${5}$], [5], table.cell(rowspan:2)[${5}$], table.cell(rowspan:2)[5], 
      table.hline(stroke: 0.7pt + accent), $f[1] + 3$,
      [${1, 3}$], [4],
      table.cell(rowspan:2)[4], table.cell(rowspan:2)[3], $f[3]$, [${5}$], [5], table.cell(rowspan:2)[${5, 3}$], table.cell(rowspan:2)[8], 
      table.hline(stroke: 0.7pt + accent), $f[2] + 3$,
      [${5, 3}$], [8],
      table.cell(rowspan:2)[5], table.cell(rowspan:2)[5], $f[4]$, [${5, 3}$], [8], table.cell(rowspan:2)[${5, 5}$], table.cell(rowspan:2)[10], 
      table.hline(stroke: 0.7pt + accent), $f[3] + 5$,
      [${5, 5}$], [10],
      table.cell(rowspan:2)[6], table.cell(rowspan:2)[7], 
      table.hline(stroke: 0.7pt + accent), $f[5]$,
      [${5, 5}$], [10], table.cell(rowspan:2)[${5, 3, 7}$], table.cell(rowspan:2)[15], $f[4] + 7$, [${5, 3, 7}$], [15],
      table.cell(rowspan:2)[7], table.cell(rowspan:2)[3], 
      table.hline(stroke: 0.7pt + accent), $f[6]$,
      [${5, 3, 7}$], [15], table.cell(rowspan:2)[#hl(${5, 3, 7}$)], table.cell(rowspan:2)[
        #hl[15]
      ], $f[5] + 3$, [${5, 5, 3}$], [13],
    ), kind: image, caption: [Calculations for finding the weight of a heaviest sparse subset of the set ${1, 5, 3, 3, 5, 7, 3}$])

    #infobox[
      Note that our algorithm does not keep track of the actual subsets, nor does it find it by backtracking. The algorithm works just on the weights of subsets. The sets themselves are shown here just for clarity.
    ]
]

#pagebreak()

#quest[3.6.2][
  *(Minimize recharge)* Mr. Singh drives his electric car from Srinagar to Kanyakumari along the highway NH-44. His car's battery, when fully charged, can travel $k$ kilometers. The built-in map of his car indicates the distances between charging stations on his route. Mr. Singh started with a full charge from Srinagar and wishes to make as few charges as possible along the way. \
  Design an efficient algorithm to determine at which charging stations he should stop, and prove that your strategy yields an optimal solution. Justify its time complexity.
]

#ans[
  Let there be $n$ charging stations along the route from Srinagar to Kanyakumari, numbered $1$ to $n$. Thus there are $n + 1$ segments of the path divided by the charging stations. Lets denote these as $a_0, a_1, ..., a_n$. The segment that comes after charging station $i$ is $a_i$.

  Consider the greedy strategy: Choose to charge at a charging station $i$ if the next segment ($a_i$) cannot be covered by the current charge. 

  #let a = (7, 2, 3, 4, 1, 3, 4, 5, 2, 7, 3, 2)
  // #a.sum()
  //        |   |        |     |     |     |  

  #algorithm-figure(
    "Minimize Recharge",
    vstroke: 1pt + luma(200),
    {
      import algorithmic: *
      Procedure(
        "Minimize-Recharge-Greedy",
        ("A", "k"),
        {
          Assign[stations][$[]$]
          Assign[charge][$k$]
          LineBreak
          For(
            [$i <- 0$ *to* $n$],
            {
              If(
                $"length("a_i")" > k$,
                {
                  Return[$oo$]
                }
              )
              LineBreak
              If(
                $"length("a_i")" > "charge"$,
                {
                  Line[*append* $i$ *to* stations]
                  Assign[charge][$k$]
                }
              )
              Assign[charge][$"charge" - "length"(a_i)$]
            }
          )
          Return[stations]
        },
      )
    }
  )

  *Proof of Correctness*

  1. *Validity:* By definition, the greedy strategy is a valid one, since it simulates the charge of the car's battery at every station, and it ensures that at no point will the charge be $<= 0$.

  2. *Optimality:*

  // Let $S^* = {s^*_1, s^*_2, ..., s^*_p}$ be an optimal solution, and $S = {s_1, s_2, ..., s_q}$ be the output of our algorithm. Here $S$ and $S^*$ are the set of stations where Mr. Singh must charge his car.

  // Assume that $|S^*| < |S|$ ($p < q$), that is the proposed strategy does not give an optimal solution.

  // Clearly, $S^*$ is different from $S$. We claim that there must exist some $i, 1 <= i <= p$ such that $s^*_i != s_i$.

  // Then, we have two cases:

  // - $s^*_i < s_i$: 

  Let us show that there must exist a optimal solution with the same choice as the greedy strategy for its first halt.

  From the starting point (Srinagar), the greedy strategy will choose to halt at the farthest reachable station (given the current charge = $k$). Say this station is station $r$. If any solution chooses to stop and charge at some station $r' < r$, then pushing the halt to $r$ does not increase the number of charges required. Thus an optimal solution must exist with the first choice the same as the greedy choice.

  Now, note that after the first choice of halting, the car is fully charged, and the remaining problem is equivalent to the original problem, with a smaller input size. Thus we have an optimal substructure, and by induction it follows that the greedy approach is optimal for the entire problem.

  *Time Complexity*

  We loop over every path segment and in each iteration we chose to charge or not charge in $O(1)$ time. Thus the overall time complexity of the algorithm is $O(n)$.
]

#pagebreak()

#quest[3.6.3][
  *(Min-max red-blue pairing)* There are $n$ red points and $n$ blue points placed along a horizontal line. Their positions are given in arrays $R[1..n]$ and $B[1..n]$ respectively. Suggest an algorithm to pair up each red point with exactly one blue point, such that the *maximum pair-gap* is minimized. Prove its correctness and write its time complexity. Note: The *pair-gap* between two points refers to the absolute difference of their positions.
]

#ans[
  *Observation* 

  Consider $r_1 < r_2$ and $b_1 < b_2$ to be 2 pairs of points. There exists two red-blue pairings for these points:

  1. $r_1$-$b_1$ and $r_2$-$b_2$: maximum pair gap $= max(|r_1 - b_1|, |r_2 - b_2|)$
  2. $r_1$-$b_2$ and $r_2$-$b_1$: maximum pair gap = $max(|r_1 - b_2|, |r_2 - b_1|)$

  We claim that pairing 1 is always optimal, i.e. the maximum pair gap for pairing 1 is less than or equal to that of pairing 2.

  We can prove the claim by considering each case for $r_1, r_2, b_1, b_2$:
  - $r_1 < r_2 <= b_1 < b_2$: $max(|r_1 - b_1|, |r_2 - b_2|) <= max(|r_1 - b_2|, |r_2 - b_1|) = b_2 - r_1$
  - $b_1 < b_2 <= r_1 < r_2$: Equivalent to the previous case.
  - $r_1 <= b_1 < b_2 <= r_2$: $|r_1 - b_1| < |r_1 - b_2|$ and $|r_2 - b_2| < |r_2 - b_1|$, thus $max(|r_1 - b_1|, |r_2 - b_2|) <= max(|r_1 - b_2|, |r_2 - b_1|)$
  - $b_1 <= r_1 < r_2 <= b_2$: Equivalent to previous case.
  - $r_1 <= b_1 <= r_2 <= b_2$: $max(|r_1 - b_1|, |r_2 - b_2|) <= max(|r_1 - b_2|, |r_2 - b_1|) = b_2 - r_1$
  - $b_1 <= r_1 <= b_2 <= r_2$: Equivalent to previous case.

  Thus we have shown that for two pairs of points, it is optimal to pair them in a 'non-crossing' manner, to minimize the maximum pair gap.

  This leads to the following greedy algorithm: Sort both the arrays, and pair the $i$th red point with the $i$th blue point.
  
  #algorithm-figure(
    "Min-Max Red-blue Pairing",
    vstroke: 1pt + luma(200),
    {
      import algorithmic: *
      Procedure(
        "Greedy-RedBlue-Pairing",
        ("R", "B"),
        {
          Fn("sort", ("R"))
          Fn("sort", ("B"))
          Assign[pairings][[]]
          For(
            $i <- 1 "to" n$,
            Line[append into pairings $(R_i, B_i)$]
          )
          Return[pairings]
        }
      )
    }
  )

  *Proof of Correctness*

  Consider a pairing with some $i$ where $R_i$ is paired with $B_j$, $j != i$. WLOG assume that $j > i$. There must exist some $k > i$ such that $R_k$ is paired with some $B_m$, $m < j$. (Pigeonhole principle)

  We say, this pairing has a crossing pair of points. We can always get a better (or equivalent) pairing by uncrossing the pairs, i.e. by removing pairs $(R_i, B_j)$ and $(R_k, B_m)$, and replacing them with the pairs $(R_i, B_m)$ and $(R_k, B_j)$. We have shown this above. 

  Thus from any pairing if we repeatedly do the uncrossing process, we get a non-crossing pairing, finally reaching the pairing $P, (R_i, B_i) in P thick  forall i $; which is what our greedy algorithm returns.

  *Time Complexity*

  Sorting dominates the complexity, $O(n lg n)$.
]

#pagebreak()

#quest[3.6.4][
  *(Minimum operating cost)* Suppose you are running a lightweight consulting business. Your clients are distributed between the East Coast and the West Coast, and this leads to the following question.\
  Each month, you can either run your business from an office in New York (NY) or from an office in San Francisco (SF). In month $i$, you’ll incur an operating cost of $N_i$ if you run the business out of NY or an operating cost of $S_i$ if you run it out of SF. However, if you run the business out of one city in month $i$, and then out of the other city in month $i + 1$, then you incur a fixed moving cost of $M$ to switch base offices. \
  Given a sequence of $n$ months, a plan is a sequence of $n$ locations—each one equal to either NY or SF—such that the $i$th location indicates the city in which you will be based in the $i$th month. The cost of a plan is the sum of the operating costs for each of the $n$ months, plus a moving cost of $M$ for each time you switch cities. The plan can begin in either city. Given a value for the moving cost $M$, and sequences of operating costs $N_1, ..., N_n$ and $S_1, ..., S_n$, find a plan of minimum cost.
]


#grid(columns: (3em, 1fr), [])[
  #set enum(numbering: it => strong[(#" abcd".at(it))])
  + Show that the following algorithm does not solve this problem, by giving an instance on which it does not return the correct answer.
    ```
    for i = 1 to n
      if Ni < Si then choose NY in Month i
      else choose SF in Month i
    end for
    ```
    In your example, say what the correct answer is and also what the algorithm above finds.
  #grid(columns: (2em, 1fr), strong(high2[Sol.]))[Consider the following instance: $n = 3$, $M = 100$, $N_i = [2, 5, 1]$, $S_i = [3, 2, 7]$.

  The given algorithm will return the following plan:
  $
  ["NY", "SF", "NY"]
  $
  which has a cost of $2 + 2 + 1 + 100 + 100 = 205$.

  An optimal plan is $
  ["NY", "NY", "NY"]
  $
  which has a cost of $2 + 5 + 1 = 8$.

  The algorithm does not consider the moving cost; thus it does not always give the correct answer.
]

2. Give an example of an instance in which every optimum plan must move (i.e. change locations) at least three times. Provide a brief explanation, saying why your example has this property.

#grid(columns: (2em, 1fr), strong(high2[Sol.]))[Consider the following instance: $n = 4$, $M = 2$, $N_i = [1, 20, 1, 20]$, $S_i = [20, 1, 20, 1]$.

  An optimal plan is $
  ["NY", "SF", "NY", "SF"]
  $
  which has a cost of $1 + 1 + 1 + 1 + 2 + 2 + 2 = 10$.

  This instance has the property that any optimal plan must move at least three times. This is because if a plan moves less than three times, we can show that the cost of that plan will be $>= 20$ as it must choose a month and a place whose operating cost is 20.
]

3. Give an efficient algorithm that finds an optimal plan. Justify its correctness and  runtime.
  
#grid(columns: (2em, 1fr), strong(high2[Sol.]))[
  
    *Optimal Substructure*: Consider plan $P_i$ to be an optimal plan for months 1 to $i$. Without loss of generality, assume that plan $P_i$ operates at NY for month $i$. There are two cases:
    - $P_i$ operates at NY for month $i - 1$. Then, $P_i [1..i - 1]$ itself must be an optimal plan for $i - 1$ months, ending with NY. 
    - $P_i$ operates at SF for month $i - 1$. Again, $P_i [1..i - 1]$ must be an optimal plan for $i - 1$ ending at SF.
    This is because if the substructure is not optimal, if we replace it with an optimal substructure, we will get a better solution, which is a contradiction.

    Similarly, the same applies even if $P_i$ operates at SF for month $i$.

    *Overlapping Subproblems*
    
    $
    f_N [i] = min(f_N [i - 1] + N_i, quad f_S [i - 1] + M + N_i)\
    f_S [i] = min(f_S [i - 1] + S_i, quad f_N [i - 1] + M + S_i)\
    $

    This naturally leads to a DP solution:

    #algorithm-figure(
      "Minimum Operating Cost",
      vstroke: 1pt + luma(200),
      {
        import algorithmic: *
        Procedure(
          "Min-Operating-Cost",
          ($n$, $S$, $N$, $M$),
          {
            Assign[$f_S [1]$][$S_1$]
            Assign[$f_N [1]$][$N_1$]
            For([$j <- 2$ to $n$], {
              IfElseChain($f_S [j - 1] + S_j <= f_N [j - 1] + M + S_j$, {
                Assign[$f_S [j]$][$f_S [j - 1] + S_j$]
                Assign[$"trace"_S [j]$][SF]
              }, {
                Assign[$f_S [j]$][$f_N [j - 1] + M + S_j$]
                Assign[$"trace"_S [j]$][NY]
              })
              LineBreak
              IfElseChain($f_N [j - 1] + N_j <= f_S [j - 1] + M + N_j$, {
                Assign[$f_N [j]$][$f_N [j - 1] + N_j$]
                Assign[$"trace"_N [j]$][NY]
              }, {
                Assign[$f_N [j]$][$f_S [j - 1] + M + N_j$]
                Assign[$"trace"_S [j]$][SF]
              })
            })
            Return(FnInline("min", ($f_S [n]$, $f_N [n]$)))
          }
        )
      }
    ) <a4>
#v(2cm)
     #algorithm-figure(
      "Backtracking to retrieve plan",
      vstroke: 1pt + luma(200),
      {
        import algorithmic: *
        Procedure(
          "Optimal-Plan",
          ($n$, $f_N$, $f_S$, $"trace"_N$, $"trace"_S$),
          {
            Assign[plan][[]]
            IfElseChain($f_N [n] < f_S [n]$, Assign[curr][NY],  Assign[curr][SF])
            
            For($j <- n "to" 1$, {
              Line[*prepend* curr *to* plan]
              If($j = 1$, Break)
              IfElseChain([curr = NY], {
                Assign[curr][$"trace"_N [j]$]
              }, {
                Assign[curr][$"trace"_S [j]$]
              })
            })
            Return[plan]
          }
        )
      }
    ) <a5>

    *Correctness*: Inductive proof. For $n = 1$, the algorithm correctly gives $min(N_1, S_1)$. Assuming it correctly finds the minimum cost for $n - 1$ months, by the optimal substructure property it must also get the minimum cost for $n$ months.

    *Runtime*:
    - @a4: Time complexity: $O(n)$, Space complexity: $O(n)$
    - @a5: Time complexity: $O(n)$, Space complexity: $O(n)$
    
  ]


]

#pagebreak()

#quest[3.6.5][
  *(Optimal Strategy for a Game)*
  There is a sequence of $n$ coins with values $v_i$ > 0 for $i = 1, 2, ..., n$. There are two players, Player 1 and Player 2. Each player chooses either the first coin or the last coin from the remaining coins alternately, starting with Player 1. Once a player chooses a coin, he removes it from the sequence of coins. The goal of Player 1 is to maximize his earning. The goal of Player 2 is to maximize his earning, or equivalently to minimize the earning of Player 1. \ Give an efficient algorithm to determine the maximum possible earning of Player 1 irrespective of the strategy of Player 2. Justify its correctness, time and space complexities, and provide a demonstration for the input $4, 7, 3, 8, 2, 5$.
]

#ans[
  Interestingly, a greedy choice of picking the more valuable coin fails here. This is shown by this example: $7, 20, 1, 3$. Here,  player 1 should choose 3 instead of 7, in order to guarantee to get 20 and win the game.

  Since we cannot greedily make choices, we must find some other property of the problem.

  *Optimal Substructure*: The optimal  choices for player 1 on a sequence of $n$ coins, must contain within it optimal choices for the resulting sequence of $n - 2$ coins (after the first move). 

  *Overlapping subproblems*: To compute the best choices for some state $[i..j]$, we need to compute for smaller subproblems $[i+2..j]$, $[i+1..j-1]$, $[i..j-2]$. These subproblems overlap, thus we can memoize the result by doing a bottom-up DP.

  *Formalising the DP*

  Let $f[i, j] = $ maximum possible earning of the first player given the state of coins $i$ through $j$.

  - If the first player chooses the first coin:
    - The other player may choose the second coin or the last coin.
  - If the first player chooses the last coin:
    - The other player may choose the first coin or the second last coin.

  We assume that the other player chooses his choice so as to minimise the first player's earnings.

  Thus, we can define the recurrence

  $
  f[i, j] &= max(
    v_i + min(f[i + 2, j], f[i + 1, j - 1]),
    v_j + min(f[i, j - 2], f[i + 1, j - 1])
  )\
  f[i, i] &= v_i\
  f[i, i + 1] &= max(v_i, v_(i + 1))
  $

  *Order of computation*


  We must go in order of increasing size ($j - i$) of the range, since larger subproblems depend upon smaller subproblems.

  We also observe that to compute $f[i, j]$, we only require subproblems of size $j - i-2$. Since we finally need $f[1, n]$, if $n - 1$ is odd, we only need to compute for ranges with odd sizes, similarly if $n - 1$ is even, we only need to compute for ranges with even sizes.
  
  #v(3em)
  #algorithm-figure(
    "Optimal strategy for a game",
    vstroke: 1pt + luma(200),
    {
      import algorithmic: *
      Procedure(
        "Max-Earning",
        ($n$, $v$),
        {
          Assign[parity][$(n - 1) mod 2$]
          For([size $<-$ parity to $(n - 1)$ *step* 2], {
            For([$i <- 1$ to $n - "size"$], {
              Assign[$j$][$i + "size"$]
              IfElseChain($"size" = 0$, {
                Assign[$f[i, j]$][$v_i$]
              }, $"size" = 1$, {
                Assign[$f[i, j]$][$max(v_i, v_j)$]
              }, {
                Line[$f[i, j] <- max\($\ $quad v_i + min(f[i + 2, j], f[i + 1, j - 1]),$\ $quad v_j + min(f[i, j - 2], f[i + 1, j - 1])$\ $)$]
              })
            })
          })
          Return[$f[1, n]$]
        }
      )
    }
  )

  *Correctness*

  For $n = 0, 1$ the algorithm gives the correct answer (trivial). By the optimal substructure property, we can construct the solution for $n$ coins by finding the solution for $n - 2$ coins. By induction, this proves correctness.

  *Complexity*

  - Time Complexity: $O(n^2)$
  - Space Complexity: $O(n^2)$

  We only require optimal values for ranges of size $k - 2$ to compute optimal values for ranges of size $k$. So it is possible to optimize the storage to be $O(n)$.

  *Demonstration*

  Let the set of coins be $4, 7, 3, 8, 2, 5$. The algorithm is demonstrated in @f2 and @f3 below.

  
  #figure(table(
    columns: 5,
    stroke: none,
    align: (x, y) => if x != 3 or y == 0 { center } else { left },
    table.hline(),
    [size], 
    table.vline(stroke: 0.7pt),
    [$i$], 
    [$j$], 
    table.vline(stroke: 0.7pt + accent),
    [choice of coin], 
    table.vline(stroke: 0.7pt),
    $f[i, j]$,
    table.hline(),
    [$1$], [$1$], [$2$], [$v_1 = 4$], [$7$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_2 = 7$, [],
    table.hline(stroke: 0.7pt + accent, start: 1),
    [], [$2$], [$3$], [$v_2 = 7$], [$7$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_3 = 3$, [],
    table.hline(stroke: 0.7pt + accent, start: 1),
    [], [$3$], [$4$], [$v_3 = 3$], [$8$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_4 = 8$, [],
    table.hline(stroke: 0.7pt + accent, start: 1),
    [], [$4$], [$5$], [$v_4 = 8$], [$8$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_5 = 2$, [],
    table.hline(stroke: 0.7pt + accent, start: 1),
    [], [$5$], [$6$], [$v_5 = 2$], [$5$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_6 = 5$, [],
    table.hline(stroke: 0.7pt),
    [$3$], [$1$], [$4$], [$v_1 + min(f[2, 3], f[3, 4]) = 4 + 7 = 11$],[$15$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_4 + min(f[1, 2], f[2, 3]) = 8 + 7 = 15$, [], 
    table.hline(stroke: 0.7pt + accent, start: 1),
    [], $2$, $5$, $v_2 + min(f[3, 4], f[4, 5]) = 7 + 8 = 15$, [$15$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_5 + min(f[2, 3], f[3, 4]) = 2 + 7 = 9$, [], 
    table.hline(stroke: 0.7pt + accent, start: 1),
    [], $3$, $6$, $v_3 + min(f[4, 5], f[5, 6]) = 3 + 5 = 8$, [$13$],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $v_6 + min(f[3, 4], f[4, 5]) = 5 + 8 = 13$, [],
    table.hline(stroke: 0.7pt),
    [$5$], $1$, $6$, $v_1 + min(f[2, 5], f[3, 6]) = 4 + 13 = 17$, [#hl($20$)],
    table.hline(stroke: 0.7pt + accent, start: 3, end: 4),
    [], [], [], $hl(v_6) + min(f[1, 4], f[2, 5]) = 5 + 15 = hl(20)$, [],
    table.hline(),
  ), kind: image, caption: [Computational steps to fill up the DP Table]) <f2>

  #let len =0.7cm
  #figure(table(
    columns: (auto, len, len, len, len, len, len),
    rows: (auto, len, len, len, len, len, len),
    align: (x, y) => if x == 0 { right } else {  center },
    stroke: none,
    fill: (x, y) => if x >= 1 and y < 6 {if (x <= y ) {luma(200)} else if calc.odd(y - x) {rgb("#e2e2e2")}},
    table.hline(start: 1),
    high1[$i = 1$], table.vline(), [], [$7$], [], [$15$], [], hl($20$), table.vline(end: 6),
    high1[$2$], [], [], [$7$], [], [$15$], [], 
    high1[$3$], [], [], [], [$8$], [], [$13$], 
    high1[$4$], [], [], [], [], [$8$], [], 
    high1[$5$], [], [], [], [], [], [$5$], 
    high1[$6$], [], [], [], [], [], [], 
    table.hline(start: 1),
    table.cell(colspan: 2, align: right, high1[$j = 1$]), high1[$2$], high1[$3$], high1[$4$], high1[$5$], high1[$6$],
  ), kind: image, caption: [DP Table for finding max earning with $v = {4, 7, 3, 8, 2, 5}$.\ We only use cells where $i <= j$ and $j - i$ is odd.]) <f3>
  
]


#v(3em)
#align(center, line(length: 50%))