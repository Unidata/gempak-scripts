<?php

/*
PRODSCRIPT SETTINGS FILE
This file serves two purposes:
First, some initial commands are run.  These are mostly just setting variables.
Second, functions are defined that will be referenced by product scripts.

Be aware that this script will still be "executed" so vars that are defined early on_
were likely done there for a reason.  In other words, moving things around may break stuff, so don't!

Gensini - 2014
*/

# Set the DISPLAY environmental variable, needed for _gf programs:
putenv("DISPLAY=:8");

# Display GEMPAK output?
$PrintOutput = true;

# This is the prodscript directory:
function ProdDir(){return "/home/scripts/models/prodscripts";}
# This is the base directory of where images will ultimately reside:
function BaseDir(){return "/home/apache/climate/data/forecast";}
function SubDir($Model,$RunTime,$Sector, $Date = null) {
	if (($Model == "ECMWF") && ($Sector == "NAZM")) {
		return "/".$Model."/".$RunTime."/NA";
	} elseif ($Model == "CFS"){
		if (!is_null($Date)) {
			return "/".$Model."/".$Date."/".$Sector;
		} else {

		$Today = date("Ymd");
		$FullRunTime = "$RunTime:00:00";
		$TimeClass = new DateTime("$Today $FullRunTime");
		if ($RunTime == 18) {
			$TimeClass->modify('-1 day');
		}
		$CFSRunTime = $TimeClass->format("Ymd");
		$CFSRunTime .= $RunTime;

		return "/".$Model."/".$CFSRunTime."/".$Sector;
		}
	} else {
		return "/".$Model."/".$RunTime."/".$Sector;
	}
}

# Default image size:
$DefaultImageSize = "800;600";

# This is an array of sectors that should only plot "base" for mapfil:
$BigSectors = array("US", "NA", "WLD", "AO", "PO");

/*
FUNCTIONS USED FOR DEFINING VARIABLES
*/

# This function will return the image size to be used:
function SetImageSize($Sector,$DefaultSize){
	if (($Sector == "ILS") || ($Sector == "ILB")) {
		$ImageSize = "1024;768";
	} elseif ($Sector == "NHEM") {
		$ImageSize = "800;800";
	} else {
		$ImageSize = $DefaultSize;
	}
	return $ImageSize;
}

# This function will return an array with the sector coords and projection:
function SetSectorInfo($Sector){
	$SectorFileName = "/home/scripts/reference/sectors.txt";
	$FloaterSectorFileName = "/home/scripts/reference/floater.txt";
	$WXCSectorFileName = "/home/apache/climate/wxchallenge/wxcs.dat";

	if (($Sector == "WXCS") || ($Sector == "WXCB")) {
		$WXCsectorFile = file($WXCSectorFileName);
		if ($Sector == "WXCS") {
			$Domain = trim($WXCsectorFile[8]);
		} else {
			$Domain = trim($WXCsectorFile[9]);
		}
		$Projection = "lcc";
	} elseif ($Sector == "FLT") {
		$Domain = trim(file_get_contents($FloaterSectorFileName));
		$Projection = "lcc";
	} else {
		$SectorFile = file($SectorFileName);
		foreach ($SectorFile as $line) {
			if (substr(trim($line), 0, 1) == "#"){continue;} # hashtags denote comments, skip this line.
			$line = trim(preg_replace("/[[:blank:]]+/"," ",$line));
			list($abbr, $sTitle, $coords, $proj) = explode(" ", $line);
			if ($Sector == $abbr) {
				$Domain = $coords;
				$Projection = $proj;
				break;
			}
		}
	}

	$SectorInfo = array(
		'Domain' => $Domain,
		'Projection' => $Projection
	);

	return $SectorInfo;
}

# This function will return an array with the adjusted modname and appropriate grid name:
function SetModGridNames($Model) {
	$GridFileName = "/home/scripts/reference/gridnames.txt";
	$GridsFile = file($GridFileName);
	foreach ($GridsFile as $line) {
		$line = trim(preg_replace("/[[:blank:]]+/"," ",$line));
		list($mod, $grid) = explode(" ", $line);
		if ($Model == $mod) {
			$ModName = $mod;
			$GridName = $grid;
			break;
		}
	}

	if ($ModName == "GFSHD") {
	    $ModName = "GFS";
	} elseif ($ModName == "GFSNA") {
	    $ModName = "GFS";
	} elseif ($ModName == "NAM12") {
	    $ModName = "NAM";
	} elseif ($ModName == "NAMAK") {
	    $ModName = "NAM";
	}

	$ModInfo = array(
		'ModName' => $ModName,
		'GridName' => $GridName
	);

	return $ModInfo;
}

function HRRRparmAdjust($type,$parm) {
	if ($type == "GVCORD") {
		switch ($parm) {
			case 'NONE':
				$HRRRparm = "ATMO";
				break;
		}
	}
	return $HRRRparm;
}

