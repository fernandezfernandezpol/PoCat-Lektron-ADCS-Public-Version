%% Demonstrate a CubeSat attitude and power system dynamics.
% This simulation includes drag and radiation pressure. The only actuator 
% available for attitude is magnetic torquers, which is modeled as a 
% dipole. Performs an animation at the end which may take a few minutes.
% The satellite is initialized pointing to the Earth with a rotation equal
% to orbit rate, to nominally maintain that pointing. The z body axis is
% pointed towards the Earth (nadir).
%
% Things to try:
%   1. Turn surface disturbances off by uncommenting the line setting
%      d.surfData to empty; notice that the altitude no longer drops.
%   2. Initialize the battery charge b0 to zero
%   3. Comment out or change the fixed dipole in the for loop
%   4. Try a 1U instead of a 3U
%
% Since version 8.
%
%  ----------------------------------------------------------------------
%  See also AnimQ, QForm, Plot2D, TimeLabl, RK4, Skew, Date2JD, 
%  InertiaCubeSat, CubeSatAero, RHSCubeSat, CubeSatFaces, BDipole, 
%  SolarFluxPrediction
%  ----------------------------------------------------------------------
%%
%------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%------------------------------------------------------------------------

%% Select the CubeSat type
% The face areas and normals are needed by the aero model.  They are given
% by the CubeSatFaces function.
% -------------------------------------------------------------------------
close all; clear all;

cube = '1U';
[a,n,r] = CubeSatFaces( cube, 1 );

%% Time parameters
% Specify the simulation duration and timestep.
%----------------------------------------------
tic
orbits = 31;
dT     = 2; % sec

%% Constants
mu0                 = 4e-7*pi;
d.mu = mu0;

%% Start with defaults for the RHS
% RHSCubeSat will return a default data structure. The defaults are for a
% 1U CubeSat in orbit around the Earth. These will need to be modified for
% each simulation. CubeSats are 1 kg per unit (U).  The InertiaCubeSat
% function computes the inertia of a CubeSat assuming the mass is uniformly
% distributed throughout the volume.  This is usually a good first 
% approximation.
%--------------------------------------------------------------------------
Initial_date = [2018 1 1 0 0 0];
d      = RHSCubeSat;
d.jD0  = Date2JD(Initial_date); % Julian date
d.mass = 1.23; % kg
d.inertia0 = InertiaCubeSat( cube, d.mass );
rCM  = [0;0;0];
sat  = MassStructure(d.mass, d.inertia0, [0;0;0] );
mGG  = 0.1;
rGG  = [0;0;0.6];
Iboom = -mGG*SkewSq(rGG ); % point mass inertia
boom  = MassStructure(mGG, Iboom, rGG );
mass = AddMass( [sat boom] );
d.inertiaf = mass.inertia; % final inertia matrix with boom
d.inertia  = d.inertia;    % initial intertia matrix = non-deployed boom

% Conditions for boom deployment
max_theta = 30;         % max angle from nadir (deg) to deploy boom
max_omega = 1;          % max angular speed (deg/s) to deploy boom
deployed  = 0;          % flag to indicate if boom has been deployed

%% Initial State
% The state vector is [position;velocity;quaternion;angular velocity;
% battery state of charge]. We initialize in a circular orbit with the
% satellite aligned with LVLH: z towards nadir and x along velocity.
%--------------------------------------------------------------------------
a0 = 6378.165 + 400; % km
i0 = 51.6*pi/180;    % rad
el = [a0 i0 0 0 0 0];
[r0,v0] = El2RV( el );
q0 = QLVLH(r0,v0);
w0 = 5*pi/180*(2*[0;0;rand]-1);%5*[-OrbRate(a0);0;0]; % .001
b0 = 20000;
x = [r0;v0;q0;w0;b0];

PltOrbit( el, d.jD0 );
tEnd   = orbits*Period(a0); 
nSim   = floor(tEnd/dT);

%% Surface model
% Specify the surface model properties.  Used to calculate the forces on
% the CubeSat from drag and radiation pressure.
%--------------------------------------------------------------------------
d.surfData.cD    = 2.7; % coefficient of drag
d.surfData.nFace = n;
d.surfData.rFace = r; 
d.surfData.cM    = [0;0;0];
d.surfData.area  = a;
d.surfData.sigma = [1 1 1 1 1 1;zeros(2,6)];
d.surfData.att.type = 'eci';
%d.surfData       = []; % turns off surface disturbances
d.aeroModel      = @CubeSatAero;
d.opticalModel   = @CubeSatRadiationPressure;
d.skewOmegaEarth = Skew([0;0;7.291e-5]);

