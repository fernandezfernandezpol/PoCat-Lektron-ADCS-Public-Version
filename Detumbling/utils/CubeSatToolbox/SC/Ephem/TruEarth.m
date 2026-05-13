function [c, g, n, p] = TruEarth( T, useEofE )
	
%--------------------------------------------------------------------------
%   Computes the matrix from mean of Aries 2000 to earth fixed frame.
%   Uses EarthRot, EarthNut, and EarthPre in sequence.
%
%--------------------------------------------------------------------------
%   Form:
%   [c, g, n, p] = TruEarth( T, useEofE )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   T           (1,1) Julian centuries of 86400s dynamical time from j2000.0
%   useEofE     (1,1) If entered will use the equation of the equinoxes
%                     for the earth rotation matrix
%
%   -------
%   Outputs
%   -------
%   c           (3,3) Matrix from Mean of 2000.0 to earth fixed
%   g           (3,3) Greenwich matrix
%   n           (3,3) Nutation matrix
%   p           (3,3) Precession matrix
%
%--------------------------------------------------------------------------
%   References:   Seidelmann, ed. The Explanatory Supplement to the Astronomical
%                 Almanac, University Science Books, 1992, p. 20.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993-1997 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 1.1
%--------------------------------------------------------------------------

% Input processing
%-----------------
if( nargin < 1 )
  T = [];
end

% Defaults
%---------
if( isempty(T) )
  T = JD2T(Date2JD);
end

if( nargin > 1 )
  g = EarthRot(T,1); % 1 tells it to use the equation of the equinoxes
else
  g = EarthRot(T);
end
n = EarthNut(T);
p = EarthPre(T);
c = g*n*p;


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-15 15:32:35 -0400 (Tue, 15 Mar 2016) $
% $Revision: 41893 $
