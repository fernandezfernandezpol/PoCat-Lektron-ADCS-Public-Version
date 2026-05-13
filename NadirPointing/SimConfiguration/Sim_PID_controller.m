%% Design the PID Controller
% Specify the Y body axis for alignment with the chosen ECI vector
%-----------------------------------------------------------------

p = PID3Axis2;
% (m4) NOTE: Reassigns p, overwriting the orbit/pointing struct set in
%            Sim_sat_initial_state.m (p.eci_vector). Consider a distinct name.

% Inertia_matrix_raw = [131657.12 -301.4 -1229.8; -301.4 114011.54 -390.13; -1229.8 -390.13 125414.51];
% 
% % CONVERSIÓN DE UNIDADES: Asumiendo g*mm^2 a kg*m^2
% conversion_factor = 1e-9; 
% Inertia_matrix = Inertia_matrix_raw * conversion_factor;
% d.inertia = Inertia_matrix;

Inertia_matrix = 1e-9 * [125496.77   -584.95   240.80;
                        -584.95   105534.17   -266.4;
                        240.80   -266.4   121177.15];
[V, D]         = eig(Inertia_matrix);
Inertia_matrix = mean(diag(D)) * eye(3);
d.inertia      = Inertia_matrix;

[p.a, p.b, p.c, p.d, constants] = PIDMIMO( Inertia_matrix, 1, 0.005/4, 300, 0.1, dT,'Delta');
% [p.a, p.b, p.c, p.d, constants] = PIDMIMO( Inertia_matrix, 1e6, 0, 3e6, 0.1, dT,'Delta');

p.inertia            = d.inertia;
p.max_angle          = 0.01;
p.accel_sat          = [100;100;100];
p.mode               = 1;
p.q_target_last      = q0;
p.q_desired_state    = [1;0;0;0];
p.eci_vector         = x(1:3)/norm(x(1:3));
p.body_vector        = [0;0;1];
% p.vector_angle       = [0;0;1];
% m_max                = [0.01595,0.00841,0.01595];
m_max                = [Sx,Sy,Sz] * 150 / 1e3;
p.vector_angle       = [0;0;-1];
% m_max = [0.01595,0.00841,0.01595];