%% Power system model
% Specify solar cells on each face and the battery capacity. The six one's
% in solarCellArea indicate that this model has a solar cell completely
% covering all six faces of the CubeSat. If you changed one of the one's to
% a zero, then the model would have one face with no solar cell.
%--------------------------------------------------------------------------
d.power.solarCellNormal    = n;
d.power.solarCellEff       = 0.27;
d.power.effPowerConversion = 0.96*0.93;
d.power.solarCellArea      = 0.0063*[1 1 1 1 1 0];
d.power.consumption        = 0.9365 ;
d.power.batteryCapacity    = 37000*2; % J

%% Thermal model
% Specify properties of each face . 

d.uSurface   = [1  -1  0   0  0  0;...      % (3,6) Surface unit vectors
                0   0  1  -1  0  0;...
                0   0  0   0  1 -1];
            
alpha_GaAs = 0.88;  epsilon_GaAs = 0.80;    % Solar panel
alpha_gold = 0.25;  epsilon_gold = 0.02;    % Gold foil
alpha_silver = 0.37;epsilon_silver = 0.44;  % Silver foil
alpha_black = 0.95; epsilon_black = 0.85;   % black painting

alpha_side   = 0.62*alpha_GaAs + (1 - 0.62 - 2*0.6*10/100)*alpha_gold + (2*0.6*10/100)*alpha_black;
alpha_top    = 0.62*alpha_GaAs + (1 - 0.62 - 4*0.6*0.6/100)*alpha_gold + 4*0.6*0.6/100*alpha_black;
alpha_bottom = (1 - 4*0.6*0.6/100)*alpha_gold + 4*0.6*0.6/100*alpha_black;

epsilon_side   = 0.62*epsilon_GaAs + (1 - 0.62 -2*0.6*10/100)*epsilon_gold + (2*0.6*10/100)*epsilon_black;
epsilon_top    = 0.62*epsilon_GaAs + (1 - 0.62 - 4*0.6*0.6/100)*epsilon_gold + 4*0.6*0.6/100*epsilon_black;
epsilon_bottom = (1 - 4*0.6*0.6/100)*epsilon_gold + 4*0.6*0.6/100*epsilon_black;

d.alpha      =  [alpha_side alpha_side alpha_side alpha_side alpha_bottom alpha_top];                     % {1,6} Absorptivity
d.epsilon    =  [epsilon_side epsilon_side epsilon_side epsilon_side epsilon_bottom epsilon_top];         % {1,6} Emissivity
d.area       = 0.1*0.1*ones(1,6);           % (1,6) Area
d.cP         = 900;                         % (1,1) Specific heat
d.powerTotal = d.power.consumption;         % (1,1) Internal power (W)
T0           = 25 + 273.15;                 % Initial temperature [K]
%% Solar flux
% Get the solar flux predictions for the atmospheric density model.  The
% atmospheric density model used is Jacchia's 1970 model.  See the function 
% AtmJ70 for more information. To use AtmDens2 instead of AtmJ70, set 
% d.atm to empty (d.atm = []).
%--------------------------------------------------------------------------
[aP, f, fHat, fHat400] = SolarFluxPrediction( d.jD0, 'nominal' );
d.atm.aP      = aP(1); 
d.atm.f       = f(1); 
d.atm.fHat    = fHat(1); 
d.atm.fHat400 = fHat400(1);

%% Planet
% Specify the planet we are orbiting and its radius.
%---------------------------------------------------
d.planet = 'earth';
d.rP = 6378.165;

%% Initialize control
% This variable will be used in the control loop to specify the Bdot control for
% each timestep. For now, start with zero.
%------------------------------------------
d.dipole = [0;0;0];
kd = 1000000;
dipole_max_x = 0.2; % A*m^2 Max dipole moment of X-axis MTQ
dipole_max_y = 0.2; % A*m^2 Max dipole moment of Y-axis MTQ
dipole_max_z = 0.2; % A*m^2 Max dipole moment of Z-axis MTQ
d.dipole_bias = dipole_max_z*[0; 0; 0.25];

