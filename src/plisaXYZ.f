C
C  PLISA REWRITES THE SOLUTION VECTOR GENERATED BY THE INVERSION
C  PROGRAMS, LISA OR WORK3, AS A SERIES OF CONTOUR FILES THAT ARE
C  PLOTTED WITH CONTOUR.F (original program from S. Hartzell)
C
c	This version of PLISA generates contour files in XYZ format (xdist,ydist,slip)
c	for plotting with GMT.  Slip values are keyed to r/g/b color values to produce
c	slip models using previously-generated grayscale color palette (made with makecpt)  
c	(CMendoza: sep2009; modified jan2010)
c
      COMMON/POINT/ICON,XH,YH
      COMMON/RUPT/TEMP(5000),DSP(5000),SLIP(300,300,30,2)
      DIMENSION SS(300,300),DS(300,300),TS(300,300)
      DIMENSION TD(50),BD(50),R(50),DISL(2),XM(60)
      CHARACTER*40 NAME,SPACE
C     
C     SLIP(J,I,N,M), SS(I,J), DS(I,J), TS(I,J)
C     I...NUMBER OF POINTS ALONG THE LENGTH OF THE FAULT.
C     J...NUMBER OF POINTS DOWN THE DIP.
C     N...NUMBER OF TIME SLICES.
C     M...NUMBER OF MECHANISMS.
C
      WRITE(6,500)
  500 FORMAT (1X,'ENTER THE NAME OF THE INPUT FILE')
      READ (5,501) NAME
  501 FORMAT(A)
      WRITE(6,503)
  503 FORMAT(1X,'ARE YOU DOING A HINGED FAULT, 1=YES 0=NO')
      READ(5,*) IHING
      WRITE(6,504)
  504 FORMAT(1X,'ENTER NMECH; 1 or 2')
      READ(5,*)MECH
  100 WRITE(6,101)
  101 FORMAT(1X,'ENTER THE NUMBER OF TIME SLICES')
      READ(5,*)NSLC
      IF(IHING .EQ. 1) THEN
      WRITE(6,505)
  505 FORMAT(1X,'ENTER THE FAULT LENGTH, THE TOTAL FAULT WIDTH,',/,
     +1X,'AND THE SUBFAULT WIDTHS ABOVE AND BELOW THE HINGE.')
      READ(5,*) FL,FW,SUBWT,SUBWB
      GO TO 506
      END IF
      WRITE(6,102)
  102 FORMAT(1X,'ENTER FAULT LENGTH AND FAULT WIDTH IN KM')
      READ(5,*)FL,FW
      DIP=DIP*3.1415926/180.
  506 WRITE(6,103)
  103 FORMAT(1X,'HOW MANY SUBFAULTS ALONG THE LENGTH AND DOWN THE DIP')
      READ(5,*)NX,NY
      write(6,507)
  507 format(1x,'ENTER DIST (km) OF ORIGIN FROM LEFT & TOP EDGES')
      read(5,*)xhyp,yhyp
	  xsw=fl/nx
	  ysw=fw/ny
      xh=xhyp-(xsw/2.)
	  yh=yhyp-(ysw/2.)
	ntx=nx
	nty=ny
      IF(IHING .EQ. 1) THEN
      WRITE(6,602)
  602 FORMAT(1X,'ENTER THE DISLOCATION SCALING FACTOR FOR ABOVE AND',/,
     +1X,'BELOW THE HINGE.')
      READ(5,*) DSFTOP,DSFBOT
      WRITE(6,603)
  603 FORMAT(1X,'HOW MANY SUBFAULTS DOWN THE DIP ABOVE AND BELOW',/,
     +1X,'THE HINGE.')
      READ(5,*) NSUBT,NSUBB
      GO TO 604
      END IF
      WRITE(6,104)
  104 FORMAT(1X,'HOW MANY CM DISLOCATION PER UNIT WEIGHT FROM LISA')
      READ(5,*)SCALE
  604 CONTINUE
      WRITE(6,607)
  607 FORMAT(1X,'ENTER THE RIDIGITY*10**11 FOR EACH SUBFAULT DOWN',/,
     +1X,'THE DIP.')
      READ(5,*) (R(J),J=1,NY)
      WRITE(6,609)
 609  FORMAT(1X,'DO YOU WANT PLOT FILES OF THE CUMULATIVE',/,
     +1X,'SUM OF THE SLIPS IN EACH TIME WINDOW ( = 1 ), OR ',/,
     +1X,'PLOT FILES OF THE SLIP IN EACH SEPARATE TIME WINDOW ( = 2 )')
      READ(5,*) NSELEC
      WRITE(6,610)
 610  FORMAT(1X,'DO YOU WANT SLIPS PLOTTED AS A FUNCTION OF MAX VALUE',/,
     +1X,'IN EACH PLOT ( = 1 ), OR DO YOU WANT TO PLOT SLIP RELATIVE',/,
     +1X,'TO A GIVEN VALUE ( = 2 )')
      READ(5,*) NMX
	  if (nmx.eq.2) then
		write(6,*)' Enter max slip value to use for plotting'
		read(5,*) smx
		endif
  700 NW=NX*NY*NSLC*MECH
      OPEN(UNIT=7,FILE=NAME,STATUS='OLD')
      OPEN(UNIT=8,FILE='SLIP_CM.DAT',STATUS='UNKNOWN')
      DO 108 I=1,5
  108 READ(7,501) SPACE
      READ(7,201)(TEMP(K),K=1,NW)
  201 FORMAT(1X,6E13.5)
      ICON=0
	dx=fl/ntx
	dy=fw/nty
      DO 20 I=1,30
  20  XM(I)=0.
