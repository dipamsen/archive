#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Computational Complexity"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Computational Complexity]

In the previous modules, we have discussed many different algorithms of various types for solving different problems. *Algorithm Design* concerns itself with the following question: Given a problem $P$, find an algorithm which solves $P$ with the best _cost_. For our discussions, the cost was associated with the time complexity with which the algorithm runs.

*Computation Theory* is a theoretical domain which deals with what problems can be solved with
