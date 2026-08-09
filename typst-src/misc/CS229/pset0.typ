
= PSet 0
#let phi = symbol(
  str(sym.phi.alt),
  ("alt", str(sym.phi))
)
1. *Gradients and Hessians*#[

  + #[$f(x) = 1/2 x^T A x + b^T x$, $A in SS^n$, $b in RR^n$
  $
  => nabla f(x) = A x + b
  $]
  + #[$f(x) = g(h(x))$, $g: RR ->RR, h:RR^n -> RR$\

  $
  (nabla f(x))_i &= (partial f(x))/(partial x_i) \ &= lr((partial g(t))/(partial t)|)_(t=h(x)) (partial h(x))/(partial x_i)\
  &= g'(h(x)) (partial h(x))/(partial x_i)\
  => nabla f(x) &= g'(h(x)) nabla h(x)
  $]

  + #[
    $f(x) = 1/2 x^T  A x + b^T x, A in SS^n, b in RR^n$
    $
    nabla^2 f(x) = A
    $
  ]

  + #[
    $f(x) = g(a^T x), g: RR -> RR, a in RR^n$
    $
      nabla f(x) &= a g'(a^T x)\
      (nabla^2 f(x))_(i j) &= (partial^2 f(x))/(partial x_i partial x_j) = frac(partial, partial x_i) g'(a^T x) a_j = a_i a_j g''(a^T x)\
      => nabla^2 f(x) &= g''(a^T x) mat(a_1^2, a_1 a_2, dots.h, a_1 a_n; a_2 a_1, a_2^2, dots.h, a_2 a_n; dots.v, dots.v, dots.down, dots.v; a_n a_1, a_n a_2, dots.h, a_n^2)\
      &= a a^T g''(a^T x) 
    $
  ]
]

2. #[*Positive Definite Matrices*
  $
  A succ 0 "iff" x^T A x > 0 forall x != 0
  $

  + #[
    $ 
    A = z z^T\
    $
    Firstly, note that $A$ is symmetric.
    $ x^T A x &= x^T z z^T x\
    &= (z^T x)^T (z^T x)\
    &= lr(||z^T x||)_2^2 > 0 wide forall x != 0 
    $
    Thus, $A succ 0$.
  ]

  + #[
    $
    A = z z^T
    $

    Outer product. Null space: vectors $x$ such that $A x = 0$.

    $
    A x &= 0\
    => z z^T x &= 0\
    => (x^T z) z^T &= 0
    $
    Note that the resultant vector is a scalar multiple of $z^T$. A scalar multiple of $z^T$ can be zero only if the scalar factor is zero. (Given that $z$ is non-zero.)
    $
    => x^T z = 0
    $
    This is true for all $x$ orthogonal to $z$. Thus null space is the $(n-1)$ dimensional subspace orthogonal to $z$.

    Since $dim(cal(R)(A)) + dim(cal(N)(A)) = n$, $"rank"(A) = 1$. This means there is only one linearly independent column of $A$, i.e. any column can be written as a multiple of any other column. This is evident from the definition of the outer product.
  ]

  + #[
    $A in RR^(n times n)$ is PSD, $B in RR^(m times n)$ is arbitrary. Let $G = B A B^T in RR^(m times m)$.
    $
    G &= B A B^T\
    x^T G x &= x^T B A B^T x\
    &= y^T A y
    $
    for $y = B^T x$. Note that since $A$ is PSD, $y^T A y >=0 forall y $.

    So, $G$ is PSD.
  ]
]

+ #[
  *Eigenvectors, Eigenvalues and the spectral theorem*

  + #[
    $ A = T Lambda T^(-1)\
    => A T = T Lambda
    $

    Here, $i$th column of the LHS will be $A t^((i))$. The $i$th column of the RHS will be $lambda_i t^((i))$.

    So, $
    A t^((i)) = lambda_i t^((i))
    $
  ]
  + #[
    If $U$ is orthogonal, $U^T = U^(-1)$, so $A = U Lambda U^T = U Lambda U^(-1)$. From (a), it follows that $A u^((i)) = lambda_i u^((i))$ and thus $u^((i))$ is an eigenvector of $A$.
  ]
  + #[
    If $A$ is PSD, then $x^T A x >= 0 forall x $.
    By spectral theorem, 
    $
    x^T U Lambda U^T x >=0 forall x \
    => y^T Lambda y >= 0 forall y \
    => sum lambda_i y_i^2 >= 0 forall y 
    $
    This is only possible if all $lambda_i >= 0$.
  ]
]

#pagebreak()
