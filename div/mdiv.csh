#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/div

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = con
set Product = mdiv

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
	set map = "22//1 + 32//1"
endif

# Define the parameter:
set mdiv = "mul(sdiv(dwpf,wnd @10 %HGHT),10000)"

##################################
# Begin Product-Specific Details #
##################################

gdplot3_gf << eof
	\$mapfil = ${mapfil}
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 2
	GVCORD	 = hght
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
	GDPFUN	 = ${mdiv}!kntv(wnd @10 %HGHT)
	TYPE	 = f!s
	CONTUR	 = 0!1/1!0
	CINT	 = 50/500/1050
	LINE	 = !4/1/1
	FINT	 = -60;-50;-40;-30;-20;-10;10;20;30;40;50;60
	FLINE	 = 15;14;13;12;11;10;31;21;20;19;18;17;16
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
	WIND	 = ak6/.6//111/.4
	REFVEC	 =  
	TITLE	 = 31/-3/MOISTURE FLUX DIVERGENCE / 10m WIND (kts) - COD NEXLAB   WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = ${map}
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
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
#mkdir ${BaseDir}
mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
