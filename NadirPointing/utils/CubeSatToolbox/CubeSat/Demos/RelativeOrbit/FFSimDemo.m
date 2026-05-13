%% Demonstrate the use of FFSim to analyze disturbance effects.
%
%   Since version 8.
%  ------------------------------------------------------------------------
%  See also FFSim, FFSimPlotter, Goals2DeltaElem
%  ------------------------------------------------------------------------
%%
%--------------------------------------------------------------------------
%	Copyright 2009 Princeton Satellite Systems, Inc. All rights reserved.
%--------------------------------------------------------------------------

if( ~exist('FormationFlying/Transformation/Goals2DeltaElem') )
  warning('This demo requires the Formation Flying Module.')
  return
end

%% Initialize simulation data structure

% Reference orbital elements [a, theta, i, q1, q2, W]
%  a        semi major axis
%  theta    latitude (perigee + true anomaly)
%  i        inclination
%  q1       e*cos(w), e is eccentricity, w is perigee
%  q2       e*sin(w)
%  W        right ascension
clear s;
s.el0       = [6928.14 0 0.617846555205993 0 0 0];

% Choose desired relative motion to be 250 m relative ellipse
s.goals.y0 = 0;      % center of ellipse in along-track direction
s.goals.aE = .25;    % size of ellipse
s.goals.beta = 0;    % phase on ellipse at equator crossing
s.goals.zInc = .1;   % cross-track oscillation (inclination difference)
s.goals.zLan = -.1;  % cross-track oscillation (right ascension difference)

% initialize relative state to achieve desired relative motion
s.dEl0      = Goals2DeltaElem( s.el0, s.goals );

% other simulation options
s.nOrbits   = 5;
s.nSPO      = 300;
s.distOpt   = [1 1 1];
s.area      = [1 .5];
s.mass      = [50 10];


%% Simulate 
d = FFSim(s);

%% View results...
FFSimPlotter( d );


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 11:19:43 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39864 $
