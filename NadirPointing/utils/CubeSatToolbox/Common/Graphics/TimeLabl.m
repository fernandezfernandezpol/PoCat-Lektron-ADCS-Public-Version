function [t, c, u] = TimeLabl( t, dT )

%--------------------------------------------------------------------------
%   Generates a time label given the maximum value of t and rescales t.
%
%   If two arguments are entered it computes the time series t as
%
%   t = (0:(nSim-1))*dT;
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [t, c, u] = TimeLabl( t )
%   [t, c. u] = TimeLabl( nSim, dT )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   t			 (1,:)  Time (sec)
%
%   or
%
%   nSim         (1,1)  Number of time steps
%   dT           (1,1)  Time step (sec)
%
%   -------
%   Outputs
%   -------
%   t			 (1,:) Time
%   c			 (1,:) Label (years,days,hours,minutes,seconds)
%   u            (1,:) Units of time
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1995, 2007 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin > 1 )
  t = (0:(t-1))*dT;
end

secInYear   = 365.25*86400;
secInDay    = 86400;
secInHour   =  3600;
secInMinute =    60;

tMax        = max(t);

if( tMax > secInYear )
  c = 'Time (years)';
  t = t/secInYear;
  u = 'year';
elseif( tMax > 3*secInDay )
  c = 'Time (days)';
  t = t/secInDay;
  u = 'day';
elseif( tMax > 3*secInHour )
  c = 'Time (hours)';
  t = t/secInHour;
  u = 'hour';
elseif( tMax > 3*secInMinute )
  c = 'Time (min)';
  t = t/secInMinute;
  u = 'min';
else
  c = 'Time (sec)';
  u ='sec';
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-03-15 16:41:02 -0400 (Sat, 15 Mar 2014) $
% $Revision: 37264 $
