#!/usr/bin/php
<?php

# Load required settings & functions:
require ("/home/scripts/models/prodscripts/settings.php");

# Directory containing all the product script sub-directories, defined in settings.php:
$ProdDir = ProdDir();

# Current working directory, set this to where our color table is...
# Be aware, this is also where the image will be created:
$cwd = "$ProdDir/stp";

# Define the level and product to be generated (for use in filenames):
$Level = "con";
$Product = "stp";

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
	$Mapfil = "county + base";
	$Map = "30//1 + 32//1";
}

if (($ModName == "RAP") || ($Sector == "FLT")) {
	$wind = ".5";
} else {
	$wind = ".4";
}

$stnplt = SetStationPlt($Product, $Sector);
$IJSkip = SetIJSkip($GridName, $Sector);

# Name of the gird we're making for STP, hrrr MUST be lower case:
$STPgrid = strtolower($Model).$FHour."-".strtolower($Sector).".grd";

# Gempak magic, the parms we will send to the program:
# WARNING!!! Notice the blank line after r, yeah... that's mandatory.
$parms = "
GDFILE	 = $GridName | $ModRunTime
GDOUTF   = $STPgrid
GFUNC    = mul(mul(mul(quo(sub(2000,HGHT@0%LCLV),1000),quo(CAPE,1500)),quo(hlcy@1000:0%HGHT,150)),quo(mag(shr@0:6000%HGHT),20))
GDATTIM  = f$FHour
GLEVEL   = 0
GVCORD   = NONE
GRDNAM   = STP@0%NONE
GRDTYP   = S
GPACK    = grib/16
PROJ     = 
GRDAREA  = 
KXKY     =
MAXGRD   =
CPYFIL   = $GridName
ANLYSS   =
r

exit
";

# Here we go, run the program and send it parms:
$gddiag = proc_open("gddiag", $desc, $pipes, $cwd);
fwrite($pipes[0], $parms);

# Catch program output, and print to screen (or where-ever):
if ($PrintOutput) {
	$return = stream_get_contents($pipes[1]);
	print_r($return);
}

// all done! Clean up
fclose($pipes[1]);
#fclose($pipes[2]);
proc_close($gddiag);

# Gempak magic, the parms we will send to the program:
$parms = "
\$mapfil = $Mapfil
GDFILE	 = $GridName | $ModRunTime + $STPgrid
GDATTIM	 = f$FHour
GLEVEL	 = 0
GVCORD	 = none
PANEL	 = 0
SKIP	 = 0
SCALE	 = 0
GDPFUN	 = cape
TYPE	 = F
FINT     = 100000 
FLINE 	 = 31
TEXT	 = 1/1/hw
IJSKIP   = YES
CLEAR	 = y
GAREA	 = $Domain
PROJ	 = $Projection
MAP	     = $Map
IJSKIP   = yes
DEVICE	 = GIF|$ImageFileName|$Size
STNPLT   =  
BOXLIN   = 32
REGION   = view	
TITLE    = 0
CLRBAR	 = 
r
GDPFUN	 = mask(STP+2,SGT(CINS,-100)) ! kntv(wnd@10%hght)
TYPE	 = F ! B
CONTUR	 = 0
CINT	 = .1;.25;.5;.75;1;1.25;1.5;1.75;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20
LINE	 = 2/1/1
FINT	 = .1;1;2;3;4;5;7;9;11;13;15
FLINE	 = 31;9;10;11;12;13;14;15;16;17;18;19
CLEAR	 = n
IJSKIP   = YES
STNPLT   = $stnplt
HILO     = 32;32/15#;15#//25/20;0  
HLSYM    = .8;.8/2/1;1/1;1/HW
CLRBAR	 = 31/h/lc/.5;.002/.95;.012//|.65/1
TITLE    = 31/-3/FIXED-LAYER SIG TOR / 10m WIND (kts) - COD NEXLAB   WEATHER.COD.EDU
WIND	 = bk32/.5//112
TXTFIL 	 = $TextFileName
TXTLOC	 = .8;1
TXTYPE	 = 1/2//221/s/c/sw
TXTCOL	 = 31
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
#unlink($cwd."/gemglb.nts");
#unlink($cwd."/last.nts");
unlink($cwd."/$STPgrid");

?>
