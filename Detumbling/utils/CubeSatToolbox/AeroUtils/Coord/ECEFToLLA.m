function lla = ECEFToLLA( rECEF, rP )

%% Compute latitude, longitude, altitude from ECEF position.
% Assumes spherical planet.
%--------------------------------------------------------------------------
%   Form:
%   lla = ECEFToLLA( rECEF, rP );
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   rECEF       (3,:)   ECEF position vector [km]
%   rP          (1,1)   Radius of planet (for Earth: 6378.14) [km]
%                       
%
%   -------
%   Outputs
%   -------
%   lla         (3,:)   Latitude [rad], longitude [rad], altitude [km]
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 2007 Princeton Satellite Systems, Inc. All rights reserved
%--------------------------------------------------------------------------

rMag = Mag(rECEF);
h = rMag-rP;
r = [rECEF(1,:)./rMag;rECEF(2,:)./rMag;rECEF(3,:)./rMag];
lat = asin(r(3,:));
lon = atan2(r(2,:),r(1,:));
lla = [lat;lon;h];

%--------------------------------------------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:25:16 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41949 $
