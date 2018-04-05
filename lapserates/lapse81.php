#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/lapserates";

# Define the level and product to be generated (for use in filenames):
$Level = "con";
$Product = "lapse81";

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
	$Mapfil = "rdis + base";
	$Map = "4//1 + 32//1";
}

$stnplt = SetStationPlt($Product, $Sector);
$IJSkip = SetIJSkip($GridName, $Sector);

# Gempak magic, the parms we will send to the program:
$parms = "
	\$mapfil = rdis+base
    GDFILE	 = $GridName | $ModRunTime
	GDATTIM	 = f$FHour
	GLEVEL	 = 850:1000
	GVCORD	 = pres
	PANEL	 = 0
	SKIP	 = 0
	SCALE	 = 0
	GDPFUN	 = ABS(STAB)!kntv(VLAV(wnd))
	TYPE	 = CF!B
	CONTUR	 =  
	CINT     = 6.0;6.5;7.0;7.5;8.0;8.5;9.0;9.5;10;10.5;11;11.5;12;12.5;13;13.5 
	LINE	 = 32/10/1
	FINT     = 6;6.25;6.5;6.75;7;7.25;7.5;7.75;8;8.25;8.5;8.75;9;9.25;9.5;9.75;10
	FLINE    = 31;7;8;9;11;12;13;14;16;17;19;20;22;24;25;26;27;28
	HILO     = 
    HLSYM    = 
    CLRBAR   = 31/h/lc/.5;.002/.95;.012/2/|.65/1
	WIND	 = bk32/.7//112
	REFVEC	 = 
	TITLE	 = 31/-3/1000-850 mb LAPSE RATE (C/km) / AVG. WIND (kts) - COD NEXLAB   WEATHER.COD.EDU
    TEXT	 = 1/1/hw
	CLEAR	 = y
	GAREA	 = $Domain
	PROJ	 = $Projection
	MAP	     = 4//1+32//1
	LATLON	 =  
	DEVICE	 = GIF|$ImageFileName|$Size
	STNPLT   = 
	SATFIL	 =
	RADFIL   =
	IMCBAR   =
	FILTER   = 1
    BOXLIN   = 32
	REGION   = view 
	TXTFIL 	 = $TextFileName
	TXTLOC	 = .8;1
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