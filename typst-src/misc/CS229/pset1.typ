#import "template.typ": *

= PSet 1
#let phi = symbol(
  str(sym.phi.alt),
  ("alt", str(sym.phi))
)
#let eg(y, i) = $#y^((#i))$
#let ht = $h_theta$
#let yi = $y^((i))$
#let xi = $x^((i))$
1. #[
  *Linear Classifiers (logistic regressions and GDA)*

  + #[Average empirical loss for logistic regression

  $
  J(theta) = -1/m sum_(i=1)^m eg(y, i) log(g(theta^T eg(x, i))) + (1-yi) log(1-g(theta^T xi))
  $

  $yi in {0, 1}$, $ht(x) = g(theta^T x)$ and $g(z) = frac(1, 1+e^(-z))$

  Hessian of $J(theta)$: 

  $
  (nabla^2 J(theta))_(i, j) &= frac(partial^2, partial theta_i partial theta_j) J(theta) \ &= partial/(partial theta_j) (-1/m sum_(i=1)^m yi/g(theta^T xi) g'(theta^T xi) xi_i - (1-yi)/(1-g(theta^T xi)) g'(theta^T xi) xi_i )\
  &= partial/(partial theta_j) (-1/m sum_(i=1)^m yi (1-g(theta^T xi) ) xi_i - (1-yi)g(theta^T xi) xi_i)\
  &= -1/m partial/(partial theta_j) sum_(i=1)^m xi_i (yi - yi g(theta^T xi) - g(theta^T xi) + yi g(theta^T xi))\
  &= -1/m partial/(partial theta_j) sum_(i=1)^m xi_i (yi - g(theta^T xi)) = 1/m sum_(i=1)^m xi_i xi_j g(theta^T xi) (1-g(theta^T xi))
  $

  Here, 

  $
  nabla_theta J(theta) &= 1/m sum_(i=1)^m (g(theta^T xi) - yi) xi\

&= 1/m sum_(i=1)^m (g(mat(-, theta^T, -) mat(bar; xi; bar)) - yi) mat(bar; xi; bar)
$
This can be thought of linear combination of columns $xi$. Recall, $A x$ can be written as linear combination of columns of $A$ with coefficients in $x$:

$
A x = mat(bar, bar, , bar; a_1, a_2, dots.h.c, a_n; bar, bar, , bar) mat(x_1; x_2; dots.v; x_n) = x_1 mat(bar; a_1; bar) + x_2 mat(bar; a_2; bar) + dots.c + x_n mat(bar; a_n; bar)
$

So, in this case let $X$ be the matrix whose rows are $xi$. Our coefficient vector then has components like $g(theta^T xi) - yi$. We can say, that vector is $g(X theta) - Y$.
(Note that $theta^T xi equiv xi^T theta$ and superposing rows of $xi$, we get $X theta$.)

