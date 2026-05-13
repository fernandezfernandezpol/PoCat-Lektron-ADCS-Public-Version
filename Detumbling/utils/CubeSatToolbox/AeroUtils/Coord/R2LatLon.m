function [lat, lon] = R2LatLon( x, y, z )

%% Computes geocentric latitude and longitude from r 
%
% Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [lat, lon] = R2LatLon( x, y, z )
%   [lat, lon] = R2LatLon( r )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x            (1,:)     X or [x;y;z]
%   y            (1,:)     Y
%   z            (1,:)     Z
%
%   -------
%   Outputs
%   -------
%   lat          (1,:)     Latitude (rad)
%   lon          (1,:)     East longitude (0 in xz-plane, +right hand rule
%                          about +z)  (rad)
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1993 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin == 3 )
  r = [x;y;z];
else
  r = x;
end

u    = Unit(r);
lon  = atan2( u(2,:), u(1,:) );
lat  = asin( u(3,:) );

if( nargout == 0 )
  Plot2D(lon*180/pi,lat*180/pi,'Longitude (deg)','Latitude (deg)','Latitude vs. Longitude');
  clear lat
end

% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:25:16 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41949 $
