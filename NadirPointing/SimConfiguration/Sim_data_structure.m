%% Start with defaults for the RHS
% RHSCubeSat will return a default data structure. The defaults are for a
% 1U CubeSat in orbit around the Earth. These will need to be modified for
% each simulation. CubeSats are 1 kg per unit (U).  The InertiaCubeSat
% function computes the inertia of a CubeSat assuming the mass is uniformly
% distributed throughout the volume.  This is usually a good first 
% approximation.
%--------------------------------------------------------------------------
d      = RHSCubeSat;
d.jD0  = Date2JD([2019 4 5 0 0 0]); % Julian date
d.decimaldate = datenum(2019,4,5,0,0,0);

d.mass        = 0.234; % kg
d.inertia     = 1e-9 * [125496.77   -584.95   240.80;
                        -584.95   105534.17   -266.4;
                        240.80   -266.4   121177.15];
[V, D]        = eig(d.inertia);
d.inertia     = mean(diag(D)) * eye(3);
Sim_thermal_control_config_file;

Sx=0.053153016000000;
Sz=Sx;
Sy=0.028032560000000;

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
% covering all six faces of the CubaeSat. If you changed one of the one's to
% a zero, then the model would have one face with no solar cell.
%--------------------------------------------------------------------------
d.power.solarCellNormal    = n;
d.power.solarCellEff       = 0.3;
d.power.effPowerConversion = 0.9;
d.power.solarCellArea      = 0.0012*[1 0 1 1 1 1];
% d.power.consumption        = 80/(3600)*dT*10^-3; %W each dT, ADCS 80mWh
% (C4) FIX: Formula is dimensionally inconsistent — 80 mWh converted to J is
%           288 J; with the extra dT and 1e-3 factors the result is ~5.6e-6, off
%           by 8 orders of magnitude. For 80 mW continuous ADCS power use:
d.power.consumption = 0.08;  % W (80 mW continuous ADCS)
battery_mAh                = 1400;
battery_voltage            = 3.3; %V
d.power.batteryCapacity    = battery_mAh*3.6*battery_voltage; % J

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
% This variable will be used in the control loop to specify the control for
% each timestep. For now, start with zero.
%------------------------------------------
d.dipole = [0;0;0];

%% Time parameters
% Initial values of the magnetic field in ECI and body frame.
%----------------------------------------------
d.fieldECIbefore = BDipole( x(1:3), d.jD0 );
d.fieldBODYbefore = QForm( x(7:10), d.fieldECIbefore );
