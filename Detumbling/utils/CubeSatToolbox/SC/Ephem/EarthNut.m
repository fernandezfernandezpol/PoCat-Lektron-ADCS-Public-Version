function [n, eps0, epsT, deltaPsi, deltaEps] = EarthNut( T )
	
%--------------------------------------------------------------------------
%   The matrix that rotates from the Earth mean axes to the true axes.
%   See also NutDelta, ObOfE.
%   Default is today's date.
%
%--------------------------------------------------------------------------
%   Form:
%   [n, eps0, epsT, deltaPsi, deltaEps] = EarthNut( T )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   T       	(1,1) Julian centuries of 86400s dynamical time from j2000.0
%
%   -------
%   Outputs
%   -------
%   n        	(3,3) Nutation matrix (transforms from mean to true)
%   eps0    	(1,1) Mean obliquity     (deg)
%   epsT     	(1,1) True obliquity     (deg)
%   deltaPsi	(1,1) Delta in longitude (deg)
%   deltaEps	(1,1) Delta in obliquity (deg)
%
%--------------------------------------------------------------------------
%   References:	Seidelmann, P., ed. The Explanatory Supplement to the 
%             Astronomical Almanac, University Science Books, 1992, p. 115.
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
     
[deltaPsi,deltaEps] = NutDelta( T );

eps0  = ObOfE( T );

epsT  = eps0 + deltaEps;

cdpsi = CosD(deltaPsi);
sdpsi = SinD(deltaPsi);
ceps0 = CosD(    eps0);
seps0 = SinD(    eps0);
cepsT = CosD(    epsT);
sepsT = SinD(    epsT);

n = [cdpsi,-sdpsi*ceps0,-sdpsi*seps0;...
     sdpsi*cepsT,cdpsi*cepsT*ceps0+sepsT*seps0,cdpsi*cepsT*seps0-sepsT*ceps0;...
     sdpsi*sepsT,cdpsi*sepsT*ceps0-cepsT*seps0,cdpsi*sepsT*seps0+cepsT*ceps0];


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-15 15:32:35 -0400 (Tue, 15 Mar 2016) $
% $Revision: 41893 $
