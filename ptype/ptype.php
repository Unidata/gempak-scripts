#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/ptype";

# Define the level and product to be generated (for use in filenames):
$Level = "prec";
$Product = "ptype";

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
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = UL
SKIP	 = 0
SCALE	 = 500000
GDPFUN	 = WXTR
TYPE	 = F
CONTUR	 =  
CINT	 =  
LINE	 =  
FINT     = 1/1/1
FLINE	 = 31;6
HILO     =  
HLSYM    =  
CLRBAR   =  
WIND	 = bk32/.7//112
REFVEC	 =  
TITLE	 = 31/-2/CATEGORICAL RAIN
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
FILTER   = 1
BOXLIN   = 32
REGION   = view 
TXTCOL	 = 
TXTYPE	 = 
TXTFIL 	 = 
TXTLOC	 = 
COLUMN   =  
SHAPE    =  
INFO     =  
LOCI     = 
ANOTLN   =  
ANOTYP   =  
r
\$mapfil = base
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = UR
SKIP	 = 0
SCALE	 = 500000
GDPFUN	 = WXTS
TYPE	 = F
CONTUR	 =  
CINT	 =  
LINE	 =  
FINT     = 1/1/1
FLINE	 = 31;7
HILO     =  
HLSYM    =  
CLRBAR   =  
WIND	 = bk32/.7//112
REFVEC	 =  
TITLE	 = 31/-2/CATEGORICAL SNOW
TEXT	 = 1/1/hw
CLEAR	 = n
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = 32//1
LATLON	 =  
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = 
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 1
BOXLIN   = 32
REGION   = view 
TXTCOL	 = 31
TXTYPE	 = .91/2//221/s/c/sw
TXTFIL 	 = $TextFileName
TXTLOC	 = .48;1
COLUMN   =  
SHAPE    =  
INFO     =  
LOCI     = 
ANOTLN   =  
ANOTYP   =  
r
\$mapfil = base
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = LL
SKIP	 = 0
SCALE	 = 500000
GDPFUN	 = WXTP
TYPE	 = F
CONTUR	 =  
CINT	 =  
LINE	 =  
FINT     = 1/1/1
FLINE	 = 31;8
HILO     =  
HLSYM    =  
CLRBAR   = 
WIND	 = bk32/.7//112
REFVEC	 =  
TITLE	 = 31/-2/CATEGORICAL SLEET
TEXT	 = 1/1/hw
CLEAR	 = n
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = 32//1
LATLON	 =  
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = 
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 1
BOXLIN   = 32
REGION   = view 
TXTCOL	 = 
TXTYPE	 = 
TXTFIL 	 = 
TXTLOC	 = 
COLUMN   =  
SHAPE    =  
INFO     =  
LOCI     = 
ANOTLN   =  
ANOTYP   =  
r
\$mapfil = base
GDFILE	 = $GridName | $ModRunTime
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = LR
SKIP	 = 0
SCALE	 = 500000
GDPFUN	 = WXTZ
TYPE	 = F
CONTUR	 =  
CINT	 =  
LINE	 =  
FINT     = 1/1/1
FLINE	 = 31;9
HILO     =  
HLSYM    =  
CLRBAR   = 
WIND	 = bk32/.7//112
REFVEC	 =  
TITLE	 = 31/-2/CATEGORICAL FREEZING RAIN
TEXT	 = 1/1/hw
CLEAR	 = n
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = 32//1
LATLON	 =  
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   = 
SATFIL	 =
RADFIL   =
IMCBAR   =
FILTER   = 1
BOXLIN   = 32
REGION   = view 
TXTCOL	 = 
TXTYPE	 = 
TXTFIL 	 = 
TXTLOC	 = 
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