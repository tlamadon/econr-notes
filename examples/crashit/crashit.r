

setwd("~/git/econr-notes/examples/crashit")
dyn.load('crashit.so')

.Call("crashit",R_args=FALSE)
