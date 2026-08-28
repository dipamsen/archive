#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node, cetz


#show: project.with(
  subject: "Algorithms II",
  topic: "Graph Matching"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt

#title[Graph Matching]
