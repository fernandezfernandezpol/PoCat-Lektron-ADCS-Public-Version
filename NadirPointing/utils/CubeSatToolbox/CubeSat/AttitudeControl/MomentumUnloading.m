function [tMM, m, angle] = MomentumUnloading( u, b, gain, h, tol )

%% Compute the torque from a magnetic momentum unloading system.
% Uses a pseudo-inverse control law. If the magnetic field is
% aligned the the momentum no control is possible and you will
% see a spike in the response.
%
% The dipole commands can be implemented by a linear control of the
% dipole current or by pulsewidth modulation.
%
% tMM = - gain*h
%
% But the torque is t = m x b
% where m is the dipole vector
%
% so m (u x b)m = - gain*h
%
% [uxb]m = -gain*h
%
% so
%
% m      = -gain pinv([uxb]) h
%
% tol prevents a dipole from being used that is too closely aligned
% with the magnetic field. 
%
% Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   [tMM, m, angle] = MomentumUnloading( u, b, gain, h, tol )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   u            (3,:)     Dipole unit vectors
%   b            (3,1)     B-Field (T)
%   gain         (3,1)     Proportional gain (N/Nms)
%   h            (3,1)     Momentum (Nms)
%   tol          (1,1)     Tolerance for using a dipole (default 0.2)
%
%   -------
%   Outputs
%   -------
%   tMM          (3,1)     Total torque
%   m            (:,1)     Dipole commands
%   angle        (1,1)     b dot h
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2010 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 5 )
    tol = 0.2;
end

bMag  = Mag(b);

b     = Unit(b);

t     = Cross(u,b);

n     = size(u,2);

j     = 0;

for k = 1:n
    if( Mag(t(:,k)) > tol )
        j    = j + 1;
        i(j) = k;
    end
end

t      = t(:,i);
mI    = -gain*pinv(t)*h/bMag;
angle =  acos(Dot(Unit(b),Unit(h)));

tMM   =  zeros(3,1);

for k = 1:size(t,2)
    tMM = tMM + mI(k)*t(:,k)*bMag;
end 

m     = zeros(n,1);

m(i)  =  mI;


% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 14:16:11 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41946 $
