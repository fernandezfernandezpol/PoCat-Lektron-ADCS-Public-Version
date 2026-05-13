clc;
clear;
clear all
%% A spacecraft with rate or hysteresis damping.
% You can try different kinds of damping. One is 3-axis damping
% that applies a damping constant to each axis rate. You should 
% find a constant that approximates whatever damper you have.
% If everything is working properly the spacecraft will align its
% torque rod with the Earth's magnetic field.
%
% This simulation does not have any disturbances. Run for a small number of
% orbits to clearly see the hysteresis loops. They are minor loops since
% the Earth's field is not strong enough to take the rod to saturation. Run
% for several days to damp the rates close to zero.
%
% The second type is magnetic hysteresis damping. Read the headers for
% RHSHysteresisDamper.m, TorqueHysteresis.m, and MagneticHysteresis.m
% MagneticHysteresis.m for more information.
%
% Things to try:
%
%       1. Try both types of damping.
%       2. Determine a damping constant that produces the same results as
%          hysteresis damping.
%       3. Try different orbits.
%       4. Try different dipoles.
%       5. With no damping determine the oscillation frequency of the
%          spacecraft.
%       6. See what happens with a rotation rate about the dipole axis.
%       7. Remove the dipole and initialize with nonzero rates instead.
%
%   Since version 2014.1
%
%  ----------------------------------------------------------------------
%  See also BFromHHysteresis, RHSHysteresisDamper, RHSRigidBodyWithDamping,
%  HysteresisOutput
%  ----------------------------------------------------------------------
%%
%--------------------------------------------------------------------------
%   Copyright (c) 2014 Princeton Satellite Systems, Inc.
%   All Rights Reserved
%--------------------------------------------------------------------------


%% Constants
%-----------
rE                  = Constant('equatorial radius earth');
degToRad            = pi/180;
mu0                 = 4e-7*pi;

%% Simulation parameters
%-----------------------
d                   = struct;
nOrbits             = 30;	 % Number of orbits for the simulation
d.jD0               = JD2000; % Start date
d.mu                = Constant('mu earth'); % Earth's gravitational parameter
altitude            = 300; % Orbit altitude (km)
inclination         = 90*degToRad; % Orbit inclination (rad)
d.dampingType       = 2;        % 1 is 3-axis damping 2 is a damping function

% Spacecraft with a dipole from a torque rod or permament magnet
%---------------------------------------------------------------
d.dipole            = [0;0;0]; % in ATM^2 along the x-axis
d.uDipole           = Unit(d.dipole);

% Dimensiones en "U" (1 U = 0.1 m). Para 5 cm -> 0.5 U
Usize = [0.5 0.5 0.5];     

% Masa conocida del PocketQube (kg)
d.mass = 0.25;  

% [d.inertia, d.mass]	= InertiaCubeSat( '0.5U' );
[d.inertia, mass_out] = InertiaCubeSat(Usize, d.mass);
d.inertia           = d.inertia(1,1)*eye(3); % Make spherical to simplify

% Compute the orbit
%------------------
el                  = [rE+altitude inclination 0 0 0 0];
[r,v]               = El2RV(el); % Get the starting position and velocity vectors
q                   = QLVLH(r,v); % Quaternion
[bI,bIDot]          = BDipole(r,d.jD0,v);

%% Damper parameters
%-------------------
if( d.dampingType == 1 )
  d.dampingData       = 1e-6;     % Damping constant
  d.dampingFun        = [];       % Not used
  z                   = [];       % Not used
else
  d.dampingData.Br	= 0.004;      % Remanence (T)
  d.dampingData.Bs	= 0.025;     % Saturation flux density (T)
  d.dampingData.Hc	= 12;      % Coercive force (A/m)
  
% ---------------- Hysteresis rods (geometría adecuada para 5x5x5 cm) -------
% Orientaciones: pares en +/- x, +/- y, +/- z (6 barras)
d.dampingData.u = [ 1 -1  0  0  0  0;
                    0  0  1 -1  0  0;
                    0  0  0  0  1 -1];   % columnas -> vectores unitarios    
  % d.dampingData.u = [[1;0;0] [1;0;0] [0;0;1] [0;0;1]];

  % Dimensions are radius 1 mm by 95 mm
    % Geometría: r_rod y L_rod elegidos para caber en 5 cm (L_rod <= 0.04 m)
    r_rod = 0.001;    % radio 1 mm
    L_rod = 0.04;     % longitud 4 cm
    nBars = size(d.dampingData.u,2);
    vol_single = pi * r_rod^2 * L_rod;
    d.dampingData.v = vol_single * ones(1,nBars);  % m^3 por barra

  d.dampingFun        = @RHSHysteresisDamper;       % Damper function
  uECI                = QTForm(q,d.dampingData.u);
  hMag                = Dot(uECI,bI   )/mu0;
  hMagDot             = Dot(uECI,bIDot)/mu0;
  z                   = BFromHHysteresis( hMag, hMagDot, d.dampingData );
  %z = 0*z;
