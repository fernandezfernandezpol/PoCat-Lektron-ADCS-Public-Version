%% Time Parameters
% Sets the integration step dT [s] and total step count nSim for one orbit.
tic
orbits = 1;
tEnd   = orbits * Period(a0);
dT     = 0.25;        % integration step [s]
nSim   = floor(tEnd/dT);
