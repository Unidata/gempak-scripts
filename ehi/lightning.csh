#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/ehi

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = con
set Product = ltng

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

# Add station IDs to WXC images:
if (($Sector == "WXCS") || ($Sector == "WXCB")) then
    set stnplt = "30/1|30/15/4/2|wxcstations.tbl"
    #set stnplt = "32/1|32/15/4/2|spcwatch.tbl"
else if ($Sector == "FLT") then
    set stnplt = "32/.65|32/15/2/2|spcwatch.tbl"
else
	set stnplt = ""
endif

# Set valid time for date string:
set hour = `date -u +%H`
@ starttime = -1 * ($hour - $ModRunTime)
@ diff = ((-1 * ($hour - $ModRunTime)) + $FHour)
set vtime = `date -u -d "+$diff hours" "+%HZ %a %h %d %Y"`

# Create text file for date string:
echo ${ModRunTime}Z  ${ModName} ${FHour} hour - Valid ${vtime} "         ." > ${ModRunTime}${Level}${Product}${FHour}${Sector}.txt

##################################
# Begin Product-Specific Details #
##################################
gdplot3_gf << eof
	\$mapfil = county+base
    GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 0
	GVCORD	 = NONE
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
	GDPFUN	 = LTG3
	TYPE	 = F
	CONTUR	 =  
	CINT	 =  
	LINE	 = 32/10/1
	FINT     = .02;.5;1;1.5;2;2.5;3;4;5;6;7;8;10;12;14;16;18;20;22;25;30
	FLINE	 = 31;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28
	HILO     =  
    HLSYM    = 
    CLRBAR   = 31/h/lc/.5;.002/.95;.012/2/|.65/1
	WIND	 = bk32/.7//112
	REFVEC	 =  
	TITLE	 = 31/-3/LIGHTNING THREAT (FLASHES/KM**2/5 MIN) - COD NEXLAB   WEATHER.COD.EDU
    TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 27/1/1+32//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = ${stnplt}
	SATFIL	 =
	RADFIL   =
	IJSKIP   = YES
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
	TXTFIL 	 = ${ModRunTime}${Level}${Product}${FHour}${Sector}.txt
	TXTLOC	 = .79;1
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
#mkdir -p ${BaseDir}
mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${ModRunTime}${Level}${Product}${FHour}${Sector}.txt
