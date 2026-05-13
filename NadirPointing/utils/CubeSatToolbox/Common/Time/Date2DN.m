function dn = Date2DN( datetime )

%--------------------------------------------------------------------------
%   Compute the day number from the date. Uses the format from clock. If no
%   inputs are given it will compute the day number for the instant
%   of the function call.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   dn = Date2DN( datetime )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   datetime     (1,6) [year month day hour minute seconds]
%
%   -------
%   Outputs
%   -------
%   dn           (1,1) Day number
%
%--------------------------------------------------------------------------
%   References: Montenbruck, O., T.Pfleger, Astronomy on the Personal
%               Computer, Springer-Verlag, Berlin, 1991, p. 12.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993-2004 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin == 0 )
  datetime = clock;
else
  datetime = DTSToDTA( datetime );
end

if ( datetime(2) == 0 ),
  error('No zero month')
end
if ( datetime(3) == 0 ),
  error('No zero day')
end

dn = Date2JD(datetime)-Date2JD([datetime(1),1,1,0,0,0])+1;

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 11:30:23 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34969 $