$
  
  nabla_theta J(theta)= 1/m X^T (g (X theta) - Y)
  $


  Similarly, the Hessian is of the form

  $
  H_(j k) &=1/m sum_(i=1)^m xi_j xi_k g(theta^T xi) (1-g(theta^T xi))\

  H_k &= 1/m sum_(i=1)^m xi_k g(theta^T xi) (1-g(theta^T xi)) mat(bar; xi; bar)\
  &= 1/m X^T (g(X theta ) (1-g(X theta)) X_k)
  $

  Here, the notation $1 - g(X theta)$ means $[1, 1, ..., 1]^T  - g(X theta)$, commonly known as broadcasting.

  Also, another subtlety in the last equality is the conversion of $g(theta^T x)$ to $g(X theta)$.

  $
  X theta = mat(bar.h, eg(x, 1), bar.h; bar.h, eg(x, 2), bar.h; , dots.v, ; bar.h, eg(x, m), bar.h) theta = mat(bar.h, theta^T eg(x, 1), bar.h; bar.h, theta^T eg(x, 2), bar.h; , dots.v, ; bar.h, theta^T eg(x, m), bar.h)
  $

  $
  g(X theta) = mat(bar.h, g(theta^T eg(x, 1)), bar.h; bar.h, g(theta^T eg(x, 2)), bar.h; , dots.v, ; bar.h, g(theta^T eg(x, m)), bar.h)
  $

  $
  H_k &= 1/m sum_(i=1)^m xi _k g(theta^T xi) (1-g(theta^T xi)) mat(bar; xi; bar)\ &= 1/m X^T 
  vec(
    eg(x, 1)_k g(theta^T eg(x, 1))(1-g(theta^T eg(x, 1))),
    eg(x, 2)_k g(theta^T eg(x, 2))(1-g(theta^T eg(x, 2))),
    dots.v, 
    eg(x, m)_k g(theta^T eg(x, m))(1-g(theta^T eg(x, m)))
  )\
  &= 1/m X^T (X_k dot g(X theta) dot (1-g(X theta)))
  $

  where $dot$ represents elementwise multiplication.

  $
  H &= 1/m X^T mat(bar, bar, , bar; X_1 dot g(X theta) dot (1-g(X theta)), X_2 dot g(X theta) dot (1-g(X theta)), dots.c, X_n dot g(X theta) dot (1-g(X theta)); bar, bar, , bar) 
  $

  At this point, the pattern to be identified is the following:

  $
  H_(j k) &=1/m sum_(i=1)^m xi_j xi_k g(theta^T xi) (1-g(theta^T xi))
  $or,

  $
  H_(j k) = 1/m sum_(i=1)^m w_i xi_j xi_k
  $

  This is a weighted sum of outer products. ($i$th feature vector's outer product weighted by $w_i = g(theta^T xi) (1-g(theta^T xi))$)

  This can be represented by the product

  $
  H = 1/m X^T W X
  $

  where $W = op("diag")(w_1, w_2, dots.c, w_m)$.

  $
  H &= 1/m MatrixCols(#{(i) => $x^((#i))$}, m)
  MatrixDiag(#{i => $w_#i$}, m)
  MatrixRows(#{(i) => $x^((#i))$}, m)\
  &= 1/m MatrixCols(#{(i) => $w_#i x^((#i))$}, m)
  MatrixRows(#{(i) => $x^((#i))$}, m)\
  &= 1/m MatrixCols(#{(i) => $ x^((#i))$}, m)
  MatrixRows(#{(i) => $w_#i x^((#i))$}, m)
  $

  The last representation above is the same as the one we arrived at from elementwise operations.

  The second last one can be written as $(X^T dot g(X theta) dot (1-g(X theta))) X$ where $g$ $m$-vectors are broadcasted to $n times m$ ones and elementwise multiplied.

  $
  z^T H z = z^T X^T W X z = (X z)^T W (X z) = y^T W y
  $

  which is a diagonalised quadratic form.

  $
  = sum_(i=1)^n w_i y_i^2
  $
  (Note that Hessian wrt $theta $ is $in RR^(n times n)$ since each feature vector (and $theta$) is $in RR^n$)

  Notice that $w_i$'s are always positive (since $g(dot)$ and $1-g(dot) >=0 forall dot$). Hence, $H$ is positive semi-definite.

  Alternatively, expand the original quadratic form:

  $
  z^T H z &= 1/m sum_(i=1)^m  g(theta^T xi) (1-g(theta^T xi))sum_(j=1)^n sum_(k=1)^n z_j z_k xi_j xi_k\
  
  &=1/m sum_(i=1)^m w_i sum_(j=1)^n z_j xi_j sum_(k=1)^n z_k xi_k = 1/m sum_(i=1)^m w_i (z^T xi)^2 >= 0
  $
]

+ #[
  *Coding Problem*

  Newton's Method: Update $theta$ as

  $
  theta := theta - H^(-1) nabla_theta l(theta)
  $

  where $l(theta) = sum_(i=1)^m yi  log h(xi) + (1-yi)log(1-h(xi))$.

  $
  H = X^T W X\
  nabla_theta J(theta) = X^T (h(xi) - yi)
  $

  ```focus
class LogisticRegression(LinearModel):
    theta = []

    def fit(self, x: np.ndarray, y: np.ndarray):
        # *** START CODE HERE ***
        # y is in {0, 1}

        m, n = x.shape
        self.theta = np.zeros(n)

        def h(x):
            return 1 / (1 + np.exp(-x @ self.theta))

        # grad:
        g = x.T @ (h(x) - y)

        # Hessian: 
        W = np.diag(h(x) * (1 - h(x)))
        H = x.T @ W @ x

        while True:
            prev = self.theta
            self.theta -= np.dot(np.linalg.inv(H), g)    

            if np.linalg.norm(self.theta - prev, ord=1) < 1e-5:
                break
        # *** END CODE HERE ***

    def predict(self, x):
        # *** START CODE HERE ***
        return (1 / (1 + np.exp(-x @ self.theta)))
        # *** END CODE HERE ***
  ```

  
    #image("images/p01b_1.png")
    
    #image("images/p01b_2.png")
]


+ #[
  Given that

  $
  p(y) = cases(phi quad &"if" y = 1, 1 - phi quad &"if" y = 0)\
  p(x|y=0) = frac(1, (2 pi)^(n\/2) |Sigma|^(1\/2)) exp(-1/2 (x - mu_0)^T Sigma^(-1) (x - mu_0))\
  p(x|y=1) = frac(1, (2 pi)^(n\/2) |Sigma|^(1\/2)) exp(-1/2 (x - mu_1)^T Sigma^(-1) (x - mu_1))\
  $

  parametrized by $phi, mu_0, mu_1, Sigma$

  To show: 

  $
  p(y=1|x; phi, mu_0, mu_1, Sigma) = frac(1, 1 + exp(-(theta^T x + theta_0)))
  $

  From Bayes rule,

  $
  p(y=1|x) &= (p(x|y=1) p(y=1)) / p(x)\ &= frac(p(x|y=1) p(y=1), p(x|y=1) p(y=1) + p(x|y=0) p(y=0))\
  &= frac(exp(-1/2 (x - mu_1)^T Sigma^(-1) (x - mu_1)) times phi, exp(-1/2 (x - mu_1)^T Sigma^(-1) (x - mu_1)) times phi + exp(-1/2 (x - mu_0)^T Sigma^(-1) (x - mu_0)) times (1 - phi))\
  &= frac(1, 1 + exp(-1/2 (x - mu_0)^T Sigma^(-1) (x - mu_0) + 1/2 (x - mu_1)^T Sigma^(-1) (x - mu_1)) times (1 - phi)/phi)
  $

  Let negative of value within the $exp$ be $M$.

  $
  M &= 1/2 ((x - mu_0)^T Sigma^(-1) (x - mu_0) - (x - mu_1)^T Sigma^(-1) (x - mu_1)) - log(frac(1-phi, phi))\
  &= 1/2(x^T Sigma^(-1) x - mu_0^T Sigma^(-1) x - x^T Sigma^(-1) mu_0 + mu_0^T Sigma^(-1) mu_0 - x^T Sigma^(-1) x + mu_1^T Sigma^(-1) x + x^T Sigma^(-1) mu_1 - mu_1^T Sigma^(-1) mu_1)\ &#hide[=] - log((1 - phi)/phi)\
  &=1/2 (mu_1^T - mu_0^T) Sigma^(-1) x + 1/2x^T Sigma^(-1) (mu_1 - mu_0) + 1/2mu_0^T Sigma^(-1) mu_0 - 1/2mu_1^T Sigma^T mu_1 - log(frac(1-phi, phi))\
  &= (Sigma^(-1) (mu_1 - mu_0))^T x + 1/2 (mu_0 + mu_1)^T Sigma^(-1) (mu_0 - mu_1) - log((1 - phi)/phi)
  $
  Comparing this quantity to $theta^T x + theta_0$, we can see that


  $
  theta = Sigma^(-1) (mu_1  - mu_0)\
  theta_0 = 1/2 (mu_0 + mu_1)^T Sigma^(-1) (mu_0 - mu_1) - log((1 - phi)/phi)
  $

  Thus, GDA results in a classifier having a linear decision boundary (since $p(y=1|x)$ follows a sigmoid).
]



+ #[

  #let params = $phi, mu_0, mu_1, Sigma$
  
  $
  l(params) &= sum_(i=1)^m log p(xi, yi; params)\
  &= sum_(i=1)^m log p(xi|yi; mu_0, mu_1, Sigma) p(yi; phi)
  $

  
  $
  p(y) = cases(phi quad &"if" y = 1, 1 - phi quad &"if" y = 0)\
  p(x|y=0) = frac(1, (2 pi)^(n\/2) |Sigma|^(1\/2)) exp(-1/2 (x - mu_0)^T Sigma^(-1) (x - mu_0))\
  p(x|y=1) = frac(1, (2 pi)^(n\/2) |Sigma|^(1\/2)) exp(-1/2 (x - mu_1)^T Sigma^(-1) (x - mu_1))\
  $


  To maximise $l(params)$, make $frac(partial l, partial phi) = 0, frac(partial l, partial Sigma) = 0, frac(partial l, partial mu_0) = 0, frac(partial l, partial mu_1) = 0$.

  $
  frac(partial l, partial phi) &= sum_(i=1)^m frac(partial, partial phi) log p(yi; phi)\
  &= sum_(i=1)^m 1/p(yi; phi)(-1)^(yi+1) = 0\
  &=> sum_(i=1)^m 1{yi=1} 1/phi - sum_(i=1)^m 1{yi=0} 1/(1-phi)  =0\
  &=> frac(phi, 1-phi) =  frac(sum_(i=1)^m 1{yi=1}, sum_(i=1)^m 1{yi=0})\
  &=> phi  = 1/m sum_(i=1)^m 1{yi=1}
  $

  $
  frac(partial l, partial mu_0) &=  sum_(i=1)^m frac(partial, partial mu_0) log p(xi|yi; mu_0, mu_1, Sigma)\
  &= sum_(i=1)^m 1{yi=0} frac(partial, partial mu_0) log 1/sqrt(2 pi Sigma) exp(-1/2 (xi - mu_0)^2/Sigma)\
  &= sum_(i=1)^m 1{yi=0} Sigma^(-1) (xi-mu_0) = 0\
  &=> mu_0 = (sum_(i=1)^m  1{yi=0} xi )/(sum_(i=1)^m 1{yi=0}) 
  $

  Similarly

  $
  mu_1 = frac(sum_(i=1)^m 1{yi=1} xi, sum_(i=1)^m 1{yi=1})
  $

  $
  frac(partial l, partial Sigma)  &= sum_(i=1)^m frac(partial, partial Sigma) log p(xi|yi; mu_0, mu_1, Sigma)\
  &= sum_(i=1)^m frac(partial, partial Sigma) (-log ((2 pi)^(n\/2) |Sigma|^(1\/2)) -1/2 (xi - mu_y)^T Sigma^(-1) (xi - mu_y))
  $

  where 
  $mu_y =cases(mu_0 quad y=0, mu_1 quad y=1) = 1{y=0} mu_0 + 1{y=1} mu_1$

  $
  &= sum_(i=1)^m -1/(2Sigma) - 1/2(xi -mu_y)^2 frac(partial, partial Sigma) 1/Sigma = sum_(i=1)^m -1/(2 Sigma) + (xi - mu_y)^2 / (2Sigma^2) = 0 $$
  =>  m Sigma &= sum_(i=1)^m (xi - mu_y)^2\
  => Sigma  &= 1/m  sum_(i=1)^m (xi - mu_y)^2\
  => Sigma &= 1/m sum_(i=1)^m (xi - mu_yi) (xi - mu_yi)^T
  $
  
]
#let Cov = math.op("Cov")
+ #[
  *Coding Problem*

  See (c). We can write

  $
  p(y=1|x) &= frac(1, 1+exp(-(theta^T x + theta_0 )))\
  &= frac(1, 1+exp(-theta^T x))
  $

  (redefine $x$ to be $n+1$-dimensional with $x_0 = 1$ and $theta_0$)

  where $theta = Sigma^(-1) (mu_1 - mu_0)$ and $theta_0 =1/2 (mu_0 + mu_1)^T Sigma^(-1) (mu_0 - mu_1) - log((1 - phi)/phi)$

  ```focus

class GDA(LinearModel):
    def fit(self, x, y):
        # *** START CODE HERE ***
        phi = np.mean(y)
        # axis=0 means normal array of vectors avg
        mu_0 = np.mean(x[y == 0], axis=0) 
        mu_1 = np.mean(x[y == 1], axis=0)

        m, n = x.shape

        sigma = np.zeros((n, n))
        for i in range(m):
            sigma += np.outer(x[i] - (mu_1 if y[i] == 1 else mu_0), x[i] - (mu_1 if y[i] == 1 else mu_0))
        sigma /= m

        sigma_inv = np.linalg.inv(sigma)

        self.theta = np.zeros(n + 1)
        self.theta[1:] = sigma_inv @ (mu_1 - mu_0)
        self.theta[0] = 0.5 * (mu_0 + mu_1).T @ sigma_inv @ (mu_0 - mu_1) - np.log((1 - phi) / phi)

        # *** END CODE HERE ***

    def predict(self, x):
        # *** START CODE HERE ***
        x_mod = np.zeros((x.shape[0], x.shape[1] + 1))
        x_mod[:, 1:] = x
        x_mod[:, 0] = 1

        return 1 / (1 + np.exp(-x_mod @ self.theta))
        # *** END CODE HERE ***

  ```

  #image("images/p01e_1.png")

  #image("images/p01e_2.png")
]

+ #[
  Dataset 1:
  #image("images/p01f_cmp_1.png")]

+ #[
  
  Dataset 2:
  #image("images/p01f_cmp_2.png")

  In Dataset 1, GDA (red) performs worse, possibly due to data not being Gaussian.
]

+ #[

  To make GDA perform better in Dataset 1, we need a transformation which makes it more "normal".
  Note that the data points in Dataset 1 are strictly non-negative.

  A *power transform* is a data mapping which is used to normalise data and stabilise variance. 

  The Box-Cox transform is given as

  $
  y_i^((lambda)) = cases(display((y_i^((lambda)) - 1)/lambda) quad &"if" lambda != 0, ln y_i &"if" lambda = 0 )
  $

  where $y_i > 0$ is the data being transformed, which in our case is $xi_j$.
]

]

