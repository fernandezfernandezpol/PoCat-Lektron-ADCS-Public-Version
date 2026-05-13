%% Sensor Configuration
% Loads sensor noise and calibration parameters from the shared config file,
% then sets the active sensor flags for this run.
Sensors_Config_File;

Sensors.magnetometer.on = 1;
safeFact                = 1; % noise scaling factor (1 = nominal)
Sensors.sunSensors.on   = 1;