# This function will return stnplt, which is dynamic for some products:
function SetStationPlt($Product, $Sector) {
	if (($Sector == "WXCS") || ($Sector == "WXCB")) {
		switch ($Product) {
			case 'cloud':
				$stnplt = "24/1|24/15/4/2|wxcstations.tbl";
				break;
			case 'irsat':
				$stnplt = "24/1|24/15/4/2|wxcstations.tbl";
				break;
			case 'cthk':
				$stnplt = "10/1|10/15/4/2|wxcstations.tbl";
				break;
			case '30mbdewp':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'ltng':
				$stnplt = "30/1|30/15/4/2|wxcstations.tbl";
				break;
			case 'uphly':
				$stnplt = "30/1|30/15/4/2|wxcstations.tbl";
				break;
			case 'scp':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'mucape':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'gust':
				$stnplt = "30/1|30/15/4/2|wxcstations.tbl";
				break;
			case 'mlcape':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'sbcape':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'prec':
				$stnplt = "28/1|28/15/4/2|wxcstations.tbl";
				break;
			case 'cprec':
				$stnplt = "28/1|28/15/4/2|wxcstations.tbl";
				break;
			case 'precacc':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'pwat':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'radar':
				$stnplt = "30/1|30/15/4/2|wxcstations.tbl";
				break;
			case 'temp':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'thetae':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'wetblb':
				$stnplt = "32/1|32/15/4/2|wxcstations.tbl";
				break;
			case 'rhum':
				$stnplt = "17/1|17/15/4/2|wxcstations.tbl";
				break;
			default:
				$stnplt = "";
				break;
		}
	} elseif (($Sector == "FLT") || ($Sector == "CHI") || ($Sector == "ATL") || ($Sector == "DEN") || ($Sector == "OKC")) {
		switch ($Product) {
			case 'cape1000':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'ltng':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'snowmn12':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'uphly':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'gust':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'radar':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'snow1':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'snow12':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'snow4':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'snow8':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			case 'stp':
				$stnplt = "32/.65|32/15/2/2|spcwatch.tbl";
				break;
			default:
				$stnplt = "";
				break;
		}
	} else {
		$stnplt = "";
	}	
	return $stnplt;
}

# This product will return stream, settings for streamlines, which is dynamic for some products:
function SetStream($Product, $ModName, $Sector = null) {
	
	if ($Product == "30mbdewp") {
		if ($ModName == "RAP") {
			$stream = "0.3";
		} elseif (($ModName == "NAM") && ($Sector == "AK")) {
			$stream = "0.3";
		} else {
			$stream = "1";
		}
	} elseif ($Product == "rhum") {
		if (($ModName == "RAP") && ($Sector == "US")) {
			$stream = "0.4";
		} elseif (($ModName == "NAM") && ($Sector == "AK")) {
			$stream = "0.3";
		} else {
			$stream = "0.85";
		}
	} elseif ($Product == "mdiv") {
		if (($ModName == "NAM") && ($Sector == "AK")) {
			$stream = "0.2";
		} else {
			$stream = "1";
		}
	} elseif ($Product == "pvort") {
		if (($ModName == "RAP") && ($Sector == "US")) {
			$stream = "0.2";
		} elseif (($ModName == "NAM") && ($Sector == "AK")) {
			$stream = "0.2";
		} elseif ($Sector == "NA") {
			$stream = "0.4";
		} elseif ($Sector == "WLD") {
			$stream = "0.15";
		} else {
			$stream = "0.85";
		}
	}
	return $stream;
}

# This product will return filter, which is dynamic for some products:
function SetFilter($ModName) {
	switch ($ModName) {
		case 'RAP':
			$Filter = "0.8";
			break;		
		default:
			$Filter = "0.6";
			break;
	}	
	return $Filter;
}