%% Initialize the plotting array to save time
% Preallocates memory for the plotting variables.
% -----------------------------------------------
xPlot = [x zeros(14,nSim)];
[xT, dist,power] = RHSCubeSat( x, 0, d );
dragPlot  = [dist.fAerodyn zeros(3,nSim)];
radPlot   = [dist.fOptical zeros(3,nSim)];
tRadPlot   = [dist.tOptical zeros(3,nSim)];
tAeroPlot = [dist.tAerodyn zeros(3,nSim)];
tMagPlot  = [dist.tMag zeros(3,nSim)];
tGGPlot   = [dist.tGG zeros(3,nSim)];
powerPlot = [power zeros(1,nSim)];
bPlot     = zeros(3,nSim+1);
qPlot     = zeros(4,nSim+1);
P_MTQ_totx = zeros(1,nSim+1);
P_MTQ_toty = zeros(1,nSim+1);
P_MTQ_totz = zeros(1,nSim+1);
deployment = zeros(1,nSim+1);

%% Run the simulation
%--------------------
t = 0;
h = waitbar(0,'CubeSat Simulation');
upF = ceil(nSim/20);
kW = 1;
p.bFieldBody_old = [0; 0; 0];

for k = 1:nSim
    
    % Magnetic field - the magnetometer output is proportional to this
    %-----------------------------------------------------------------
    % Current Julian date
%--------------------
jD              = d.jD0 + t/86400;
    % Magnetic field
%---------------
r = x(1:3);
v = x(4:6);
q = x(7:10);
w = x(11:13);
[bFieldECI, bFieldDotECI]	= BDipole(r,jD,v);

%     bField       = BDipole( x(1:3), d.jD0+t/86400 );
p.bFieldBody	  = QForm(q,bFieldECI);
Bdot              = (p.bFieldBody - p.bFieldBody_old)./dT;
p.bFieldBody_old  = p.bFieldBody;
p.bFieldECI     = bFieldECI;
p.bFieldDotECI  = bFieldDotECI;

    % Control system placeholder - apply constant dipole
    %---------------------------------------------------
    d.dipole     = -kd*diag(d.inertia).*Bdot + d.dipole_bias; % Amp-turns m^2
    % Limit maximum dipole to the maximum that MTQ can provide
    if abs(d.dipole(1)) > dipole_max_x
        d.dipole(1) = sign(d.dipole(1)).*dipole_max_x;
    end
    if abs(d.dipole(2)) > dipole_max_y
        d.dipole(2) = sign(d.dipole(2)).*dipole_max_y;
    end
    if abs(d.dipole(3)) > dipole_max_z
        d.dipole(3) = sign(d.dipole(3)).*dipole_max_z;
    end
    
    P_MTQ_totx(k+1) = 0.4*(abs(d.dipole(1)) + 0*abs(d.dipole(2)) + 0*abs(d.dipole(3)))*5; % 1.2W max full actuation 3 axes, 5 V
    P_MTQ_toty(k+1) = 0.4*(0*abs(d.dipole(1)) + abs(d.dipole(2)) + 0*abs(d.dipole(3)))*5; % 1.2W max full actuation 3 axes, 5 V
    P_MTQ_totz(k+1) = 0.4*(0*abs(d.dipole(1)) + 0*abs(d.dipole(2)) + abs(d.dipole(3)))*5; % 1.2W max full actuation 3 axes, 5 V

    %         m_ideal = -kd*diag(d.inertia)*Bdot;%Ideal magnetic moment
%         control = cross(m_ideal,mag_read(i,:))';
    

p.torqueDipole	= Cross(d.dipole,p.bFieldBody);

% Orbit dynamics
%---------------
vDot = -mu0*r/Mag(r)^3;
p.torqueDamper = [0;0;0];

% Attitude dynamics
%------------------
wDot = d.inertia\(p.torqueDamper + p.torqueDipole - Cross(w,d.inertia*w));
    
    % A time step with 4th order Runge-Kutta
    %---------------------------------------
    x = RK4( @RHSCubeSat, x, dT, t, d );
    
    % Obtain effect of disturbances and control
    %------------------------------------------
    [xT, dist,power] = RHSCubeSat( x, t, d );
    dragPlot(:,k+1) = dist.fAerodyn;
    tAeroPlot(:,k+1) = dist.tAerodyn;
    radPlot(:,k+1) = dist.fOptical;
    tRadPlot(:,k+1) = dist.tOptical;
    tMagPlot(:,k+1) = dist.tMag;
    tGGPlot(:,k+1) = dist.tGG;
    powerPlot(:,k+1) = power;
    bPlot(:,k+1) = bFieldECI;
    qLVLH = QLVLH(r,v);
    qPlot(:,k+1) = QMult(QPose(qLVLH),q);
    
    mm = Q2Mat( qPlot(:,k+1) );
    thetam= acosd(mm(3,3));
    if thetam < max_theta & max(abs(x(11:13))) < max_omega*pi/180 & ~deployed;
        d.inertia = d.inertiaf;
        d.dipole_bias = [0; 0; 0];
        deployed = 1;
    end
    deployment(1,k+1) = deployed;
    
    % Update plotting and time
    %-------------------------
    xPlot(:,k+1) = x;
    t            = t + dT;
    
    if k/upF >= kW
      waitbar(k/nSim,h);
      kW = kW + 1;
    end
