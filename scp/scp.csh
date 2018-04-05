#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/scp

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = con
set Product = scp

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

# Set valid time for date string:
set hour = `date -u +%H`
@ starttime = -1 * ($hour - $ModRunTime)
@ diff = ((-1 * ($hour - $ModRunTime)) + $FHour)
set vtime = `date -u -d "+$diff hours" "+%HZ %a %h %d %Y"`

# Create text file for date string:
echo ${ModRunTime}Z  ${ModName} ${FHour} hour - Valid ${vtime} "         ." > ${Level}${Product}${FHour}${Sector}.txt

if ($Sector == "US") then
	set mapfil = "base"
	set map = "32/1/1"
else
	set mapfil = "rdis + base"
	set map = "24/1/1 + 32/1/1"
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
	SCALE	 = 0
	IJSKIP   = NO
	GDPFUN	 = mul(mul(quo(CAPE,1000),quo(hlcy@3000:0%HGHT,100)),quo(mag(wnd@500%PRES),20))!kntv(wnd@850%PRES)!kntv(wnd@500%PRES)
	TYPE	 = F!B!B!
	CONTUR	 = 0
	CINT	 = .1;.25;.5;.75;1;1.25;1.5;1.75;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20
	LINE	 = 32/10/1!2/1/1
	FINT	 = .5;1;2;4;7;10;15;20;25;30;35
	FLINE	 = 31;9;10;11;12;13;14;15;16;17;18;19
	HILO     =32;32/15#;15#//2/20;0  
    HLSYM    = .8;.8/2/1;1/1;1/HW
	CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
	FILTER   = 0.7
    WIND	 = !bk32/.6//112!bk4/.6//112
	TITLE    = 31/-3/SUPERCELL COMPOSITE / 850(BLACK)-500(BLUE)mb CROSSOVERS - COD NEXLAB   WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP		 = ${map}
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = 
	FILTER   = 1
	BOXLIN   = 32
	REGION   = view   
	TXTFIL 	 = ${Level}${Product}${FHour}${Sector}.txt
	TXTLOC	 = .8;1
	TXTYPE	 = 1/2//221/s/c/sw
	TXTCOL	 = 31

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
rm ${Level}${Product}${FHour}${Sector}.txt