#let ti = $t^((i))$

+ #[
  *Incomplete, Positive-Only Labels*

  Binary Classification Problem.

  Dataset ${(xi, ti, yi)}_(i=1)^m$ where $ti={0,1}$ is the label, and $yi={0, 1}$ indicate whether it is labelled.

  $yi = 0$ - example is unlabeled, maybe positive or negative.
  $yi = 0$ - example is labeled and is positive.

  $
  p(ti=1|yi=1) = 1
  $

  Construct  binary classifier $h$
$
h(xi) = p(ti=1|xi)
$
  
  + #[

    Given that
    $
    p(yi=1|ti=1, xi) = p(yi=1|ti=1)
    $
    or equivalently
    $
    p(xi, yi=1|ti=1) = p(xi|ti=1) p(yi=1|ti=1)
    $
    (i.e. given a positive example, the probability of it being labelled is independent of the example itself, labelled examples are a random sample of positive examples.)

    To show: $
    p(ti=1|xi) = p(yi=1|xi)/alpha
    $
    Properties:
    $
    p(X|A) = p(X, A)/p(A)\
    p(X) = p(X|A_1)p(A_1) + ... + p(X|A_n)p(A_n)
    $
    for $A_i$ mutually exclusive and collectively exhaustive.

    $
    alpha &= p(yi=1, xi) / p(ti=1, xi)\
    &= frac(p(yi=1, xi|ti=1)p(ti=1) + p(yi=1, xi|ti=0)p(ti=0), p(ti=1, xi))\
    &= frac(p(yi=1|ti=1)p(xi|ti=1)p(ti=1) + cancel(p(yi=1|ti=0))p(xi, ti=1)p(ti=0),p(ti=1, xi))\
    &= p(yi=1|ti=1)
    $

    (fraction of positive examples that are labelled)

    This proves that $p(yi=1|xi)$ and $p(ti=1|xi)$ are proportional. Note that for all training examples we know the value of $yi$ but not $ti$. So with our usual methods we can model $p(yi=1|xi)$ and using it find $p(ti=1|xi)$.
  ]

  + #[
  Validation set $V$ 

