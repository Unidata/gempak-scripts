#!/bin/csh -f
source /home/gempak/NAWIPS/Gemenviron
setenv DISPLAY :9

# Deal with directory formalities:
set ProdDir = "/home/scripts/models/prodscripts/"
cd $ProdDir/speeds

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
set ModRunTime = $1
set ModName = $2
set FHour = $3
set Sector = $4

# Define the level and product to be generated (for use in filenames):
set Level = 250
set Product = spd

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

##################################
# Begin Product-Specific Details #
##################################
set filesize = 0
set count = 0
while ($filesize < 3000)
	gdplot3_gf << eof
		\$mapfil = base
		GDFILE	 = ${GridName} | ${ModRunTime}
		GDATTIM	 = f${FHour}
		GLEVEL	 = 250
		GVCORD	 = pres
		PANEL	 = 0
		SKIP	 = 0
		SCALE	 = 0
		GDPFUN	 = mag(kntv(wnd))!kntv(wnd)!quo(HGHT,10)
		TYPE	 = F        !B        !C
		CONTUR	 = 0 
		CINT	 = 6
		LINE	 = 32/1/2
		FINT     = 50;60;70;80;90;100;110;120;130;140;150;160;170;180;190;200;210;220
		FLINE	 = 31;8;9;10;11;12;13;14;15;16;17;19;20;21;22;23;24;25;26
		HILO     =  
		HLSYM    =  
		CLRBAR   = 31/h/lc/.5;.002/.95;.012//|.65/1
		WIND	 = bk32/.7//112
		REFVEC	 =  
		TITLE	 = 31/-3/250mb WIND SPEEDS (kts) / HEIGHT (dm) - COD NEXLAB   WEATHER.COD.EDU
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

set filesize = `stat -c %s $ImageFileName`
if ($count > 0) then
sleep 3
endif
if ($count > 5) then
set filesize = 10000
endif	
@ count = $count + 1
end
##################################

# Move image to output dir:
#mkdir ${BaseDir}
mv -f $ImageFileName ${BaseDir}

# Remove temp Gempak .nts files:
rm gemglb.nts
rm last.nts

# Remove text file for date string:
rm ${Level}${Product}${FHour}.txt
rm ${ImageFileName}.*
