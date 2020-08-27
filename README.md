# PE
 Helper functions to compute conditional probability and expectation from a data set. This can be used to calculate estimators in causal inference. 
 
# Limitation

The current version has only been tested on data containing binary variables.

# Examples

The following two examples demonstrate the useage of this package. Note that the argument for the main functions, **P()** and **E()**, are designed so that the code will look identical to the mathematical expression. The package can be similarly applied to other estimators, such as natural indirect and direct effect, controlled direct effect, instramental variables, etc.

## Standardization

Suppose we have a dataset containing binary variables Y, the treatment outcome; A, the treatment group; and C, a sufficient confounder. We can estimate the average treatment effect by,

<a href="https://www.codecogs.com/eqnedit.php?latex=\begin{align*}&space;E(Y^1&space;-&space;Y^0&space;|&space;A&space;=&space;1)&space;&=&space;E(Y^1|A&space;=&space;1)&space;-&space;E(Y^0|A=1)&space;\&space;\&space;\&space;&\text{by&space;linearity&space;of&space;expectation},\\&space;&=&space;E(Y^1|A&space;=&space;1)&space;-&space;E_{C|A=1}E(Y^0|A=1,&space;C)&space;\&space;\&space;\&space;&\text{by&space;law&space;of&space;total&space;probability},\\&space;&=&space;E(Y^1|A&space;=&space;1)&space;-&space;E_{C|A=0}E(Y^0|A=0,&space;C)&space;\&space;\&space;\&space;&\text{sufficient&space;confounder},\\&space;&=&space;E(Y|A&space;=&space;1)&space;-&space;E_{C|A=0}E(Y|A=0,&space;C)&space;\&space;\&space;\&space;&\text{by&space;consistency},\\&space;&=&space;E(Y|A&space;=&space;1)&space;-&space;\sum_c&space;E(Y|A=0,&space;C=c)P(C=c|A=0)&space;\&space;\&space;\&space;&\text{definition&space;of&space;expectation}.&space;\end{align*}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\begin{align*}&space;E(Y^1&space;-&space;Y^0&space;|&space;A&space;=&space;1)&space;&=&space;E(Y^1|A&space;=&space;1)&space;-&space;E(Y^0|A=1)&space;\&space;\&space;\&space;&\text{by&space;linearity&space;of&space;expectation},\\&space;&=&space;E(Y^1|A&space;=&space;1)&space;-&space;E_{C|A=1}E(Y^0|A=1,&space;C)&space;\&space;\&space;\&space;&\text{by&space;law&space;of&space;total&space;probability},\\&space;&=&space;E(Y^1|A&space;=&space;1)&space;-&space;E_{C|A=0}E(Y^0|A=0,&space;C)&space;\&space;\&space;\&space;&\text{sufficient&space;confounder},\\&space;&=&space;E(Y|A&space;=&space;1)&space;-&space;E_{C|A=0}E(Y|A=0,&space;C)&space;\&space;\&space;\&space;&\text{by&space;consistency},\\&space;&=&space;E(Y|A&space;=&space;1)&space;-&space;\sum_c&space;E(Y|A=0,&space;C=c)P(C=c|A=0)&space;\&space;\&space;\&space;&\text{definition&space;of&space;expectation}.&space;\end{align*}" title="\begin{align*} E(Y^1 - Y^0 | A = 1) &= E(Y^1|A = 1) - E(Y^0|A=1) \ \ \ &\text{by linearity of expectation},\\ &= E(Y^1|A = 1) - E_{C|A=1}E(Y^0|A=1, C) \ \ \ &\text{by law of total probability},\\ &= E(Y^1|A = 1) - E_{C|A=0}E(Y^0|A=0, C) \ \ \ &\text{sufficient confounder},\\ &= E(Y|A = 1) - E_{C|A=0}E(Y|A=0, C) \ \ \ &\text{by consistency},\\ &= E(Y|A = 1) - \sum_c E(Y|A=0, C=c)P(C=c|A=0) \ \ \ &\text{definition of expectation}. \end{align*}" /></a>

Using the **P()** and **E()** functions from this package, this expression can be calculated with the following code:
```{r}
E(Y | A == 1) - sum(E(Y | A == 0, C) * P(Y == 1| A == 0, C)))
```

## Difference-in-difference

Suppose we have binary variables F, the pre-exposure outcome; D, the post-exposure outcome; and E an indicator for exposure. Assuming that additive equi-confounding holds with the pre-exposure outcome, that is,

<a href="https://www.codecogs.com/eqnedit.php?latex=E(D^0|E=1)&space;-&space;E(D^0|E=0)&space;=&space;E(F|E&space;=&space;1)&space;-&space;E(F|E&space;=&space;0)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?E(D^0|E=1)&space;-&space;E(D^0|E=0)&space;=&space;E(F|E&space;=&space;1)&space;-&space;E(F|E&space;=&space;0)," title="E(D^0|E=1) - E(D^0|E=0) = E(F|E = 1) - E(F|E = 0)," /></a>

then we can estimate the average effect of exposure in the exposed by,

<a href="https://www.codecogs.com/eqnedit.php?latex=\begin{align*}&space;E(D^1&space;-&space;D^0|E=1)&space;&=E(D^1|E=1)&space;-&space;E(D^0|E=1)&space;\&space;\&space;\&space;&\text{by&space;linearity&space;of&space;expectation,}&space;\\&space;&=E(D^1|E=1)&space;-&space;(E(D^0|E=0)&space;&plus;&space;E(F|E&space;=&space;1)&space;-&space;E(F|E=0))&space;\&space;\&space;\&space;&\text{by&space;equi-confounding,}&space;\\&space;&=(E(D|E=1)&space;-&space;E(D|E=0))&space;-&space;(E(F|E=1)&space;-&space;E(F|E=0))&space;\&space;\&space;\&space;&\text{by&space;consistency.}&space;\\&space;\end{align*}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\begin{align*}&space;E(D^1&space;-&space;D^0|E=1)&space;&=E(D^1|E=1)&space;-&space;E(D^0|E=1)&space;\&space;\&space;\&space;&\text{by&space;linearity&space;of&space;expectation,}&space;\\&space;&=E(D^1|E=1)&space;-&space;(E(D^0|E=0)&space;&plus;&space;E(F|E&space;=&space;1)&space;-&space;E(F|E=0))&space;\&space;\&space;\&space;&\text{by&space;equi-confounding,}&space;\\&space;&=(E(D|E=1)&space;-&space;E(D|E=0))&space;-&space;(E(F|E=1)&space;-&space;E(F|E=0))&space;\&space;\&space;\&space;&\text{by&space;consistency.}&space;\\&space;\end{align*}" title="\begin{align*} E(D^1 - D^0|E=1) &=E(D^1|E=1) - E(D^0|E=1) \ \ \ &\text{by linearity of expectation,} \\ &=E(D^1|E=1) - (E(D^0|E=0) + E(F|E = 1) - E(F|E=0)) \ \ \ &\text{by equi-confounding,} \\ &=(E(D|E=1) - E(D|E=0)) - (E(F|E=1) - E(F|E=0)) \ \ \ &\text{by consistency.} \\ \end{align*}" /></a>

Using the **P()** and **E()** functions from this package, this expression can be calculated with the following code:
```{r}
(E(D | E == 1) - E(D | E == 0)) - (E(F | E == 1) - E(F | E == 0))
```


# Installation
This package can be installed from GitHub using the `devtools` package:

``` r
# install.packages('devtools')
devtools::install_github('tgrimes/PE')
```