$V_+$ - set of labelled (hence positive) examples in $V$

Assume $h(xi) approx p(yi=1|xi) forall xi$

Assume $p(ti=1|xi) approx 1$ (all examples are positive)

Show that $h(xi) approx alpha$ for $xi in V_+$

For $xi in V_+$, $ h(xi) &= p(yi=1|xi) = alpha times  p(ti=1|xi) \
&= alpha times 1 = alpha
$


This shows if we model $p(yi=1|xi)$, then prediction on any labelled value will output a probability approximately $alpha$.
This can be used to estimate the proportionality factor $alpha$ which is necessary to estimate $p(ti=1|xi)$. (This is an unknown quantity in a $(xi, yi)$ dataset.)
  ]

  + #[
    *Coding Problem*
    
    To train model on t-labels. 
    
    ```py
    model = LogisticRegression()
    x_train, y_train = util.load_dataset(train_path, label_col='t', 
                                         add_intercept=True)
    x_test, y_test = util.load_dataset(test_path, label_col='t', 
                                       add_intercept=True)
    model.fit(x_train, y_train)

    t_pred = model.predict(x_test)

    util.plot(x_test, y_test, model.theta, 
              pred_path_c.replace('.txt', '.png'))

    np.savetxt(pred_path_c, t_pred > 0.5, fmt='%d')
    ```

    #image("images/p02c_pred.png")
  ]

  + #[
    To train model on y-labels and to predict $p(yi=1|xi)$
    
    ```py
    x_train, y_train = util.load_dataset(train_path, label_col='y', 
                                         add_intercept=True)
    model.fit(x_train, y_train)

    x_test, y_test = util.load_dataset(test_path, label_col='y', 
                                       add_intercept=True)
    y_pred = model.predict(x_test)


    util.plot(x_test, y_test, model.theta, 
              pred_path_d.replace('.txt', '.png'))

    np.savetxt(pred_path_d, y_pred > 0.5, fmt='%d')
    ```

    #image("images/p02d_pred.png")

    Here, blue data points are labelled ones. Green data points are unlabelled and thus contain both positive and negative examples.

    The red line is the decision boundary where $p(y=1|x) = 0.5$. (The model has 'learned' (albeit very badly) to distinguish between labelled and unlabelled examples).
  ]

  + #[
    Now since $p(t=1|x) = 1/alpha p(y=1|x)$, we can scale up the probability values and predict based on $p(t=1|x) > 0.5$.

    To visualise, the following two plots shows an example of possible sigmoid curve for $p(y=1|x)$ (left) with its decision boundary marked, and its scaled version $p(t=1|x)$ (right). As it is clear from the figure, by doing so the decision boundary shifts towards the unlabelled (negative) examples. (This is what should happen, because earlier it predicted all examples as unlabelled (negative).)

    #grid(columns: 2, image("images/sigmoid-1.png"), image("images/sigmoid-2.png"))

    ```py
    x_valid, y_valid = util.load_dataset(valid_path, label_col='y', add_intercept=True)
    y_valid_pred = model.predict(x_valid)
    alpha = np.mean(y_valid_pred)

    t_pred = y_pred / alpha

    np.savetxt(pred_path_e, t_pred > 0.5, fmt='%d')
    ```

    However we need to figure out how to draw the boundary of this corrected model.

    Normally, the decision boundary is drawn by solving $p(y=1|x) = 0.5$, which is equivalent to $theta^T x = 0$.

    $
    theta_0 + theta_1 x_1 + theta_2 x_2  = 0
    $

    However, here we need $p(t=1|x) = 0.5$, which means

    $
    p(ti=1|xi) = 1/alpha p(yi=1|xi) &= 0.5\
    => frac(1, 1 + exp(- theta^T xi)) &= alpha/2\
    =>  exp(-theta^T xi) &= 2 / alpha - 1\
    => theta^T xi &= -ln(2/alpha - 1)\
    =>  theta_0 + theta_1 x_1 + theta_2 x_2 &= -ln(2/alpha - 1)\

    => theta_0(1 + 1/theta_0 ln(2/alpha - 1)) + theta_1 x_1 + theta_2 x_2 &= 0
    $

    The `plot()` function takes in a `correction` argument for this purpose, which is a 'scaling' factor for the constant term.

    In this case, the `correction` is $1 + 1/theta_0 ln(2/alpha - 1)$.

    ```py
    correction = 1 + np.log(2 / alpha - 1) / model.theta[0]
    util.plot(x_test, y_test, model.theta, 
              pred_path_e.replace('.txt', '.png'), correction=correction)
    ```

    #image("images/p02e_pred.png")

    In the above image we are back to representing the positive examples in blue and negative examples in green.
    
    Notice that since our correction only affected the constant term of our equation of the line, the decision boundary here is parallel to the one for $p(y=1|x)$.

    (Remark) In case sorting is required instead of classification, we can directly sort based on $p(y=1|x)$ (without needing to estimate $alpha$). In the above example, this is equivalent to sorting based on probability prediction of (d), so examples near the top-right of the x1-x2 space will be sorted towards the beginning.
  ]
]

