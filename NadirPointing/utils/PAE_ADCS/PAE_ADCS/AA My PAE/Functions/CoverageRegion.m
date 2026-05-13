% CoverageRegion

% satellite coordinates
 lat = 40*pi/180; % latitude (rad)
 lon = 2*pi/180; % longitude (rad)
 h = 500; % altitude (km)

 % sensor cone attributes
 pitch = 25*pi/180;
 halfFOV = 40*pi/180;
 azim = 60*pi/180;

 % compute swath and create plot
 RapidSwath(lat, lon, h, halfFOV, pitch, azim);

 PrintFig(0,1,1,'CoverageRegion')