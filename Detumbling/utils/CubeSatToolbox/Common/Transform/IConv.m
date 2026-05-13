function IMat = IConv( IVec )

%--------------------------------------------------------------------------
%   Transform a 6x1 compact inertia vector into a 3x3 inertia matrix.
%
%   Vector form:   [Ixx; Iyy; Izz; Ixy; Ixz; Iyz]
%
%--------------------------------------------------------------------------
%   Form:
%   IMat = IConv( IVec )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   IVec          (6,1)    Compact inertia vector
%
%   -------
%   Outputs
%   -------
%   IMat          (3,3)    Full inertia matrix
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2003 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

IMat = [IVec(1) IVec(4) IVec(5);IVec(4) IVec(2) IVec(6);IVec(5) IVec(6) IVec(3)];

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-23 14:53:10 -0400 (Wed, 23 Mar 2016) $
% $Revision: 42034 $
