%% Demonstrate CubeSat attitude and power system dynamics.
close all
clear all


% The model includes 3 orthogonal reaction wheels. The satellite is
% intialized into a polar orbit. The control law keeps the satellite
% aligned with the magnetic field, which results in flips at the poles.
%
% -------------------------------------------------------------------------
%  See also PIDMIMO, QForm, QTForm, CreateLatexTable, 
%  LatexScientificNotation, SaveStructure, Plot2D, TimeLabl, Dot, RK4, Unit, 
%  Date2JD, InertiaCubeSat, RHSCubeSatRWA, BDipole, PID3Axis
% -------------------------------------------------------------------------
%%
%------------------------------------------------------------------------
%   Copyright (c) 2009-2010,2016 Princeton Satellite Systems, Inc.
%   All rights reserved.
%------------------------------------------------------------------------
%   Since version 9 (2010).
%   2016.1 Add display of solar area with DrawCubeSatSolarAreas.
%------------------------------------------------------------------------

clear g; clear u; clear p; clear d; close all; 

%% Constants
%-----------
radToDeg        = 180/pi;
densitySilicon  = 2600;
densityAl       = 2700; % Aluminum
densityTungsten = 19300;

%% Simulation parameters
%-----------------------
days  = 0.1;
tEnd  = days*86400; 
dT    = 1;
nSim  = ceil(tEnd/dT);

%% CubeSat Initialize
Data_CubeSat_Config_File

%% Thermal Control
Thermal_Control_Config_File;

%% Initial state vector for a circular orbit
%------------------------------------------
a    = 6387.165+800; % km
v    = VOrbit(a);

r    = [a;0;0];                 % Position vector
v    = [0;0;v];                 % Velocity vector - polar orbit
q    = [1;0;0;0];               % Quaternion
w    = pi/180*(2*[0;0;rand]-1);                 % Angular rate of spacecraft
c    = [0;0;0];                 % Reaction wheel rates
b    = 2*3600;                  % Battery state of charge (J = Wh*3600)

% State is [position;velocity;quaternion;angular velocity;wheels;battery charge]
%-------------------------------------------------------------------------
x    = [r;v;q;w;c;b];

%% Start Julian date
%------------------
d.jD0  = Date2JD([2012 4 5 0 0 0]);

%% Design the PID Controller
PID_Controller_Config_File;

%% Atmosphere model data
% Skip the J70 model as it is slow; use the commented out code to switch
% back if desired. AtmDens2 will be used instead.
%d.atm = [];
[aP, f, fHat, fHat400] = SolarFluxPrediction( d.jD0, 'nominal' );
d.atm.aP      = aP(1); 
d.atm.f       = f(1); 
d.atm.fHat    = fHat(1); 
d.atm.fHat400 = fHat400(1);

%% Initialize the plotting array to save time
%--------------------------------------------
qECIToBody   = x(7:10);
bField       = QForm( qECIToBody, BDipole( x(1:3), d.jD0 ) );
p.eci_vector = Unit(-x(1:3));
angleError(1)  = acos(Dot(p.eci_vector,QTForm(qECIToBody,p.body_vector)))*radToDeg;
angleError2(1)= acos(Dot(p2.eci_vector,QTForm(qECIToBody,p2.body_vector)))*radToDeg;
xPlot        = [[x;0;0;0;0;angleError(1);bField;0;0;0] zeros(length(x)+11,nSim)];

%% Initialize the time display
%----------------------------
TimeDisplay( 'initialize', 'CubeSat RWA Sim', nSim );

%% Initialite Sensors
Sensors_Config_File;

%% Run the simulation
%-------------------
t = 0;
torque=[0;0;0];

