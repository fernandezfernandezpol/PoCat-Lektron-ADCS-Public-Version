function ICM = InertiaCM( I0, m, rCM )

%--------------------------------------------------------------------------
%   Compute the inertia about the CM given the inertia about point 0,
%   the position of the CM with respect to point 0, and the mass.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   ICM = InertiaCM( I0, m, rCM );
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   I0      (3,3)    Inertia about point 0 (kg-m^2)
%   m       (1,1)    Mass (kg)
%   rCM     (3,1)    Position of CM with respect to 0
%   
%   -------
%   Outputs
%   -------
%   ICM     (3,3)    Inertia about CM
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

ICM = I0 + m*SkewSq(rCM);

% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