#
function SetIJSkip($GridName, $Sector) {
	$IJSkip = "";
	if ($GridName == "GFSHD") {
		switch ($Sector) {
			case 'WLD':
				$IJSkip = "";
				break;
			case 'NA':
				$IJSkip = "0;335;680/0;190;350";
				break;
			case 'US':
				$IJSkip = "0;435;610/0;215;300";
				break;
			case 'CGP':
				$IJSkip = "0;485;570/0;245;285";
				break;
			case 'SGP':
				$IJSkip = "0;490;560/0;225;270";
				break;
			case 'NE':
				$IJSkip = "0;535;610/0;245;290";
				break;
			case 'SE':
				$IJSkip = "0;520;585/0;225;265";
				break;
			case 'SW':
				$IJSkip = "0;455;530/0;230;275";
				break;
			case 'CAN':
				$IJSkip = "0;455;545/0;255;300";
				break;
			case 'AK':
				$IJSkip = "0;330;505/0;275;330";
				break;
			case 'PO':
				$IJSkip = "0;245;510/0;200;330";
				break;
			case 'AO':
				$IJSkip = "/0;180;310";
				break;
			case 'NHEM':
				$IJSkip = "/0;179;361";
				break;
			default:
				$IJSkip = "";
				break;
		}
	} elseif ($GridName == "HRRR") {
		switch ($Sector) {
			case 'CGPsf':
				$IJSkip = "0;535;1375/0;415;1000";
				break;
			case 'MW':
				$IJSkip = "0;890;1675/0;560;1130";
				break;
			case 'SL':
				$IJSkip = "0;630;1405/0;630;1220";
				break;
			case 'NEsf':
				$IJSkip = "0;1200;2145/0;520;1250";
				break;
			case 'SGP':
				$IJSkip = "0;350;1490/0;90;910";
				break;
			case 'SE':
				$IJSkip = "0;920;2100/0;1;820";
				break;
			case 'GC':
				$IJSkip = "0;1010;1720/0;180;720";
				break;
			case 'CP':
				$IJSkip = "0;400;1140/0;950;1377";
				break;
			case 'NW':
				$IJSkip = "0;1;930/0;690;1377";
				break;
			case 'SW':
				$IJSkip = "0;1;1000/0;200;1110";
				break;
			case 'CHI':
				#$IJSkip = "0;1180;1420/0;770;930"; #For the old (original) CHI sector
				$IJSkip = "0;1164;1435/0;745;940"; 
				break;
			case 'ATL':
				$IJSkip = "0;1390;1540/0;460;570";
				break;
			case 'DEN':
				$IJSkip = "0;700;855/0;730;840";
				break;
			case 'OKC':
				$IJSkip = "0;830;1135/0;475;695";
				break;
			case 'ILS':
				$IJSkip = "0;890;1675/0;560;1130"; 
				break;
			default:
				$IJSkip = "yes";
				break;
		}
	} elseif ($GridName == "RAP") {
		switch ($Sector) {
			case 'US':
				$IJSkip = "";
				break;
			case 'CGP':
				$IJSkip = "0;135;340/0;110;260";
				break;
			case 'SGP':
				$IJSkip = "0;105;325/0;40;195";
				break;
			case 'NE':
				$IJSkip = "0;265;451/0;120;285";
				break;
			case 'SE':
				$IJSkip = "0;215;440/0;15;185";
				break;
			case 'SW':
				$IJSkip = "0;1;230/0;60;235";
				break;
			case 'CAN':
				$IJSkip = "0;35;285/0;165;337";
				break;
			default:
				$IJSkip = "";
				break;
		}
	} elseif ($GridName == "NAM12") {
		switch ($Sector) {
			case 'US':
				$IJSkip = "";
				break;
			case 'CGP':
				$IJSkip = "0;225;450/0;140;310";
				break;
			case 'SGP':
				$IJSkip = "0;190;435/0;65;240";
				break;
			case 'NE':
				$IJSkip = "0;365;614/0;150;345";
				break;
			case 'SE':
				$IJSkip = "0;315;560/0;40;215";
				break;
			case 'SW':
				$IJSkip = "0;75;330/0;90;280";
				break;
			case 'CAN':
				$IJSkip = "0;110;390/0;205;410";
				break;
			default:
				$IJSkip = "";
				break;
		}
	} elseif ($GridName == "NAM") {
		switch ($Sector) {
			case 'US':
				$IJSkip = "";
				break;
			case 'CGP':
				$IJSkip = "0;65;135/0;45;100";
				break;
			case 'SGP':
				$IJSkip = "0;55;130/0;20;75";
				break;
			case 'NE':
				$IJSkip = "0;110;185/0;45;105";
				break;
			case 'SE':
				$IJSkip = "0;95;170/0;10;75";
				break;
			case 'SW':
				$IJSkip = "0;20;100/0;25;85";
				break;
			case 'CAN':
				$IJSkip = "0;35;120/0;60;125";
				break;
			default:
				$IJSkip = "";
				break;
		}
	} elseif ($GridName == "NAM4KM") {
		switch ($Sector) {
			case 'CGP':
				$IJSkip = "0;540;1080/0;350;740";
				break;
			case 'SGP':
				$IJSkip = "0;460;1040/0;160;570";
				break;
			default:
				$IJSkip = "";
				break;
		}
	}
	return $IJSkip;
}

# This function determines the LI grid name, because it is different in some models:
function SetCAPE($ModName) {
	
	if ($ModName == "RAP") {
		$CAPE = "CAPE@255:0%PDLY";
	} else {
		$CAPE = "CAPE@180:0%PDLY";
	}
	return $CAPE;
}

