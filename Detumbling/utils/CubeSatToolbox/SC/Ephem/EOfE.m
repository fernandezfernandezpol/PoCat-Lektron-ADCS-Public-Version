function [e, eps0, epsT, deltaPsi, deltaEps] = EOfE( T )

%--------------------------------------------------------------------------
%   Computes the equation of the equinoxes
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [e, eps0, epsT, deltaPsi, deltaEps] = EOfE( T )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   T           (1,1) Julian centuries of 86400s dynamical time from j2000.0
%
%   -------
%   Outputs
%   -------
%   e           (1,1) Equation of the equinoxes (deg)
%   eps0        (1,1) Mean obliquity     (deg)
%   epsT        (1,1) True obliquity     (deg)
%   deltaPsi    (1,1) Delta in longitude (deg)
%   deltaEps    (1,1) Delta in obliquity (deg)
%
%--------------------------------------------------------------------------
%	References:	  The Astronomical Almanac for the Year 1993, U.S. Government
%	              Printing Office, 1993, p. B6.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin == 0 )
  T = JD2T(Date2JD);
end

% Find the nutation deltas
%-------------------------
[deltaPsi,deltaEps] = NutDelta(T);

% Find the mean obliquity of the ecliptic
%----------------------------------------
eps0  = ObOfE(T);

epsT  = eps0 + deltaEps;

% The equation of the equinoxes
%------------------------------
e = deltaPsi*CosD(epsT);

% PSS internal file version information
%--------------------------------------
% $Date: 2014-12-22 14:54:42 -0500 (Mon, 22 Dec 2014) $
% $Revision: 39276 $
