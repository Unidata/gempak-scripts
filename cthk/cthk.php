#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/cthk";

# Define the level and product to be generated (for use in filenames):
$Level = "prec";
$Product = "cthk";

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
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
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
GAREA	 = $Domain
PROJ	 = $Projection
LATLON	 =  
IJSKIP   = $IJSkip
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = $stnplt
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
GAREA	 = $Domain
PROJ	 = $Projection
LATLON	 =  
MAP	     = 24//1 + 23//2
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = 
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