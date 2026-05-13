%% Simulation Data Structure
% Builds the d struct used by RHSCubeSat. Starts from the toolbox defaults,
% then overrides every field with PoCat-Lektron PQ parameters.

d         = RHSCubeSat;
d.mass    = 0.234; % kg

% Measured inertia tensor [kg·m²]; diagonalized to a scalar approximation
% so the control gain design is axis-independent.
d.inertia = 1e-9 * [125496.77   -584.95   240.80;
                     -584.95   105534.17  -266.4;
                      240.80    -266.4   121177.15];
[V, D]    = eig(d.inertia);
d.inertia = mean(diag(D)) * eye(3);

d.jD0         = juliandate(datetime(2019, 4, 5, 0, 0, 0)); % epoch (Julian date)
d.decimaldate = datenum(2019, 4, 5, 0, 0, 0);

Sim_thermal_control_config_file;

%% Surface Model
% Aerodynamic and radiation-pressure disturbances; face data from Sim_pq_model.
d.surfData.cD       = 2.7;
d.surfData.nFace    = n;
d.surfData.rFace    = r;
d.surfData.cM       = 1e-3*[-0.24; -0.29; -0.42]; % center of mass offset [m]
d.surfData.area     = a;
d.surfData.sigma    = [1 1 1 1 1 1; zeros(2,6)];   % optical coefficients (diffuse)
d.surfData.att.type = 'eci';
d.aeroModel         = @CubeSatAero;
d.opticalModel      = @CubeSatRadiationPressure;
d.skewOmegaEarth    = Skew([0;0;7.291e-5]);

%% Power System
% Solar cells cover five of the six faces (one face has no cell).
d.power.solarCellNormal    = n;
d.power.solarCellEff       = 0.3;
d.power.effPowerConversion = 0.9;
d.power.solarCellArea      = 0.0012 * [1 0 1 1 1 1]; % m² per face
d.power.consumption        = 80 / (3600) * dT * 10^-3; % ADCS draw [J per step]
battery_mAh                = 1400;
battery_voltage            = 3.3; % V
d.power.batteryCapacity    = battery_mAh * 3.6 * battery_voltage; % J

%% Atmospheric Model
% Solar flux indices for the Jacchia 1970 (J70) density model at epoch.
[aP, f, fHat, fHat400] = SolarFluxPrediction( d.jD0, 'nominal' );
d.atm.aP               = aP(1);
d.atm.f                = f(1);
d.atm.fHat             = fHat(1);
d.atm.fHat400          = fHat400(1);

%% Planet
d.planet = 'earth';
d.rP     = Constant('equatorial radius earth');
d.mu     = Constant('mu earth');

%% Control Initialization
d.dipole = [0; 0; 0]; % dipole command [A·m²], updated each control step

%% Initial Magnetic Field
% Store the field at t=0 so the B-Dot gain kbdot can be computed before
% entering the simulation loop.
d.bFieldECIbefore  = BDipole( x(1:3), d.jD0 );
d.bFieldBodyBefore = QForm( x(7:10), d.bFieldECIbefore );

%% Orbit Reference
el         = [rE+altitude(1) inclination 0 0 0 0];
[bI,bIDot] = BDipole(r0,d.jD0,v0);

%% Hysteresis Rods
d.HR = 0; % 0 = magnetorquers only; 1 = add passive hysteresis-rod damper

%% Magnetorquer Coil Geometry
% Computes the effective coil area coefficient for each axis from the PCB
% winding layout. The dipole moment is m = I * N * A, where N*A is
% accumulated across all turns and layers (coef_surface_*).

% --- Lateral-face coils (X and Z axes) ---
Lmm = 32.3; Lm = Lmm * 1e-3; % outer side length [m]
dmm = 0.22;  dm = dmm * 1e-3; % wire diameter [m]
wmm = 0.22;  wm = wmm * 1e-3; % turn-to-turn pitch [m]
Nturns  = 38;
Nlayers = 4;

coef_surface_lat = 0;
for i = 1:Nturns
    side_i           = Lm - 2*(i-1)*(wm + dm); % inner side at turn i
    coef_surface_lat = coef_surface_lat + Nlayers * side_i^2;
end

% --- Top-face coil (Y axis) ---
Lmm = 26.2; Lm = Lmm * 1e-3;
dmm = 0.20;  dm = dmm * 1e-3;
wmm = 0.25;  wm = wmm * 1e-3;

coef_surface_top = 0;
for i = 1:Nturns
    side_i           = Lm - 2*(i-1)*(wm + dm);
    coef_surface_top = coef_surface_top + Nlayers * side_i^2;
end

% --- Maximum dipole moment per axis ---
IomA = 150; IoA = IomA * 1e-3; % peak drive current [A]

Sx = coef_surface_lat; % effective area [m²] for X
Sy = coef_surface_top; % effective area [m²] for Y
Sz = Sx;               % Z coil is identical to the lateral coil

Moment_lat = IoA * Sx;
Moment_top = IoA * Sy;

% Factor of 2: H-bridge allows current reversal, doubling usable dipole range
d.maxmoment = 2*[Moment_lat, Moment_top, Moment_lat];
