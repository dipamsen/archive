= PSet 1 (Problems from other versions)

#let phi = symbol(
  str(sym.phi.alt),
  ("alt", str(sym.phi))
)
#let xi = $x^((i))$
#let yi = $y^((i))$

+ #[
  *Newton's Method for computing least squares* (Public Course, 1)

  + #[
    $
    J(theta) &= 1/2 sum_(i=1)^m (theta^T xi - yi)^2\
    frac(partial, partial theta_j) J(theta) &= sum_(i=1)^m (theta^T xi - yi)xi_j\
    nabla_theta J(theta) &= sum_(i=1)^m (theta^T xi - yi)xi\
    &=X^T (X theta - y) \
    frac(partial^2 J(theta), partial theta_j partial theta_k)  &= sum_(i=1)^m xi_j xi_k \
    H &= X^T X
    $
  ]

  + #[
    First iteration of Newton's Method:

    $
    theta &:= theta + H^(-1) nabla_theta l(theta)\
    &:= theta - (X^T X)^(-1)X^T (X theta - y)
    $
    Assuming initialising with $theta = 0$
    $
    theta^star = (X^T X)^(-1) X^T y
    $

    which is the solution to the normal equation.
  ]  
]

+ #[
  *Naive Bayes* (Public Course, 4)

  Input features $x_j in {0, 1}$. $x = mat(x_1, x_2, dots.c, x_n)^T$ is the input vector. For each training example, the output $y in {0, 1}$.

  Model Parameters:

  $
  phi_(j|y = 0)  &= p(x_j = 1|y = 0)\
  phi_(j|y=1) &= p(x_j = 1|y=1)\
  phi_y &= p(y=1)
  $

  Model joint distribution of $(x, y)$ as

  $
  p(y) &= (phi_y)^y (1-phi_y)^(1-y)\
  p(x|y=0) &= product_(j=1)^n p(x_j|y=0) &= product_(j=1)^n (phi_(j|y=0))^(x_j) (1 - phi_(j|y=0))^(1-x_j)\
  p(x|y=1) &= product_(j=1)^n p(x_j|y=1) &= product_(j=1)^n (phi_(j|y=1))^(x_j) (1 - phi_(j|y=1))^(1-x_j)\
  $

  + #[
    $
    l(phi.alt) = sum_(i=1)^m log p(xi, yi; phi.alt)
    $

    where $phi.alt = {phi_y, phi_(j|y=0), phi_(j|y=1), j = 1, ..., n}$
    $
    l(phi.alt) &= sum_(i=1)^m log p(xi, yi; phi.alt)\
    &= sum_(i=1)^m log p(xi|yi; phi_(j|yi)) p(yi; phi_y)\
    &= sum_(i=1)^m (sum_(j=1)^n (x_j log phi_(j|yi) + (1 - x_j) log (1 - phi_(j|yi))) + yi log (phi_y) + (1 - yi) log (1 - phi_y))
    $

  ]
  + #[

    MLE:

    $
    frac(partial, partial phi_y) l(phi.alt) = sum_(i=1)^m yi/phi_y - frac(1-yi, 1 - phi_y) = 0\
    => phi_y/(1-phi_y) = frac(sum_(i=1)^m yi, sum_(i=1)^m 1 - yi) \
    => phi_y = (sum_(i=1)^m 1{yi=1})/m
    $

    $
    frac(partial, partial phi_(j|yi)) l(phi.alt) =sum_(i=1)^m  x_j/phi_(j|yi) - frac(1 - x_j, 1 - phi_(j|yi)) = 0\
    => sum_(i=1)^m  frac( x_j, phi_(j|yi)) - frac( 1 - x_j, 1 - phi_(j|yi)) = 0  \
    => sum_(i=1)^m 1{yi=0} (x_j/phi_(j|y=0) - (1-x_j)/(1-phi_(j|y=0))) + 1{yi=1} (x_j/phi_(j|y=1) - (1-x_j)/(1-phi_(j|y=1))) = 0
    $
    $
    => phi_(j|y=0)/(1-phi_(j|y=0) ) = (sum_(i=1)^m 1{yi=0} x_j) / (sum_(i=1)^m 1{yi=0}(1-x_j))\
    => phi_(j|y=0) = (sum_(i=1)^m 1{yi=0,xi_j=1})/(sum_(i=1)^m 1{yi=0})\
    => phi_(j|y=1) = (sum_(i=1)^m 1{yi=1,xi_j=1})/(sum_(i=1)^m 1{yi=1})
    $
    
  ]

  + #[
    To show: $p(y=1|x) >= 0.5$ is equivalent to $theta^T x >= -theta_0$ for some $theta$ and $theta_0$ 

    $
    p(y=1|x) = p(y=1, x)/p(x) = (p(x|y=1)p(y=1))/p(x)\ = (product_(j=1)^n (phi_(j|y=1))^(x_j) (1 - phi_(j|y=1))^(1-x_j) phi_y)/(product_(j=1)^n (phi_(j|y=1))^(x_j) (1 - phi_(j|y=1))^(1-x_j) phi_y + product_(j=1)^n (phi_(j|y=0))^(x_j) (1 - phi_(j|y=0))^(1-x_j) (1-phi_y)) >= 1/2\
    =>product_(j=1)^n (phi_(j|y=1))^(x_j) (1 - phi_(j|y=1))^(1-x_j) phi_y >= product_(j=1)^n (phi_(j|y=0))^(x_j) (1 - phi_(j|y=0))^(1-x_j) (1-phi_y)
    $
    Take log on both sides. (log is a monotonically increasing function)

    $
    log phi_y + sum_(j=1)^n x_j log phi_(j|y=1) + (1 - x_j)log(1 - phi_(j|y=1)) wide \ wide= log (1-phi_y) +  sum_(j=1)^n x_j log phi_(j|y=0) + (1 - x_j) log (1 - phi_(j|y=0))\
    => sum_(j=1)^n x_j (log phi_(j|y=1)/(1-phi_(j|y=1))  (1 - phi_(j|y=0))/phi_(j|y=0)) + log ((1 - phi_(j|y=1))/(1 - phi_(j|y=0))) >= - log ((phi_y)/(1-phi_y))\
    $

    This is same as $theta^T x + theta_0 >= 0$ with

    $
    theta_j &= log phi_(j|y=1)/(1-phi_(j|y=1))  (1 - phi_(j|y=0))/phi_(j|y=0)\
    theta_0 &= sum_(j=1)^m log ((1 - phi_(j|y=1))/(1 - phi_(j|y=0))) + log(frac(phi_y, 1 - phi_y))
    $ // TODO Verify
  ] 
]

// + #[
//   *Linear regression: Linear in what?* (2019 Summer, 5)

//   + #[
//     *Learning degree-3 polynomials of the input*

//     $
//     h_theta (x) = theta_3 x^3 + theta_2 x^2 + theta_1 x + theta_0
//     $

//     $h_theta$ is still linear in $theta$, so we can use linear regression with feature vector 

//     $
//     phi(x) = vec(1, x, x^2, x^3) in RR^4
//     $
    
//     Let $hat(x)^((i)) = ^triangle.small phi \(xi\)$.

//     $
//     J(theta) = 1/2 sum_(i=1)^n (theta^T hat(x)^((i)) - yi)^2
//     $

//     Update rule:
//     $
//     theta := theta - alpha sum_(i=1)^n (theta^T hat(x)^((i)) - yi) hat(x)^((i))
//     $
//   ]

//   + #[
//     *Coding question: degree-3 polynomial regression*

//     // TODO
//   ]
// ]

#pagebreak(weak: true)