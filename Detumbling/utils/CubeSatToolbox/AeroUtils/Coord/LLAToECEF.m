function rECEF = LLAToECEF( lla, rP )

%% Compute ECEF position from latitude, longitude, altitude.
% Assumes spherical planet.
%--------------------------------------------------------------------------
%   Form:
%   rECEF = LLAToECEF( lla, rP );
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   lla         (3,:)   Latitude [rad], longitude [rad], altitude [km]
%   rP          (1,1)   Radius of planet (for Earth: 6378.14) [km]
%                       
%
%   -------
%   Outputs
%   -------
%   rECEF       (3,1)   ECEF position vector [km]
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 2007 Princeton Satellite Systems, Inc. All rights reserved
%--------------------------------------------------------------------------

lat = lla(1,:);  % latitude  (rad)
lon = lla(2,:);  % longitude (rad)
h   = lla(3,:);  % altitude

rECEF = [(rP+h).*cos(lat).*cos(lon);...
   (rP+h).*cos(lat).*sin(lon);...
   (rP+h).*sin(lat)];

% NOTE: We expand this operation for speed. It is equilavent to:
% rECEF = RotMat(lon,3)*RotMat(-lat,2)*[rP+h;0;0];

%--------------------------------------------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:25:16 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41949 $
