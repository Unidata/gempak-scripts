#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

rm cross.gif

##################################
# Begin Product-Specific Details #
##################################

gdcross_gf << eof
	CXSTNS	 =  bro>apn
	GDATTIM	 =  f00
	GVCORD	 =  pres
	GFUNC	 =  relh
	GVECT	 =  
	GDFILE	 =  RAP
	WIND	 =  
	REFVEC	 =  10
	PTYPE	 =  log
	YAXIS	 =  
	CINT	 =  
	SCALE	 =  
	LINE	 =  31/1/1
	BORDER	 =  30
	TITLE	 =  31
	CLEAR	 =  yes
	DEVICE	 =  GIF|cross.gif|800;600
	TEXT	 =  1
	PANEL	 =  0
	CLRBAR	 =  31/h/cc/.5;.03/.6;.01
	CONTUR	 =  3
	FINT	 =  5;10;20;30;40;50;60;70;80;90;95
	FLINE	 =  12;1;2;3;4;5;6;7;8;9;10;11
	CTYPE	 =  f
    FILTER   =  y
	

r

exit

eof