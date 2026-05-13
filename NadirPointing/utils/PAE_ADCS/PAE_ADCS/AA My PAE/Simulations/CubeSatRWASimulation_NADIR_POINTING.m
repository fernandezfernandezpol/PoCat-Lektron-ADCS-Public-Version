%% Demonstrate CubeSat attitude and power system dynamics.
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
addpath('C:\Users\Camps\Proc_txt\PROYECTOS\3Cat-n\CubeSatToolbox\PAE_ADCS\AA My PAE\')
addpath('C:\Users\Camps\Proc_txt\PROYECTOS\3Cat-n\CubeSatToolbox\PAE_ADCS\AA My PAE\Functions')
addpath('C:\Users\Camps\Proc_txt\PROYECTOS\3Cat-n\CubeSatToolbox\PAE_ADCS\AA My PAE\Config_Files');

%clear g; u; p; d; close all
clear all; close all;

magnetorquers = 1; % 1 use magnetorquers; 0 use reaction wheels
m_max = 10*0.000924*32/22; % A·m^2. 42 cm^2 · 22 mA = 0.000924  % now max current is 32 mA, not 22 mA, but still is not enough to achieve control.
% Minimum momentum to achieve control is 2*0.000924*32/22

%% Constants
%-----------
radToDeg        = 180/pi;
densitySilicon  = 2600;
densityAl       = 2700; % Aluminum
densityTungsten = 19300;

%% Simulation parameters
%-----------------------
days  = 1/15;
tEnd  = days*86400; 
dT    = 0.1;
nSim  = ceil(tEnd/dT);

%% Initial state vector for a circular orbit
%------------------------------------------
x    = 6387.165+800; % km
v    = VOrbit(x);

r    = [x;0;0];                 % Position vector
v    = [0;0;v];                 % Velocity vector - polar orbit
q    = [1;0;0;0];               % Quaternion
w    = [0;0;0];                 % Angular rate of spacecraft
w    = [0.9*OrbRate(x);-1*OrbRate(x);-1*OrbRate(x)];                 % Angular rate of spacecraft >> INCREASE FROM 10X TO 20X, 50X, 100X TO SEE THAT IT TAKES LONGER TO STABILIZE, OR IT CANNOT EVEN STABILIZE!
c    = [0;0;0];                 % Reaction wheel rates
b    = 2*3600;                  % Battery state of charge (J = Wh*3600)

% State is [position;velocity;quaternion;angular velocity;wheels;battery charge]
%-------------------------------------------------------------------------
x    = [r;v;q;w;c;b];

%% Start Julian date
%------------------
d.jD0  = Date2JD([2012 4 5 0 0 0]);

%% CubeSat model
% Initialize data structure
%% CubeSat Initialize
Data_CubeSat_Config_File
%% Thermal Control
Thermal_Control_Config_File;
%% Initialite Sensors
Sensors_Config_File;

DrawCubeSatSolarAreas(d.power)

%% Design the PID Controller
% Specify the z body axis for alignment with the chosen ECI vector
%-----------------------------------------------------------------
p                    = PID3Axis;    % Since it is executed without input arguments, and only one output argument, it is equivalent to d = DefaultData; and torque = d.

%[p.a, p.b, p.c, p.d] = PIDMIMO( 1, 1, 0.01, 200, 0.1, dT ); 
%[a, b, c, d, k] = PIDMIMO( inr, zeta, omega, tauInt, omegaR, tSamp, sType )
[p.a, p.b, p.c, p.d] = PIDMIMO( 1, 1, 0.01, 200, 0.1, dT ); 

p.inertia            = d.inertia;
p.max_angle          = 0.01;
p.accel_sat          = [100;100;100];
p.mode               = 1;
p.q_target_last      = q;
p.q_desired_state    = [0; 0; 0; 1];   
p.body_vector        = [0; 0; 1]; % X = Blue; Y = Green; Z = Red; +: towards nadir, -: towards zenith
                                  % MODIFY LINES 167-172 TO SELECT NADIR POINTING OR ALIGNMENT WITH MAGNETIC FIELD OF THE EARTH (OR OTHER DIRECTIONS. TO BE DEFINED)
%% Atmosphere model data
% Skip the J70 model as it is slow; use the commented out code to switch
% back if desired. AtmDens2 will be used instead.
d.atm = [];
% [aP, f, fHat, fHat400] = SolarFluxPrediction( d.jD0, 'nominal' );
% d.atm.aP      = aP(1); 
% d.atm.f       = f(1); 
% d.atm.fHat    = fHat(1); 
% d.atm.fHat400 = fHat400(1);

%% Initialize the plotting array to save time
%--------------------------------------------
qECIToBody   = x(7:10);
bField       = QForm( qECIToBody, BDipole( x(1:3), d.jD0 ) );
p.eci_vector = Unit(bField);
angleError   = acos(Dot(p.eci_vector,QTForm(qECIToBody,p.body_vector)))*radToDeg;

xPlot        = [[x;0;0;0;0;angleError;bField;0;0;0] zeros(length(x)+11,nSim)];

%% Initialize the time display
%----------------------------
TimeDisplay( 'initialize', 'CubeSat RWA Sim', nSim );

%% Run the simulation
%-------------------
t = 0;

for k = 1:nSim
  % Display the status message
  %---------------------------
  TimeDisplay('update');
    
  % Quaternion
  %-----------
  qECIToBody   = x(7:10);

  % Magnetic field - the magnetometer output is proportional to this
  %-----------------------------------------------------------------
  bField       = QForm( qECIToBody, BDipole( x(1:3), d.jD0+t/86400 ) );
  bField_Earth = bField;

% UNCOMMENT THESE 3 LINES TO ADD BIASES AND NOISE TO MAGNETOMETERS READINGS
%  magNoise = Sensors.magnetometer.sigmaNoise;
%  magBias  = Sensors.magnetometer.biasError;
%  bField   = bField_I+magNoise'+magBias';

  %% Angular Rate - the gyros output are proportional to this
  bias_next = Sensors.gyros.bias0 + Sensors.gyros.rrw.*sqrt(dT).*[normrnd(0,1),normrnd(0,1),normrnd(0,1)];
  gyroBias = Sensors.gyros.biasOn*0.5*(Sensors.gyros.bias0 + bias_next);
  Sensors.gyros.bias0 = bias_next;
  gyroNoise= sqrt(Sensors.gyros.arw.^2./dT + 1/12*Sensors.gyros.rrw.^2.*dT).*[normrnd(0,1),normrnd(0,1),normrnd(0,1)];
  w_read = Sensors.gyros.Cerror*x(11:13) + gyroBias' + gyroNoise';%Real measurement
    
%   if Sensors.gyros.ratingOn == 1%Convert to digital signal
%     w_read = sensor_rating(w_read, Sensors.gyros.max_scale,Sensors.gyros.min_scale,Sensors.gyros.scale_division)';
%   end

  % Control system momentum management
  %-----------------------------------
  d.dipole     = [0.0;0;0]; % Amp-turns m^2

  % Reaction wheel control - align with the magnetic field
  %-------------------------------------------------------
  p.eci_vector = Unit(bField);
  % Reaction wheel control - align z with nadir
  %-------------------------------------------------------
  %p.eci_vector=-Unit(x(1:3));   % NADIR POINTING 
  
  if abs(w_read(1)) > 30*pi/180 | abs(w_read(2)) > 30*pi/180 | abs(w_read(3)) > 30*pi/180
    p.bFieldBody_before = [0; 0; 0];
    [d,x,p] = DetumblingFunction(x,d,p,bField_Earth,dT,Sensors);
    torque=p.torqueDipole;
    disp('detumbling')
    d.dipole  = torque;
    d.tRWA    = 0;
  else

  angleError   = acos(Dot(p.eci_vector,QTForm(qECIToBody,p.body_vector)))*radToDeg;
  [torque, p]  = PID3Axis( qECIToBody, p );
  warning('off')
  if magnetorquers % CON MTQ NO VA
%       [m, tErr, t_actual] = MagneticControl_modif( bField_Earth, torque, eye(3), 100 , Sensors.magnetometer.MaxX);  % m is the vector with the actuation (A·m^2) that need to be applied
      % Torque unit vectors transposed
      gamma   = Cross(eye(3),bField_Earth);
      % Least squares fit
      c = 1.0e-03;
%       m = inv(gamma'*gamma)*gamma'*torque;
      m       = ((gamma'*gamma + c)\(gamma'*torque));
      if abs(m(1)) > m_max; m(1) = sign(m(1))*m_max; end
      if abs(m(2)) > m_max; m(3) = sign(m(2))*m_max; end
      if abs(m(3)) > m_max; m(1) = sign(m(3))*m_max; end

      % Compute the torque error
	  t_actual       = sum(gamma*m,2);
	  tErr	         = t_actual - torque;
      d.tRWA         = -t_actual; 
%       if norm(t_actual,2) <= norm(torque,2)
%         d.tRWA  =  -t_actual; 
%       else
%           d.tRWA = 0*torque;
%           disp(t)
%       end   
  else             % CON RW SI VA
      d.tRWA  = -torque;  % TORQUES ALONG X, Y AND Z AXES
  end

%    end
  % [t_actual, torque]
  % THESE TORQUES WILL HAVE TO BE CONVERTED FOR THE MAGNETORQUERS USING: torque = m x B_Earth, 
  % WHERE m IS IN [A·m^2] (RULE OF THUMB, RIGHT HAND), AND B_Earth IN [Teslas] FROM WHERE YOU CAN GET THE CURRENTS THROUGH EACH COIL:
  % BEWARE!!! | I_{x,y,z} | < I_max, THAT LIMITS THE MAXIMUM TORQUE THAT CAN BE CREATED BY A COIL AS EACH MAGNETORQUER HAS A MAXIMUM [A·m^2] IT CAN PROVIDE
  % BEWARE!!! SINCE EACH MAGNETORQUER PRODUCES A TORQUE WITH 3 COMPONENTS, YOU WILL HAVE TO SOLVE FOR THE 3 EQUATIONS AT THE SAME TIME.

  % A time step with 4th order Runge-Kutta
  %---------------------------------------
  x_ant = x;
  if isnan(x); halt; end
  x            = RK4( @RHSCubeSat, x, dT, t, d );
if isnan(x) 
    disp([num2str(t), ' - warning']);
end
  % Get the power
  %--------------
  [xDot, dist, power] = RHSCubeSat( x, t, d );

  % Update plotting and time
  %-------------------------
  hRWA         = x(14:16)*d.inertiaRWA;
  xPlot(:,k+1) = [x;power;torque;angleError;bField;hRWA];
  t            = t + dT;

  end
end
TimeDisplay( 'close' );
%% Plotting
%---------
kP = 1:k+1;
[t, tL] = TimeLabl( (0:k)*dT );
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

Plot2D(t,xPlot(22,:));
title('Angle Error between Z and nadir(deg)');
xlabel(tL); ylabel('degrees º');

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

PlotSatAttitude(xPlot)

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-16 15:34:31 -0400 (Wed, 16 Mar 2016) $
% $Revision: 41916 $
 