C
C     CALCULATE THE MOMENT & SAVE DISP VALUES
C
      K=0
      SM=0.
      nsub=0
      DO 2 I=1,NX
      IB=INT((NTX*(I-1)/NX) + 0.5) + 1
      IE=INT((NTX*I/NX) + 0.5)
      DO 3 J=1,NY
      nsub=nsub+1
      JB=INT((NTY*(J-1)/NY) + 0.5) + 1
      JE=INT((NTY*J/NY) + 0.5)
      IF(IHING .NE. 1) AREA=(FL/NX)*(FW/NY)
      IF(IHING .EQ. 1) THEN
      SCALE=DSFTOP
      AREA=(FL/NX)*SUBWT
      JB=INT((NTY*(J-1)*SUBWT/FW)+0.5)+1
      JE=INT((NTY*J*SUBWT/FW)+0.5)
      IF(J .GT. NSUBT) THEN
      SCALE=DSFBOT
      AREA=(FL/NX)*SUBWB
      JJ=J-NSUBT
      JB=INT(NTY*((NSUBT*SUBWT+(JJ-1)*SUBWB)/FW)+0.5)+1
      JE=INT(NTY*((NSUBT*SUBWT+JJ*SUBWB)/FW)+0.5)
      IF(J .EQ. NY) JE=NTY
      END IF
      END IF
      DISL(1)=0.
      DISL(2)=0.
      DO 4 M=1,MECH
      DO 4 N=1,NSLC
      K=K+1
      DO 5 II=IB,IE
      DO 5 JJ=JB,JE
    5 SLIP(JJ,II,N,M)=TEMP(K)*SCALE
      DISL(M)=DISL(M)+TEMP(K)*SCALE
      FACT=TEMP(K)*SCALE*AREA*R(J)*1.0E+21
      IF(M .EQ. 1) XM(N)=XM(N)+FACT
      IF(M .EQ. 2) XM(N+NSLC)=XM(N+NSLC)+FACT
      DSP(K)=TEMP(K)*SCALE
    4 CONTINUE
      TDISL=SQRT(DISL(1)**2+DISL(2)**2)
      write(6,*)' Subfault:',nsub,' Displacement:',tdisl
      if (mech.eq.2) then
	rake=atan2(disl(2),disl(1))*(180./3.1415926)
	write(6,*)'     Rake:',rake
	endif
    3 SM=SM+TDISL*AREA*R(J)*1.0E+21
    2 CONTINUE
      WRITE(6,106) (XM(I),I=1,NSLC)
  106 FORMAT(1X,'MOMENT IN EACH TIME WINDOW FOR MECH NUMBER 1 = ',/,
     +5(1X,E12.6)) 
      if (mech .eq. 2) WRITE(6,107) (XM(NSLC+I),I=1,NSLC)
  107 FORMAT(1X,'MOMENT IN EACH TIME WINDOW FOR MECH NUMBER 2 = ',/,
     +5(1X,E12.6)) 
      WRITE(6,109) SM
  109 FORMAT(1X,'THE TOTAL MOMENT IS ',E12.6,' DYNE-CM')
      WRITE(8,*)'SOLUTION VECTOR (CENTIMETERS)'
      WRITE(8,201)(DSP(K),K=1,NW)
