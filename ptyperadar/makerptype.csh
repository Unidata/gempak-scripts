#!/bin/csh

foreach fhr (F012 F013 F014 F015 F016 F017 F018)
gdplot3 << EOF
r snow-1.nts
GDFILE  = nam4km|12
GDATTIM = ${fhr}
!GAREA   = 33.6;-84.8;47.0;-63.6
IJSKIP  = 0
!PROJ    = STR/90.0;-78.3;0.0
GAREA    = 36.5;-82.9;46.3;-63.3
PROJ     = STR/90.0;-78.3;0.0
CLRBAR  = 32//LL/0.005;0.05/|tiny/22//hw
TITLE   = 32/1/~^ NAM4 Simulated Reflectivity
CLEAR   = y
DEVICE  = gif|${fhr}.gif|1024;768
r

r mixed-1.nts
CLEAR   = n
CLRBAR  = 32//LL/0.040;0.05/|tiny/22//hw
DEVICE  = gif|${fhr}.gif|1024;768
r

r mixed-2.nts
CLEAR   = n
CLRBAR  = 
TITLE   = 
DEVICE  = gif|${fhr}.gif|1024;768
r

r rain-1.nts
CLEAR   = n
CLRBAR  = 32//LL/0.075;0.05/|tiny/22//hw
TITLE   = 32/-2/Colored by P-type (Snow, Mixed, Rain)
DEVICE  = gif|${fhr}.gif|1024;768
r

EOF

end

gpend


