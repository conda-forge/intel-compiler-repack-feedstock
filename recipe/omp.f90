! Exercises the parts of intel-fortran-rt that simple.f90 does not:
! OpenMP (libiomp5), formatted file I/O (libifcore) and C interop.
program omp_test
  use iso_c_binding, only: c_double, c_int
  use omp_lib
  implicit none
  integer, parameter :: n = 100000
  integer(c_int) :: i, nthreads, u
  real(c_double) :: total, back

  total = 0
  !$omp parallel do reduction(+:total)
  do i = 1, n
     total = total + real(i, c_double)
  end do
  !$omp end parallel do

  !$omp parallel
  !$omp single
  nthreads = omp_get_num_threads()
  !$omp end single
  !$omp end parallel
  print *, "threads:", nthreads, "sum:", total

  open(newunit=u, file="omp_test.txt", status="replace", action="readwrite")
  write(u, "(F20.1)") total
  rewind(u)
  read(u, "(F20.1)") back
  close(u, status="delete")

  if (total /= real(n, c_double) * (n + 1) / 2 .or. back /= total) then
     print *, "Result: wrong sum", total, back
     call exit(1)
  end if
  print *, "Result: ok"
end program omp_test