end
close(h);

%% Plotting
%----------
time     = (0:nSim)*dT;
[tP, tL] = TimeLabl( time );

% Y-axis labels
%--------------
yL = {'r_x (km)' 'r_y (km)' 'r_z (km)' 'v_x (km/s)' 'v_y (km/s)' 'v_z (km/s)'...
      'q_s' 'q_x' 'q_y' 'q_z' '\omega_x (rad/s)' '\omega_y (rad/s)' '\omega_z (rad/s)' 'b (Wh)'};

GroundTrack( xPlot( 1: 3,:), time, d.jD0 );
rMag = Mag(xPlot( 1: 3,:));
Plot2D( tP, rMag-rMag(1), tL, '\Delta h km', 'Change in Altitude' );

Plot2D( tP, xPlot(7:10,:), tL, {yL{ 7:10}}, 'CubeSat ECI To Body Quaternion' );
Plot2D( tP, qPlot, tL, {yL{ 7:10}}, 'CubeSat LVLH To Body Quaternion' );
Plot2D( tP, xPlot(11:13,:), tL, {yL{11:13}}, 'CubeSat Attitude Rate (rad/s)' );
Plot2D( tP, [xPlot(14,:)/3600;powerPlot], tL,  {yL{14},'Power (W)'},  'CubeSat Power System' );

Plot2D( tP, dragPlot*1e3,    tL,  {'F_x (mN)', 'F_y (mN)', 'F_z (mN)'}, 'CubeSat Drag Force (mN)' );
Plot2D( tP, tAeroPlot*1e6,   tL,  {'T_x (uNm)','T_y (uNm)','T_z (uNm)'},'CubeSat Aerodynamic Torques')
Plot2D( tP, tMagPlot*1e6,    tL,  {'T_x (uNm)','T_y (uNm)','T_z (uNm)'},'CubeSat Magnetic Torques')
Plot2D( tP, tGGPlot*1e6,     tL,  {'T_x (uNm)','T_y (uNm)','T_z (uNm)'},'CubeSat Gravity Gradient Torques')
Plot2D( tP, radPlot*1e3,     tL,  {'F_x (mN)','F_y (mN)','F_z (mN)'},'CubeSat Radiation Force (mN)')
Plot2D( tP, tRadPlot*1e6,    tL,  {'T_x (uNm)','T_y (uNm)','T_z (Nm)'},'CubeSat Radiation Torques')
Plot2D( tP, bPlot,           tL,  {'B_x (T)','B_y (T)','B_z (T)'},'Magnetic Field (ECI Frame)')

for kk=1:length(qPlot(1,:))
    m = Q2Mat( qPlot(:,kk) );
    theta(kk) = acosd(m(3,3));
end
figure
plot(tP, theta); xlabel('Time [hours]'); ylabel('Angle antenna boresight - nadir [deg]');
grid

r = xPlot(1:3,:);
q = xPlot(7:10,:);
jD= d.jD0 + time/86400;
Temp = IsothermalCubeSatSim( d, r, q, jD, T0 );
figure
plot(tP, Temp -  273.15); xlabel('Time [hours]'); ylabel('Average Temperature [ºC]');
grid
 
figure
plot(tP, P_MTQ_totx,'r'); hold on; plot(tP, P_MTQ_toty,'g'); plot(tP, P_MTQ_totz,'b'); xlabel('Time [hours]'); ylabel('[W]'); title('Power MTQ [W]');
grid

Figui;
save todo.mat
% % % pause
% % % %% Animate ALL
% % % %-------------------------------
% % % AnimQ( qPlot(:,:) );
toc


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-29 14:46:53 -0400 (Tue, 29 Mar 2016) $
% $Revision: 42111 $
