%% Magnetorquer Coil Area Calculation
% Standalone design script — not called during simulation.
% Computes the effective coil-area coefficient (sum of N*A over all turns and
% layers) for each magnetorquer axis, then estimates the achievable magnetic
% dipole moment at the rated drive current.
%
% Results from Sim_data_structure use IomA = 150 mA (peak H-bridge drive).
% This script uses IomA = 32 mA as a conservative operating point.

% --- Lateral-face coils (X and Z axes) ---
Lmm = 32.3; Lm = Lmm * 1e-3; % outer side length [m]
dmm = 0.22;  dm = dmm * 1e-3; % wire diameter [m]
wmm = 0.22;  wm = wmm * 1e-3; % turn pitch [m]
Nturns  = 38;
Nlayers = 4;

coef_surface_lat = 0;
for i = 1:Nturns
    side_i           = Lm - 2*(i-1)*(wm + dm);
    coef_surface_lat = coef_surface_lat + Nlayers * side_i^2;
end

% --- Top-face coil (Y axis) ---
Lmm = 26.2; Lm = Lmm * 1e-3;
dmm = 0.20;  dm = dmm * 1e-3;
wmm = 0.25;  wm = wmm * 1e-3;

coef_surface_top = 0;
for i = 1:Nturns
    side_i           = Lm - 2*(i-1)*(wm + dm);
    coef_surface_top = coef_surface_top + Nlayers * side_i^2;
end

% --- Dipole moment at rated current ---
IomA = 32; IoA = IomA * 1e-3; % [A]

Sx = coef_surface_lat;
Sy = coef_surface_top;
Sz = Sx;

Moment_lat = IoA * Sx;
Moment_top = IoA * Sy;
