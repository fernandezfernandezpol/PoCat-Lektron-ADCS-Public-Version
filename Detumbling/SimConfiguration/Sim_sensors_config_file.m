%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  SENSORS CONFIGURATION FILE   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  SENSORS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
Sensors.on=1;

%% MAGNETOMETER (XSENS MTI)
%%-------------------------------------------------------------------------

Sensors.magnetometer.on=1;
safeFact = 0.1;   % security factor

Cm1std = [0.005144464, 0.002784961, 0.002428284;
          0.002784961, 0.004001455, 0.001122388;
          0.002428284, 0.00112217, 0.004000846]*safeFact;       % STD calibration matrix magnetometer 
Sensors.magnetometer.Cerror = normrnd(eye(3),Cm1std);%%Error in the calibration matrix
bm1std = [42.946099, 24.277434, 37.842037]*1e-9*safeFact;       % STD in BIAS ESTIMATION magnetometer 

Sensors.magnetometer.biasError = normrnd([0,0,0],bm1std);%%Error in the bias calibration
Sensors.magnetometer.sigmaNoise=[14, 15, 20]*10^-9*safeFact;%T  % STD of BIAS Gaussian noise magnetometer 

Sensors.magnetometer.MaxX = 0.2; % A*m^2 Max dipole moment of X-axis MTQ
Sensors.magnetometer.MaxY = 0.2; % A*m^2 Max dipole moment of Y-axis MTQ
Sensors.magnetometer.MaxZ = 0.2; % A*m^2 Max dipole moment of Z-axis MTQ

%GYROSCOPES
%--------------------------------------------------------------------------

%Activation
Sensors.gyros.on = 1;
Sensors.gyros.noiseOn = 1;
Sensors.gyros.biasOn = 1;
Sensors.gyros.ratingOn = 1;

%Sensor parameters
Cgstd = [0.030126101,0.086968229,0.020780010;...
        0.024061195,0.031376110,0.043422602;...
        0.031325418,0.056554503,0.042132247]*safeFact;
Sensors.gyros.Cerror = normrnd(eye(3),Cgstd);%%Error in the calibration matrix
bgstd = [0.1,0.1,0.1]*safeFact;
Sensors.gyros.BiasError = normrnd([0,0,0],bgstd);%%Error in the bias calibration

%% BEWARE!! GYROS RANDOM WALK. THIS ERROR IS NOT PRESENT IN OTHER SENSORS!
Sensors.gyros.bias0=([normrnd(0,3),normrnd(0,3),normrnd(0,3)] + Sensors.gyros.BiasError)*pi/180; %initial bias (b(t0)=b0) [rad/s]
Sensors.gyros.arw = [0.0378,0.0662,0.05417]*pi/180;%Angle Random Walk --> units [rad/sqrt(s)] || Standard -->IEEE Std. 952-2004
Sensors.gyros.rrw = [0.00013339,0.0001783,0.00010072]*pi/180;%Rate Random Walk --> units [rad/sqrt(s^3)] || Standard -->IEEE Std. 952-2004
           
Sensors.gyros.max_scale = 300*pi/180;
Sensors.gyros.min_scale = -300*pi/180;
Sensors.gyros.scale_division= (Sensors.gyros.max_scale-Sensors.gyros.min_scale)/(2^16-1);
% 
% 
% if Sensors.gyros.on && Sensors.on == 1
%  
%     %Gyro Noise
%     Sensors.gyros.Noise= Sensors.gyros.noiseOn*sqrt(Sensors.gyros.arw.^2./dT + 1/12*Sensors.gyros.rrw.^2.*dT).*[normrnd(0,1),normrnd(0,1),normrnd(0,1)];
%     
%     w_read = Sensors.gyros.Cerror*x(11:13) + Sensors.gyros.BiasError' + Sensors.gyros.Noise';%Real measurement
%     
%     if Sensors.gyros.ratingOn == 1%Convert to digital signal
%     w_read = sensor_rating(w_read, Sensors.gyros.max_scale,Sensors.gyros.min_scale,Sensors.gyros.scale_division)';
%     end
% end

%SUN SENSORS
%--------------------------------------------------------------------------

%Acctivation
Sensors.sunSensors.on = 1;
Sensors.sunSensors.noiseOn = 1;
Sensors.sunSensors.biasOn = 1;
Sensors.sunSensors.ratingOn = 1;

%Sensor parameters
Sensors.sunSensors.mode = 1;
Sensors.sunSensors.V0 = 1415e-3*[1,1,1,1,1,1];%[V]     Output voltage for a "Sun" source at 0 deg (nadir/zenith) for nominal illumination
              
Sensors.sunSensors.R = 1415e-3/1000*[1, 1, 1, 1, 1, 1];%Calibration factors [V/(W/m2)]  % ORIEL'S light source provided 1000 W/m^2
Sensors.sunSensors.D = [1, 1, 1, 1, 1, 1];% Deviation form cosine law directivity DOES NOT APPLY. A LUT WAS USED INSTEAD
Sensors.sunSensors.biasError=12e-3*[1, 1, 1, 1, 1, 1]; %Dark current bias [mV]
Sensors.sunSensors.sigmaNoise=20e-3*[1, 1, 1, 1, 1, 1]; %Sun sensor noise [mV]
           
Sensors.sunSensors.max_scale = 2500e-3;  % [mV]
Sensors.sunSensors.min_scale = 0;        % [mV]
Sensors.sunSensors.scale_division= 2e-3; % [mV]

% % Añadir el sesgo de corriente oscura
% V_with_bias = V_ideal + Sensors.sunSensors.biasError;
% 
% % Añadir ruido aleatorio
% noise = normrnd(0, Sensors.sunSensors.sigmaNoise);
% V_measured = V_with_bias + noise;
