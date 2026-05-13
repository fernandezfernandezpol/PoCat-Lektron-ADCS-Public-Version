%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Data CubeSat CONFIGURATION FILE   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CubeSat model
% Initialize data structure
%--------------------------
d = RHSCubeSat;

%% CubeSats are 1 kg per U
%---------------
model = [0.5 0.5 0.5];%'3U';
[area,nFace,rFace] = CubeSatFaces( model, 1 );
d.mass = 0.25; % kg
d.inertia = abs(InertiaCubeSat( model, d.mass ));

%% Model data
%------------
d.surfData.area = area;
d.surfData.nFace = nFace;
d.surfData.rFace = rFace;
d.surfData.att.type = 'eci';

%% Reaction wheel design
%-----------------------
d.kWheels    = [14:16]; % indices of wheel states
radius       = 0.020;
thickness    = 0.004; % This is 4 mm
volRWA       = pi*radius^2*thickness;
massRWA      = volRWA*densityTungsten; % Mass from density x volume
d.inertiaRWA = (massRWA/2)*radius^2; % Polar inertia
thicknessSolarPanel = 0.004;

%% Add power system model
% Lithium batteries are 360000 J/kg according to 
% http://en.wikipedia.org/wiki/Lithium-ion_battery,
% so size the battery for 100 g = 36000 J = 10 Wh
% Solar cell efficieny is 27% to 29.5% according to Emcore,
% http://www.emcore.com/solar_photovoltaics/
%---------------------------------------------------------
d.power.solarCellNormal    = [1 1 -1 -1 0 0 0 0;0 0 0 0 1 1 -1 -1;0 0 0 0 0 0 0 0];
d.power.solarCellEff       = 0.295; 
d.power.effPowerConversion = 0.9;
d.power.solarCellArea      = 0.1*0.116*ones(1,8);
d.power.consumption        = 4;
d.power.batteryCapacity    = 36000; 
volSolarPanel              = d.power.solarCellArea(1,1)*thicknessSolarPanel;
massSolarPanel             = volSolarPanel *densitySilicon;
