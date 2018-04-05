#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/rcthk
# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = sfc
set Product = rcthk

# Set the size of the image
if (($Sector == "ILS") || ($Sector == "ILB")) then
    set Size = "1024;768"
else
    set Size = "800;600"
endif

# Load Sector Coords and projections:
if (($Sector == "WXCS") || ($Sector == "WXCB")) then
	set SectorFileName = "/home/apache/climate/wxchallenge/wxcs.dat"
	if ($Sector == "WXCS") then
		set Domain = `awk '{if (NR==9) print}' $SectorFileName`
	else if ($Sector == "WXCB") then
		set Domain = `awk '{if (NR==10) print}' $SectorFileName`
	endif
	set Projection = "lcc"
else
	set SectorFileName = "/home/scripts/reference/sectors.txt"
	set Domain = `awk '$1 == "'$Sector'" {print $3}' $SectorFileName`
	set Projection = `awk '$1 == "'$Sector'" {print $4}' $SectorFileName`
endif

# Convert Model Name to Grid Name:
set GridFileName = "/home/scripts/reference/gridnames.txt"
set GridName = `awk '$1 == "'$ModName'" {print $2}' $GridFileName`

# Check if GFSHD, and if so remove the HD
if ($ModName == "GFSHD") then
    set ModName = GFS
else if ($ModName == "GFSNA") then
    set ModName = GFS
endif

# Convert Model Name to lower case for filenames:
set LModName = `echo $ModName | tr "[:upper:]" "[:lower:]"`

# Set File Name and change to output directory:
set ImageFileName = "${LModName}${Sector}_${Level}_${Product}_${FHour}.gif"
#mkdir /home/apache/climate/data/forecast/${ModName}/${ModRunTime}/${Sector}
#cd /home/apache/climate/data/forecast/${ModName}/${ModRunTime}/${Sector}


# Set valid time for date string
set hour = `date -u +%H`
@ starttime = -1 * ($hour - $ModRunTime)
@ diff = ((-1 * ($hour - $ModRunTime)) + $FHour)
set vtime = `date -u -d "+$diff hours" "+%HZ %a %h %d %Y"`

# Create text file for date string:
echo ${ModRunTime}Z  ${ModName} ${FHour} hour - Valid ${vtime} "         ." > ${Level}${Product}${FHour}.txt

##################################
# Begin Product-Specific Details #
##################################

gpcolor << eof
	COLORS	= 6 = 0:50:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 7 = 95:95:95
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 8 = 0:130:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 9 = 0:170:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 10 = 10:210:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 11 = 50:255:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 12 = 180:255:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 13 = 255:255:0 
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 14 = 210:175:0 
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 15 = 255:0:0 
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 16 = 150:0:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 17 = 190:190:190
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 18 = 150:0:150
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 19 = 255:0:255 
	DEVICE  = GIF|$ImageFileName|${Size}
r
exit
eof

gdplot3_gf << eof
	GDFILE	 =  ${GridName} | ${ModRunTime}
	GDATTIM	 =  f${FHour}
	GLEVEL	 =  1000
	GVCORD	 =  HGHT
	PANEL	 =  0
	SKIP	 =  0
	SCALE	 =  0
	GDPFUN   = REFD
	CINT     = 
	TYPE	 =  F
	CONTUR	 =  0
	LINE	 =  
	FINT     =  5;10;15;20;25;30;35;40;45;50;55;60
	FLINE	 =  32;6;8;9;10;11;13;14;15;16;18;19;17
	HILO     =  
    HLSYM    =  
    #HILO	 =  4;2/H;L//3/1;1/YES
	#HLSYM	 =  3//1/6/hw
    CLRBAR   =  31/h/lc/.5;.002/.95;.012/1/|.65/1
	WIND	 =  bk32/.7//112
	REFVEC	 =  
	TITLE	 =  
    TEXT	 = 1/1/hw
	CLEAR	 =  y
	GAREA	 =  ${Domain}
	PROJ	 =  ${Projection}
	LATLON	 =  
	DEVICE	 =  GIF|$ImageFileName|${Size}
	STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
	TXTFIL 	 = ${Level}${Product}${FHour}.txt
	TXTLOC	 = .8;1
	TXTYPE	 = 1/2//221/s/c/sw
	TXTCOL	 = 31
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

