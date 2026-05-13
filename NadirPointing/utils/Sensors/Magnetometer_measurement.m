%% MAGNETOMETER (XSENS MTI)
%%-------------------------------------------------------------------------

%Uncertainty in the calibration
Cm1std = [0.005144464, 0.002784961, 0.002428284;
          0.002784961, 0.004001455, 0.001122388;
          0.002428284, 0.00112217, 0.004000846]*safeFact;       % STD calibration matrix magnetometer 
Sensors.magnetometer.Cerror = normrnd(eye(3),Cm1std);%%Error in the calibration matrix
bm1std = [42.946099, 24.277434, 37.842037]*1e-9*safeFact;       % STD in BIAS ESTIMATION magnetometer 

%Noise error
Sensors.magnetometer.biasError = normrnd([0,0,0],bm1std);%%Error in the bias calibration
Sensors.magnetometer.sigmaNoise=[1, 1, 1]*4*10^-8*safeFact;%T  % STD of BIAS Gaussian noise magnetometer 

% Add bias error and calibration matrix error
B_body_frame_with_bias = (Sensors.magnetometer.Cerror * bfieldBODY) + Sensors.magnetometer.biasError';
    
% Add the noise at the sample
noise = normrnd(0, Sensors.magnetometer.sigmaNoise);
d.fieldBODY = B_body_frame_with_bias + noise';