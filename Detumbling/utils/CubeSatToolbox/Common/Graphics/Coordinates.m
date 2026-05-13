function h = Coordinates(m)

%--------------------------------------------------------------------------
%   Creates a figure with x,y,z coordinates at the origin.
%   The figure has a black background and white axes.
%--------------------------------------------------------------------------
%   Form:
%   h = Coordinates( m )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   m             (1)     Magnitude of each axis
%   
%
%   -------
%   Outputs
%   -------
%   h             (1)     Figure handle
%
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
%   Copyright (c) 2003 Princeton Satellite Systems, Inc.
%   All rights reserved.
%------------------------------------------------------------------------

if( nargin < 1 )
   m = 1;
end

h = figure;

plot3([0 m],[0 0],[0 0],'b-','linewidth',2), hold on
plot3([0 0],[0 m],[0 0],'g-','linewidth',2)
plot3([0 0],[0 0],[0 m],'r-','linewidth',2)

plot3(m,0,0,'b.','markersize',20)
plot3(0,m,0,'g.','markersize',20)
plot3(0,0,m,'r.','markersize',20)

set(h,'color','black');
set(gca,'color','black')
set(gca,'ycolor','white','xcolor','white','zcolor','white')
xlabel('x','fontsize',16,'color','blue'), ylabel('y','fontsize',16,'color','green'), zlabel('z','fontsize',16,'color','red','rotation',0)
axis equal
axis([-m m -m m -m m])
grid on
rotate3d on


% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-31 10:58:55 -0400 (Tue, 31 Jul 2012) $
% $Revision: 30218 $