+ #[
  *Poisson Regression*
  + #[
    $ p(y; lambda) = frac(e^(-lambda) lambda^y, y!) $

    The exponential family is characterised by the following PDF:

    $
    p(y; eta) = b(y) exp(eta^T T(y) - a(eta))
    $
    where $y$ is the data, $eta$ is the natural parameter, $T(y)$ is the sufficient statistic (mostly $T(y) = y$), $b(y)$ is the base measure, and $a(eta)$ is the log-partition function, playing the role of normalising factor.

    The Poisson distribution is

    $
    p(y; lambda) &= frac(e^(-lambda) lambda^y, y!)\
    &= 1/y! exp(-lambda + y ln lambda)
    $

    It can be written in terms of an exponential distribution, with

    $
    eta &= ln lambda\
    T(y) &= y\
    b(y) &= 1/y!\
    a(eta) &= lambda = e^eta
    $
  ]

  + #[ //// TODO Rewrite answer to be more accurate
    If $y|x; theta tilde "ExponentialDistribution"(eta)$, to model $y|x; theta$ we can use a GLM, with $eta = theta^T x$. We train $h_theta (x) = E[y|x; theta] = E[y|theta^T x]$

    To learn, $limits(max)_theta log p(yi, theta^T xi)$.

    Canonical response function $g$ is the one that gives the distributions mean as a function of the natural parameter $eta$.

    For Poisson's GLM, $E[y] = mu = lambda = g(eta) = e^eta$.

    Then hypothesis (predictor to be learned) $
    h_theta (x) = mu =  e^(theta^T x)
    $
  ]

  + #[ 
    Stochastic Ascent Rule: (For any GLM)
    $
    theta_j := theta_j + alpha frac(partial, partial theta_j) l(theta)
    $
    
    $
    log p(y|x; theta)
    &= log frac(e^(-lambda) lambda^y, y!) &&= -lambda + y ln lambda - sum_(i=1)^y ln i\
    &&&=- e^(theta^T x) + y theta^T x - ln y!\
    $

    Then, log likelihood:

    $
    l(theta) = sum_(i=1)^m log p(yi|xi; theta) = sum_(i=1)^m - e^(theta^T xi) + yi theta^T xi - ln yi!
    $

    By MLE:

    $
    frac(partial, partial theta_j) l(theta) = sum_(i=1)^m - xi_j e^(theta^T xi) + xi_j yi = xi_j (yi - e^(theta^T xi))
    $

    Thus update rule: 

    $
    theta_j := theta_j + alpha (yi - e^(theta^T xi)) xi_j
    $
    
  ]
  // #show math.equation: it => {
    // #show "+=": math.class("binary", math.class("normal", sym.plus) + math.class("normal", sym.eq))
  // }

  + #[
    *Coding Problem*

    Stochastic Gradient Descent:

    $
    "loop:"\
    &"for" i = 1 "to" m\
    &wide theta := theta + alpha (yi - exp(theta^T xi)) xi
    $

    Batch Gradient Descent
    $
    "loop:"&\
    &theta &&:= theta + alpha sum_(i=1)^m (yi - exp(theta^T xi)) xi\
    &&&:= theta + alpha 
      MatrixCols(#{i => $x^((#i))$}, m)
      vec(y^((1)) - exp(theta^T x^((1))), y^((2)) - exp(theta^T x^((2))), dots.v, y^((m)) - exp(theta^T x^((m))))
    \
    &&&:= theta + alpha X^T (y - exp(X theta))
    $

    (The sum is a linear combination of $xi$ vectors!)

    ```focus
  class PoissonRegression(LinearModel):
    def fit(self, x, y, stochastic=False):
        # *** START CODE HERE ***
        m, n = x.shape
        self.theta = np.zeros(n)
        c = 0
        while True:
            c += 1
            prev = np.copy(self.theta)

            # Stochastic gradient ascent
            if stochastic:
                for i in range(m):
                    self.theta += self.step_size * 
                        (y[i] - np.exp(x[i] @ self.theta)) * x[i]
            # Batch gradient ascent
            else:
                self.theta += self.step_size * 
                    (x.T @ (y - np.exp(x @ self.theta)))

            diff = np.linalg.norm(self.theta - prev, ord=1)
            if diff < self.eps or c >= self.max_iter:
                break
        # *** END CODE HERE ***

    def predict(self, x):
        # *** START CODE HERE ***
        return np.exp(x @ self.theta)
        # *** END CODE HERE ***
    ```
    #v(1em)

    Ran on parameters:

    ```txt
    Stochastic Gradient Ascent:
      - lr: 5e-8
      - converges in: 4 iterations

    Batch Gradient Ascent:
      - lr: 2e-11
      - converges in: 2008 iterations
    ```
    Stochastic Gradient Ascent:
    #image("images/p03d_pred_st_loss.png")

    Batch Gradient Ascent:
    #image("images/p03d_pred_bg_loss.png")
  ]
]

