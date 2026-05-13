%% Thermal Model Configuration
% Sets surface optical properties (absorptivity α, emissivity ε) per face
% as a weighted mix of the actual materials covering each face.

% Face unit outward normals (body frame): [+X, -X, +Y, -Y, +Z, -Z]
d.uSurface = [1  -1  0   0  0  0;
              0   0  1  -1  0  0;
              0   0  0   0  1 -1];

% Material optical properties
alpha_GaAs   = 0.88; epsilon_GaAs   = 0.80; % GaAs solar panel
alpha_gold   = 0.25; epsilon_gold   = 0.02; % gold foil
alpha_silver = 0.37; epsilon_silver = 0.44; % silver foil
alpha_black  = 0.95; epsilon_black  = 0.85; % black paint (antenna mounts)

% Effective absorptivity per face from area-weighted material fractions
alpha_side   = 0.62*alpha_GaAs + (1 - 0.62 - 2*0.6*10/100)*alpha_gold + (2*0.6*10/100)*alpha_black;
alpha_top    = 0.62*alpha_GaAs + (1 - 0.62 - 4*0.6*0.6/100)*alpha_gold + 4*0.6*0.6/100*alpha_black;
alpha_bottom = (1 - 4*0.6*0.6/100)*alpha_gold + 4*0.6*0.6/100*alpha_black;

% Effective emissivity per face
epsilon_side   = 0.62*epsilon_GaAs + (1 - 0.62 - 2*0.6*10/100)*epsilon_gold + (2*0.6*10/100)*epsilon_black;
epsilon_top    = 0.62*epsilon_GaAs + (1 - 0.62 - 4*0.6*0.6/100)*epsilon_gold + 4*0.6*0.6/100*epsilon_black;
epsilon_bottom = (1 - 4*0.6*0.6/100)*epsilon_gold + 4*0.6*0.6/100*epsilon_black;

d.alpha   = [alpha_side alpha_side alpha_side alpha_side alpha_bottom alpha_top];     % (1,6) absorptivity
d.epsilon = [epsilon_side epsilon_side epsilon_side epsilon_side epsilon_bottom epsilon_top]; % (1,6) emissivity
d.area    = 0.1*0.1*ones(1,6); % face area [m²]
d.cP      = 900;               % specific heat capacity [J/(kg·K)]
d.powerTotal = d.power.consumption; % internal dissipation [W]
T0           = 25 + 273.15;        % initial temperature [K]
