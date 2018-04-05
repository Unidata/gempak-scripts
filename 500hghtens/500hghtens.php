#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/500hghtens";

# Define the level and product to be generated (for use in filenames):
$Level = "500";
$Product = "hghtens";

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

$IJSkip = SetIJSkip($GridName, $Sector);

# Gempak magic, the parms we will send to the program:
$parms = "
\$mapfil = base
GDFILE	 = GEFS:01
GDATTIM	 = f${FHour}
GLEVEL	 = 500
GVCORD	 = pres
PANEL	 = 0
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = gt(HGHT,1)
TYPE	 = F
CONTUR	 = 0 
CINT	 = 
LINE	 = 5;18/1/1/0
FINT	 = 1
FLINE	 = 31
HILO     =  
HLSYM    = 
CLRBAR   = 
WIND	 = bk32/.8//112
REFVEC	 =  
TITLE	 = 31/-2/500mb SPAGHETTI PLOT - 5520m 5760m 5880m - COD NEXLAB   WEATHER.COD.EDU
TEXT	 = 1/1/hw
CLEAR	 = y
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = 32//1
LATLON	 =  
IJSKIP   = $IJSkip
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = 
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 
BOXLIN   = 32
REGION   = view 
COLUMN   =  
SHAPE    =  
INFO     =  
LOCI     = 
ANOTLN   =  
ANOTYP   =  
r
GDFILE	 = GEFS:01!GEFS:02!GEFS:03!GEFS:04!GEFS:05!GEFS:06!GEFS:07!GEFS:08!GEFS:09!GEFS:10!GEFS:11!GEFS:12!GEFS:13!GEFS:14!GEFS:15!GEFS:16
GDPFUN	 = HGHT
TYPE	 = C
CINT	 = 5520;5760;5880
LINE	 = 5;19;18/1/1/0
FINT	 = 
FLINE	 = 
CLEAR	 = n
TXTCOL	 = 31
TXTYPE	 = 1/2//221/s/c/sw
TXTFIL 	 = $TextFileName
TXTLOC	 = .8;1
r
GDFILE = GEFS:17!GEFS:18!GEFS:19!GEFS:20
CLEAR	 = n
r
GDFILE = {CGEFS}
CLEAR	 = n
LINE	 = 32;32/1/3/0
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
