!vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvC
!                                                                      C
!  Module name: SET_BC1                                                C
!  Purpose: Set transient flow boundary conditions                     C
!                                                                      C
!  Author: M. Syamlal                                 Date: 29-JAN-92  C
!  Reviewer: P. Nicoletti, W. Rogers, S. Venkatesan   Date: 29-JAN-92  C
!                                                                      C
!  Revision Number: 1                                                  C
!  Purpose: Add calculations for mass outflow boundary condition       C
!  Author: M. Syamlal                                 Date: 23-OCT-92  C
!  Reviewer: M. Syamlal                               Date: 11-DEC-92  C
!                                                                      C
!  Literature/Document References:                                     C
!                                                                      C
!  Variables referenced: BC_DEFINED, BC_I_w, BC_I_e, BC_J_s, BC_J_n,   C
!                        BC_K_b, BC_K_t, BC_TYPE, TIME, DT, BC_TIME,   C
!                        BC_V_g, BC_V_gh, BC_V_gl, BC_DT_l, BC_DT_h,   C
!                        BC_PLANE, IMAX2, JMAX2, KMAX2                 C
!  Variables modified: BC_V_g, BC_TIME, I, J, K, IJK, V_g              C
!                                                                      C
!  Local variables: L, IJK2, I1, I2, J1, J2, K1, K2                    C
!                                                                      C
!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^C
!
      SUBROUTINE SET_BC1 
!...Translated by Pacific-Sierra Research VAST-90 2.06G5  12:17:31  12/09/98  
!...Switches: -xf
!
!-----------------------------------------------
!   M o d u l e s 
!-----------------------------------------------
      USE param 
      USE param1 
      USE bc
      USE fldvar
      USE geometry
      USE indices
      USE physprop
      USE run
      USE funits 
      USE compar 
      IMPLICIT NONE
!-----------------------------------------------
!   G l o b a l   P a r a m e t e r s
!-----------------------------------------------
!-----------------------------------------------
!   L o c a l   P a r a m e t e r s
!-----------------------------------------------
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
! 
!                      Indices 
      INTEGER          I, J, K, IJK, IPJK, M 
! 
!                      Local index for boundary condition 
      INTEGER          L 
! 
!                      Index for setting V velocity b.c. 
      INTEGER          IJK2 
! 
!                      Starting I index 
      INTEGER          I1 
! 
!                      Ending I index 
      INTEGER          I2 
! 
!                      Starting J index 
      INTEGER          J1 
! 
!                      Ending J index 
      INTEGER          J2 
! 
!                      Starting K index 
      INTEGER          K1 
! 
!                      Ending K index 
      INTEGER          K2 
! 
!-----------------------------------------------
      INCLUDE 'function.inc'
!
!  Set the boundary conditions
!
      DO L = 1, DIMENSION_BC 
         IF (BC_DEFINED(L)) THEN 
!
!  The range of boundary cells
!
            I1 = BC_I_W(L) 
            I2 = BC_I_E(L) 
            J1 = BC_J_S(L) 
            J2 = BC_J_N(L) 
            K1 = BC_K_B(L) 
            K2 = BC_K_T(L) 


      


            IF (BC_TYPE(L) == 'MASS_OUTFLOW') THEN 
               CALL SET_OUTFLOW (L, I1, I2, J1, J2, K1, K2) 
!
!           Calculate and accumulate the actual mass and volume outflow
!
               CALL CALC_OUTFLOW (L) 
               IF (TIME + 0.1d0*DT>=BC_TIME(L) .OR. TIME+0.1d0*DT>=TSTOP) THEN 
                  BC_TIME(L) = TIME + BC_DT_0(L) 
