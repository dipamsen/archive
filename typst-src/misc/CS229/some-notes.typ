
= Gradient Descent

Given a scalar valued function $f(x, y) = x^2-3y+y^2$, $nabla f$ is a vector field in $RR^2$.

$
nabla f = frac(partial, partial x) f(x,  y) hat(i) + frac(partial, partial y) f(x, y) hat(j)\
=> lr(nabla f(x, y)|, size: #150%)_((0, 0)) = -3hat(j)
$

In machine language contexts, we have two variables: $n$: number of features, and $m$: number of training examples.

The hypothesis (prediction) function $h_theta (x)$ takes as input $ x in RR^n$ and returns the guessed output.

$theta$ are a set of parameters (weights) which control the model's outputs. These are the "turnable dials" which the machine "learns". Number of tunable parameters is $tilde$ number of features, as each parameter is a weight for the corresponding feature.

#let ind(x, i) = $#x^((#i))$

We have $m$ such training examples: $ind(x, 1), ind(x, 2), ..., ind(x, m)$. Let the corresponding predictions be $ind(y, i)$. Note that depending on the situation $ind(y, i)$ may be a continuous real value, or a specific value from a discrete set.

In supervised learning, the Cost Function ($J(theta): RR^n -> RR$) quantifies the difference between the predicted output of the model and the true output. The goal of the training process is to minimise the value of the cost function by tuning the inputs.

Usually, the cost function has terms indicating the error for each training example.

To update our $theta$s, we notice that if we think of the $theta$s as input to $J$, then in the $theta$-space, we want to reach a minima. The direction of steepest descent  (in $theta$-input space) is given by $- nabla J(theta)
$

Updation function:

$
theta_j := theta_j - alpha frac(partial , partial theta_j) J(theta)
$


#line()

=  Exponential Family

PDF can be written in the form

$
P(y; eta) = b(y) exp(eta^T T(y) - a(eta))
$ 

where $y$ is the data, $eta$ is the natural parameter, $T(y)$ is the sufficient statistic (mostly $T(y) = y$), $b(y)$ is the base measure, and $a(eta)$ is the log-partition function.


Canonical Response $g(eta)$. For linear regression, it is $g(eta) = eta$, for logistic regression it is the sigmoid funciton.

