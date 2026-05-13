function GroundTrack( r, t, jD0 )

%% Plot an orbit track. Converts the inertial positions to planet-fixed.
% Had a built-in demo showing an Earth orbit. Pass in the time array and
% the initial epoch. The epoch may be a Julian date or a datetime array.
% The initial position is marked with an 'o'.
%
% Since version 2014.1
% See also ECIToEF, R2LatLon, Date2JD, EarthMR.mat
%--------------------------------------------------------------------------
%   Form:
%   GroundTrack( r, t, jD0 )
%   GroundTrack( r, t, datetime )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   r                (3,:) ECI position vectors (km)
%   t                (1,:) Time array (sec)
%   jD0              (1,1) Epoch Julian date
%             -or- 
%   datetime         (1,6) [year month day hour minute seconds]
%
%   -------
%   Outputs
%   -------
%   none   
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	 Copyright 1995-1999, 2014 Princeton Satellite Systems, Inc. 
%  All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 2 )
  % Built-in demo
  p         = Period(9000);
  [r, v, t] = RVFromKepler( [9000 pi/4 0 0 0.2 0], linspace(0,4*p,400) );
  jD0       = JD2000;
  GroundTrack( r, t, jD0 );
  return;
end
if nargin < 3
  % Use today's date as a default
  jD0 = Date2JD;
end
if length(jD0)>1
  jD0 = Date2JD( jD0 );
end

% Array of Julian century
%------------------------
T = JD2T(jD0 + t/86400);

% Transform to the planet fixed frame
%------------------------------------
[rR,cR] = size(r);
for k = 1:cR;
  r(:,k) = ECIToEF( T(k) )*r(:,k);
end

d = load('EarthMR');
p = Map(d.planet);

[lat,lon] = R2LatLon(r);  
lat       = lat*180/pi;
lon       = lon*180/pi; 
lLon      = length(lon);
kLon      = [0 find(abs(lon(2:lLon) -lon(1:(lLon-1))) > 300 ) lLon];

h = NewFig('Ground Track');
[xdim,ydim]=size(p.planetMap);
plot(0,0), hold on
axis([-180 180 -90 90])
x=linspace(-180,180,xdim);
y=linspace(90,-90,ydim);
im = image(x,y,p.planetMap);
colormap(p.planetColorMap)
axis equal, axis tight
XLabelS('East Longitude (deg)')
YLabelS('Latitude (deg)')
lK = length(kLon);
for i = 2:lK
  range = (kLon(i-1)+1):kLon(i); 
  plot(lon(range),lat(range),'y');
end
plot(lon(1),lat(1),'yo');
grid on
hold off


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 14:16:11 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41946 $
