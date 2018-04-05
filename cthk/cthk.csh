#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts"
cd $ProdDir/cthk

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = prec
set Product = cthk

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

# Add station IDs to WXC images:
if (($Sector == "WXCS") || ($Sector == "WXCB")) then
    set stnplt = "10/1|10/15/4/2|wxcstations.tbl"
    #set stnplt = "32/1|32/15/4/2|spcwatch.tbl"
else
    set stnplt = ""
endif

##################################
# Begin Product-Specific Details #
##################################

gdplot3_gf << eof
	GDFILE	 = ${GridName} | ${ModRunTime}
	GDATTIM	 = f${FHour}
	GLEVEL	 = 850
	GVCORD	 = pres
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
	GDPFUN	 = AVG(RELH  @850 %PRES,RELH  @500 %PRES)  !tmpc   !SUB(HGHT @500 %PRES, HGHT @1000 %PRES) !SUB(HGHT @500 %PRES, HGHT @850 %PRES)
	TYPE	 = F/C         !C  !C  !C
	CONTUR	 = 0 
	CINT	 = 10/120/120  !1/0/0      !1/5400/5400    !1/4100/4100
	LINE	 = 32/10/1     !17/1/2/0   !16/1/2/0       !15/1/2/0
	FINT	 = 70;80;90;100
	FLINE	 = 32;18;19;20;21
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.45;.002/.59;.01//|.65/1
	WIND	 = 
	REFVEC	 =  
	TITLE	 = 31/-3/CRITICAL THICKNESS / 500mb - 850mb AVERAGE RH% - COD NEXLAB   WEATHER.COD.EDU
	TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	LATLON	 = 
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   = ${stnplt}
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1.1
	BOXLIN   = 32
	REGION   = view 

r

	\$mapfil = county + base
    GDPFUN	 = SUB(HGHT@700%PRES,HGHT@1000%PRES)  !SUB(HGHT@700%PRES,HGHT)  !SUB(HGHT,HGHT@1000%PRES) !SUB(HGHT@500%PRES,HGHT@700%PRES)
	TYPE	 = C   !C  !C  !C
	CONTUR	 = 0 
	CINT	 = 1/2840/2840 !1/1540/1540    !1/1300/1300    !1/2560/2560
	LINE	 = 14/1/2/0    !13/1/2/0       !12/1/2/0       !11/1/2/0
	FINT	 = 
	FLINE	 = 
	HILO	 = 
	HLSYM	 = 
	CLRBAR	 = 31/h/lc/.45;.002/.59;.01//|.65/1
	WIND	 = 
	REFVEC	 =  
	TITLE	 =  
	TEXT	 = 1/1/hw
	CLEAR	 = n
	GAREA	 = ${Domain}
	PROJ	 = ${Projection}
	MAP	     = 24//1 + 23//2
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|${Size}
	STNPLT   =  
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1.1
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

##################################

# Move image to output dir:
#mkdir ${BaseDir}
mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
