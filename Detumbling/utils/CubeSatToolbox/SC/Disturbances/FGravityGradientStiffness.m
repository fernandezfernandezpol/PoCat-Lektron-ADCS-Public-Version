function [xDot, tGG] = FGravityGradientStiffness( x, t, inertia, orbitRate )

%--------------------------------------------------------------------------
%   Gravity gradient for a rigid body with small offsets from LVLH. 
%   The spacecraft is aligned with LVLH with orbit rate is about the -y axis. 
%   This model is valid only for small angles about LVLH.
%--------------------------------------------------------------------------
%   Form:
%   [xDot, tGG] = FGravityGradientStiffness( x, t, inertia, orbitRate )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x          (6,1)  [roll;pitch;yaw;xRate;yRate;zRate]
%   t          (1,1)  time
%   inertia    (3,3)  Inertia matrix
%   orbitRate  (1,1)  Orbit rate
%
%   -------
%   Outputs
%   -------
%   xDot       (6,1)  State derivative
%   tGG        (3,1)  Gravity gradient torque
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2000 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

theta    = x(1:3);
nu       = [0;-orbitRate;0];
w        = x(4:6) + nu;

c        = eye(3) - Skew(theta);
u        = c*[0;0;-1];
thetaDot = x(4:6) - c*nu;
tGG      = 3*orbitRate^2*Cross(u,inertia*u);

xDot     = [thetaDot;inertia\(-Cross(w,inertia*w) + tGG)];

% PSS internal file version information
%--------------------------------------
% $Date: 2015-07-07 11:19:00 -0400 (Tue, 07 Jul 2015) $
% $Revision: 40386 $