!
!             Average and Print out the flow rates
!
                  BC_MOUT_G(L) = ABS(BC_MOUT_G(L))/BC_OUT_N(L) 
                  BC_VOUT_G(L) = ABS(BC_VOUT_G(L))/BC_OUT_N(L) 
                  CALL START_LOG 
                  IF(DMP_LOG)WRITE (UNIT_LOG, 1000) L, TIME 
                  IF(DMP_LOG)WRITE (UNIT_LOG, 1100) BC_MOUT_G(L), BC_VOUT_G(L) 
                  DO M = 1, SMAX 
                     BC_MOUT_S(L,M) = ABS(BC_MOUT_S(L,M))/BC_OUT_N(L) 
                     BC_VOUT_S(L,M) = ABS(BC_VOUT_S(L,M))/BC_OUT_N(L) 
                     IF(DMP_LOG)WRITE (UNIT_LOG, 1200) M, BC_MOUT_S(L,M), BC_VOUT_S(L,M) 
                  END DO 
                  CALL END_LOG 
                  BC_OUT_N(L) = 0 
!
!           Adjust the velocities if needed
!
                  IF (BC_MASSFLOW_G(L) /= UNDEFINED) THEN 
                     IF (BC_MOUT_G(L) > SMALL_NUMBER) THEN 
                        SELECT CASE (TRIM(BC_PLANE(L)))  
                        CASE ('W')  
                           BC_U_G(L) = BC_U_G(L)*BC_MASSFLOW_G(L)/BC_MOUT_G(L) 
                        CASE ('E')  
                           BC_U_G(L) = BC_U_G(L)*BC_MASSFLOW_G(L)/BC_MOUT_G(L) 
                        CASE ('S')  
                           BC_V_G(L) = BC_V_G(L)*BC_MASSFLOW_G(L)/BC_MOUT_G(L) 
                        CASE ('N')  
                           BC_V_G(L) = BC_V_G(L)*BC_MASSFLOW_G(L)/BC_MOUT_G(L) 
                        CASE ('B')  
                           BC_W_G(L) = BC_W_G(L)*BC_MASSFLOW_G(L)/BC_MOUT_G(L) 
                        CASE ('T')  
                           BC_W_G(L) = BC_W_G(L)*BC_MASSFLOW_G(L)/BC_MOUT_G(L) 
                        END SELECT 
                     ENDIF 
                  ELSE IF (BC_VOLFLOW_G(L) /= UNDEFINED) THEN 
                     IF (BC_VOUT_G(L) > SMALL_NUMBER) THEN 
                        SELECT CASE (TRIM(BC_PLANE(L)))  
                        CASE ('W')  
                           BC_U_G(L) = BC_U_G(L)*BC_VOLFLOW_G(L)/BC_VOUT_G(L) 
                        CASE ('E')  
                           BC_U_G(L) = BC_U_G(L)*BC_VOLFLOW_G(L)/BC_VOUT_G(L) 
                        CASE ('S')  
                           BC_V_G(L) = BC_V_G(L)*BC_VOLFLOW_G(L)/BC_VOUT_G(L) 
                        CASE ('N')  
                           BC_V_G(L) = BC_V_G(L)*BC_VOLFLOW_G(L)/BC_VOUT_G(L) 
                        CASE ('B')  
                           BC_W_G(L) = BC_W_G(L)*BC_VOLFLOW_G(L)/BC_VOUT_G(L) 
                        CASE ('T')  
                           BC_W_G(L) = BC_W_G(L)*BC_VOLFLOW_G(L)/BC_VOUT_G(L) 
                        END SELECT 
                     ENDIF 
                  ENDIF 
                  BC_MOUT_G(L) = ZERO 
                  BC_VOUT_G(L) = ZERO 
                  DO M = 1, SMAX 
                     IF (BC_MASSFLOW_S(L,M) /= UNDEFINED) THEN 
                        IF (BC_MOUT_S(L,M) > SMALL_NUMBER) THEN 
                           SELECT CASE (TRIM(BC_PLANE(L)))  
                           CASE ('W')  
                              BC_U_S(L,M) = BC_U_S(L,M)*BC_MASSFLOW_S(L,M)/&
                                 BC_MOUT_S(L,M) 
                           CASE ('E')  
                              BC_U_S(L,M) = BC_U_S(L,M)*BC_MASSFLOW_S(L,M)/&
                                 BC_MOUT_S(L,M) 
                           CASE ('S')  
                              BC_V_S(L,M) = BC_V_S(L,M)*BC_MASSFLOW_S(L,M)/&
                                 BC_MOUT_S(L,M) 
                           CASE ('N')  
                              BC_V_S(L,M) = BC_V_S(L,M)*BC_MASSFLOW_S(L,M)/&
                                 BC_MOUT_S(L,M) 
                           CASE ('B')  
                              BC_W_S(L,M) = BC_W_S(L,M)*BC_MASSFLOW_S(L,M)/&
                                 BC_MOUT_S(L,M) 
                           CASE ('T')  
                              BC_W_S(L,M) = BC_W_S(L,M)*BC_MASSFLOW_S(L,M)/&
                                 BC_MOUT_S(L,M) 
                           END SELECT 
                        ENDIF 
                     ELSE IF (BC_VOLFLOW_S(L,M) /= UNDEFINED) THEN 
                        IF (BC_VOUT_S(L,M) > SMALL_NUMBER) THEN 
                           SELECT CASE (TRIM(BC_PLANE(L)))  
                           CASE ('W')  
                              BC_U_S(L,M) = BC_U_S(L,M)*BC_VOLFLOW_S(L,M)/&
                                 BC_VOUT_S(L,M) 
                           CASE ('E')  
                              BC_U_S(L,M) = BC_U_S(L,M)*BC_VOLFLOW_S(L,M)/&
                                 BC_VOUT_S(L,M) 
                           CASE ('S')  
                              BC_V_S(L,M) = BC_V_S(L,M)*BC_VOLFLOW_S(L,M)/&
                                 BC_VOUT_S(L,M) 
                           CASE ('N')  
                              BC_V_S(L,M) = BC_V_S(L,M)*BC_VOLFLOW_S(L,M)/&
                                 BC_VOUT_S(L,M) 
                           CASE ('B')  
                              BC_W_S(L,M) = BC_W_S(L,M)*BC_VOLFLOW_S(L,M)/&
                                 BC_VOUT_S(L,M) 
                           CASE ('T')  
                              BC_W_S(L,M) = BC_W_S(L,M)*BC_VOLFLOW_S(L,M)/&
                                 BC_VOUT_S(L,M) 
                           END SELECT 
                        ENDIF 
                     ENDIF 
                     BC_MOUT_S(L,M) = ZERO 
                     BC_VOUT_S(L,M) = ZERO 
                  END DO 
                  DO K = BC_K_B(L), BC_K_T(L) 
                     DO J = BC_J_S(L), BC_J_N(L) 
                        DO I = BC_I_W(L), BC_I_E(L) 
                         IF (.NOT.IS_ON_myPE_plus2layers(I,J,K)) CYCLE
                           IJK = FUNIJK(I,J,K) 
                           SELECT CASE (TRIM(BC_PLANE(L)))  
                           CASE ('W')  
                              IJK2 = IM_OF(IJK) 
                              U_G(IJK2) = BC_U_G(L) 
                           CASE ('E')  
                              U_G(IJK) = BC_U_G(L) 
                           CASE ('S')  
                              IJK2 = JM_OF(IJK) 
                              V_G(IJK2) = BC_V_G(L) 
                           CASE ('N')  
                              V_G(IJK) = BC_V_G(L) 
                           CASE ('B')  
                              IJK2 = KM_OF(IJK) 
                              W_G(IJK2) = BC_W_G(L) 
                           CASE ('T')  
                              W_G(IJK) = BC_W_G(L) 
                           END SELECT 
                           DO M = 1, SMAX 
                              SELECT CASE (TRIM(BC_PLANE(L)))  
                              CASE ('W')  
                                 IJK2 = IM_OF(IJK) 
                                 U_S(IJK2,M) = BC_U_S(L,M) 
                              CASE ('E')  
                                 U_S(IJK,M) = BC_U_S(L,M) 
                              CASE ('S')  
                                 IJK2 = JM_OF(IJK) 
                                 V_S(IJK2,M) = BC_V_S(L,M) 
                              CASE ('N')  
                                 V_S(IJK,M) = BC_V_S(L,M) 
                              CASE ('B')  
                                 IJK2 = KM_OF(IJK) 
                                 W_S(IJK2,M) = BC_W_S(L,M) 
                              CASE ('T')  
                                 W_S(IJK,M) = BC_W_S(L,M) 
                              END SELECT 
                           END DO  
