#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/precip";

# Define the level and product to be generated (for use in filenames):
$Level = "prec";
$Product = "prec";

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
$ModRunTime = $argv[1];
$Model = $argv[2];
$FHour = $argv[3];
$Sector = $argv[4];
$QPFhr = $argv[5];

# Set the size of the image:
$Size = SetImageSize($Sector,$DefaultImageSize);

# Load Sector Coords and projections:
$SectorArr = SetSectorInfo($Sector);
$Domain = $SectorArr["Domain"];
$Projection = $SectorArr["Projection"];

# Convert model name to grid name, and return a "clean" model name:
$ModArr = SetModGridNames($Model);
$ModName = $ModArr["ModName"];
$GridName = $ModArr["GridName"];

# Make lowercase modname, used for image filename:
$LModName = strtolower($ModName);

# Set Base Directory and Image File Name:
$BaseDir = BaseDir();
$SubDir = SubDir($ModName,$ModRunTime,$Sector);
$ImageFileName = $LModName.$Sector."_".$Level."_".$Product."_".$FHour.".gif";

# Get the file name for the date string (file will be created by running this script):
$TextFileName = DateLabelFile($ModRunTime, $ModName, $FHour, $Level, $Product, $Sector, $cwd);

# This is poor programming, but technically works... the best kind of works!
# Extra points if you get that reference, if not http://www.youtube.com/watch?v=hou0lU8WMgo
# But seriously, this could be done better, and I did some seriously shady stuff for the WLD sector.
# Level of caring, fading... fading... RISING... fading... fading... gone.
if ($Sector == "US") {	
	$Mapfil = "base";
	$Map = "5//1";
	$ZHcint = "2!300/5100/5700!60";
	$NZHcint = "!2!300/5100/5700!60";
} elseif (($Sector == "NA") || ($Sector == "AO") || ($Sector == "PO")) {
	$Mapfil = "base";
	$Map = "5//1";
	$ZHcint = "4!300/5100/5700!60";
	$NZHcint = "!4!300/5100/5700!60";
} elseif ($Sector == "WLD") {
	$Mapfil = "base";
	$Map = "5//1";
	$ZHcint = "300/5100/5700";
	$NZHcint = "!300/5100/5700";
	$MSLP = "";
} else {
	$Mapfil = "rdis + base";
	$Map = "27//1 + 5//1";
	$ZHcint = "2!300/5100/5700!60";
	$NZHcint = "!2!300/5100/5700!60";
}

$stnplt = SetStationPlt($Product, $Sector);
$IJSkip = SetIJSkip($GridName, $Sector);
$QPF = SetQPF($ModName,$QPFhr);

if ($Sector != "WLD") {
	$MSLP = SetMSLP($ModName);
}

# Gempak magic, the parms we will send to the program:
if ($FHour == 000) {
	goto ZeroHour;
} else {
	goto NonZeroHour;
}

ZeroHour:
$parms = "
\$mapfil = $Mapfil
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = 0
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = ${MSLP}!SUB(HGHT@500%PRES,HGHT@1000%PRES)!SUB(HGHT@500%PRES,HGHT@1000%PRES)
TYPE	 = F/C!C!C
CONTUR	 = 0 
CINT	 = $ZHcint
LINE	 = 6/1/1!14/1/1!14/10/1
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
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = $Map
LATLON	 =  
IJSKIP   = $IJSkip
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = $stnplt
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 0.8
STREAM   = 
BOXLIN   = 32
REGION   = view 
TXTCOL	 = 31
TXTYPE	 = 1/2//221/s/c/sw
TXTFIL 	 = $TextFileName
TXTLOC	 = .8;1
COLUMN   =  
SHAPE    =  
INFO     =  
LOCI     = 
ANOTLN   =  
ANOTYP   =  
r
exit
";
goto Done;

NonZeroHour:
$parms = "
\$mapfil = $Mapfil
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = 0
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = quo(${QPF},25.4)!${MSLP}!SUB(HGHT@500%PRES,HGHT@1000%PRES)!SUB(HGHT@500%PRES,HGHT@1000%PRES)
TYPE	 = F!C!C!C
CONTUR	 =  
CINT	 = $NZHcint
LINE	 = !6/1/1!14/1/1!14/10/1
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
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = $Map
LATLON	 =  
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = $stnplt
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 0.8
STREAM   = 
BOXLIN   = 32
REGION   = view 
TXTCOL	 = 31
TXTYPE	 = 1/2//221/s/c/sw
TXTFIL 	 = $TextFileName
TXTLOC	 = .8;1
COLUMN   =  
SHAPE    =  
INFO     =  
LOCI     = 
ANOTLN   =  
ANOTYP   =  
r
exit
";

Done:

# Here we go, run the program and send it parms:
$p = proc_open("gdplot3_gf", $desc, $pipes, $cwd);
fwrite($pipes[0], $parms);

# Catch program output, and print to screen (or where-ever):
if ($PrintOutput) {
	$return = stream_get_contents($pipes[1]);
	print_r($return);
}

// all done! Clean up
fclose($pipes[1]);
#fclose($pipes[2]);
proc_close($p);

#For now, move image from cwd to pwd TESTING PURPOSES ONLY!:
#$pwd = getcwd();
$FullPath = $BaseDir.$SubDir;
EnsureDirExists($FullPath);
rename("$cwd/$ImageFileName", $FullPath."/".$ImageFileName);

# For production, have unlink commands here to delete temp files.
unlink($TextFileName);
unlink($cwd."/gemglb.nts");
unlink($cwd."/last.nts");

?>