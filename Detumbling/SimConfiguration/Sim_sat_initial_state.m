%% Initial State
% Defines x, the 14-element state vector [r(3); v(3); q(4); w(3); battery(1)].

% Orbit: semi-major axis from top of an altitude range, 90 deg inclination
altitude = 400:15:500;
a0       = Constant('equatorial radius earth') + altitude(end); % km

inclination = 90 * degToRad; % rad

v  = VOrbit(a0);
r0 = [a0;0;0]; % ECI position [km]
v0 = [0;0;v];  % ECI velocity [km/s]

% Random initial quaternion (uniform on SO(3) via normalized Gaussian)
q0 = randn(4,1);
% q0 = [0.8498;0.1756;0.3765;0.3246];
% q0 = [0.0305;0.2628;-0.1852;-0.9464];
q0 = q0 / norm(q0);
% q0 = [0.8924;0.0989;0.2393;0.3693];
% q0 = [-0.7944;0.047;0.3556;0.4902];
% q0 = [0.54022;0.681;0.4496;0.2054];

% Initial angular rate — high spin to represent worst-case post-deployment tumbling
% w0 = [0;0;0];
% w0 = [OrbRate(a0);-OrbRate(a0);OrbRate(a0)];
% w0 = [1;2;-1] * degToRad;
w0 = [90;90;90]*degToRad;
% w0 = [10;5;-5]*degToRad;
% w0 = [70*pi/180;OrbRate(a0);OrbRate(a0)];

b0 = 20000; % Initial battery charge [J]

x = [r0;v0;q0;w0;b0];
