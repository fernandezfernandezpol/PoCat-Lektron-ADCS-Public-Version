function PlaybackOrbitSim( time, object, planet, style )

%% Play back an orbit simulation of multiple objects with sensor cones.
% Utilizes AnimationGUI.
%
% Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   PlaybackOrbitSim( time, object, planet, style )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   time          (1,N)    Time vector. For display only. Use any units.
%   object         (:)     Data structure array of simulated objects in orbit
%                          See PackageOrbitDataForPlayback.m. Fields are:
%                             rEF: [3xN double] Earth fixed position (km)
%                             vEF: [3xN double] Earth fixed velocity (km/s)
%                             lat: [1xN double] Latitude (rad)
%                             lon: [1xN double] Longitude (rad)
%                               h: [1xN double] Altitude (km)
%                         coneFOV: [1xN double] Cone field of view (rad)
%                       conePitch: [1xN double] Cone pitch from nadir (rad)
%                     coneAzimuth: [Nx1 double] Cone azimuth from north (rad)
%                        coneAxis: [3xN double] Cone axis in Earth-fixed frame
%                          swathX: [NxP double] Swath curve, Earth-fixed x-coord.
%                          swathY: [NxP double] Swath curve, Earth-fixed y-coord.
%                          swathZ: [NxP double] Swath curve, Earth-fixed z-coord.
%                        swathLat: [NxP double] Swath curve, latitude
%                        swathLon: [NxP double] Swath curve, longitude
%   planet         (:)     Name of planet file to use (e.g. 'EarthHR')
%   style          (:)     '2D' or '3D'   
%                          NOTE: '2D' is not yet supported. To be supported
%                          in a future release.
%
%   -------
%   Outputs
%   -------
%   None
%
%   See also:  PackageOrbitDataForPlayback.m
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright 2009 Princeton Satellite Systems, Inc. All rights reserved.
%--------------------------------------------------------------------------

% built-in demo with two objects
%-------------------------------
if( nargin<1 )
   
   jD0         = Date2JD;
   sma         = 6800;
   el          = [sma, pi/4, 0, 0, 0, 0];
   T           = Period(sma);
   n           = OrbRate(sma);
   time        = 0:20:T*2;
   [r1,v1]     = RVFromKepler(el,time);
   coneFOV     = pi/4;
   conePitch   = pi/4*cos(n*time).^2;
   coneAzimuth	= 0;
   inputFrame  = 'ECI';
   
   object(1)   = PackageOrbitDataForPlayback( jD0, time, r1, v1, coneFOV, conePitch, coneAzimuth, inputFrame );
   
   el          = [sma, pi/4 + .08, 0, .08, 0, .05];
   [r2,v2]     = RVFromKepler(el,time);
   
   object(2)   = PackageOrbitDataForPlayback( jD0, time, r2, v2, coneFOV*0, conePitch, coneAzimuth, inputFrame );
   
   planet = 'EarthMR';
   style  = '3D';
   
end

nT   = length(time);
nObj = length(object);

% if no names are provided, add indexed names
%--------------------------------------------
if( ~isfield(object,'name') )
   for i=1:nObj
      object(i).name = ['Obj',int2str(i)];
   end
end

% if no colors are provided, create a color spread
if( ~isfield(object,'color') )
   
   colors = ColorSpread(nObj);
   for i=1:nObj
      object(i).color = colors(i,:);
      names{i} = object(i).name;
   end
   
   % add a legend for reference
   LegendFig(names,colors,'Playback Orbit Sim');
   
end
   
% prepare data for animation GUI
%-------------------------------
for i=1:length(object)
   scData(i).t = time;
   scData(i).c = DupVect(object(i).color,nT)';
   switch lower(style)
      case '3d'
         scData(i).r = object(i).rEF;
         scData(i).axis = object(i).coneAxis;
         scData(i).angle = object(i).coneFOV;
         scData(i).curveX = object(i).swathZ;
         scData(i).curveY = object(i).swathY;
         scData(i).curveZ = object(i).swathX;
      case '2d'
         scData(i).r = [object(i).lon; object(i).lat];
         scData(i).curveX = object(i).swathLon;
         scData(i).curveY = object(i).swathLat;
   end
end

tgtData = [];
options = struct('axisType',planet,'view',style,'docked',0);
AnimationGUI( 'initialize', scData, [], time, options );

return

g = get(findobj('tag','AnimationGUI'),'userdata');
set(g.axes,'cameraviewangle',3.5)
set(g.axes,'camerapositionmode','manual')



%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 14:16:11 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41946 $
