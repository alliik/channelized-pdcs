program test 
use formatmod
use parampost 
use constants
use openbinary 
use maketopo 
use makeascii
use var_3d
use column
use findhead 
use find_richardson 
use entrainment 
use massdist
implicit none
integer:: tfind=8
double precision:: ZLOC=450.0
logical::printstatus 
double precision:: width, lambda
double precision, allocatable:: isosurface(:,:,:)
double precision, dimension(:):: current(4)
double precision:: scaleh
allocate(isosurface(1200,4,15))
RMAX=404
YMAX=154
ZMAX=302
length1=RMAX*YMAX*ZMAX
width=201
lambda=0
printstatus=.false.
timesteps=8
tstart=3
tstop=timesteps
depth = 27

call ALLOCATE_ARRAYS

!print*, 'testing openbin'
call openbin(100, 'EP_G', EP_G1)
!call openbin(200, 'U_G', U_G1)
!call openbin(300, 'T_G', T_G1)
!call openbin(400, 'V_G', V_G1)
!call openbin(500, 'W_G', W_G1)

call handletopo('l300_W201', XXX, YYY, ZZZ)
call  logvolfrc(EP_G1, EPP)

!print*, ZZZ(:,1)
!call openascii(1100, 'EP_P_t')
!call makeEP(1100, EP_P, tfind)
!call makeUG(1200, U_G, printstatus) 

!call makeTG(1300, T_G, printstatus)
call isosurf(width, lambda, scaleh)
!call gradrich(EP_P, T_G1, U_G, Richardson, SHUY)

!call bulkent(EP_G1) 

call massinchannel(width, depth, lambda, scaleh)


print*, "end program"

end program

