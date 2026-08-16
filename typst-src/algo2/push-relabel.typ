#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Push Relabel"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Push Relabel]

We have studied some algorithms to find the maximum flow in a flow network. These algorithms are _augmenting path_ algorithms, meaning they maintain a valid flow and augment it iteratively to increase its value.

Here, we consider a new approach for the maximum flow problem, which is known as the push-relabel paradigm. Unlike the augmenting path algorithms, where we maintain validity and progress towards optimality, in this approach, we try to maintain an optimal flow, and progress towards making the flow valid.