# This function determines the LI grid name, because it is different in some models:
function SetLI($ModName) {
	
	if ($ModName == "GFS") {
		$LI = "LIFT@0%NONE";
	} else {
		$LI = "LFT4@180:0%PDLY";
	}
	return $LI;
}

# This function determines the MSLP grid name, because it is different in some models:
function SetMSLP($ModName) {
	
	switch ($ModName) {
		case 'NAM':
			$MSLP = "EMSL";
			break;
		case 'NAM4KM':
			$MSLP = "sm9s(EMSL)";
			break;
		case 'RAP':
			$MSLP = "quo(MSLMA,100)";
			break;
		default:
			$MSLP = "PMSL";
			break;
	}
	return $MSLP;
}

# This function determines the QPF grid name, because it is different in some models:
function SetQPF($ModName,$QPFhr) {
	
	if ($ModName == "RAP") {
		$QPF = "S".$QPFhr."M";
	} else {
		$QPF = "P".$QPFhr."M";
	}
	return $QPF;
}

/*
The next three functions deal with the date label that is in the upper right corner of each image.
The first function is essentially a list of models/runs that need a day subtracted,
The second function determines the valid time, dynamic based in part on current time,
And the second function creates a text file to be used to plot that string on the image.
*/

# This funciton is a list of model names and runtime pairs which need a day subtracted from the label.
# This need arises when a model of a runtime for one day, will have its images generated on the next day.
# A value of True will be returned if we do need to subtract a day, False if not (False is the default).
function RanNextDay_Check($ModName,$RunTime) {
	$NeedSubtraction = FALSE;

	switch ($ModName) {
		case 'HRRR':
			if ($RunTime == 23) {$NeedSubtraction = TRUE;}
			break;
		case 'SREF':
			if ($RunTime == 21) {$NeedSubtraction = TRUE;}
			break;
		case 'CFS':
			if ($RunTime == 18) {$NeedSubtraction = TRUE;}
			break;
		default:
			// The passed model should never require a subtraction, move along.
			break;
	}

	return $NeedSubtraction;
}

# This function will calculate the valid time based on the current and initialization times.
# There is a small chance of this being off if running data not from current day:
function GetValidTime($RunTime, $FHour) {
	$Today = date("Y-m-d");
	$FullRunTime = "$RunTime:00:00";
	$TimeClass = new DateTime("$Today $FullRunTime");
	$TimeClass->modify("$FHour hours");

	return $TimeClass;
}

# This function will create a text file used in the labels of the model product:
function DateLabelFile($RunTime, $ModName, $FHour, $Level, $Product, $Sector, $TextDir, $Date = null){
	# date will look like: date("H\Z D M d Y")	
	
	if (($ModName == "CFS") && (!is_null($Date))) {
		$ValidTimeClass = DateTime::createFromFormat('YmdH', $Date);
		$ValidTimeClass->modify("$FHour hours");
		$Valid = $ValidTimeClass->format("H\Z D M d Y");
	} else {
		$ValidTimeClass = GetValidTime($RunTime, $FHour);
		if (RanNextDay_Check($ModName,$RunTime)){  # See first function in this grouping for list of Model and Runtime pairs which will return true.
			$ValidTimeClass->modify('-1 day');
		}
		$Valid = $ValidTimeClass->format("H\Z D M d Y");
	}

	// $ValidTimeClass = GetValidTime($RunTime, $FHour);
	// if (($ModName == "CFS") && ($RunTime == 18)){
	// 	$ValidTimeClass->modify('-1 day');
	// }
	// $Valid = $ValidTimeClass->format("H\Z D M d Y");
		

	switch ($ModName) {
		case 'SREF':
			$spaces = "            .";
			break;
		case 'HRRR':
			$spaces = "            .";
			break;
		case 'ECMWF':
			$spaces = "             .";
			break;
		case 'NAM4KM':
			$spaces = "             .";
			break;
		case 'ENSTHIN':
			$spaces = "              .";
			break;
		case 'GEFS':
			$spaces = "           .";
			break;
		default:
			$spaces = "          .";
			break;
	}
	if ($Product == "ptype") {$spaces = "";}

	$Text = $RunTime."Z $ModName $FHour hour - Valid $Valid$spaces";

	$fname = "$TextDir/".$RunTime.$ModName.$Level.$Product.$Sector.$FHour.".txt";
	file_put_contents($fname, $Text);
	return $fname;
}

/*
This function will make the directory for the image if it does not already exist
*/
function EnsureDirExists($path) {
	if (!file_exists($path)) {
	    mkdir($path, 0775, true);
	}
}

/*
descriptor array, used for proc_open:
*/

$desc = array(
    0 => array('pipe', 'r'), // 0 is STDIN for process
    1 => array('pipe', 'w'), // 1 is STDOUT for process
    2 => array('file', '/tmp/error-output.txt', 'a') // 2 is STDERR for process
);

?>
