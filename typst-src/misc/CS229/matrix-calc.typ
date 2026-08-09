
= Some Matrix Derivatives 

+ #[
  $nabla_A tr A B = nabla_A tr B A  = B^T$

  Let $B in RR^(n times m)$ and $f(A): RR^(m times n)-> RR = tr A B$. Then, $(i <=m, j <= n)$
  $
  (nabla_A tr A B)_(i j) = frac(partial (tr A B), partial A_(i j)) &= frac(partial ((A B)_11 + ... + (A B)_(m m)), partial A_(i j))\
  &= frac(partial, partial A_(i j)) (sum_p^m (A B)_(p p)) \ & = frac(partial, partial A_(i j)) (sum_p^m sum_q^n A_(p q) B_(q p)) \
  &= B_(j i)\
  => nabla_A tr A B &= B^T
  $ #h(1fr) $qed$
]

+ #[
  $nabla_(A^T) f(A) = (nabla_(A) f(A))^T$

  Let $A in RR^(m times n)$.

  $
  (nabla_(A^T) f(A))_(i j) &= frac(partial, partial (A^T)_(i j)) f(A) = frac(partial, partial A_(j i)) f(A)\
  &= (nabla_A f(A))_(j i)\
  => nabla_(A^T) f(A) &= (nabla_A f(A))^T
  $#h(1fr) $qed$
]



+ #[
  $nabla_A tr A B A^T C = C A B + C^T A B^T$

  Let $A in RR^(m times n)$, $B in RR^(n times  n)$, $C in RR^(m times m)$.
  Let $D = A B A ^T C in RR^(m times m)$
  
  $
    (nabla_A tr A B A^T C)_(i j) &= frac(partial , partial A_(i j)) (tr A B A^T C)\
  $

  Notice that for matrix multiplication,

  $
  (A B)_(i j) &= sum_(k) A_(i k) B_(k j)\
  (A B C)_(i j) &= sum_(k, l)  A_(i k) B_(k l) C_(l j)\
  (A B C D)_(i j) &= sum_(k, l, m) A_(i k) B_(k l) C_(l m) D_(m j)
  $

  Then,

  $
  tr A B A^T C &= sum_p sum_(q, r, s) A_(p q) B_(q r) A^T_(r s) C_(s p)\
  frac(partial , partial A_(i j)) (tr A B A^T C) &= sum_(r, s) B_(j r) A^T_(r s) C_(s i) + sum_(p, q) A_(p q) B_(q j) C_(i p) \ &= (B A^T C)_(j i) + (C A B)_(i j)\
  => nabla_A tr A B A^T C &= C^T A B^T + C A B
  $#h(1fr) $qed$
]

#pagebreak()
