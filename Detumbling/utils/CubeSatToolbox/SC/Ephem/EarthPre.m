function p = EarthPre( T )
	
%--------------------------------------------------------------------------
%   Computes the earth precession matrix
%
%--------------------------------------------------------------------------
%   Form:
%   p = EarthPre( T )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   T	(1,1) Julian centuries of 86400s dynamical time from j2000.0
%
%   -------
%   Outputs
%   -------
%   p	(3,3) Precession matrix
%
%--------------------------------------------------------------------------
%   References:   Seidelmann, The Explanatory Supplement to the Astronomical
%                 Almanac,  University Science Books, 1992, p. 103.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 1.1
%--------------------------------------------------------------------------

if( nargin == 0 )
  T = JD2T(Date2JD);
end

degToRad = pi/180;
	
zeta   = (0.6406161 + (8.390e-5 + 5.00e-6*T)*T)*T*degToRad;
z      = (0.6406161 + (3.041e-4 + 5.10e-6*T)*T)*T*degToRad;
theta  = (0.5567530 - (1.185e-4 + 1.16e-5*T)*T)*T*degToRad;
	
czeta  = cos( zeta  );
szeta  = sin( zeta  );
cz     = cos( z     );
sz     = sin( z     );
ctheta = cos( theta );
stheta = sin( theta );

p = [czeta*ctheta*cz-szeta*sz,-szeta*ctheta*cz-czeta*sz,-stheta*cz;...
     czeta*ctheta*sz+szeta*cz,-szeta*ctheta*sz+czeta*cz,-stheta*sz;...
     czeta*stheta,-szeta*stheta,ctheta];


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-15 15:32:35 -0400 (Tue, 15 Mar 2016) $
% $Revision: 41893 $