angleError3=0;
d.tRWA=[0;0;0];
time=0;
p.bFieldBody_before = [0; 0; 0];
kd=1e6;
torque1=[0;0;0];
detumbling=1;
for k = 1:nSim
  % Display the status message
  %---------------------------
  TimeDisplay('update');
   
  % Quaternion
  %-----------
  qECIToBody   = x(7:10);

  %% Magnetic field - the magnetometer output is proportional to this
  %-----------------------------------------------------------------
    bFieldBody   = QForm( qECIToBody, BDipole( x(1:3), d.jD0+t/86400 ) );
    magNoise=Sensors.magnetometer.sigmaNoise;
    magBias = Sensors.magnetometer.biasError;
    bField(:,k)=bFieldBody+magNoise'+magBias';
  
  %% Angular Rate - the gyros output are proportional to this
    bias_next = Sensors.gyros.bias0 + Sensors.gyros.rrw.*sqrt(dT).*[normrnd(0,1),normrnd(0,1),normrnd(0,1)];
    gyroBias = Sensors.gyros.biasOn*0.5*(Sensors.gyros.bias0 + bias_next);
    Sensors.gyros.bias0 = bias_next;
    gyroNoise= sqrt(Sensors.gyros.arw.^2./dT + 1/12*Sensors.gyros.rrw.^2.*dT).*[normrnd(0,1),normrnd(0,1),normrnd(0,1)];
    w_read = Sensors.gyros.Cerror*x(11:13) + gyroBias' + gyroNoise';%Real measurement
    
    if Sensors.gyros.ratingOn == 1%Convert to digital signal
    w_read = sensor_rating(w_read, Sensors.gyros.max_scale,Sensors.gyros.min_scale,Sensors.gyros.scale_division)';
    end
  
  
% Current Julian date
%--------------------
jD              = d.jD0 + t/86400;
%% %DETUMBLING____________________
% 
[d,x,p] =DetumblingFunction(x,d,p,bField(:,k),dT,Sensors);

  % A time step with 4th order Runge-Kutta
  %---------------------------------------
  x            = RK4(@RHSCubeSat2, x, dT, t, d,bField(:,k),w_read );

  % Get the power
  %--------------
  [xDot, dist, power] = RHSCubeSat2( x, t, d ,bField(:,k),w_read);

 torque=p.torqueDipole;
  % Update plotting and time
  %-------------------------
  hRWA         = x(14:16)*d.inertiaRWA;
  xPlot(:,k+1) = [x;power;torque;angleError3;bField(:,k);hRWA];
  t            = t + dT;

end
TimeDisplay( 'close' );

%% Plotting
%---------
kP = 1:k+1;
time=(0:k)*dT ;
[t, tL] = TimeLabl(time);


%% Y-axis labels
%--------------
yL = {'r_x (km)' 'r_y (km)' 'r_z (km)' 'v_x (km/s)' 'v_y (km/s)' 'v_z (km/s)'...
      'q_s' 'q_x' 'q_y' 'q_z' '\omega_x (rad/s)' '\omega_y (rad/s)' '\omega_z (rad/s)' ...
      '\omega_x (rad/s)' '\omega_y (rad/s)' '\omega_z (rad/s)' 'b (Wh)' 'Power (W)' ...
      'T_x (Nm)' 'T_y (Nm)' 'T_z (Nm)' 'Angle Error (deg)' 'B_x' 'B_y' 'B_z',...
      'H_x (Nms)' 'H_y (Nms)' 'H_z (Nms)'};
 
%% Plotting utility
%-----------------
Plot2D( t, xPlot( 1: 3,kP), tL, yL(  1: 3), 'CubeSat Orbit' );
Plot2D( t, xPlot( 7:10,kP), tL, yL(  7:10), 'CubeSat ECI To Body Quaternion' );
Plot2D( t, xPlot(11:13,kP), tL, yL( 11:13), 'CubeSat Attitude Rate (rad/s)' );
Plot2D( t, xPlot(14:16,kP), tL, yL( 14:16), 'CubeSat Reaction Wheel Rate (rad/s)' );
Plot2D( t, [xPlot(17,kP)/3600;xPlot(18,kP)], tL, yL( 17:18), 'CubeSat Power' );
Plot2D( t, xPlot(19:22,kP), tL, yL( 19:22), 'CubeSat Control Torque' );
Plot2D( t, xPlot(23:25,kP), tL, yL( 23:25), 'CubeSat Magnetic Field' );
Plot2D( t, xPlot(26:28,kP), tL, yL( 26:28), 'CubeSat RWA Momentum' );

