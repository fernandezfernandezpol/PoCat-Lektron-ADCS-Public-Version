%% ERROR GYRO
safeFact = 1;

bgstd = [0.1,0.1,0.1]*safeFact*pi/180;
Sensors.gyros.BiasError = normrnd([0,0,0],bgstd);%%Error in the bias calibration

%%BEWARE!! GYROS RANDOM WALK. THIS ERROR IS NOT PRESENT IN OTHER SENSORS!
Sensors.gyros.bias0=([normrnd(0,3),normrnd(0,3),normrnd(0,3)] + Sensors.gyros.BiasError)*pi/180; %initial bias (b(t0)=b0) [rad/s]
Sensors.gyros.arw = [0.0378,0.0662,0.05417]*pi/180;%Angle Random Walk --> units [rad/sqrt(s)] || Standard -->IEEE Std. 952-2004
Sensors.gyros.rrw = [0.00013339,0.0001783,0.00010072]*pi/180;%Rate Random Walk --> units [rad/sqrt(s^3)] || Standard -->IEEE Std. 952-2004
           
Sensors.gyros.max_scale = 200*pi/180;
Sensors.gyros.min_scale = -200*pi/180;
Sensors.gyros.scale_division= (Sensors.gyros.max_scale-Sensors.gyros.min_scale)/(2^16-1);

if Sensors.gyros.on && Sensors.on == 1

    %Gyro Noise
    Sensors.gyros.Noise= Sensors.gyros.noiseOn*sqrt(Sensors.gyros.arw.^2./dT + 1/12*Sensors.gyros.rrw.^2.*dT).*[normrnd(0,deg2rad(0.1)),normrnd(0,deg2rad(0.1)),normrnd(0,deg2rad(0.1))];%RAD/s

    % w_read = Sensors.gyros.Cerror*x(11:13) + Sensors.gyros.BiasError' + Sensors.gyros.Noise';%Real measurement
    w_meas = x(11:13) + Sensors.gyros.BiasError' + Sensors.gyros.Noise';%Real measurement
    gyro_nonoise(:,k) = x(11:13);
    gyro_noise(:,k)= w_meas;

    
    if Sensors.gyros.ratingOn == 1%Convert to digital signal
        w_meas = sensor_rating(w_meas, Sensors.gyros.max_scale,Sensors.gyros.min_scale,Sensors.gyros.scale_division)';
    end
end

if Sensors.gyros.queue_pos == Sensors.gyros.queue_size
% (M8) FIX: queue_pos, queue_size, and queue are not initialized in
%           Sim_sensors_config_file.m; this block errors on the first call.
%           Add to Sim_sensors_config_file.m:
%           Sensors.gyros.queue_size = 5;
%           Sensors.gyros.queue_pos  = 1;
%           Sensors.gyros.queue      = zeros(3, Sensors.gyros.queue_size);
    Sensors.gyros.queue_pos=1;
end

Sensors.gyros.queue(1,Sensors.gyros.queue_pos)=w_meas(1);
Sensors.gyros.queue(2,Sensors.gyros.queue_pos)=w_meas(2);
Sensors.gyros.queue(3,Sensors.gyros.queue_pos)=w_meas(3);


w_read(1) = sum(Sensors.gyros.queue(1,:))/Sensors.gyros.queue_pos;
w_read(2) = sum(Sensors.gyros.queue(2,:))/Sensors.gyros.queue_pos;
w_read(3) = sum(Sensors.gyros.queue(3,:))/Sensors.gyros.queue_pos;
% w_read = mean(Sensors.gyros.queue,2);

gyro_noise_av(:,k)=w_read;
Sensors.gyros.queue_pos = Sensors.gyros.queue_pos+1;
w_read=w_meas;
% (M7) FIX: Overrides the moving-average computed on the three lines above,
%           making the entire queue logic (lines 32-47) dead code.
%           Either remove lines 32-47 or remove this line to enable averaging.