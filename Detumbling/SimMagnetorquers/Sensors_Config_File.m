%% Sensors Configuration File
% Initializes all sensor structs with noise, calibration-error, and
% quantization parameters. Called once before the simulation loop.
% Individual on/off flags can be overridden in Sim_sat_sensors.m.

Sensors.on = 1;

%% Magnetometer (XSENS MTI)
Sensors.magnetometer.on = 1;
safeFact = 1; % noise scaling factor (1 = nominal)

% Calibration-matrix uncertainty (Gaussian STD, added to identity at run time)
Cm1std = [0.005144464, 0.002784961, 0.002428284;
          0.002784961, 0.004001455, 0.001122388;
          0.002428284, 0.00112217,  0.004000846] * safeFact;
Sensors.magnetometer.Cerror = normrnd(eye(3), Cm1std);

% Bias and noise errors
bm1std = [42.946099, 24.277434, 37.842037]*1e-9 * safeFact; % bias STD [T]
Sensors.magnetometer.biasError  = normrnd([0,0,0], bm1std);
Sensors.magnetometer.sigmaNoise = [1,1,1]*1.5e-6 * safeFact; % Gaussian noise STD [T]

% Actuator saturation limits (stored here for convenience)
Sensors.magnetometer.MaxX = 0.2; % [A·m²]
Sensors.magnetometer.MaxY = 0.2;
Sensors.magnetometer.MaxZ = 0.2;

%% Gyroscopes
Sensors.gyros.on       = 1;
Sensors.gyros.noiseOn  = 1;
Sensors.gyros.biasOn   = 1;
Sensors.gyros.ratingOn = 0; % set to 1 to enable ADC quantization

% Moving-average queue (averages over ~10 s to suppress high-frequency noise)
Sensors.gyros.queue_size = ceil(10/dT);
Sensors.gyros.queue      = zeros(3, Sensors.gyros.queue_size);
Sensors.gyros.queue_pos  = 1;

% Calibration-matrix uncertainty
Cgstd = [0.030126101, 0.086968229, 0.020780010;
         0.024061195, 0.031376110, 0.043422602;
         0.031325418, 0.056554503, 0.042132247] * safeFact;
Sensors.gyros.Cerror    = normrnd(eye(3), Cgstd);

% Bias error (constant over the run; re-drawn each Sensors_Config_File call)
bgstd = [0.2,0.2,0.2]*pi/180 * safeFact; % [rad/s]
Sensors.gyros.BiasError = normrnd([0,0,0], bgstd);

% Random-walk noise parameters (IEEE Std 952-2004)
% Note: gyro bias drifts as a random walk — this error is absent in other sensors.
Sensors.gyros.bias0 = ([normrnd(0,3), normrnd(0,3), normrnd(0,3)] + Sensors.gyros.BiasError)*pi/180;
Sensors.gyros.arw   = [0.0378, 0.0662, 0.05417]*pi/180;   % Angle Random Walk [rad/√s]
Sensors.gyros.rrw   = [0.00013339, 0.0001783, 0.00010072]*pi/180; % Rate Random Walk [rad/√s³]

% ADC quantization range
Sensors.gyros.max_scale      =  90*pi/180; % [rad/s]
Sensors.gyros.min_scale      = -90*pi/180;
Sensors.gyros.scale_division = (Sensors.gyros.max_scale - Sensors.gyros.min_scale)/(2^16-1);

if Sensors.gyros.on && Sensors.on == 1
    Sensors.gyros.Noise = Sensors.gyros.noiseOn * ...
        sqrt(Sensors.gyros.arw.^2./dT + 1/12*Sensors.gyros.rrw.^2.*dT) .* ...
        [normrnd(0,deg2rad(1)), normrnd(0,deg2rad(1)), normrnd(0,deg2rad(1))];

    w_read = x(11:13) + Sensors.gyros.BiasError' + Sensors.gyros.Noise';

    if Sensors.gyros.ratingOn == 1
        w_read = sensor_rating(w_read, Sensors.gyros.max_scale, ...
                               Sensors.gyros.min_scale, Sensors.gyros.scale_division)';
    end
end

%% Sun Sensors
Sensors.sunSensors.on       = 1;
Sensors.sunSensors.noiseOn  = 1;
Sensors.sunSensors.biasOn   = 1;
Sensors.sunSensors.ratingOn = 1;

Sensors.sunSensors.mode = 1;
Sensors.sunSensors.V0   = 1415e-3*[1,1,1,1,1,1]; % [V] output at normal incidence

% Calibration: responsivity [V/(W/m²)], ORIEL 1000 W/m² reference source
Sensors.sunSensors.R          = 1415e-3/1000*[1,1,1,1,1,1];
Sensors.sunSensors.D          = [1,1,1,1,1,1]; % cosine-law deviation (LUT used instead)
Sensors.sunSensors.biasError  = 12e-3*[1,1,1,1,1,1]; % dark-current bias [V]
Sensors.sunSensors.sigmaNoise = 0.2*[1,1,1,1,1,1];   % Gaussian noise STD [V]

% ADC quantization
Sensors.sunSensors.max_scale      = 2500e-3; % [V]
Sensors.sunSensors.min_scale      = 0;
Sensors.sunSensors.scale_division = 2e-3;    % [V/LSB]