exit

eof

gpcolor << eof
	COLORS	= 11 = 176:0:176
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 12 = 248:252:72
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 13 = 0:176:176
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 14 = 176:0:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 15 = 0:176:0
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 16 = 248:252:248
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 17 = 72:76:248
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 18 = 96:0:96
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 19 = 152:0:152
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 20 = 200:0:200
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 21 = 248:0:248
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 22 = 184:0:248
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 23 = 176:176:176
	DEVICE  = GIF|$ImageFileName|${Size}
r
    COLORS	= 24 = 72:76:72
	DEVICE  = GIF|$ImageFileName|${Size}
r
	COLORS	= 101 = 0:0:0
	DEVICE  = GIF|$ImageFileName|${Size}
r

exit

eof

gdplot3_gf << eof
	\$mapfil = county + base
    GDFILE	 =  ${GridName} | ${ModRunTime}
	GDATTIM	 =  f${FHour}
	GLEVEL	 =  850
	GVCORD	 =  pres
	PANEL	 =  0
	SKIP	 =  0
	SCALE	 =  0
	GDPFUN	 =  tmpc   !SUB(HGHT @500 %PRES, HGHT @1000 %PRES) !SUB(HGHT @500 %PRES, HGHT @850 %PRES)
	TYPE	 =  C  !C  !C
	CONTUR	 =  0 
	CINT	 =  1/0/0      !1/5400/5400    !1/4100/4100
	LINE	 =  17/1/2/0   !16/1/2/0       !15/1/2/0
	FINT	 = 
	FLINE	 = 
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.45;.002/.59;.01//|.65/1
	WIND	 = 
	REFVEC	 =  
	TITLE	 =  31/-3/CRITICAL THICKNESS / 1km AGL SIMULATED REFLECTIVITY - COD NEXLAB   WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 =  N
	GAREA	 =  ${Domain}
	PROJ	 =  ${Projection}
	MAP	 =  24//1 + 23//2
	LATLON	 =  
	DEVICE	 =  GIF|$ImageFileName|${Size}
	STNPLT   =  
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1.1
	BOXLIN   = 32
	REGION   = view 
	TXTCOL	= 31
	TXTYPE	 = 1/2//221/s/c/sw
	TXTFIL 	= ${Level}${Product}${FHour}.txt
	TXTLOC	= .8;1
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

exit

eof

gdplot3_gf << eof
	\$mapfil = county + base
    GDFILE	 =  ${GridName} | ${ModRunTime}
	GDATTIM	 =  f${FHour}
	GLEVEL	 =  850
	GVCORD	 =  pres
	PANEL	 =  0
	SKIP	 =  0
	SCALE	 =  0
	GDPFUN	 =  SUB(HGHT@700%PRES,HGHT@1000%PRES)  !SUB(HGHT@700%PRES,HGHT)  !SUB(HGHT,HGHT@1000%PRES) !SUB(HGHT@500%PRES,HGHT@700%PRES)
	TYPE	 =  C   !C  !C  !C
	CONTUR	 =  0 
	CINT	 =  1/2840/2840 !1/1540/1540    !1/1300/1300    !1/2560/2560
	LINE	 =  14/1/2/0    !13/1/2/0       !12/1/2/0       !11/1/2/0
	FINT	 = 
	FLINE	 = 
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.45;.002/.59;.01//|.65/1
	WIND	 = 
	REFVEC	 =  
	TITLE	 =  
	TEXT	 = 1/1/hw
	CLEAR	 =  n
	GAREA	 =  ${Domain}
	PROJ	 =  ${Projection}
	MAP	 =  24//1 + 23//2
	LATLON	 =  
	DEVICE	 =  GIF|$ImageFileName|${Size}
	STNPLT   =  
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1.1
	BOXLIN   = 32
	REGION   = view 
	TXTCOL	= 31
	TXTYPE	 = 1/2//221/s/c/sw
	TXTFIL 	= ${Level}${Product}${FHour}.txt
	TXTLOC	= .8;1
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

exit

eof

##################################

# Move image to output dir:
mv -f $ImageFileName /home/apache/climate/zuranski

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
