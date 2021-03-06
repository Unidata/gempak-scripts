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
$Product = "precacc";

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
$TextFileName = DateLabelFile($ModRunTime, $ModName, $FHour, $Level, $Product, $cwd);

if (in_array($Sector, $BigSectors)) {
	if ($Sector == "WLD") {
		$Mapfil = "base";
		$Map = "32//1";
	} else {
		$Mapfil = "rdis + base";
		$Map = "29//1 + 32//1";
	}
	$Type = "F";
} else {
	$Mapfil = "county + base";
	$Map = "29//1 + 32//1";
	$Type = "F";
}

# Need to make sure there are at least 2 characters for precip:
$Pcount = $FHour+0;
$Pcount = str_pad($Pcount, 2, '0', STR_PAD_LEFT);

$QPF = SetQPF($ModName,$Pcount);
$MSLP = SetMSLP($ModName);
$stnplt = SetStationPlt($Product, $Sector);
$IJSkip = SetIJSkip($GridName, $Sector);

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
GDPFUN	 = $MSLP
TYPE	 = F
CONTUR	 = 0 
CINT	 = .01;.05;.1;.5;1;1.5;2;2.5;3;3.5;4;5;6;7;8;9;10;11;12
LINE	 = 32/10/1
FINT	 = 0
FLINE	 = 31
HILO	 = 
HLSYM	 = 
CLRBAR	 = 
WIND	 = 
REFVEC	 =  
TITLE	 = 31/-3/PRECIP ACCUMULATION (in) - COD NEXLAB   WEATHER.COD.EDU
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
FILTER   = 1.1
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
GDPFUN	 = quo(${QPF},25.4)
TYPE	 = $Type
CONTUR	 = 0 
CINT	 = .01;.02;.03;.04;.05;.06;.07;.08;.09;.1;.2;.3;.4;.5;.6;.7;.8;.9;1;1.5;2;2.5;3;3.5;4;5;6;7;8;9;10;11;12
LINE	 = 32/10/1
FINT	 = .01;.05;.1;.5;1;1.5;2;2.5;3;3.5;4;5;6;7;8;9;10;11;12
FLINE	 = 31;9;10;11;12;13;14;15;16;17;18;19;20;21;23;24;25;28;29;30
HILO	 = 
HLSYM	 = 
CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
WIND	 = 
REFVEC	 =  
TITLE	 = 31/-3/PRECIP ACCUMULATION (in) - COD NEXLAB   WEATHER.COD.EDU
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
FILTER   = 1.1
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
