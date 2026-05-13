%% MKF Initialization parameters

KF.q0 = q0;                 %Initial quaternion
KF.w0 = w0;                 %Initial angular velocity
KF.I3 = eye(3);             %Identity matrix 3x3
KF.I6 = eye(6);             %Identity matrix 6x6
KF.Z3 = zeros(3);           %Zero matrix 3x3
KF.std_deltaq = deg2rad(2); %Standard deviation angular deltaq rad
KF.std_w = deg2rad(0.1);    %Standard deviation angular speed rad/s
KF.sim_state = 1;
KF.std_v = 1.5*10^-6; %T
KF.std_Qw = 10^-3;
KF.Qw = (KF.std_Qw).* KF.I3;


% KF.P0 = [KF.std_deltaq^2*KF.I3 KF.Z3; KF.Z3 KF.std_w0^2*KF.I3]; %Initial Covariance matrix
KF.P0 = 10^-3*KF.I6;
KF.Rv = (KF.std_v)^2 .* KF.I3;
KF.Rw = (KF.std_w)^2 .* KF.I3;
KF.Qn = [dT^3/3.*KF.Qw dT^2/2.*KF.Qw ; dT^2/2.*KF.Qw dT.*KF.Qw];