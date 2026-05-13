function jDMid = JDToMidnight( jD )

%--------------------------------------------------------------------------
%   Converts a Julian date to the nearest midnight.
%
%   Since version 10.
%--------------------------------------------------------------------------
%   Form:
%    jDMid = JDToMidnight( jD )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   jD           (:)  Julian date
%
%   -------
%   Outputs
%   -------
%   jDMid        (:)  Julian midnights
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	 Copyright (c) 2012 Princeton Satellite Systems, Inc.
%    All rights reserved.
%--------------------------------------------------------------------------

% Demo
%-----
if( nargin < 1 )
    JDToMidnight( JD2000 + 0.8 )
    JDToMidnight( JD2000 + 0.2 )
    return
end
    

jDFloor = floor(jD);

dJD = jD - jDFloor;

if( dJD >= 0.5 )
    jDMid = jDFloor + 0.5;
else
    jDMid = jDFloor - 0.5;
end

% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
