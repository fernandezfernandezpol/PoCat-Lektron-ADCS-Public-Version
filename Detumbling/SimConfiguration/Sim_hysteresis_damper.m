%% Hysteresis Damper
% Configures the passive hysteresis-rod subsystem when d.HR == 1.
% Two damping types are available:
%   Type 1 — linear viscous damping (constant × angular rate)
%   Type 2 — physics-based nonlinear hysteresis model (RHSHysteresisDamper)

if d.HR
    d.dampingType = 2;

    if d.dampingType == 1
        d.dampingData = 1e-6; % viscous damping constant [N·m·s/rad]
        d.dampingFun  = [];
        z             = [];
    else
        % Load B-H curve data for the ferromagnetic rod material
        HyMu80;

        % Unit vectors along each rod axis (one rod per body axis)
        d.dampingData.u = [[1;0;0] [0;1;0] [0;0;1]];
        nBars           = size(d.dampingData.u, 2);

        % Rod dimensions: circular cross-section, radius 1 mm, length 25 mm
        d.dampingData.v = pi*0.001^2*0.025*ones(1, nBars);

        d.dampingFun = @RHSHysteresisDamper;

        % Initialize rod magnetization from the field at t=0
        uECI     = QTForm(q0, d.dampingData.u);
        hMag     = Dot(uECI, bI)   / mu0;
        hMagDot  = Dot(uECI, bIDot) / mu0;
        z0       = BFromHHysteresis( hMag, hMagDot, d.dampingData );

        % Append rod magnetization states to the state vector
        x = [x; z0'];
    end
end
