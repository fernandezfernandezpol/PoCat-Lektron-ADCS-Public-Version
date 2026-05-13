clc;
clear;
close all;
PSSSetPaths(1);

%% Constants
rE       = Constant('equatorial radius earth');
mu0      = 4e-7*pi;
degToRad = pi/180;
radToDeg = 180/pi;

%% Initial State
% State vector layout: [position(3); velocity(3); quaternion(4); angular_rate(3); battery(1)]
Sim_sat_initial_state;

%% Time Parameters
Sim_time_parameters;

%% PocketQube Geometry
% Face areas and normals required by the aerodynamic disturbance model.
Sim_pq_model;

%% Sensor Configuration
Sim_sat_sensors;

%% Simulation Data Structure
% Builds the d struct: spacecraft mass, inertia, orbit epoch, surface model,
% power system, atmosphere, planet, and magnetorquer saturation limits.
Sim_data_structure;

%% Controller Struct Initialization
% Detumbling does not use PID attitude control; this script only populates
% the p struct fields referenced by helper functions inside the loop.
Sim_PID_controller;

%% Hysteresis Damper
% Initializes the optional passive hysteresis-rod damper (disabled by default,
% controlled by the d.HR flag set in Sim_data_structure).
Sim_hysteresis_damper;

%% Pre-allocate Plotting Arrays
xPlot            = [x zeros(length(x),nSim)];
[xT, dist,power] = RHSCubeSat( x, 0, d );
dragPlot         = [dist.fAerodyn zeros(3,nSim)];
radPlot          = [dist.fOptical zeros(3,nSim)];
tRadPlot         = [dist.tOptical zeros(3,nSim)];
tAeroPlot        = [dist.tAerodyn zeros(3,nSim)];
tMagPlot         = [dist.tMag zeros(3,nSim)];
tGGPlot          = [dist.tGG zeros(3,nSim)];
powerPlot        = [power zeros(1,nSim)];
bPlot            = zeros(3,nSim+1);
qPlot            = zeros(4,nSim+1);
angleError_real  = zeros(1,nSim);
intensity        = zeros(3,nSim);
gyro_noise       = zeros(3,nSim);

% B-Dot gain: scales dipole command so the actuator saturates at nominal spin rate
kbdot = mean(d.maxmoment) / (mean(w0) * mean(d.bFieldBodyBefore));

%% Run the Simulation
do_detumbling    = 1;
timer_detumbling = 0;
t                = 0;
upF              = ceil(nSim/20);
kW               = 1;
simStart         = tic;
starttime        = datetime('now','Format','HH:mm:ss');
h                = waitbar(0,'CubeSat Simulation', ...
    'Name','CubeSat Simulation', ...
    'CreateCancelBtn', ...
    'setappdata(gcbf,''canceling'',true)', ...
    'CloseRequestFcn', 'delete(gcbf)');

setappdata(h,'canceling',false);
kids      = allchild(h);
btnCancel = findobj(kids,'Style','pushbutton');
canceled  = false;

if ~isempty(btnCancel)
    set(btnCancel,'String','Stop');
end

fprintf('-----------\n');
fprintf('\t· Began at: %s (HH:MM:SS).\n', char(starttime));

