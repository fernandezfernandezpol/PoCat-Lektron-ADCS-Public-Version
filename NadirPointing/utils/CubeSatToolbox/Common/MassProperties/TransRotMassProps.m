function [m0,TP0] = TransRotMassProps( mA, rA, T0A )

%--------------------------------------------------------------------------
%   Translate and rotate mass properties to a new coordinate system. 
%   Mass properties in "mA" are defined in its local coordinate frame.
%   Inertia is defined about principal axes. Rotation from frame mA to mA's
%   principal axes is defined by inputs (axisPA,anglePA)
%   
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   [m0,TP0] = TransRotMassProps( mA, rA, T0A )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   mA          (.)    Mass data structure in frame A
%                      .mass        (1,1) Mass
%                      .cM          (3,1) Center-of-mass
%                      .inertiaP    (3,1) Principal moments of inertia
%                      .P           (3,3) Rotation matrix for principal axes
%                      .inertiaCM   (3,3) Inertia matrix about CM, in frame A
%   rA           (3,1)   Position vector of frame A origin in frame 0
%   T0A          (3,3)   Rotation matrix from frame 0 to frame A
%   
%   -------
%   Outputs
%   -------
%   m0          (:)    Mass data structure in frame 0
%                      .mass        (1,1) Mass
%                      .cM          (3,1) Center-of-mass
%                      .inertiaP    (3,1) Inertia matrix about CM, along principal axes
%                      .P           (3,3) Rotation matrix for principal axes
%                      .inertiaCM   (3,3) Inertia matrix about CM, in frame 0
%                      .inertia     (3,3) Inertia matrix about point 0, in frame 0
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% mass is equivalent
m0.mass = mA.mass;

% transformation matrix from frame A to frame P (principal axes of inertia)
TAP      = mA.P;

% center of mass in frame 0
m0.cM = rA + T0A'*mA.cM;

% transformation matrix from frame 0 to frame P
T0P  = TAP*T0A;

% transformation matrix from frame P to frame 0
TP0  = T0P';

% support different possible formats for inertia
[m,n] = size(mA.inertiaP);
if( m*n == 9 )
   inr = mA.inertiaP;
elseif( m*n == 6 )
   inr = IConv( mA.inertiaP );  % convert 6x1 vector to 3x3 matrix representation
elseif( m*n == 3 )
   inr = diag(mA.inertiaP);     % convert 3x1 diagonal vector to 3x3 matrix
else
   warning('unsupported format for inertia matrix')
end

% retain principal moments of inertia
m0.inertiaP = mA.inertiaP;

% update principal axes to be defined with respect to frame 0
m0.P        = T0P;

% ASSUMING P matrix rotates from A frame to principal axes...
% moment of inertia about CM in frame 0
m0.inertiaCM = TP0*inr*TP0';

% moment of inertia about point 0 in frame 0
m0.inertia = m0.inertiaCM - mA.mass*SkewSq(m0.cM);

% store the rotation matrix from 0 to A
m0.R = T0A;

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
