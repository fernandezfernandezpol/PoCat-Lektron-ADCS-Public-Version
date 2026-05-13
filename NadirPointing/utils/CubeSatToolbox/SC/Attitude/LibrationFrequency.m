function s = LibrationFrequency( inertia, orbitRate )

%--------------------------------------------------------------------------
%   Compute the libration frequency from inertia and orbit rate.
%--------------------------------------------------------------------------
%   Form:
%   s = LibrationFrequency( inertia, orbitRate )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   inertia    (3,3)  Inertia matrix
%   orbitRate  (1,1)  Orbit rate
%
%   -------
%   Outputs
%   -------
%   s          (6,1)  Frequencies
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2002 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------


if( nargin < 1 )
  inertia = [];
end

if( nargin < 2 )
  orbitRate = 2*pi/VOrbit(6978);
end

if( isempty(inertia) )
  inertia        = diag([60 100 10]);
  n              = orbitRate;
  iX             = inertia(1,1);
  iY             = inertia(2,2);
  iZ             = inertia(3,3);
  a              = [[0 0 n;0 0 0;-n 0 0] eye(3);...
                    3*n^2*(iZ - iY)/iX 0 0 0 0 n*(iZ - iY)/iX;...
			  0 -3*n^2*(iX - iZ)/iY 0 0 0 0;...
			  0 0 0 n*(iY - iX)/iZ 0 0]
  [v, s] = eig(a);
  diag(s)
  abs(v)
end

a = Jacobian( @FGravityGradientStiffness, zeros(6,1), 0, inertia, orbitRate );

s = eig(a);


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-06-27 10:44:18 -0400 (Fri, 27 Jun 2014) $
% $Revision: 37982 $
