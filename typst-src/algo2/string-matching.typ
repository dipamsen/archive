#import "template.typ": *
#import "algorithm.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.5.2"


#show: project.with(
  subject: "Algorithms II",
  topic: "String Matching"
)

#let op(x) = smallcaps[#x]
#let phi = sym.phi.alt
#let bu(x) = math.bold(math.upright(x))

#title[String Matching]

0. define the problem
1. naive matching
  - example
  - complexity
2. observations
3. define LPS
4. how to find matches using lps
5. time complexity, correctness
6. how to compute lps, time complexity, correctness


