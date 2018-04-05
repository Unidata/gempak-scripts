#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9
set ProdDir = "/home/scripts/models/prodscripts"
#cd $ProdDir/dewpoint
# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = sfc
set Product = dewp

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

# Check if GFSHD, and if so remove the HD... And deal with NAM12 in a similar fashion.
if ($ModName == "GFSHD") then
    set ModName = GFS
else if ($ModName == "GFSNA") then
    set ModName = GFS
else if ($ModName == "NAM12") then
    set ModName = NAM
endif

# Convert Model Name to lower case for filenames:
set LModName = `echo $ModName | tr "[:upper:]" "[:lower:]"`

# Set Base Directory and File Name:
set BaseDir = "/home/apache/climate/data/forecast/${ModName}/${ModRunTime}/${Sector}"
set ImageFileName = "${LModName}${Sector}_${Level}_${Product}_${FHour}.gif"

# Set valid time for date string
set hour = `date -u +%H`
@ starttime = -1 * ($hour - $ModRunTime)
@ diff = ((-1 * ($hour - $ModRunTime)) + $FHour)
set vtime = `date -u -d "+$diff hours" "+%HZ %a %h %d %Y"`

# Create text file for date string:
echo ${ModRunTime}Z  ${ModName} ${FHour} hour - Valid ${vtime} "         ." > ${Level}${Product}${FHour}.txt

#Filter roads
if ($Sector == "US") then
	set mapfil = "base"
	set map = "32//1"
else
	set mapfil = "rdis + base"
	set map = "28//1 + 32//1"
endif

# Account for various definitions of LI
if ($ModName == "GFS") then
    set LI = "LIFT@0%NONE"
else
    set LI = "LFT4@180:0%PDLY"
endif

##################################
# Begin Product-Specific Details #
##################################

gdplot3_gf << eof
	\$mapfil = ${mapfil}
    GDFILE	 =  ${GridName} | ${ModRunTime}
	GDATTIM	 =  f${FHour}
	GLEVEL	 =  2
	GVCORD	 =  hght
	PANEL	 =  0
	SKIP	 =  0
	SCALE	 =  0
	GDPFUN	 =  DWPF!DWPF!${LI}!${LI}
	TYPE	 =  FC!C!C!C
	CONTUR	 =  0!1/1!1/1
	CINT	 =  0;5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80;85;90;95;100!45!1/-30/-1!1/1/50
	LINE	 =  32/10/1!31/1/1/n!28/1/1!27/1/1/n
	FINT	 = -10;-5;0;5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80
	FLINE	 = 31;23;22;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
	WIND	 = ak6/.6//111/.4
	REFVEC	 =  
	TITLE	 =  31/-3/2m DEWPOINT (F) / LIFTED INDEX (C) - COD NEXLAB   WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 =  y
	GAREA	 =  ${Domain}
	PROJ	 =  ${Projection}
	MAP	     =  ${map}
	LATLON	 =  
	DEVICE	 =  GIF|$ImageFileName|1024;768
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1.1
	STREAM   = 1/0.8
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

##################################

# Move image to output dir:
mkdir ${BaseDir}
mv -f $ImageFileName /home/apache/climate/gensini

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
