function h = DrawCubeSat( v, f, d )

%% Draw a CubeSat with surface normals.
% The vertices and faces can be obtained from CubeSatModel. If d or d.surfData
% is input after the faces, it will draw surface normals.
%--------------------------------------------------------------------------
%   Form:
%   h = DrawCubeSat( v, f, d )
%   DrawCubeSat;               % Demo
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   v    	(:,3)   Vertices
%   f    	(:,3)   Faces
%   d   	 (.)    Data structure from the function RHSCubeSat
%                  .surfData  (.)  Surface data
%                      .nFace    (3,n) Face normals
%                      .rFace    (3,n) Face locations (m)
%
%   -------
%   Outputs
%   -------
%   h     (1,1)   Figure handle
%
%--------------------------------------------------------------------------
%   See also CubeSatModel, RHSCubeSat
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2016 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 2016.1
%--------------------------------------------------------------------------
%%

if nargin == 0
  d = CubeSatModel( 'struct' );
  [v, f, d] = CubeSatModel( [2 3 1], d );
  DrawCubeSat( v, f, d );
  return;
end

h = NewFig('CubeSat Model');
patch('vertices',v,'faces',f,'facecolor',[0.8 0.8 0.8]);
XLabelS('x')
YLabelS('y')
ZLabelS('z')
view(3)
grid on
rotate3d on
rF = [];
nF = [];
if nargin > 2
  if isfield(d,'surfData')
    rF = d.surfData.rFace;
    nF = d.surfData.nFace;
  elseif isfield(d,'rFace')
    rF = d.rFace;
    nF = d.nFace;
  end
end
if ~isempty(rF)
  hold on
  quiver3(rF(1,:),rF(2,:),rF(3,:),nF(1,:),nF(2,:),nF(3,:))
  TitleS('CubeSat with Surface Normals')
else
  TitleS('CubeSat Patches')
end
axis equal
rotate3d on


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-16 15:31:50 -0400 (Wed, 16 Mar 2016) $
% $Revision: 41914 $