! for GHD theory to compute mixture BC of velocity and density
                           IF(TRIM(KT_TYPE) == 'GHD') THEN
                             ROP_S(IJK,MMAX) = ZERO
                             U_S(IJK,MMAX) =  ZERO 
                             V_S(IJK,MMAX) =  ZERO 
                             W_S(IJK,MMAX) =  ZERO 
                             U_S(IJK2,MMAX) =  ZERO 
                             V_S(IJK2,MMAX) =  ZERO 
                             W_S(IJK2,MMAX) =  ZERO 
                             DO M = 1, SMAX 
                                ROP_S(IJK,MMAX) = ROP_S(IJK,MMAX) + ROP_S(IJK,M)
                                SELECT CASE (TRIM(BC_PLANE(L)))  
                                CASE ('W')  
                                   IJK2 = IM_OF(IJK) 
                                   U_S(IJK2,MMAX) =  U_S(IJK2,MMAX) + BC_U_S(L,M)*ROP_S(IJK2,M)
                                CASE ('E')  
                                   IJK2 = IP_OF(IJK)
                                   U_S(IJK,MMAX) =  U_S(IJK,MMAX) + BC_U_S(L,M)*ROP_S(IJK2,M)
                                CASE ('S')  
                                   IJK2 = JM_OF(IJK) 
                                   V_S(IJK2,MMAX) =  V_S(IJK2,MMAX) + BC_V_S(L,M)*ROP_S(IJK2,M)
                                CASE ('N')  
                                   IJK2 = JP_OF(IJK)
                                   V_S(IJK,MMAX) =  V_S(IJK,MMAX) + BC_V_S(L,M)*ROP_S(IJK2,M)
                                CASE ('B')  
                                   IJK2 = KM_OF(IJK) 
                                   W_S(IJK2,MMAX) =  W_S(IJK2,MMAX) + BC_W_S(L,M)*ROP_S(IJK2,M)
                                CASE ('T')  
                                   IJK2 = KP_OF(IJK)
                                   W_S(IJK,MMAX) =  W_S(IJK,MMAX) + BC_W_S(L,M)*ROP_S(IJK2,M)
                                END SELECT 
                             END DO 
                             SELECT CASE (TRIM(BC_PLANE(L)))  
                             CASE ('W')  
                                IJK2 = IM_OF(IJK) 
                                U_S(IJK2,MMAX) =  U_S(IJK2,MMAX) / ROP_S(IJK,MMAX)
                             CASE ('E')  
                                U_S(IJK,MMAX) =  U_S(IJK,MMAX) / ROP_S(IJK,MMAX)
                             CASE ('S')  
                                IJK2 = JM_OF(IJK) 
                                V_S(IJK2,MMAX) =  V_S(IJK2,MMAX) / ROP_S(IJK,MMAX)
                             CASE ('N')  
                                V_S(IJK,MMAX) =  V_S(IJK,MMAX) / ROP_S(IJK,MMAX)
                             CASE ('B')  
                                IJK2 = KM_OF(IJK) 
                                W_S(IJK2,MMAX) =  W_S(IJK2,MMAX) / ROP_S(IJK,MMAX)
                             CASE ('T')  
                                W_S(IJK,MMAX) =  W_S(IJK,MMAX) / ROP_S(IJK,MMAX)
                             END SELECT 
                           ENDIF
