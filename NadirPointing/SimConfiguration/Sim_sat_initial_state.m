%% Initial State
% The state vector is [position;velocity;quaternion;angular velocity;
% battery state of charge].
%--------------------------------------------------------------------------

%Satellite altitude
% a0    = 6387.165+500; % km
% (M1) FIX: Likely typo — Earth equatorial radius is 6378.165 km, not 6387.165 km.
%           Sets orbital altitude ~509 km instead of intended 500 km (~9 km bias).
a0 = 6378.165 + 500; % km

%Satellite initial velocity
v    = VOrbit(a0);

%satellite initial position in ECI
r0    = [a0;0;0];                 % Position vector

%Satellite initial velocity in ECI
v0    = [0;0;v];                 % Velocity vector

%Satellite initial quaternion
% q0 = randn(4,1); % Generar un vector aleatorio de 4 elementos
% q0 = q0 / norm(q0); % Normalizar el cuaternión para que tenga magnitud 1
% q0=[0.8924;0.0989;0.2393;0.3693]; %Main quaternion
q0 = [0.7071;0;0.7071;0];
% q0 = [1;0;0;0];
q0 = q0 / norm(q0);
% q0=[0.282051597168532;0.683091541439498;0.613312153382015;0.278713194991566];
% q0=[0.54022;0.681;0.4496;0.2054];

%Satellite initialangular velocity
% w0    = [0;0;0];                 % Angular rate of spacecraft
w0    = [OrbRate(a0);-OrbRate(a0);OrbRate(a0)]; 
% w0 = 5*[1;1;1]*pi/180;
% w0 = [15;15;15]*pi/180;
% w0    = [3;2;-4]*pi/180; 
% w0    = [25;15;-20]*pi/180; 
% w0    = [5;10;-7]*pi/180; 

%Satellite initial battery state of charge
% b0 = 20000;
% (M5) FIX: b0 exceeds battery capacity (1400 mAh × 3.6 × 3.3 V = 16632 J).
%           Battery state stays clamped at b0 for the entire sunlit phase.
b0 = 16632; % J  (full charge = 1400 mAh × 3.6 × 3.3 V)

%Satellite state vector
x = [r0;v0;q0;w0;b0];
% PltOrbit( el, d.jD0 );
% p.eci_vector = r0/norm(r0);
% (C3) FIX: r0/norm(r0) is the zenith direction (+radial). For nadir pointing negate it.
%           Also update p.eci_vector in NadirPointing.m (inside loop) accordingly.
p.eci_vector = r0/norm(r0);
% (m4) NOTE: p is reused as the PID struct in Sim_PID_controller.m (p = PID3Axis2),
%            which overwrites all p.* fields set here. Use a distinct name there.