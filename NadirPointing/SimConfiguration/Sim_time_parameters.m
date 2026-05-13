%% Time parameters
% Specify the simulation duration and timestep.
%----------------------------------------------
tic
orbits = 2;
tEnd   = orbits*Period(a0); 
dT     = 1; 
nSim   = floor(tEnd/dT);

Input_delay = 0; %s