+ #[
  *Convexity of Generalised Linear Models*
  
  To show: NLL loss of GLM is a convex function w.r.t. model parameters 
  
  $
  p(y; eta) = b(y) exp(eta^T T(y) - a(eta)))
  $

  Simplified:
  $
  p(y; eta) = b(y) exp(eta y - a(eta))
  $
  + #[
    $
    EE (Y | X; theta) = EE(Y|eta) &= integral y thin p(y; eta) dif y \
    mu &= integral y thin b(y) exp(eta y - a(eta)) dif y\
    => mu e^(a(eta)) &= integral y thin b(y) exp(eta y) dif y\
    // frac(partial mu, partial eta) &= integral y thin b(y) exp(eta y - a(eta)) (y  - a'(eta)) dif y 
    $

    Normalisation Condition:

    $
    integral thin p(y; eta) dif y = integral b(y) e^(eta y) / e^(a(eta)) dif y = 1\
    => e^(a(eta)) = integral b(y) e^(eta y) dif y\
    => e^(a(eta)) a'(eta) = integral y thin b(y) e^(eta y) dif y  
    $
    On comparison, 

    $
    e^(a eta) mu = e^(a eta) a'(eta)\
    => mu = a'(eta)
    $
  ]
#let Var = math.op("Var")
  + #[
    $
    Var(Y|X\; theta) = Var(Y\;eta) &= integral y^2 p(y; eta) dif y - mu^2\
    &= integral y^2 b(y) exp(eta y - a(eta)) dif y - mu^2
    $

    From Normalisation Condition, we have

    $
    a'(eta) &= integral y b(y) exp(eta y - a(eta)) dif y\
    => a''(eta) &=  integral y b(y) exp(eta y - a(eta)) (y - a'(eta)) dif y\
    &= integral y^2 thin b(y) exp(eta y - a(eta)) dif y -  a'(eta) integral y thin b(y) exp(eta y - a(eta)) dif y\
    &= integral y^2 thin b(y) exp(eta y - a(eta) dif y) - mu^2
    $

    On Comparison,

    $
    Var(Y|X\; theta) = a''(eta)
    $
  ]

  + #[
    $
    cal(L)(theta) = p(y | x; theta) = b(y) exp(eta y - a(eta))\
  => cal(l)(theta) =- log b(y) + a(theta^T x) - theta^T x y\

  nabla_theta cal(l) (theta) = x thin (a'(theta^T x) - y)\

  H = nabla_theta (x thin a'(theta^T x)) =a''(theta^T x) x x^T
    $

    For $H$ to be PSD,
    $
    z^T H z = z^T a''(theta^T x) x x^T z = a''(theta^T x ) z^T x x^T z &= a''(theta^T x) (x^T z)^T (x^T z)\
    &= a''(theta^T x) (x^T z)^2 >= 0 forall z
    $

    (since $a''(eta) = Var(Y | X\; theta) >= 0 $)

    Thus NLL loss of a GLM is convex.

    Given that gradient of NLL is $x (a' (theta^T x) - y)$, we have gradient descent update rule:

    $
    theta := theta - alpha (a'(theta^T xi) - yi) xi
    $

    and prediction function $h_theta (x) = a'(theta^T x)$.

    Thus, for any GLM, we find the update function to be similar:

    $
    theta := theta + alpha (yi - h_theta (xi)) xi
    $
  ]
]

+ #[
  *Locally weighted linear regression*

  #let wi = $w^((i))$
  
  + #[
    $ J(theta) = 1/2 sum_(i=1)^m w^((i)) (theta^T xi - yi)^2 $

    + #[
      To show that $J(theta) = (X theta - y)^T W (X theta - y)$ for diagonal $W$.

      $
      J(theta) &= 1/2mat(w^((1)) theta^T x^((1)) - y^((1)), w^((2)) theta^T x^((2)) - y^((2)), dots.c, w^((m)) theta^T x^((m)) - y^((m))) dot vec(theta^T x^((1)) - y^((1)), theta^T x^((2)) - y^((2)), dots.v, theta^T x^((m)) - y^((m)))\
      &=1/2 mat(theta^T x^((1)) - y^((1)), theta^T x^((2)) - y^((2)), dots.c, theta^T x^((m)) - y^((m))) MatrixDiag(#{x => $w^((#x))$}, m) vec(theta^T x^((1)) - y^((1)), theta^T x^((2)) - y^((2)), dots.v, theta^T x^((m)) - y^((m)))\
      &=1/2 (X theta -  y)^T W (X theta - y)
      $

      where $W = 1/2  op("diag")(w^((1)), w^((2)), ..., w^((m)))$
    ]

    + #[
     $
     J(theta) &=1/2 (X theta - y)^T W (X theta - y)\
     &=1/2( (X theta)^T W X theta - y^T W X theta - (X theta)^T W y + y^T W y)\
    &= 1/2(theta^T X^T W X theta - y^T W X theta - theta^T X^T W y + y^T W y)\
    nabla_theta J(theta) &= X^T W X theta - 1/2X^T W^T y - 1/2X^T W y\
    &= X^T W X theta - X^T W y = 0 $$
    => X^T W X theta &= X^T W y\
    => theta  &= (X^T W X)^(-1) X^T W y
     $

     ($nabla_x x^T A x = 2 A x$ for symmetric $A$)
    ]

    + #[
      Assume model:

      $
      p(yi|xi; theta) = 1/(sqrt(2 pi) sigma^((i))) exp(- frac((yi - theta^T xi)^2, 2 (sigma^((i)))^2))
      $

      NLL: 

      $
      l(theta) &= sum_(i=1)^m frac((yi - theta^T xi)^2, 2 (sigma^((i)))^2) \
      &= 1/2 sum_(i=1)^m frac(1, (sigma^((i)))^2) (yi - theta^T xi)^2
      $

      Thus it is equivalent to weighted linear regression with $wi = 1/(sigma^((i)))^2$.
    ]
  ]

  + #[
    *Coding Problem*

    Use $
    wi =exp(-frac(||xi - x||^2_2, 2 tau^2))
    $

    $
    theta  &= (X^T W X)^(-1) X^T W y
    $

    ```focus
    
class LocallyWeightedLinearRegression(LinearModel):
    def fit(self, x, y):
        # *** START CODE HERE ***
        self.x = x
        self.y = y
        # *** END CODE HERE ***

    def predict_single(self, x):
        # *** START CODE HERE ***
        m, n = self.x.shape
        W = np.zeros((m, m))
        for i in range(m):
            W[i, i] = np.exp(-np.sum((x - self.x[i])**2)/(2*self.tau**2))
        theta = np.linalg.inv(self.x.T @ W @ self.x) 
                      @ self.x.T @ W @ self.y
        y_pred = x @ theta
        return y_pred
        # *** END CODE HERE ***

    def predict(self, x):
        # *** START CODE HERE ***
        m, n = x.shape
        y = np.zeros(m)
        
        for i in range(m):
            y[i] = self.predict_single(x[i])

        return y
        # *** END CODE HERE ***
    
    ```
    // #image("images/p05b_tau_0.5.png")
    (see plot in (c))\
    MSE = 0.3305
    
    Model seems to be underfitting. 
  ]
  + #[
    ```py
    mse_values = []
    for tau in tau_values:
        clf = LocallyWeightedLinearRegression(tau)
        clf.fit(x_train, y_train)
        y_pred = clf.predict(x_valid)
        mse = np.mean((y_valid - y_pred)**2)
        mse_values.append(mse)
        plt.figure()
        plt.plot(x_train[:, 1], y_train, 'bx')
        plt.plot(x_valid[:, 1], y_pred, 'ro')
        plt.xlabel('x')
        plt.ylabel('y')
        plt.title('tau = ' + str(tau))
        plt.savefig('output/p05c_tau_{}.png'.format(tau))
    best_tau = tau_values[np.argmin(mse_values)]
    ```

    Best $tau$ value: 0.05, MSE = 0.017 on test set

    #image("images/p05c_tau_10.0.png")
    #image("images/p05c_tau_1.0.png")
    #image("images/p05c_tau_0.5.png")
    #image("images/p05c_tau_0.1.png")
    #image("images/p05c_tau_0.05.png")
    #image("images/p05c_tau_0.03.png")

    Note that $tau$ is the standard deviation of the gaussian for the local weighting. So lower $tau$ means that weights will be strongly local.
  ]
]

#pagebreak(weak: true)