#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/mlsbcape";

# Define the level and product to be generated (for use in filenames):
$Level = "con";
$Product = "sbcape";

# Handle the incoming vars:
# Ordering is Model Runtime, Model Name, Forecast Hour, Sector.
$ModRunTime = $argv[1];
$Model = $argv[2];
$FHour = $argv[3];
$Sector = $argv[4];
$Date = $argv[5];

# Set the size of the image:
$Size = SetImageSize($Sector,$DefaultImageSize);

# Load Sector Coords and projections:
$SectorArr = SetSectorInfo($Sector);
$Domain = $SectorArr["Domain"];
$Projection = $SectorArr["Projection"];

# Convert model name to grid name, and return a "clean" model name:
$ModArr = SetModGridNames($Model);
$ModName = $ModArr["ModName"];
#$GridName = $ModArr["GridName"];
$GridName = "/home/data/gempak/model/cfs/${Date}f${FHour}_cfs.gem";

# Make lowercase modname, used for image filename:
$LModName = strtolower($ModName);

# Set Base Directory and Image File Name:
$BaseDir = BaseDir();
$SubDir = SubDir($ModName,$ModRunTime,$Sector, $Date);
$ImageFileName = $LModName.$Sector."_".$Level."_".$Product."_".$FHour.".gif";

# Get the file name for the date string (file will be created by running this script):
$TextFileName = DateLabelFile($ModRunTime, $ModName, $FHour, $Level, $Product, $Sector, $cwd, $Date);

if (in_array($Sector, $BigSectors)) {
	$Mapfil = "base";
	$Map = "32//1";
} else {
	$Mapfil = "rdis + base";
	$Map = "32//1 + 32//1";
}

$stnplt = SetStationPlt($Product, $Sector);
$IJSkip = SetIJSkip($GridName, $Sector);

# Gempak magic, the parms we will send to the program:
$parms = "
\$mapfil = $Mapfil
GDFILE	 = $GridName
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = 0
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = TMPK@850%PRES
TYPE	 = F
FINT     = 0 
FLINE 	 = 1
TEXT	 = 1/1/hw
CLEAR	 = y
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = $Map
LATLON	 =  
IJSKIP   = $IJSkip
DEVICE	 = GIF|$ImageFileName|$Size
BOXLIN   = 32
REGION   = view 
TITLE    = 0
r
GDPFUN	 = mask(abs(CINS),sge(CAPE,10))!CAPE
TYPE	 = F!C
CONTUR	 = 0
CINT	 = 10;100;500;1000;1500;2000;2500;3000;4000;5000;6000;7000;8000
LINE	 = 6;7;6;8;9;10;11;12;13;14;15;16;17/1/1;2;2;2;2;2;2;2;2;2;2;2;2
FINT	 = 10;25;50;75;100
FLINE	 = 31;2;2;3;4;5/1;2;7;7;7;7
HILO	 = 
HLSYM	 = 
CLRBAR	 = 31/h/lc/.5;.002/.8;.012//|.65/1
WIND	 = 
REFVEC	 =  
TITLE	 = 31/-3/SBCAPE (J/kg) / SBCIN (J/kg) - COD NEXLAB   WEATHER.COD.EDU
TEXT	 = 1/1/hw
CLEAR	 = n
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = $stnplt
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 2
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