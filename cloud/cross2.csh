#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

rm cross.gif

##################################
# Begin Product-Specific Details #
##################################

gdthgt << eof
	GPOINT	 =  OUN
	GDATTIM	 =  f00;f12
	GVCORD	 =  PRES
	GFUNC	 =  cld
	GVECT	 =  wnd
	GDFILE	 =  NAM12
	PTYPE	 =  log
	TAXIS	 =  
	YAXIS	 =  /100
	BORDER	 =  31
	LINE	 =  12;1;2;3;4;5;6;7;8;9;10;11
	CINT	 =  5;10;20;30;40;50;60;70;80;90;95
	WIND	 =  bk31
	TITLE	 =  31
	CLEAR	 =  YES
	SCALE	 =  999
	PANEL	 =  0
	DEVICE	 =  GIF|cross2.gif|800;600
	TEXT	 =  1/21//hw
	

r

exit

eof

gpend

