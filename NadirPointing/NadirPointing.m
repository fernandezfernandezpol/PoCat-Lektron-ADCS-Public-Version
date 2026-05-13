clc;
clear;
close all;
PSSSetPaths(1);

%% Initial State
% The state vector is [position;velocity;quaternion;angular velocity;
% battery state of charge].
%--------------------------------------------------------------------------
Sim_sat_initial_state;

%% Time parameters
% Specify the simulation duration and timestep.
%----------------------------------------------
Sim_time_parameters;

%% Select the PocketQube type
% The face areas and normals are needed by the aero model.  They are given
% by the CubeSatFaces function.
% -------------------------------------------------------------------------
Sim_pq_model;

%% Initialite Sensors
Sim_sensors;

%% Start with defaults for the RHS
% RHSCubeSat will return a default data structure. The defaults are for a
% 1U CubeSat in orbit around the Earth. These will need to be modified for
% each simulation. CubeSats are 1 kg per unit (U).  The InertiaCubeSat
% function computes the inertia of a CubeSat assuming the mass is uniformly
% distributed throughout the volume.  This is usually a good first
% approximation.
%--------------------------------------------------------------------------
Sim_data_structure;

%% Design the PID Controller
% Specify the Y body axis for alignment with the chosen ECI vector
%-----------------------------------------------------------------
Sim_PID_controller;

%% Design of the Unscended Kalman filter
% Initial parameter initialized
%-----------------------------------------------------------------
MKF;

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
q_error   = zeros(nSim,4);
angleError_real = zeros(1,nSim);
yaw_real_vec    = zeros(1,nSim);
pitch_real_vec  = zeros(1,nSim);
roll_real_vec   = zeros(1,nSim);
moment_vec      = zeros(nSim,3);

%% Run the simulation
%--------------------
t         = 0;
upF       = ceil(nSim/20);
kW        = 1;
simStart  = tic;
starttime = datetime('now','Format','HH:mm:ss');
h         = waitbar(0,'CubeSat Simulation', ...
    'Name','CubeSat Simulation', ...
    'CreateCancelBtn', ...
    'setappdata(gcbf,''canceling'',true)', ...
    'CloseRequestFcn', 'delete(gcbf)');

setappdata(h,'canceling',false);
kids = allchild(h);
btnCancel = findobj(kids,'Style','pushbutton');
canceled = false;

if ~isempty(btnCancel)
    set(btnCancel,'String','Stop');
end

fprintf('-----------\n');
fprintf('\t· Began at: %s (HH:MM:SS).\n', char(starttime));

