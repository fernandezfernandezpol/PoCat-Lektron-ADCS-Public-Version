function [v, f] = Cone( p, u, halfAngle, l, n, c )

%--------------------------------------------------------------------------
%   Compute the vertices for a cone.
%   The cone emanates from p and points in direction u. If no outputs are
%   specified the cone will be drawn in a new figure. alpha is transparency 
%   (0.5 means half transparent)
%
%   Type Cone for a demo.
%--------------------------------------------------------------------------
%   Form:
%   [v, f] = Cone( p, u, halfAngle, l, n, c )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   p            (3,1) Location of apex
%   u            (3,1) Cone axis unit vector
%   halfAngle    (1,1) Cone half angle (rad)
%   l            (1,1) Length of cone
%   n            (1,1) Number of divisions
%   color        (1,4) [red, green, blue, alpha]
%
%   -------
%   Outputs
%   -------
%   v            (:,3) Vertices
%   f            (:,3) Faces
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2007 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% Demo
%-----
if( nargin < 1 )
  Cone( [0;1;0], [1;0;0], 0.2, 2, 10, [1 0 0 0.5] );
  return;
end

if( nargin < 5 )
  n = [];
end

if( nargin < 6 )
  c = [];
end

if( isempty(n) )
  n = 10;
end

% Create the cone
%-----------------
rL = l*tan(halfAngle);

[v, f] = Frustrum( rL, 0, l, n, 1, 1 );

% Rotate the cone
%----------------
q  = U2Q( [0;0;1], u );

v  = QForm( q, v' )';

% Translate the cone
%-------------------
v  = v + DupVect(p',size(v,1));

% Default output
%---------------
if( nargout == 0 )
  NewFig('Patch')
  patch('vertices',v,'faces',f,'facecolor',c(1:3));
  alpha(c(4));
  axis equal
  XLabelS('x')
  YLabelS('y')
  ZLabelS('z')
  view(3)
  grid on
  rotate3d on
  s = 10*max(Mag(v'));
  light('position',s*[1 1 1])
  clear v
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
