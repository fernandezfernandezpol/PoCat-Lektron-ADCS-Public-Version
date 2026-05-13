function hDot = RHSMomentum( h, t, torque )

%% RHS for momentum in the inertial frame.
% dh/dt = torque
%
% Since version 9.
%--------------------------------------------------------------------------
%   Form:
%   hDot = RHSMomentum( h, t, torque )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   h            (3,1)     Angular momentum
%   t            (1,1)     Time (unused)
%   torque       (3,1)     Torque vector
%
%   -------
%   Outputs
%   -------
%   hDot         (4,1)     Momentum derivative
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2010 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%%

hDot = torque;


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-16 14:54:29 -0400 (Wed, 16 Mar 2016) $
% $Revision: 41910 $
