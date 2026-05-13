%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%  Thermal control CONFIGURATION FILE   %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Thermal model
% Specify properties of each face . 

d.uSurface   = [1  -1  0   0  0  0;...      % (3,6) Surface unit vectors
                0   0  1  -1  0  0;...
                0   0  0   0  1 -1];
            
alpha_GaAs = 0.88;  epsilon_GaAs = 0.80;    % Solar panel
alpha_gold = 0.25;  epsilon_gold = 0.02;    % Gold foil
alpha_silver = 0.37;epsilon_silver = 0.44;  % Silver foil
alpha_black = 0.95; epsilon_black = 0.85;   % black painting

alpha_side   = 0.62*alpha_GaAs + (1 - 0.62 - 2*0.6*10/100)*alpha_gold + (2*0.6*10/100)*alpha_black;
alpha_top    = 0.62*alpha_GaAs + (1 - 0.62 - 4*0.6*0.6/100)*alpha_gold + 4*0.6*0.6/100*alpha_black;
alpha_bottom = (1 - 4*0.6*0.6/100)*alpha_gold + 4*0.6*0.6/100*alpha_black;

epsilon_side   = 0.62*epsilon_GaAs + (1 - 0.62 -2*0.6*10/100)*epsilon_gold + (2*0.6*10/100)*epsilon_black;
epsilon_top    = 0.62*epsilon_GaAs + (1 - 0.62 - 4*0.6*0.6/100)*epsilon_gold + 4*0.6*0.6/100*epsilon_black;
epsilon_bottom = (1 - 4*0.6*0.6/100)*epsilon_gold + 4*0.6*0.6/100*epsilon_black;

d.alpha      =  [alpha_side alpha_side alpha_side alpha_side alpha_bottom alpha_top];                     % {1,6} Absorptivity
d.epsilon    =  [epsilon_side epsilon_side epsilon_side epsilon_side epsilon_bottom epsilon_top];         % {1,6} Emissivity
d.area       = 0.1*0.1*ones(1,6);           % (1,6) Area
d.cP         = 900;                         % (1,1) Specific heat
d.powerTotal = d.power.consumption;         % (1,1) Internal power (W)
T0           = 25 + 273.15;                 % Initial temperature [K]