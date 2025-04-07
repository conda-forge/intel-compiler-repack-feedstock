program fortran_test
  implicit none
  integer, parameter :: n = 16
  integer :: i
  integer :: v(n) = (/ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53 /)
  integer :: v_shared(n)
  integer :: v_device(n)
  integer :: v_host(n)
  integer :: v2(n)
  logical :: eq

  print *, "Fortran Test: memory copy chain simulation"

  v_shared = v
  print *, "Stage 1 done: v -> v_shared"

  v_device = v_shared
  print *, "Stage 2 done: v_shared -> v_device"

  v_host = v_device
  print *, "Stage 3 done: v_device -> v_host"

  v2 = v_host
  print *, "Stage 4 done: v_host -> v2"

  eq = .true.
  do i = 1, n
     if (v(i) /= v2(i)) eq = .false.
  end do

  if (eq) then
     print *, "Result: Arrays are equal!"
     call exit(0)
  else
     print *, "Result: Arrays are NOT equal!"
     call exit(1)
  end if

end program fortran_test