! end of modifications for GHD theory
                                           
                        END DO 
                     END DO 
                  END DO 
               ENDIF 

 
            ELSE IF (BC_TYPE(L) == 'MASS_INFLOW') THEN !ended 430


             IF (BC_UNSTEADY == 'STOP_ATT') THEN !ended
                IF (TIME > INFLOW_TIME) THEN ! ended 385
                        DO K = BC_K_B(L), BC_K_T(L) ! ended 342
                        DO J = BC_J_S(L), BC_J_N(L) ! ended 343
                        DO I = BC_I_W(L), BC_I_E(L) !ended 344
                          IF (.NOT.IS_ON_myPE_plus2layers(I,J,K)) CYCLE
                          IJK = FUNIJK(I,J,K) 
                           SELECT CASE (TRIM(BC_PLANE(L)))  !ended 341 
                           CASE ('W')  
                              IJK2 = IM_OF(IJK) 
                              U_G(IJK2) = 0 
                           CASE ('E')  
                              U_G(IJK) = 0 
                           CASE ('S')  
                              IJK2 = JM_OF(IJK) 
                              V_G(IJK2) = 0 
                           CASE ('N')  
                              V_G(IJK) = 0 
                           CASE ('B')  
                              IJK2 = KM_OF(IJK) 
                              W_G(IJK2) = 0 
                           CASE ('T')  
                              W_G(IJK) = 0 
                           END SELECT 
                        END DO 
                     END DO 
                  END DO

                  ELSE ! in refer to end on 319
                  IF (TIME + 0.1d0*DT>=BC_TIME(L) .AND. BC_JET_G(L)/=UNDEFINED) THEN !ended 383
                  IF (BC_JET_G(L) == BC_JET_GH(L)) THEN !ended 357
                      BC_JET_G(L) = BC_JET_GL(L) 
                     BC_TIME(L) = TIME + BC_DT_L(L) 
                  ELSE IF (BC_JET_G(L) == BC_JET_GL(L)) THEN ! ended 357
                     BC_JET_G(L) = BC_JET_GH(L) 
                     BC_TIME(L) = TIME + BC_DT_H(L) 
                  ELSE ! in refer to 348, ended 347
                     BC_JET_G(L) = BC_JET_GH(L) 
                     BC_TIME(L) = TIME + BC_DT_H(L) 
                  ENDIF 
                  DO K = BC_K_B(L), BC_K_T(L) !ended 380
                     DO J = BC_J_S(L), BC_J_N(L) !ended 381
                        DO I = BC_I_W(L), BC_I_E(L) !ended 382
                          IF (.NOT.IS_ON_myPE_plus2layers(I,J,K)) CYCLE
                          IJK = FUNIJK(I,J,K)
                           SELECT CASE (TRIM(BC_PLANE(L)))
                           CASE ('W')
                              IJK2 = IM_OF(IJK)
                              U_G(IJK2) = BC_JET_G(L)
                           CASE ('E')
                              U_G(IJK) = BC_JET_G(L)
                           CASE ('S')
                              IJK2 = JM_OF(IJK)
                              V_G(IJK2) = BC_JET_G(L)
                           CASE ('N')
                              V_G(IJK) = BC_JET_G(L)
                           CASE ('B')
                              IJK2 = KM_OF(IJK)
                              W_G(IJK2) = BC_JET_G(L)
                           CASE ('T')
                              W_G(IJK) = BC_JET_G(L)
                           END SELECT
                        END DO
                     END DO
                  END DO
               ENDIF !refers to 347
                              
             END IF  !if time > inflow_time 

