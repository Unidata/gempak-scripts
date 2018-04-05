#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/ptyperadar";

# Define the level and product to be generated (for use in filenames):
$Level = "prec";
$Product = "radar";

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
$ModRunTime = $argv[1];
$Model = $argv[2];
$FHour = $argv[3];
$Sector = $argv[4];

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

if (in_array($Sector, $BigSectors)) {
	$Mapfil = "base";
	$Map = "32//1";
} else {
	$Mapfil = "inter+base";
	$Map = "29//1 + 32//1";
}

$IJSkip = SetIJSkip($GridName, $Sector);
$stnplt = SetStationPlt($Product, $Sector);

# Gempak magic, the parms we will send to the program:
$parms = "
\$mapfil = $Mapfil
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
GAREA	 = $Domain
PROJ	 = $Projection
PANEL    = 0
SKIP     = 0
SCALE    = 0
GDPFUN   = mul(cref@0%none,WXTS@0%none)
TYPE     = f
CONTUR   = 0
CINT     = 
LINE     = 
FINT     = 5;10;15;20;25;30;35;40;45
FLINE    = 0;19;20;21;22;23;24;25;26;27
HILO     = 
HLSYM    = 
CLRBAR   = 31//LR/0.95;0.05
WIND     = 
REFVEC   = 
TEXT     = 1/1/hw
CLEAR    = no
IJSKIP   = $IJSkip
CLEAR    = y
DEVICE   = GIF|$ImageFileName|$Size
MAP      = $Map
MSCALE   = 0
LATLON   = 
STNPLT   = 
SATFIL   = 
RADFIL   = 
IMCBAR   = 
LUTFIL   = 
STREAM   = 
POSN     = 4
COLORS   = 2
MARKER   = 2
GRDLBL   = 5
FILTER   = no
CLRBAR   = 32//LL/0.005;0.05/|tiny/22//hw
TITLE    = 
r
GDPFUN   = mul(cref@0%NONE,WXTP@0%none)
TYPE     = f
FINT     = 5;10;15;20;25;30;35;40;45
FLINE    = 0;10;11;12;13;14;15;16;17;18
CLRBAR   = 31//LR/0.85;0.05
CLEAR    = n
CLRBAR   = 32//LL/0.040;0.05/|tiny/22//hw
DEVICE   = GIF|$ImageFileName|$Size
r
GDPFUN   = mul(cref@0%none,WXTZ@0%none)
FINT     = 5;10;15;20;25;30;35;40;45
FLINE    = 0;10;11;12;13;14;15;16;17;18
CLEAR    = no
CLEAR    = n
CLRBAR   = 
TITLE    = 
DEVICE   = GIF|$ImageFileName|$Size
r
GDPFUN   = mul(cref@0%none,WXTR@0%none)
FINT     = 5;15;25;30;35;40;45;50;55;60;65
FLINE    = 0;1;2;3;4;5;6;7;8;26;27;9
CLEAR    = no
CLEAR    = n
CLRBAR   = 32//LL/0.075;0.05/|tiny/22//hw
TITLE    = 32/-2/COMPOSITE REFLECTIVITY BY P-TYPE (SNOW, MIXED, RAIN) - WEATHER.COD.EDU
TXTCOL	 = 32
TXTYPE	 = 1/2//221/s/c/sw
TXTFIL 	 = $TextFileName
TXTLOC	 = .8;1
BOXLIN   = 32
REGION   = view 
DEVICE   = GIF|$ImageFileName|$Size
STNPLT   = $stnplt
r
exit
";

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