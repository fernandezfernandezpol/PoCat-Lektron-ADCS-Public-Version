%% Magnetometer Measurement
% Applies calibration-matrix error, bias error, and Gaussian noise to the
% true body-frame magnetic field, simulating a realistic sensor output.

% Calibration-matrix uncertainty (drawn once per run in Sensors_Config_File)
Cm1std = [0.005144464, 0.002784961, 0.002428284;
          0.002784961, 0.004001455, 0.001122388;
          0.002428284, 0.00112217,  0.004000846] * safeFact;
Sensors.magnetometer.Cerror = normrnd(eye(3), Cm1std);

% Bias uncertainty
bm1std = [42.946099, 24.277434, 37.842037]*1e-9 * safeFact; % [T]
Sensors.magnetometer.biasError  = normrnd([0,0,0], bm1std);
Sensors.magnetometer.sigmaNoise = [1,1,1]*4e-8 * safeFact;  % Gaussian noise STD [T]

% Apply calibration error and bias, then add sample noise
B_body_frame_with_bias = (Sensors.magnetometer.Cerror * d.bFieldBody) + Sensors.magnetometer.biasError';
noise        = normrnd(0, Sensors.magnetometer.sigmaNoise);
d.bFieldBody = B_body_frame_with_bias + noise';
