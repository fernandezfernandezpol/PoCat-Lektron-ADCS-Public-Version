function T = JD2T( jd )
	
%--------------------------------------------------------------------------
%   Converts Julian days to centuries from J2000.0
%
%   Typing JD2T returns the current Julian century.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   T = JD2T( jd )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   jd           (1,:) Julian date (days)
%
%   -------
%   Outputs
%   -------
%   T            (1,:) Julian centuries of 86400s dynamical time from j2000.0
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 1 )
  jd = Date2JD;
end

T = (jd - 2451545) / 36525;

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 11:26:40 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34963 $