!           update transient jet conditions
            ELSE 
                ! opend ___________
               IF (TIME + 0.1d0*DT>=BC_TIME(L) .AND. BC_JET_G(L)/=UNDEFINED) THEN 
                  IF (BC_JET_G(L) == BC_JET_GH(L)) THEN 
                     BC_JET_G(L) = BC_JET_GL(L) 
                     BC_TIME(L) = TIME + BC_DT_L(L) 
                  ELSE IF (BC_JET_G(L) == BC_JET_GL(L)) THEN 
                     BC_JET_G(L) = BC_JET_GH(L) 
                     BC_TIME(L) = TIME + BC_DT_H(L) 
                  ELSE 
                     BC_JET_G(L) = BC_JET_GH(L) 
                     BC_TIME(L) = TIME + BC_DT_H(L) 
                  ENDIF 
                  DO K = BC_K_B(L), BC_K_T(L) 
                     DO J = BC_J_S(L), BC_J_N(L) 
                        DO I = BC_I_W(L), BC_I_E(L)
                          IF (.NOT.IS_ON_myPE_plus2layers(I,J,K)) CYCLE
                          IJK = FUNIJK(I,J,K) 
                           SELECT CASE (TRIM(BC_PLANE(L)))  
                           CASE ('W')  
                              IJK2 = IM_OF(IJK) 
                              U_G(IJK2) = BC_JET_G(L) 
                           CASE ('E')  
                              U_G(IJK) = BC_JET_G(L) 
                           CASE ('S')  
                              IJK2 = JM_OF(IJK) 
                              V_G(IJK2) = BC_JET_G(L) 
                           CASE ('N')  
                              V_G(IJK) = BC_JET_G(L) 
                           CASE ('B')  
                              IJK2 = KM_OF(IJK) 
                              W_G(IJK2) = BC_JET_G(L) 
                           CASE ('T')  
                              W_G(IJK) = BC_JET_G(L) 
                           END SELECT 
                        END DO 
                     END DO 
                  END DO 
               ENDIF 
              ! closed ================
            END IF ! IF BC_UNSTEADY == true
            
           !END IF ! if type== mass inflow 

            ELSE IF (BC_TYPE(L) == 'P_INFLOW') THEN 
