#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/ehi";

# Define the level and product to be generated (for use in filenames):
$Level = "con";
$Product = "uphly";

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

$stnplt = SetStationPlt($Product, $Sector);
$IJSkip = SetIJSkip($GridName, $Sector);

# Gempak magic, the parms we will send to the program:
$parms = "
\$mapfil = county+base
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 5000:2000
GVCORD	 = HGHT
PANEL	 = 0
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = MXUPHL01
TYPE	 = F
CONTUR	 =  
CINT	 =  
LINE	 = 32/10/1
FINT     = 1;5;10;15;25;35;50;65;80;100;125;150;175;200;225;250;275;300;325;350;375;400;500
FLINE	 = 31;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28
HILO     =32;32/15#;15#//25/20;0  
HLSYM    = .8;.8/2/1;1/1;1/HW
CLRBAR   = 31/h/lc/.5;.002/.95;.012/2/|.65/1
WIND	 = bk32/.7//112
REFVEC	 =  
TITLE	 = 31/-3/2-5km HRLY MAX UPDRAFT HELICITY - COD NEXLAB   WEATHER.COD.EDU
TEXT	 = 1/1/hw
CLEAR	 = y
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = 27/1/1+32//1
LATLON	 =  
IJSKIP   = $IJSkip
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = $stnplt
SATFIL	 =
RADFIL   =
IJSKIP   = YES
IMCBAR   =
FILTER   = 1
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
