%% Controller Struct
% In detumbling mode the PID matrices (a,b,c,d) are not used for control;
% the B-Dot law is applied directly in the main loop. This script populates
% the p struct so that helper functions (U2Q, QTForm, etc.) have the fields
% they expect.

p = PID3Axis2;

Inertia_matrix = [131657.12 -301.4 -1229.8; -301.4 114011.54 -390.13; -1229.8 -390.13 125414.51];
[p.a, p.b, p.c, p.d, constants] = PIDMIMO( Inertia_matrix, 1, 0.005/4, 300, 0.1, dT,'Delta');
% [p.a, p.b, p.c, p.d, constants] = PIDMIMO( 1, 1, 0.005/2, 150, 0.1, dT );
% [p.a, p.b, p.c, p.d, constants] = PIDMIMO( 1, 1.2, 0.005/4, 300, 0.05, dT );

p.inertia         = d.inertia;
p.max_angle       = 0.01;
p.accel_sat       = [100;100;100];
p.mode            = 1;
p.q_target_last   = q0;
p.q_desired_state = [1;0;0;0];
p.eci_vector      = x(1:3)/norm(x(1:3));
p.body_vector     = [0;0;1];
p.vector_angle    = [0;0;1];
m_max             = [3.195e-04, 3.624e-04, 3.195e-04];
