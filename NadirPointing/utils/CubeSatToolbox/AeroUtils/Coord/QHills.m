function [qEH,mEH] = QHills( rE, vE )

%--------------------------------------------------------------------------
%   Generate the quaternion that transforms from the ECI to the Hills frame.
%   The coordinates of the Hills frame are defined as:
%        x: Radial
%        z: Orbit-normal, or cross-track
%        y: Completes RHS (Along-track for circular orbits)
%
%   The relative position vector in the Frenet frame can be computed as:
%
%   rF = QForm( qEF, drE );
%
%   where dr is the relative position vector in the ECI frame. Or you may obtain 
%   the transformation matrix, mEF, as the second output. In this case, use:
%
%   rF = mEF*drE;
%--------------------------------------------------------------------------
%   Usages:
%   qEH       = QHills( rE, vE );
%   [qEH,mEH] = QHills( rE, vE );
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   rE          (3,n) Position vectors
%   vE          (3,n) Velocity vectors
%
%   -------
%   Outputs
%   -------
%   q          (4,n) Quaternions
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 2002 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

[rR,cR] = size(rE); 

x       = Unit( rE );
z       = Unit( Cross( rE, vE ) );
y       = Unit( Cross( z, x ) );

qX      = zeros(4,cR);
mX      = zeros(3,3*cR);

for k = 1:cR
   cols       = 3*k-2:3*k;
   mX(:,cols) = [x(:,k)'; y(:,k)'; z(:,k)'];
   qX(:,k)    = Mat2Q( mX(:,cols) );
end

if( nargout == 0 )
  Plot2D(1:cR,qX,'Sample','Quaternion','Q ECI To Hills');
else
  qEH = qX;
  mEH = mX;
end

% PSS internal file version information
%--------------------------------------
% $Date: 2012-08-01 18:03:29 -0400 (Wed, 01 Aug 2012) $
% $Revision: 30258 $
