#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/ptype

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = prec
set Product = ptype

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
else if ($ModName == "NAM12") then
    set ModName = NAM
endif

# Convert Model Name to lower case for filenames:
set LModName = `echo $ModName | tr "[:upper:]" "[:lower:]"`

# Set Base Directory and File Name:
set BaseDir = "/home/apache/climate/data/forecast/${ModName}/${ModRunTime}/${Sector}"
set ImageFileName = "${LModName}${Sector}_${Level}_${Product}_${FHour}.gif"

# Set valid time for date string:
set hour = `date -u +%H`
@ starttime = -1 * ($hour - $ModRunTime)
@ diff = ((-1 * ($hour - $ModRunTime)) + $FHour)
set vtime = `date -u -d "+$diff hours" "+%HZ %a %h %d %Y"`

# Create text file for date string:
echo "${ModRunTime}Z ${ModName} ${FHour} hour - Valid ${vtime}" > ${Level}${Product}${FHour}.txt

##################################
# Begin Product-Specific Details #
##################################
gdplot3_gf << eof
	\$mapfil = base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = UL
	SKIP	 = 0
	SCALE	 = 500000
	GDPFUN	 = WXTR
	TYPE	 = F
	CONTUR	 =  
	CINT	 =  
	LINE	 =  
	FINT     = 1/1/1
	FLINE	 = 31;6
	HILO     =  
    HLSYM    =  
    CLRBAR   =  
	WIND	 = bk32/.7//112
	REFVEC	 =  
	TITLE	 = 31/-2/CATEGORICAL RAIN
    TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 32//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
	TXTFIL 	 = 
	TXTLOC	 = 
	TXTYPE	 = 
	TXTCOL	 = 
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

    \$mapfil = base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = UR
	SKIP	 = 0
	SCALE	 = 500000
	GDPFUN	 = WXTS
	TYPE	 = F
	CONTUR	 =  
	CINT	 =  
	LINE	 =  
	FINT     = 1/1/1
	FLINE	 = 31;7
	HILO     =  
    HLSYM    =  
    CLRBAR   =  
	WIND	 = bk32/.7//112
	REFVEC	 =  
	TITLE	 = 31/-2/CATEGORICAL SNOW
    TEXT	 = 1/1/hw
	CLEAR	 = n
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 32//1
	LATLON	 = 
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
	TXTFIL 	 = ${Level}${Product}${FHour}.txt
	TXTLOC	 = .48;1
	TXTYPE	 = .91/2//221/s/c/sw
	TXTCOL	 = 31
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

    \$mapfil = base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = LL
	SKIP	 = 0
	SCALE	 = 500000
	GDPFUN	 = WXTP
	TYPE	 = F
	CONTUR	 =  
	CINT	 =  
	LINE	 =  
	FINT     = 1/1/1
	FLINE	 = 31;8
	HILO     =  
    HLSYM    =  
    CLRBAR   = 
	WIND	 = bk32/.7//112
	REFVEC	 =  
	TITLE	 = 31/-2/CATEGORICAL SLEET
    TEXT	 = 1/1/hw
	CLEAR	 = n
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 32//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
	TXTFIL 	 = 
	TXTLOC	 = 
	TXTYPE	 = 
	TXTCOL	 = 
	COLUMN   =  
	SHAPE    =  
	INFO     =  
	LOCI     = 
	ANOTLN   =  
	ANOTYP   =  

r

    \$mapfil = base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = LR
	SKIP	 = 0
	SCALE	 = 500000
	GDPFUN	 = WXTZ
	TYPE	 = F
	CONTUR	 =  
	CINT	 =  
	LINE	 =  
	FINT     = 1/1/1
	FLINE	 = 31;9
	HILO     =  
    HLSYM    =  
    CLRBAR   = 
	WIND	 = bk32/.7//112
	REFVEC	 =  
	TITLE	 = 31/-2/CATEGORICAL FREEZING RAIN
    TEXT	 = 1/1/hw
	CLEAR	 = n
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 32//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
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
mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
