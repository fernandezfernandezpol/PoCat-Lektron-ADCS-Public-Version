function angle = HorizonAngle( rG, rS )

%% Angle between the horizon and a vector from rG to rS. 
% Angles below the  horizon are zero. Assumes the planet is a sphere.
%
% Type HorizonAngle for a demo.
%--------------------------------------------------------------------------
%   Form:
%   angle = HorizonAngle( rG, rS )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   rG             (3,1)  Position vector on ground
%   rS             (3,:)  Position vector in space
%
%   -------
%   Outputs
%   -------
%   angle          (1,:)  Horizon angle (rad)
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2001 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since version 5.5 (2003)
%--------------------------------------------------------------------------

% Demo
%-----
if( nargin < 2 )
	rG = [6378;0;0];
	a  = linspace(0,2*pi);
	rS = 6400*[cos(a);sin(a);zeros(1,length(a))];
    HorizonAngle( rG, rS );
    return;
end

uS = Unit( DupVect(rG,size(rS,2)) - rS );
uG = Unit( rG );

d  = uG'*uS;

angleX = acos( d ) - pi/2;

if( nargout == 0 )
	Plot2D(1:size(rS,2),angleX*180/pi,'Sample', 'Angle (deg)','HorizonAngle');
else
	angle = angleX;
end

% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:25:16 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41949 $
