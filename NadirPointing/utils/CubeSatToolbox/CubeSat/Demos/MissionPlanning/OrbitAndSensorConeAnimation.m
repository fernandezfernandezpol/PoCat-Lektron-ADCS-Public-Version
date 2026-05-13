%% Demonstrate the playback of multiple orbits and moving sensor cones.
%
%   Since version 8.
%  ------------------------------------------------------------------------
%  See also PackageOrbitDataForPlayback and PlaybackOrbitSim., Date2JD, 
%  OrbRate, Period, RVFromKepler
%  ----------------------------------------------------------------------
%%
%------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%------------------------------------------------------------------------

%% Define epoch and simulate orbit
%--------------------------------
jD0         = Date2JD;
sma         = 6800;
el          = [sma, pi/4, 0, 0, 0, 0];
T           = Period(sma);
n           = OrbRate(sma);
time        = 0:20:T*2;
[r1,v1]     = RVFromKepler(el,time);

%% Define sensor attributes
%-------------------------
coneFOV     = pi/4;
conePitch   = pi/4*abs(cos(n*time));
coneAzimuth	= 0;
inputFrame  = 'ECI';

%% Package orbit data for satellite 1
%------------------------------------
object(1)   = PackageOrbitDataForPlayback( jD0, time, r1, v1,...
                             coneFOV, conePitch, coneAzimuth, inputFrame );

%% simulate second orbit
%----------------------
el          = [sma, pi/4 + .08, 0, .08, 0, .05];
[r2,v2]     = RVFromKepler(el,time);

%% Package orbit data for satellite 2
%------------------------------------
object(2)   = PackageOrbitDataForPlayback( jD0, time, r2, v2,...
                           coneFOV*0.2, conePitch, coneAzimuth, inputFrame );

%% Load data into AnimationGUI using PlaybackOrbitSim
%----------------------------------------------------
planet = 'EarthMR';
style  = '3D';
PlaybackOrbitSim( time, object, planet, style )



%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 11:19:43 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39864 $
