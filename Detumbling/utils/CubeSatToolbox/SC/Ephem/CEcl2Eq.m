function c = CEcl2Eq( jD )

%--------------------------------------------------------------------------
%   Transformation matrix from ecliptic to Earth equatorial planes.
%   This is a single rotation about the x-axis. If the jd is not input it will 
%   use the mean obliquity for J2000.0. 
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   c = CEcl2Eq( jD )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   jD            (1,1)    Julian date
%
%   -------
%   Outputs
%   -------
%   c             (3,3)    Transformation matrix from the ecliptic plane
%                          to the equatorial plane
%
%--------------------------------------------------------------------------
%   References: Montenbruck, O., T.Pfleger, Astronomy on the Personal
%               Computer, Springer-Verlag, Berlin, 1991, p. 15.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if ( nargin == 0 ),
  jD = 2451545;
end

T   = (jD - 2451545)/36525;
mob = (23.43929111 - ((46.815 + (0.00059 - 0.001813*T)*T)*T)/3600)*pi/180;

smob = sin(mob);
cmob = cos(mob);

c    = [ 1 0 0; 0 cmob -smob; 0 smob cmob ];

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-03-15 12:18:01 -0400 (Sat, 15 Mar 2014) $
% $Revision: 37263 $