for k = 1:nSim
    drawnow

    % Pointing error between ECI reference vector and its current body estimate
    angleError_real(1,k) = rad2deg(acos(Dot(p.eci_vector, QTForm(x(7:10), -p.vector_angle))));

    % Sample the geomagnetic field at the current position and time
    rlla = CoordinateTransform( 'ECI', 'LLR', x(1:3), d.jD0 );

    if Sensors.magnetometer.on == 1
        [d.bFieldECI, d.bFieldDotECI] = BDipole( x(1:3), d.jD0+t/86400, x(4:6) );
        d.bFieldBody                  = QForm( x(7:10), d.bFieldECI );
        Magnetometer_measurement;
    else
        % Ideal IGRF field with noise floor only (no calibration errors)
        IGRF_sigmaNoise               = [344, 322, 481]*10^-9*safeFact; % T
        [d.bFieldECI, d.bFieldDotECI] = BDipole( x(1:3), d.jD0+t/86400, x(4:6) );
        d.bFieldBody                  = QForm( x(7:10), d.bFieldECI );
    end

    % Control runs at 1 Hz regardless of the RK4 integration step size
    if mod(k, ceil(1/dT)) == 0 || k == 1
        Gyro_measurement;

        % B-Dot law: m = k * (omega x B)  — dissipative, unconditionally stable
        omega         = gyro_noise(:, k);
        omega_cross_b = cross(omega, d.bFieldBody);
        d.dipole      = kbdot * omega_cross_b;

        % Saturate each axis at its magnetorquer maximum dipole
        for i = 1:3
            if abs(d.dipole(i)) > d.maxmoment(i)
                d.dipole(i) = sign(d.dipole(i)) * d.maxmoment(i);
            end
        end
    end

    % Convert dipole moment to coil drive current for logging [mA]
    intensity(1,k) = d.dipole(1) / Sx * 1e3;
    intensity(2,k) = d.dipole(2) / Sy * 1e3;
    intensity(3,k) = d.dipole(3) / Sz * 1e3;

    % Propagate state one step with 4th-order Runge-Kutta
    x            = RK4( @RHSCubeSat, x, dT, t, d );
    p.eci_vector = x(1:3) / norm(x(1:3));

    % Evaluate disturbances and power at the new state for post-processing
    [xT, dist, power] = RHSCubeSat( x, t, d );
    dragPlot(:,k+1)   = dist.fAerodyn;
    tAeroPlot(:,k+1)  = dist.tAerodyn;
    radPlot(:,k+1)    = dist.fOptical;
    tRadPlot(:,k+1)   = dist.tOptical;
    tMagPlot(:,k+1)   = dist.tMag;
    tGGPlot(:,k+1)    = dist.tGG;
    powerPlot(:,k+1)  = power;
    bPlot(:,k+1)      = d.bFieldECI;
    qLVLH             = QLVLH(x(1:3),x(4:6));
    qPlot(:,k+1)      = QMult(QPose(qLVLH),x(7:10));

    xPlot(:,k+1)     = x;
    t                = t + dT;
    timer_detumbling = timer_detumbling + dT;

    % Carry current field into next step (used by finite-difference derivative)
    d.bFieldECIbefore  = d.bFieldECI;
    d.bFieldBodyBefore = d.bFieldBody;

    if isvalid(h)
        val      = getappdata(h,'canceling');
        canceled = ~isempty(val) && any(logical(val(:)));
    else
        canceled = true;
    end
    if canceled
        break
    end
    if k/upF >= kW && isvalid(h)
        waitbar(k/nSim,h);
        kW = kW + 1;
    end
end

endtime           = datetime('now','Format','HH:mm:ss');
fprintf('\t· Ended at: %s (HH:MM:SS).\n', char(endtime));

simTime           = toc(simStart);
simTimeSec        = seconds(simTime);
simTimeSec.Format = 'hh:mm:ss';
fprintf('-----------\n');
fprintf('The simulation took %s (HH:MM:SS).\n', char(simTimeSec));
close(h);
if isvalid(h), delete(h); end

%% Post-Processing
time     = (0:nSim) * dT;
[tP, tL] = TimeLabl( time );

%% Plot Magnetorquer Drive Currents
figure
set(gcf, 'Name', 'Magnetorquers Intensity - X Axis', 'NumberTitle', 'off')
plot(tP(1:length(tP)-1), intensity(1,:));
title('Intensity — X Axis')
ylabel('mA')
xlabel('Time (hours)')

figure
set(gcf, 'Name', 'Magnetorquers Intensity - Y Axis', 'NumberTitle', 'off')
plot(tP(1:length(tP)-1), intensity(2,:));
title('Intensity — Y Axis')
ylabel('mA')
xlabel('Time (hours)')