maximumTorque   = max(max(abs(xPlot(19:21,kP))));
maximumMomentum = max(max(abs(xPlot(26:28,kP))));
maximumSpeed    = max(max(abs(xPlot(14:16,kP))));
%Plot2D( t, xPlot(29:31,kP), tL, yL( 19:22), 'CubeSat Control Torque' );

Plot2D(t,angleError);
title('Angle Error between Z and nadir(deg)');

Plot2D(t,angleError2);
title('Angle Error between Y and velocity vector(deg)');

Plot2D(t,angleError3);
title('Angle Error between Y and Sun vector(deg)');

%% Thermal Control

r = xPlot(1:3,:);
q = xPlot(7:10,:);
jD= d.jD0 + time/86400;
Temp = IsothermalCubeSatSim( d, r, q, jD, T0 );
figure
plot(t, Temp -  273.15); xlabel('Time [minutes]'); ylabel('Average Temperature [ºC]');
grid

%%
for n=1: size(xPlot,2)
    qLVLHToBody = QMult( QPose(QLVLH(xPlot(1:3,n),xPlot(4:6,n))), xPlot(7:10,n) );
    qLPlot(:,n) = qLVLHToBody;
    eul(:,n) = Q2Eul( xPlot(7:10,n) );
end

%AnimQ( [[qLPlot; eul];  xPlot(1:6,:)]);
%Figui

PlotSatAttitude(xPlot)

%% Create a table of output
%--------------------------
g{1,1} = 'Reaction Wheel Inertia';
g{1,2} =  LatexScientificNotation( d.inertiaRWA, 1);
g{1,3} = 'kg-m$^2$';

g{2,1} = 'Reaction Wheel Radius';
g{2,2} =  sprintf('%8.4f',radius*1000);
g{2,3} = 'mm';

g{3,1} = 'Reaction Wheel Thickness';
g{3,2} =  sprintf('%8.4f',thickness*1000);
g{3,3} = 'mm';

g{4,1} = 'Maximum RWA torque';
g{4,2} =  LatexScientificNotation( maximumTorque, 4);
g{4,3} = 'Nm';

g{5,1} = 'Maximum RWA Momentum';
g{5,2} =  LatexScientificNotation( maximumMomentum, 4 );
g{5,3} = 'Nms';

g{6,1} = 'Maximum RWA Rate';
g{6,2} =  sprintf('%12.4f',maximumSpeed*30/pi);
g{6,3} = 'RPM';

g{7,1} = 'Solar Cell Efficiency';
g{7,2} =  sprintf('%8.4f',d.power.solarCellEff);
g{7,3} = '';

g{8,1} = 'Power Conversion Efficiency';
g{8,2} =  sprintf('%8.4f',d.power.effPowerConversion);
g{8,3} = '';

g{9,1} = 'Panel Area';
g{9,2} =  sprintf('%8.4f',d.power.solarCellArea(1)*1e4);
g{9,3} = 'cm$^2$';

g{10,1} = 'Average Power Consumption';
g{10,2} =  sprintf('%8.1f',d.power.consumption );
g{10,3} = 'W';

g{11,1} = 'Battery Capacity';
g{11,2} =  sprintf('%8.1f',d.power.batteryCapacity/3600);
g{11,3} = 'Wh';

CreateTable( g );

%% Save data for the budgets
%--------------------------
u.rwa.mass          = massRWA;
u.rwa.volume        = volRWA;
u.solarPanel.mass   = massSolarPanel;
u.solarPanel.volume = volSolarPanel;

SaveStructure(u,'BudgetData.mat'); 


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-16 15:34:31 -0400 (Wed, 16 Mar 2016) $
% $Revision: 41916 $
