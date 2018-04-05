#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/precip

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector, QPF-Hour.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4
set QPFhr = $5

# Define the level and product to be generated (for use in filenames):
set Level = sfc
set Product = prec

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

# Account for various handles of PMSL:
if ($ModName == NAM) then
    set PMSL = "EMSL"
	set QPF = "P${QPFhr}M"
else if ($ModName == RAP) then
    set PMSL = "MMSL"
	set QPF = "S${QPFhr}M"
else
    set PMSL = "PMSL"
	set QPF = "P${QPFhr}M"
endif

##################################
# Begin Product-Specific Details #
##################################

if ($FHour == 000) then
	goto ZeroHour
else	
	goto NonZeroHours
endif

ZeroHour:

gdplot3_gf << eof
	\$mapfil = base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
	GDPFUN	 = SUB(HGHT@500%PRES,HGHT@1000%PRES)
	TYPE	 = F/C
	CONTUR	 = 0 
	CINT	 = 300/5100/5700
	LINE	 = 14/1/1
	FINT	 = 0
	FLINE	 = 32
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 
	WIND	 = bk32/.6//112/.4
	REFVEC	 =  
	TITLE	 = 31/-3/${QPFhr}HR PRECIP (in) / MSLP (mb) / 1000-500mb THICKNESS (m) - WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 5//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   =  
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 0.8
	BOXLIN   = 32
	REGION   = view 
	TXTCOL	 = 31
	TXTYPE	 = 1/2//221/s/c/sw
	TXTFIL 	 = ${Level}${Product}${FHour}.txt
	TXTLOC	 = .8;1
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

exit

eof
goto Done

NonZeroHours:

gdplot3_gf << eof
	\$mapfil = base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
#	GDPFUN	 = quo(P${QPFhr}M,25.4)!${PMSL}!SUB(HGHT@500%PRES,HGHT@1000%PRES)!SUB(HGHT@500%PRES,HGHT@1000%PRES)
	GDPFUN	 = quo(${QPF},25.4)!SUB(HGHT@500%PRES,HGHT@1000%PRES)
	TYPE	 = F!C!C
	CONTUR	 = 
	CINT	 = !300/5100/5700
	LINE	 = !14/1/1
	FINT	 = .01;.05;.1;.15;.25;.35;.5;.75;1;1.5;2;3;4
	FLINE	 = 32;9;10;11;12;13;14;15;16;17;18;19;20;21
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
	WIND	 = bk32/0.6//112/.4
	REFVEC	 =  
	TITLE	 = 31/-3/${QPFhr}HR PRECIP (in) / MSLP (mb) / 1000-500mb THICKNESS (m) - WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 5//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
    STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 0.8
	BOXLIN   = 32
	REGION   = view 
	TXTCOL	 = 31
	TXTYPE	 = 1/2//221/s/c/sw
	TXTFIL 	 = ${Level}${Product}${FHour}.txt
	TXTLOC	 = .8;1
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

exit

eof
Done:

##################################

# Move image to output dir:
#mkdir ${BaseDir}
mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
