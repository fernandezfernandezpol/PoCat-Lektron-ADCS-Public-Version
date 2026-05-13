%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%  PID CONTROLLER CONFIGURATION FILE   %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Design the PID Controller
% Specify the z body axis for alignment with the chosen ECI vector
%-----------------------------------------------------------------
p                    = PID3Axis;
[p.a, p.b, p.c, p.d] = PIDMIMO( 1, 1, 0.01, 200, 0.1, dT ); 

p.inertia            = d.inertia;
p.max_angle          = 0.01;
p.accel_sat          = [100;100;100];
p.mode               = 1;
p.q_target_last      = q;
p.q_desired_state    = [0;0;0;1];
p.body_vector        = [0;0;1];
%% Design the PID Controller 2
% Specify the y body axis for alignment with the chosen ECI vector
p2                    = PID3Axis;
[p2.a, p2.b, p2.c, p2.d] = PIDMIMO( 1, 1, 0.01, 200, 0.1, dT ); 

p2.inertia            = d.inertia;
p2.max_angle          = 0.01;
p2.accel_sat          = [100;100;100];
p2.mode               = 1;
p2.q_target_last      = q;
p2.q_desired_state    = [0;0;0;1];
p2.body_vector        = [1;0;0];
%% Design the PID Controller 3
% Specify the x body axis for alignment with the chosen ECI vector

p3                    = PID3Axis;
[p3.a, p3.b, p3.c, p3.d] = PIDMIMO( 1, 1, 0.01, 200, 0.1, dT ); 

p3.inertia            = d.inertia;
p3.max_angle          = 0.01;
p3.accel_sat          = [100;100;100];
p3.mode               = 1;
p3.q_target_last      = q;
p3.q_desired_state    = [0;0;0;1];
p3.body_vector        = [0;0;1];

