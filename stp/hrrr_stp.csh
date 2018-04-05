#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/stp

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = con
set Product = stp

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
echo ${ModRunTime}Z  ${ModName} ${FHour} hour - Valid ${vtime} "           ." > ${ModRunTime}${Level}${Product}${FHour}${Sector}.txt

if (($Sector == "US") || ($Sector == "FLT")) then
	set mapfil = "base"
	set map = "32//1"
else
	set mapfil = "county + base"
	set map = "30//1 + 32//1"
endif

if ($Sector == "FLT") then
	set plot = "32/.65|32/15/2/2|spcwatch.tbl"
else
	set plot = ""
endif
##################################
# Begin Product-Specific Details #
##################################
#STP
gddiag << eof
	GDFILE	 = ${GridName} | ${ModRunTime}
	GDOUTF   = hrrrstp.grd
	GFUNC    = mul(mul(mul(quo(sub(2000,HGHT@0%LCLV),1000),quo(CAPE,1500)),quo(hlcy@1000:0%HGHT,150)),quo(mag(shr@0:6000%HGHT),20))
	GDATTIM  = f${FHour}
	GLEVEL   = 0
	GVCORD   = NONE
	GRDNAM   = STP@0%NONE
	GRDTYP   = S
	GPACK    = grib/16
	PROJ     = 
	GRDAREA  = 
	KXKY     =
	MAXGRD   =
	CPYFIL   = $GridName
	ANLYSS   =

r

exit

eof

gdplot3_gf << eof
	\$mapfil = ${mapfil}
	GDFILE	 = ${GridName} | ${ModRunTime} + hrrrstp.grd
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = none
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
	GDPFUN	 = cape
	TYPE	 = F
	FINT     = 100000 
	FLINE 	 = 31
	TEXT	 = 1/1/hw
	IJSKIP   = YES
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP		 = ${map}
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   =  
	BOXLIN   = 32
	REGION   = view	
	TITLE    = 0
	CLRBAR	 = 
r
	GDPFUN	 = mask(STP+2,SGT(CINS,-100)) ! kntv(wnd@10%hght)
	TYPE	 = F ! B
	CONTUR	 = 0
	CINT	 = .1;.25;.5;.75;1;1.25;1.5;1.75;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20
	LINE	 = 2/1/1
	FINT	 = .1;1;2;3;4;5;7;9;11;13;15
	FLINE	 = 31;9;10;11;12;13;14;15;16;17;18;19
	CLEAR	 = n
	IJSKIP   = YES
	STNPLT   = ${plot}
	HILO     =32;32/15#;15#//25/20;0  
    HLSYM    = .8;.8/2/1;1/1;1/HW
	CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
	TITLE    = 31/-3/FIXED-LAYER SIG TOR / 10m WIND (kts) - COD NEXLAB   WEATHER.COD.EDU
	WIND	= bk32/.5//112
	TXTFIL 	= ${ModRunTime}${Level}${Product}${FHour}${Sector}.txt
	TXTLOC	= .8;1
	TXTYPE	= 1/2//221/s/c/sw
	TXTCOL	= 31
r

exit

eof

##################################

# Move image to output dir:
#mkdir ${BaseDir}
mv -f $ImageFileName ${BaseDir}
# Remove temp Gempak .nts & .grd files:
rm gemglb.nts
rm last.nts
rm hrrrstp.grd

# Remove text file for date string:
rm ${ModRunTime}${Level}${Product}${FHour}${Sector}.txt
