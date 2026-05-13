function [x, y, z] = Ellipsd( a, b, c, n )

%--------------------------------------------------------------------------
%   Generates an ellipsoid using the equation
%
%     2      2    2
%    x     y     z
%   --- + --- + ---  = 1
%     2     2     2
%    a     b     c
%
%   Generates three n-by-n matrices so that surf(x,y,z) produces a
%   unit sphere.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [x, y, z] = Ellipsd( a, b, c, n )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   a                     x-axis coefficient
%   b                     y-axis coefficient
%   c                     z-axis coefficient
%   n                     Number of facets
%
%   -------
%   Outputs
%   -------
%   x         (n,n)       x matrix
%   y         (n,n)       y matrix
%   z         (n,n)       z matrix
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%  Copyright (c) 1996 Princeton Satellite Systems, Inc.
%  All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 4 )
  n = 20;
end

if( nargin == 0 )
  a = 1;
  b = 2;
  c = 3;
end

theta = linspace(0,2*pi,n)';
phi   = linspace(-pi/2,pi/2,n);

xX    = a*cos(theta)*cos(phi);
yX    = b*sin(theta)*cos(phi);
zX    = DupVect(c*sin(phi),n);

if( nargout == 0 )
  NewFig('Ellipsoid');
  surf(xX,yX,zX);
  Axis3D('equal')
  XLabelS('X')
  YLabelS('Y')
  ZLabelS('Z')
  TitleS(sprintf('a = %11.3e  b = %11.3e  c = %11.3e',a,b,c)); 
  grid
  grid
else
  x = xX;
  y = yX;
  z = zX;
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 10:18:42 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34945 $