for k = 1:nSim
    % Pointing error calculation
    %-----------------------------------------------------------------
    angleError_real(1,k)   = rad2deg(acos(Dot(-p.eci_vector,QTForm(x(7:10),p.body_vector))));

    % Magnetic field - the magnetometer output is proportional to this
    %-----------------------------------------------------------------
    rlla = CoordinateTransform( 'ECI', 'LLR', x(1:3), d.jD0 );

    if Sensors.magnetometer.on==1
        %Error  of the IGRF
        IGRF_std        = [344, 322, 481]*10^-9;
        IGRF_sigmaNoise = IGRF_std.^2; %T  % STD of BIAS Gaussian noise IGRF
        d.fieldECI      = BDipole( x(1:3), d.jD0+t/86400 );
        d.fieldECI      = BDipole( x(1:3), d.jD0+t/86400 );
        bfieldBODY      = QForm( x(7:10), d.fieldECI  );
        Magnetometer_measurement;
        magnetometer_data(:,k) = d.fieldBODY;
    else
        %Error  of the IGRF
        IGRF_sigmaNoise  = [344, 322, 481]*10^-9*safeFact;%T  % STD of BIAS Gaussian noise IGRF
        d.fieldECI       = BDipole( x(1:3), d.jD0+t/86400 );
        d.fieldBODY      = QForm( x(7:10), d.fieldECI  );
    end

    % Sun position
    %-----------------------------------------------------------------
    Sim_sun_position;

    % Conduct a measurement with the gyroscope
    %---------------------------------------------------
    Gyro_measurement;

    % Unscended Kalman Filter implementation
    %-----------------------------------------------------------------
    switch KF.sim_state
        case 1
            % TRIAD algorithm
            %--------------------------------------------------------------
            reference1=d.fieldECI;
            reference2=d.rSunECI;
            body1=d.fieldBODY;
            body2= d.rSunBody;
            [rotation_matrix] = triad(reference2,reference1,body2,body1);

            % Rotation to quaternion
            %--------------------------------------------------------------
            [quaternion,thetaq_check] = rotmatrix2quat(rotation_matrix);
            if dot(quaternion, x(7:10)) < 0
                quaternion = -quaternion;
            end
            quaternion = quaternion / norm(quaternion);
            thetaq_vec(:,k) = thetaq_check;
            quaternion_estimated(:,k) = quaternion;
            % quaternion=x(7:10);
            if k==1
                % Unscended Kalman Filter Initialization
                %----------------------------------------------------------
                quaternion = x(7:10);
                KF.q0 = quaternion; % Initial quaternion
                KF.qprev = KF.q0;
                KF.w0 = w_read;     % Initial angular velocity
                KF.wprev = KF.w0;
                KF.Pprev = KF.P0;   % Initial Covariance matrix
                % KF.sim_state = 2;
                KF.Qvec(:,k)  = quaternion;
            end

            % case 2
            if k>=2
                P11(k) = KF.Pprev(1,1);
                traceP(k) = trace(KF.Pprev);
                % State prediction
                %----------------------------------------------------------
                KF.w_predict = KF.wprev;
                KF.delta_predict = [cos(norm(KF.w_predict)/2*dT) ; KF.w_predict/norm(KF.w_predict)*sin(norm(KF.w_predict)/2*dT)];
                KF.qpredict = QMult(KF.qprev, KF.delta_predict);
                KF.qpredict = KF.qpredict/norm(KF.qpredict);

                KF.Rdelta = quat2rotm(KF.delta_predict);
                KF.Fn = [KF.Rdelta' dT .* KF.I3 ; KF.Z3 KF.I3];
                KF.Ppredict = KF.Fn * KF.Pprev * KF.Fn' + KF.Qn;

                % Measurement prediction
                %----------------------------------------------------------
                KF.v_meas = d.fieldBODY; % V vector, magnetometer measurement T
                KF.w_meas = w_read;      % Angular velocity measurement rad/s
                KF.state_meas = [KF.v_meas;KF.w_meas];
                KF.Rquat = quat2rotm(KF.qpredict);
                KF.v_est = KF.Rquat*d.fieldECI;
                KF.state_predict = [KF.v_est; KF.wprev];

                % Jacobian medition
                %----------------------------------------------------------
                KF.Vx = [0 KF.v_est(3) -KF.v_est(2) ; -KF.v_est(3) 0 KF.v_est(1) ; KF.v_est(2) -KF.v_est(1) 0];
                KF.Hn = [KF.Vx KF.Z3 ; KF.Z3 KF.I3];

                % Innovation matrix
                %-----------------------------------------------------------------
                KF.Qv = IGRF_sigmaNoise.*KF.I3;
                KF.innovationfactor = [KF.Rv  KF.Z3 ; KF.Z3  KF.Rw];
                KF.Sn = KF.Hn * KF.Ppredict * KF.Hn' + KF.innovationfactor;

                % Kalman Gain
                %----------------------------------------------------------
                KF.Kn = KF.Ppredict * KF.Hn' / KF.Sn;

                % Correction computation
                %----------------------------------------------------------
                KF.Correction = KF.Kn * (KF.state_meas - KF.state_predict);
                KF.deltaerror = KF.Correction(1:3);
                delta_norm = norm(KF.deltaerror);
                if delta_norm > 1e-6
                    axis = KF.deltaerror / delta_norm;
                    KF.errorq = [cos(delta_norm/2); axis * sin(delta_norm/2)];
                else
                    KF.errorq = [1; 0; 0; 0]; % near-zero correction
                end

                KF.deltaw = KF.Correction(4:6);

                % Corrections computation
                %----------------------------------------------------------
                KF.qupdated = QMult(KF.qpredict,KF.errorq);
                KF.qupdated = KF.qupdated/norm(KF.qupdated);

                if (KF.qupdated(1,1) < 0.0)
                    KF.qupdated = -KF.qupdated;
                end

                KF.qprev = KF.qupdated;

                KF.wupdated = KF.w_predict + KF.deltaw;
                KF.wprev = KF.wupdated;
                % KF.wprev = w_read;

                L = KF.I6 - KF.Kn * KF.Hn;
                KF.Pupdated = L * KF.Ppredict * L' + KF.Kn * KF.innovationfactor * KF.Kn';
                KF.Pprev = KF.Pupdated;

                w_read = KF.wupdated;
                quaternion = KF.qupdated;
                KF.Qvec(:,k)  = KF.qupdated;
            end
    end

    % Declare local params: delta quaternion, angle and unit vector
    %--------------------------------------------------------------
    q_target = U2Q( p.eci_vector, p.body_vector );

    % Real error en body frame (as q_target_body)
    q_real_error_k = QMult(QPose(x(7:10)), q_target);
    if q_real_error_k(1) < 0
        q_real_error_k = -q_real_error_k;
    end
    eul_k = quat2eul(q_real_error_k', 'ZYX');
    yaw_real_vec(k)   = rad2deg(eul_k(1));
    pitch_real_vec(k) = rad2deg(eul_k(2));
    roll_real_vec(k)  = rad2deg(eul_k(3));

    % Compute the achievable target, q_target_body
    %---------------------------------------------
    q_target_body = QMult(QPose(quaternion), q_target); %% it's q_body_target
    q_AKE(:,k) = QMult(QPose(quaternion), x(7:10));

    % Control system placeholder - apply constant dipole
    %---------------------------------------------------
    % d.dipole     = [0.001;0;0]; % Amp-turns m^2

    if (q_target_body(1,1) < 0.0)
        q_target_body = -q_target_body;
    end

    q_error(k,:) = q_target_body;

    if (q_AKE(1,k) < 0.0)
        q_AKE(:,k) = -q_AKE(:,k);
    end

    AKE(1,k) = 2*acosd(q_AKE(1,k));

    if mod(k, ceil(1/dT)) == 0 || k == 1
        % Compute the required moment for pointing to the nadir angle
        %--------------------------------------------------------------
        kP = d.inertia * constants.kP;
        kR = d.inertia * constants.kR;
        moment = ( kP .* (cross(d.fieldBODY, q_target_body(2:4))) - kR .* (cross(d.fieldBODY, w_read)) ) / (norm(d.fieldBODY)^2);
        moment_vec(k,:) = moment(:);

        % Compute the required injected intensity to the magnetorquers
        %--------------------------------------------------------------
        for i = 1:3
            if abs(moment(i)) > m_max(i)
                % Si excede el máximo, aplicamos el máximo con el signo correcto
                d.dipole(i) = sign(moment(i)) * m_max(i);
            else
                % Si no, aplicamos lo que pide el PID
                d.dipole(i) = moment(i);
            end
        end
    end

    % Calcular la intensidad continua (en mA) para graficar
    intensity(1,k) = d.dipole(1) / Sx * 1e3;
    intensity(2,k) = d.dipole(2) / Sy * 1e3;
    intensity(3,k) = d.dipole(3) / Sz * 1e3;

    % A time step with 4th order Runge-Kutta
    %---------------------------------------
    x            = RK4( @RHSCubeSat, x, dT, t, d );
    p.eci_vector = x(1:3)/norm(x(1:3));

    % Obtain effect of disturbances and control
    %------------------------------------------
    [xT, dist,power] = RHSCubeSat( x, t, d );
    qLVLH = QLVLH(x(1:3),x(4:6));
    qPlot(:,k+1) = QMult(QPose(qLVLH),x(7:10));

    % Update plotting and time
    %-------------------------
    xPlot(:,k+1) = x;
    t            = t + dT;

    % Update magnetic field
    %-------------------------
    d.fieldECIbefore  = d.fieldECI;
    d.fieldBODYbefore = d.fieldBODY;

    if isvalid(h)
        val = getappdata(h,'canceling');
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

q_angle = 2*atan2(vecnorm(q_error(:,2:4), 2, 2),q_error(:,1));
q_RMS   = rms(q_angle);

%% -----------------------------------------------------------------------
%  3-column summary figure
%  Col 1 : angleError_real  + Yaw / Pitch / Roll  (real quaternion)
%  Col 2 : q_angle          + Yaw / Pitch / Roll  (estimated quaternion)
%  Col 3 : Intensity (all)  + Ix / Iy / Iz
%  -----------------------------------------------------------------------

tVec = (0:nSim-1) * dT;          % common time axis (seconds)

% ---- Euler angles from angleError_real
yaw_real   = unwrap(yaw_real_vec(:));
pitch_real = unwrap(pitch_real_vec(:));
roll_real  = unwrap(roll_real_vec(:));

% ---- Euler angles q_error
eul_est   = quat2eul(q_error, 'ZYX');
yaw_est   = rad2deg(unwrap(eul_est(:,1)));
pitch_est = rad2deg(unwrap(eul_est(:,2)));
roll_est  = rad2deg(unwrap(eul_est(:,3)));

% ---- q_angle as column vector (it may be a row vector from the loop)
q_angle_deg = rad2deg(q_angle(:));        % ensure column

figure('Name','Attitude & Control Summary','NumberTitle','off');

% ===== COLUMN 1 – Real angle error =======================================
subplot(4,3,1);
plot(tVec, angleError_real, 'b');
title('Angle Error Real');
ylabel('Angle [°]');
grid on;

subplot(4,3,4);
plot(tVec, yaw_real, 'b');
ylabel('Yaw [°]');
grid on;

subplot(4,3,7);
plot(tVec, pitch_real, 'b');
ylabel('Pitch [°]');
grid on;

subplot(4,3,10);
plot(tVec, roll_real, 'b');
ylabel('Roll [°]');
xlabel('Time [s]');
grid on;

% ===== COLUMN 2 – Estimated (KF) =========================================
subplot(4,3,2);
plot(tVec, q_angle_deg, 'r');
title('q Error');
ylabel('Angle [°]');
grid on;

subplot(4,3,5);
plot(tVec, yaw_est, 'r');
ylabel('Yaw [°]');
grid on;

subplot(4,3,8);
plot(tVec, pitch_est, 'r');
ylabel('Pitch [°]');
grid on;

subplot(4,3,11);
plot(tVec, roll_est, 'r');
ylabel('Roll [°]');
xlabel('Time [s]');
grid on;

% ===== COLUMN 3 – Magnetorquer intensity =================================
subplot(4,3,3);
plot(tVec, sqrt(intensity(1,:).^2 + intensity(2,:).^2 + intensity(3,:).^2), 'k');
title('Intensity');
ylabel('Total [mA]');
grid on;

subplot(4,3,6);
plot(tVec, intensity(1,:), 'b');
ylabel('X-Axis [mA]');
grid on;

subplot(4,3,9);
plot(tVec, intensity(2,:), 'r');
ylabel('Y-Axis [mA]');
grid on;

subplot(4,3,12);
plot(tVec, intensity(3,:), 'g');
title('Intensity Z');
ylabel('Z-Axis [mA]');
xlabel('Time [s]');
grid on;

% Plot AKE
figure('Name', 'Attitude Knowledge Error', 'NumberTitle', 'off');

tVec_ake = (0:nSim-1) * dT;

plot(tVec_ake, AKE, 'm', 'LineWidth', 0.8);
yline(10, 'r--', '10°', 'LabelHorizontalAlignment', 'left');
yline(5,  'g--', '5°',  'LabelHorizontalAlignment', 'left');

xlabel('Time [s]');
ylabel('AKE [°]');
title('Attitude Knowledge Error');
grid on;
ylim([0, max(AKE) * 1.1]);

%% Plot LVLH
time     = (0:nSim)*dT;
[tP, tL] = TimeLabl( time );
Plot2D( tP, qPlot, tL, {'q_s' 'q_x' 'q_y' 'q_z'}, 'LVLH To Body Quaternion' );

%% Plot moment
figure('Name', 'Moment Magnetorquers', 'NumberTitle', 'off');

plot(tVec, moment_vec(:,1), 'r', 'LineWidth', 0.8); hold on;
plot(tVec, moment_vec(:,2), 'g', 'LineWidth', 0.8);
plot(tVec, moment_vec(:,3), 'b', 'LineWidth', 0.8);

xlabel('Time [s]');
ylabel('Moment [A·m^2]');
title('Moment Magnetorquers');

legend('Mx', 'My', 'Mz');

grid on;

ylim([min(moment_vec, [], 'all') * 1.1, max(moment_vec, [], 'all') * 1.1]);

%% Save plots
% SavePlots;

%% Save debug file
debugDir = fullfile(fileparts(mfilename('fullpath')), 'utils', 'debug');
if ~exist(debugDir, 'dir'), mkdir(debugDir); end
save(fullfile(debugDir, 'sim_debug.mat'));