# Transition matrix

A transition matrix is a matrix that defines a movement over states. Given a finite set of states $S$ 
you can define a transition matrix $n \times n$ such that $T_{ij}$ is the probability to move from state $s_i$ 
to state $s_j$.

Note that the transition matrix enters differently in the Bellman equation and in the flow equation.

Given a state vector witch a one on state i, if you want to know the state next period, you compute $T v_i$. However
in a bellman equation you want to know the continuation value next period. This means that you want $ t(T) V $. Confusing isn't it!

