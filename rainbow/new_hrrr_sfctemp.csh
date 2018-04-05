#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/rainbow

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = sfc
set Product = temp

# Load Sector Coords and projections:
if (($Sector == "WXCS") || ($Sector == "WXCB")) then
	set SectorFileName = "/home/apache/climate/wxchallenge/wxcs.dat"
	if ($Sector == "WXCS") then
		set Domain = `awk '{if (NR==9) print}' $SectorFileName`
	else if ($Sector == "WXCB") then
		set Domain = `awk '{if (NR==10) print}' $SectorFileName`
	endif
	set Projection = "lcc"
else if ($Sector == "FLT") then
    set SectorFileName = "/home/scripts/reference/floater.txt"
    set Domain = `awk '{if (NR==1) print}' $SectorFileName`
    set Projection = "LCC"
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
echo ${ModRunTime}Z  ${ModName} ${FHour} hour - Valid ${vtime} "           ." > ${Level}${Product}${FHour}.txt

# Adjust product for various sectors:
if ($Sector == "US") then
	set mapfil = "base"
	set map = "32//1"
	set type = "F\!C\!C\!B"
	set cint = "0\!1/32/32\!2"
	set line = "32/10/1\!31/1/1/n\!32/1/2"
else if ($Sector == "NA") then
	set mapfil = "base"
	set map = "32//1"
	set type = "F\!C\!C\!B"
	set cint = "5\!1/32/32\!4"
	set line = "\!31/1/1/n\!32/1/2"
else
	set mapfil = "rdis + base"
	set map = "27//1 + 32//1"
	set type = "F\!B"
	set cint = "5\!2"
	set line = "32/10/1\!32/1/2"
endif

# Account for various handles of PMSL:
if ($ModName == NAM) then
    set PMSL = "EMSL"
else if ($ModName == RAP) then
    set PMSL = "MMSL"
else
    set PMSL = "PMSL"
endif


##################################
# Begin Product-Specific Details #
##################################

gdplot3_gf << eof
	\$mapfil = ${mapfil}
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = 0
	SKIP	 = 0
	IJSKIP   = 12
	SCALE	 = 0
	GDPFUN	 = tmpf@2%HGHT!kntv(wnd @10 %HGHT)!tmpf@2%HGHT
	TYPE	 = F!B!P
	CONTUR	 = 0 
	CINT	 = 5
	LINE	 = 31/10/1!31/1/2
	FINT	 = -30;-25;-20;-15;-10;-5;0;5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80;85;90;95;100;105;110
	FLINE	 = 31;17;18;19;20;21;22;23;24;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21
	HILO	 = 
	HLSYM	 = 
    CLRBAR   = 31/h/lc/.5;.002/.95;.012//|.65/1
	WIND	 = bk32/.6//112
	REFVEC	 =  
	TITLE	 = 31/-3/2m TEMP (F) / 10m WIND (kts) - COD NEXLAB   WEATHER.COD.EDU
    TEXT	 = .8/1/hw
	DITHER = 2
	COLORS   = 31
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = ${map}
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|800;600
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
    STNPLT   = 
	FILTER   = yes
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
#mkdir ${BaseDir}
#mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