figure
set(gcf, 'Name', 'Magnetorquers Intensity - Z Axis', 'NumberTitle', 'off')
plot(tP(1:length(tP)-1), intensity(3,:));
title('Intensity — Z Axis')
ylabel('mA')
xlabel('Time (hours)')

%% Plot Gyroscope Angular Rate
% Gyro is sampled at 1 Hz; gyroStep sub-samples to ~2 s intervals for clarity.
gyroStep = ceil(2/dT);
gyroIdx  = [1, gyroStep:gyroStep:size(gyro_noise,2)*gyroStep];
gyroIdx  = gyroIdx(gyroIdx <= k);
tGyro    = tP(gyroIdx);

figure
set(gcf, 'Name', 'Angular Rate', 'NumberTitle', 'off')
subplot(3,1,1)
plot(tGyro, gyro_noise(1,gyroIdx)*radToDeg);
title('Angular Rate — X Axis')
ylabel('deg/s')
xlabel('Time (hours)')
grid on

subplot(3,1,2)
plot(tGyro, gyro_noise(2,gyroIdx)*radToDeg);
title('Angular Rate — Y Axis')
ylabel('deg/s')
xlabel('Time (hours)')
grid on

subplot(3,1,3)
plot(tGyro, gyro_noise(3,gyroIdx)*radToDeg);
title('Angular Rate — Z Axis')
ylabel('deg/s')
xlabel('Time (hours)')
grid on

%% Optional Plots (uncomment to enable)
% yL = {'r_x (km)' 'r_y (km)' 'r_z (km)' 'v_x (km/s)' 'v_y (km/s)' 'v_z (km/s)'...
%     'q_s' 'q_x' 'q_y' 'q_z' '\omega_x (deg/s)' '\omega_y (deg/s)' '\omega_z (deg/s)' 'b (Wh)'};
%
% GroundTrack( xPlot(1:3,:), time, d.jD0 );
% rMag = Mag(xPlot(1:3,:));
% Plot2D( tP, rMag-rMag(1),                 tL, '\Delta h km',   'Change in Altitude' );
% Plot2D( tP, xPlot(7:10,:),                tL, {yL{7:10}},      'CubeSat ECI-to-Body Quaternion' );
% Plot2D( tP, qPlot,                        tL, {yL{7:10}},      'CubeSat LVLH-to-Body Quaternion' );
% Plot2D( tP, rad2deg(xPlot(11:13,:)),      tL, {yL{11:13}},     'CubeSat Attitude Rate (deg/s)' );
% Plot2D( tP, [xPlot(14,:)/3600;powerPlot], tL, {yL{14},'Power (W)'}, 'CubeSat Power System' );
% Plot2D( tP, dragPlot*1e3,  tL, {'F_x (mN)','F_y (mN)','F_z (mN)'},      'Drag Force (mN)' );
% Plot2D( tP, tAeroPlot*1e6, tL, {'T_x (uNm)','T_y (uNm)','T_z (uNm)'},   'Aerodynamic Torques' );
% Plot2D( tP, tMagPlot*1e6,  tL, {'T_x (uNm)','T_y (uNm)','T_z (uNm)'},   'Magnetic Torques' );
% Plot2D( tP, tGGPlot*1e6,   tL, {'T_x (uNm)','T_y (uNm)','T_z (uNm)'},   'Gravity Gradient Torques' );
% Plot2D( tP, radPlot*1e3,   tL, {'F_x (mN)','F_y (mN)','F_z (mN)'},       'Radiation Force (mN)' );
% Plot2D( tP, bPlot,         tL, {'B_x (T)','B_y (T)','B_z (T)'},           'Magnetic Field (ECI)' );
% SavePlots;
% AnimQ( xPlot(7:10,1:length(xPlot)),1000);