C
C     WRITE OUT FILES.
C
      DO 6 J=1,NTY
      DO 6 I=1,NTX
      SS(I,J)=0.
      DS(I,J)=0.
    6 TS(I,J)=0.
      DO 8 N=1,NSLC
      IF(NSELEC .EQ. 2) THEN
      DO 801 J=1,NTY
      DO 801 I=1,NTX
      SS(I,J)=0.
      DS(I,J)=0.
 801  TS(I,J)=0.
      END IF
      DO 7 I=1,NTX
      DO 7 J=1,NTY
      SS(I,J)=SS(I,J)+SLIP(J,I,N,1)
      IF(MECH.EQ.1) GO TO 7
      DS(I,J)=DS(I,J)+SLIP(J,I,N,2)
      TS(I,J)=SQRT(SS(I,J)**2+DS(I,J)**2)
    7 CONTINUE
      CALL CONTOR(SS,NTX,NTY,DX,DY,NMX,SMX)
      IF(MECH.EQ.1) GO TO 8
      CALL CONTOR(DS,NTX,NTY,DX,DY,NMX,SMX)
      CALL CONTOR(TS,NTX,NTY,DX,DY,NMX,SMX)
    8 CONTINUE
      CLOSE(7)
      CLOSE(8)
      STOP
      END
      SUBROUTINE CONTOR(ZGR,NTX,NTY,DX,DY,NFLG,ZM)
C  THIS SUBROUTINE CREATES FILES CONTOUR(ICON) WHICH ARE IN A FORMAT SUITABLE
C  FOR CONTOURING WITH PROGRAM CONTOUR.F. THE PARAMETER ICON
C  STEPS EACH TIME THE PROGRAM IS CALLED.
c  
c	modified to write out slip in x-y-z format 
c	where x and y are distance along strike & downdip respectively
c	this requires passing plot origin on fault (xh,yh)
c	in COMMON statement(CM/21feb2006) 
c
c	modified to convert slip (z) values to numerical codes where max slip
c	is assigned a value of 100, coincident with GMT color palette file,
c	to plot grayscale cells instead of contours using GMT shell script 
c	max slip is either max value from slip file or some other input value
c	(CM/jan2010)

      COMMON/POINT/ICON,XH,YH
      DIMENSION ZGR(300,300),X(300),Y(300)
      CHARACTER*40 NAME2
C
C     ZGR(I,J)
C     I...NUMBER OF POINTS ALONG THE LENGTH OF THE FAULT.
C     J...NUMBER OF POINTS DOWN THE DIP.
C
      ICON = ICON + 1
      IF (ICON.LT.10) IC1=0
      IF (ICON.GE.10) IC1=1
      IF (ICON.GE.10) IC2=ICON-10
      IF (ICON.LT.10) IC2=ICON
      IF (ICON.GE.20) IC1=2
      IF (ICON.GE.20) IC2=ICON-20
      WRITE(NAME2,300) IC1,IC2
  300 FORMAT('contr',2I1,'.dat')
      OPEN(UNIT=11,FILE=NAME2,STATUS='UNKNOWN')
      WRITE (6,200) NAME2
  200 FORMAT(1X,'SUBROUTINE CONTOUR IS WRITING FILE TO ',A)
	  zmax=0.
	  do 1 i=1,ntx
	  do 1 j=1,nty
  1	  if (zgr(i,j).gt.zmax) zmax=zgr(i,j)
	  if (nflg.eq.2) zmax=zm 
      write(6,*)' MAX SLIP (cm):',zmax  
      WRITE(11,*) NTX,NTY
      DO 10 I=1,NTX
      X(I)=-XH+DX*(I-1)
      DO 10 J=1,NTY
      Y(J)=YH-DY*(J-1)
	  zval=100.*zgr(i,j)/zmax
  10  WRITE(11,*) X(I),Y(J),zval
      CLOSE (11)
      RETURN
      END