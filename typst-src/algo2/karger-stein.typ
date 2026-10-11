#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Karger's Min Cut"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Karger's Min Cut]

Here, we discuss our first randomised algorithm in this course. We will propose a randomized polynomial time algorithm to compute a cut of minimum size in an unweighted undirected graph.

= Randomized Algorithms

A randomized algorithm is an algorithm which uses randomness to make some choice in its procedure. This means,
