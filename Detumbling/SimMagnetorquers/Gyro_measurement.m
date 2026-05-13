%% Gyroscope Measurement
% Injects bias and angle/rate random-walk noise into the true angular rate,
% then pushes the noisy reading into a moving-average queue. The queue
% smooths high-frequency noise before the reading is passed to the B-Dot law.

% Re-draw bias and noise at each measurement call
bgstd = [0.1,0.1,0.1]*safeFact*pi/180;
Sensors.gyros.BiasError = normrnd([0,0,0], bgstd);

Sensors.gyros.bias0 = ([normrnd(0,3), normrnd(0,3), normrnd(0,3)] + Sensors.gyros.BiasError)*pi/180;
Sensors.gyros.arw   = [0.0378, 0.0662, 0.05417]*pi/180;
Sensors.gyros.rrw   = [0.00013339, 0.0001783, 0.00010072]*pi/180;

Sensors.gyros.max_scale      =  200*pi/180;
Sensors.gyros.min_scale      = -200*pi/180;
Sensors.gyros.scale_division = (Sensors.gyros.max_scale - Sensors.gyros.min_scale)/(2^16-1);

if Sensors.gyros.on && Sensors.on == 1
    % Combined noise STD from angle random walk and rate random walk
    Sensors.gyros.Noise = Sensors.gyros.noiseOn * ...
        sqrt(Sensors.gyros.arw.^2./dT + 1/12*Sensors.gyros.rrw.^2.*dT) .* ...
        [normrnd(0,deg2rad(0.1)), normrnd(0,deg2rad(0.1)), normrnd(0,deg2rad(0.1))];

    w_meas          = x(11:13) + Sensors.gyros.BiasError' + Sensors.gyros.Noise';
    gyro_nonoise(:,k) = x(11:13);
    gyro_noise(:,k)   = w_meas;

    if Sensors.gyros.ratingOn == 1
        w_meas = sensor_rating(w_meas, Sensors.gyros.max_scale, ...
                               Sensors.gyros.min_scale, Sensors.gyros.scale_division)';
    end
end

% Circular moving-average queue — wraps around when full
if Sensors.gyros.queue_pos == Sensors.gyros.queue_size
    Sensors.gyros.queue_pos = 1;
end

Sensors.gyros.queue(1, Sensors.gyros.queue_pos) = w_meas(1);
Sensors.gyros.queue(2, Sensors.gyros.queue_pos) = w_meas(2);
Sensors.gyros.queue(3, Sensors.gyros.queue_pos) = w_meas(3);

w_read(1) = sum(Sensors.gyros.queue(1,:)) / Sensors.gyros.queue_pos;
w_read(2) = sum(Sensors.gyros.queue(2,:)) / Sensors.gyros.queue_pos;
w_read(3) = sum(Sensors.gyros.queue(3,:)) / Sensors.gyros.queue_pos;

gyro_noise_av(:,k)      = w_read;
Sensors.gyros.queue_pos = Sensors.gyros.queue_pos + 1;
w_read                  = w_meas;