end

% Initial state vector
%---------------------
% omega       = [0;-sqrt(d.mu/Mag(r)^3);0];
omega       = [deg2rad(30);deg2rad(30);deg2rad(30)];
x0          = [r;v;q;omega;z']; % State vector

% Determine the simulation duration
%----------------------------------
orbPeriod   = Period(el(1));
d.end       = nOrbits*orbPeriod;

%% Run the simulation
%--------------------
disp('Beginning simulation...')
outf      = @(t,y,flag) HysteresisOutput(t,y,flag,d);
opts      = odeset('outputfcn',outf,'initialstep',2,'refine',4);
rhs       = @(t,x) RHSRigidBodyWithDamping( x, t, d);
[tout,y]	= ode45(rhs, [0 nOrbits*orbPeriod], x0, opts);
y = y';
disp('Done')

xP = HysteresisOutput([],[],'x');
zP = HysteresisOutput([],[],'z');
tP = HysteresisOutput([],[],'t');

%% Plot
%------

% Labels for the default plots
%-----------------------------
yL      = { 'x (km)' 'y (km)' 'z (km)'  'v_x (km/s)' 'v_y (km/s)' 'v_z (km/s)' ...
            'q_s' 'q_x' 'q_y' 'q_z' '\omega_x (rad/s)' '\omega_y (rad/s)' '\omega_z (rad/s)' ...
            't_x' 't_y' 't_z' 't_x' 't_y' 't_z' '\theta (deg)',...
            'b_x (nT)' 'b_y (nT)' 'b_z (nT)'};
 
% Time labels
%------------
[t, tL]     = TimeLabl(tP);

kRV         =  1: 6;
kQ          =  7:10;
kOmega      = 11:13;
kTorque     = 14:19;
kAngle      = 20:23;

Plot2D( t, xP(kRV,:),     tL, yL(kRV),     'Damping Sim: Orbit');
Plot2D( t, xP(kQ,:),      tL, yL(kQ),      'Damping Sim: Quaternion');
Plot2D( t, rad2deg(xP(kOmega,:)),  tL, yL(kOmega),  'Damping Sim: Angular Rate');
Plot2D( t, xP(kTorque,:)*1e6, tL, yL(kTorque), 'Damping Sim: Damping and Dipole Torques (\mu Nm)');
Plot2D( t, xP(kAngle,:),  tL, yL(kAngle),  'Damping Sim: Angle to Field and ECI B Field');
Plot2D( t, xP(20,:),  tL, yL(20),  'Damping Sim: Angle between Dipole and Field (deg)');

% Plot the dampers if there are any
%----------------------------------
if( ~isempty(z) )
    
  if( nOrbits > 1 )
      f = 's';
  else
      f = '';
  end

  n = length(z);
  for k = 1:n
    s	= sprintf('Hysteresis loop Over %d Orbit%s, Bar %d',nOrbits,f, k);
    Plot2D(zP(k+n,:),zP(k,:),'H (A/m)','B (T)',s)

    s	= sprintf('B, H and dH/dt %d Orbit%s bar %d',nOrbits,f, k);
    j   = [k k+n k+2*n];
    Plot2D(t,zP(j,:),tL,{'B (T)' 'H (A/m)' 'dH/dt (A/ms)'},s)
  end
 
end
Figui


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 11:19:43 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39864 $

% Guardar todas las figuras abiertas en un solo PDF
% -------------------------------------------------

% Nombre del archivo de salida
outputPDF = 'Resultados_Simulacion.pdf';

% Obtener handles de todas las figuras abiertas
figs = findall(0, 'Type', 'figure');

% Ordenarlas por número (para mantener el orden en que se abrieron)
[~, idx] = sort([figs.Number]);
figs = figs(idx);

% Borrar PDF si ya existe (para evitar append incorrecto)
if exist(outputPDF, 'file')
    delete(outputPDF);
end

% Exportar cada figura al PDF, anexando una tras otra
for i = 1:length(figs)
    fig = figs(i);
    if i == 1
        exportgraphics(fig, outputPDF, 'ContentType', 'vector'); % crea PDF
    else
        exportgraphics(fig, outputPDF, 'Append', true, 'ContentType', 'vector'); % añade
    end
end

disp(['✅ Todas las figuras se han guardado en: ', outputPDF]);
