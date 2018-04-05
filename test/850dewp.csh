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
set Level = 850
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

# Set mapfil and map based on sector:
if ($Sector == "US") then
	set mapfil = "base"
	set map = "32//1"
else
	set mapfil = "rdis + base"
	set map = "28//1 + 32//1"
endif

##################################
# Begin Product-Specific Details #
##################################

gdplot3_gf << eof
	\$mapfil = ${mapfil}
    GDFILE	 =  ${GridName} | ${ModRunTime}
	GDATTIM	 =  f${FHour}
	GLEVEL	 =  850
	GVCORD	 =  pres
	PANEL	 =  0
	SKIP	 =  0
	SCALE	 =  0
	GDPFUN	 =  DWPC!DWPC!HGHT!kntv(wnd)
	TYPE	 =  F/C!C!C!A
	CONTUR	 =  0!1/1
	CINT	 =  2/0/22!1/10/10!30
	LINE	 =  32/10/1!31/1/1/n!32/1/2
	FINT	 = -12;-10;-8;-6;-4;-2;0;2;4;6;8;10;12;14;16;18;20;22
	FLINE	 = 31;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
	WIND	 = ak26/.3/2/111/.4
	REFVEC	 =  
	TITLE	 =  31/-3/850mb DEWPOINT (C) / HEIGHT (m) / Wind - COD NEXLAB   WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 =  y
	GAREA	 =  ${Domain}
	PROJ	 =  ${Projection}
	MAP	     =  ${map}
	LATLON	 =  
	DEVICE	 =  GIF|$ImageFileName|${Size}
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 3
	STREAM   = 1/0.8///0.1
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
mv -f $ImageFileName /home/apache/climate/sirvatka

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
