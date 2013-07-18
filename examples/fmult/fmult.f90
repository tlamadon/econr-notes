subroutine fmult(A,X,Y,n,m)
implicit none

integer :: n,m,i,j
DOUBLE PRECISION,dimension(n,m) :: A
DOUBLE PRECISION,dimension(m) :: X
DOUBLE PRECISION,dimension(n) :: Y

do i = 1,n
Y(i)=0
do j = 1,m
  Y(i) = Y(i) + A(i,j) * X(j) 
end do
end do

end