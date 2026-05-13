function x = ObOfE( T )

%--------------------------------------------------------------------------
%   Computes the mean obliquity of the ecliptic of date.
%   (with respect to the mean equator of date)
%   Rounds to 6 decimal places.
%
%--------------------------------------------------------------------------
%   Form:
%   x = ObOfE( T )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   T	(1,:)  Julian centuries of 86400s dynamical time from j2000.0
%
%   -------
%   Outputs
%   -------
%   x	(1,:)  The obliquity of the ecliptic (degrees)
%
%--------------------------------------------------------------------------
%   References:   The Astronomical Almanac for the Year 1993,
%                  U.S. Government Printing Office, 1993, p. B18.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 1.1
%--------------------------------------------------------------------------

if( nargin < 1 )
  T = JD2T(Date2JD);
end

x = 23.439291 + ((5.03e-07*T - 1.6e-07)*T - 0.0130042)*T;
x = 1.e-6*floor(x*1.e6);


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-15 15:32:35 -0400 (Tue, 15 Mar 2016) $
% $Revision: 41893 $
