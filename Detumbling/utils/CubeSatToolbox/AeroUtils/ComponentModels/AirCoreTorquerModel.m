function [v, f] = AirCoreTorquerModel( nTurns, rWire, dims )

%% Draw an air core magnetic torquer.
%
% Type AirCoreTorquerModel for a demo.
%--------------------------------------------------------------------------
%   Form:
%   [v, f] = AirCoreTorquerModel( nTurns, rWire, dims )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   nTurns      (1,1) Wire turns
%   rWire       (1,1) Wire radius (m) 
%   dim         (1,2) Dimensions of the coil (m)
%
%   -------
%   Outputs
%   -------
%   v           (:,3) Vertices
%   f           (:,3) Faces
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2014 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% Demo 
%------
if( nargin  < 1 )
  AirCoreTorquerModel( 950, 0.00025, [0.1 0.1] );
	return
end

% Make four boxes
%----------------
areaWire  = nTurns*pi*rWire^2;
z         = sqrt(areaWire);
x         = dims(1);
y         = dims(2);
[vX, fX]	= Box( x,   z, z );
[vY, fY]	= Box( z, y-z, z );

vX(:,2)   = vX(:,2) + y/2;

v         = vX;
f         = fX;

vX(:,2)   = vX(:,2) - y;

f         = [f;fX+size(v,1)];
v         = [v;vX];

vY(:,1)   = vY(:,1) + x/2 - z/2;

f         = [f;fY+size(v,1)];
v         = [v;vY];

vY(:,1)   = vY(:,1) - x + z;

f         = [f;fY+size(v,1)];
v         = [v;vY];

% Default output is to draw the picture
%--------------------------------------
if( nargout == 0 )
  NewFig('Air Core Magnetic Torquer')
  patch('vertices',v,'faces',f,'facecolor',[0.5 0.5 0.5]);
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
% $Date: 2016-03-18 18:12:31 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41962 $
