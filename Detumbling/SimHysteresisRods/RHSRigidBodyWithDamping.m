function [xDot, p] = RHSRigidBodyWithDamping( x, t, d )

%------------------------------------------------------------------------
%   Rigid body dynamics with damping.
%
%   d.dampingFun is of the form
%
%     DampingFun( x, jD, bFieldBody, d )
%
%   where d is the damping data.
%
%   Since version 2014.1
%------------------------------------------------------------------------
%   Form:
%   [xDot, p] = RHSRigidBodyWithDamping( x, t, d )
%------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x       (13+n,1)	[r;v;q;omega;z] 
%   t       (1,1)       Time since start (s)
%   d       (1,1)       Data structure
%                       .inertia        (3,3) Spacecraft inertia (kg-m^2)
%                       .dampingFun     (1,1) Handle to the damping function
%                       .dampingData    (1,1) Damping function data
%                       .dipole         (3,1) Fixed dipole
%
%
%   -------
%   Outputs
%   -------
%   xDot    (13+n,1)	Right hand side
%   p       (1,1)     Data structure
%                       .torqueDamper   (3,1) Damper torque   (Nm)
%                       .torqueDipole   (3,1) Dipole torque	(Nm)
%                       .bfieldBody     (3,1) Magnetic field  (T)
%                       .bfieldECI      (3,1) Magnetic field  (T)
%
%------------------------------------------------------------------------
 
%------------------------------------------------------------------------
%   Copyright (c) 2014 Princeton Satellite Systems, Inc.
%   All rights reserved.
%------------------------------------------------------------------------

% Local variables
%----------------
r               = x( 1: 3);
v               = x( 4: 6);
q               = x( 7:10);
w               = x(11:13);

% Current Julian date
%--------------------
jD              = d.jD0 + t/86400;

% Magnetic field
%---------------
[bFieldECI, bFieldDotECI]	= BDipole(r,jD,v);

% Damper states if needed
%------------------------
if( d.dampingType == 2 )
    [zDot, p]       = feval( d.dampingFun, x, bFieldECI, bFieldDotECI, d.dampingData );
elseif( d.dampingType == 1 )
    zDot            = [];
    p.torqueDamper 	= -d.dampingData*w;
end

p.bFieldBody	= QForm(q,bFieldECI);
p.bFieldECI     = bFieldECI;
p.bFieldDotECI  = bFieldDotECI;
p.torqueDipole	= Cross(d.dipole,p.bFieldBody);

% Orbit dynamics
%---------------
vDot = -d.mu*r/Mag(r)^3;

% Attitude dynamics
%------------------
wDot = d.inertia\(p.torqueDamper + p.torqueDipole - Cross(w,d.inertia*w));

% The derivative vector
%----------------------
xDot = [v;vDot;QIToBDot(q,w);wDot;zDot];


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-11 14:11:51 -0400 (Wed, 11 Mar 2015) $
% $Revision: 39857 $