!
!           No need to do anything
!
            ELSE IF (BC_TYPE(L)=='P_OUTFLOW' .OR. BC_TYPE(L)=='OUTFLOW') THEN 
               CALL SET_OUTFLOW (L, I1, I2, J1, J2, K1, K2) 
               IF (BC_DT_0(L) /= UNDEFINED) THEN 
!
!           Calculate and accumulate the actual mass and volume outflow
!
                  CALL CALC_OUTFLOW (L) 
                  IF (TIME + 0.1d0*DT>=BC_TIME(L) .OR. TIME+0.1d0*DT>=TSTOP) THEN 
                     BC_TIME(L) = TIME + BC_DT_0(L) 
!
!               Average and Print out the flow rates
!
                     BC_MOUT_G(L) = ABS(BC_MOUT_G(L))/BC_OUT_N(L) 
                     BC_VOUT_G(L) = ABS(BC_VOUT_G(L))/BC_OUT_N(L) 
                     CALL START_LOG 
                     IF(DMP_LOG)WRITE (UNIT_LOG, 1000) L, TIME 
                     IF(DMP_LOG)WRITE (UNIT_LOG, 1100) BC_MOUT_G(L), BC_VOUT_G(L) 
                     BC_MOUT_G(L) = ZERO 
                     BC_VOUT_G(L) = ZERO 
                     DO M = 1, SMAX 
                        BC_MOUT_S(L,M) = ABS(BC_MOUT_S(L,M))/BC_OUT_N(L) 
                        BC_VOUT_S(L,M) = ABS(BC_VOUT_S(L,M))/BC_OUT_N(L) 
                        IF(DMP_LOG)WRITE(UNIT_LOG,1200)M,BC_MOUT_S(L,M),BC_VOUT_S(L,M) 
                        BC_MOUT_S(L,M) = ZERO 
                        BC_VOUT_S(L,M) = ZERO 
                     END DO 
                     CALL END_LOG 
                     BC_OUT_N(L) = 0 
                  ENDIF 
               ENDIF 

            ENDIF 
    
         ENDIF 
      END DO 

      
      RETURN  
 1000 FORMAT(/,1X,'Average outflow rates at BC No. ',I2,'  At Time = ',G12.5) 
 1100 FORMAT(3X,'Gas : Mass flow = ',G12.5,'     Volumetric flow = ',G12.5) 
 1200 FORMAT(3X,'Solids-',I1,' : Mass flow = ',G12.5,'     Volumetric flow = ',&
         G12.5) 
      END SUBROUTINE SET_BC1 

!// Comments on the modifications for DMP version implementation      
!// 001 Include header file and common declarations for parallelization
!// 360 Check if i,j,k resides on current processor
