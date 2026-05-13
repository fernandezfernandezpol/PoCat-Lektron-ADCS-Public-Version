function [d,x,p] = DetumblingFunction(x,d,p,bField,dT,Sensors)

%% Detumbing Function for a CubeSat orbit and attitude dynamical model.
%
% Calculates the torque that the magnetometers have to do to detumble the
% satellite
%
% The states are [position;velocity;quaternion;angular velocity; battery charge].
% The battery charge must always be the last state. Its units are J. If there
% are wheel states they must be between the spacecraft angular velocity and the
% battery charge, and the indices be logged in kWheels.
%--------
%
%   ------
%   Inputs
%   ------
%   x        (14,1)    [r;v;q;w;wRWA;b]
%   d          (.)     Data structure
%                      .jD0      (1,1) Julian date of epoch
%                      .mass     (1,1) Spacecraft mass (kg)
%                      .inertia  (3,3) Inertia matrix (kg-m2)
%                      .dipole   (3,1) Residual dipole (ATM^2)
%                      .power     (.)  Power data, see SolarCellPower 
%                      .aeroModel    * Handle, see CubeSatAero
%                      .opticalModel * Handle, see CubeSatRadiationPressure
%                      .surfData  (.)  optional; empty to skip drag/optical calcs
%                                      .cD    (3,1) Drag coefficient
%                                      .cM    (3,1) Center of mass (m)
%                                      .area  (1,n) Area (m2)
%                                      .nFace (3,n) Face normals
%                                      .rFace (3,n) Face locations (m)
%                                      .att    (.)  Attitude model
%                                      .sigma (3,n) Optical coefficients
%                                      .planet (1)  Planet effects flag
%                      .atm       (.) optional; empty to skip J70 and use AtmDens2
%                      .kWheels         (n), empty if no wheels, indices of wRWA
%                      .inertiaRWA     (1,1), optional, polar inertia (kg-m2)
%                      .tRWA           (3,1), optional, wheel torque (Nm)
%   p           (.)     %Y: what is p?
%   bField    (1,3)     Magnetic Field 
%   dT         (1,1)
%   Sensors    (.)     .magnetometers
%                      .gyros
%                      .sunsensor
%
%   -------
%   Outputs
%   -------
%   d          (.)     Data structure
%                      .jD0      (1,1) Julian date of epoch
%                      .mass     (1,1) Spacecraft mass (kg)
%                      .inertia  (3,3) Inertia matrix (kg-m2)
%                      .dipole   (3,1) Residual dipole (ATM^2)
%                      .power     (.)  Power data, see SolarCellPower 
%                      .aeroModel    * Handle, see CubeSatAero
%                      .opticalModel * Handle, see CubeSatRadiationPressure
%                      .surfData  (.)  optional; empty to skip drag/optical calcs
%                                      .cD    (3,1) Drag coefficient
%                                      .cM    (3,1) Center of mass (m)
%                                      .area  (1,n) Area (m2)
%                                      .nFace (3,n) Face normals
%                                      .rFace (3,n) Face locations (m)
%                                      .att    (.)  Attitude model
%                                      .sigma (3,n) Optical coefficients
%                                      .planet (1)  Planet effects flag
%                      .atm       (.) optional; empty to skip J70 and use AtmDens2
%                      .kWheels         (n), empty if no wheels, indices of wRWA
%                      .inertiaRWA     (1,1), optional, polar inertia (kg-m2)
%                      .tRWA           (3,1), optional, wheel torque (Nm)
%   x        (14,1)	   d[r;v;q;w;b]/dt
%   p         (.)       data
%
% ------------------------------
%   Since version 1 (2017).


kd=1e6;
%Y: Unused variables?
 qECIToBody   = x(7:10);
 r = x(1:3);
 v = x(4:6);
q = x(7:10);
w = x(11:13);

% %DETUMBLING____________________

%if norm(w) > norm(0.005*[1;1;1])
%[bFieldECI, bFieldDotECI]	= BDipole(r,jD,v);

  %  bField       = BDipole( x(1:3), d.jD0+t/86400 );
p.bFieldBody	  = bField;
Bdot              = (p.bFieldBody - p.bFieldBody_before)./dT;
p.bFieldBody_before  = p.bFieldBody;
%p.bFieldECI = bFieldECI;
%p.bFieldDotECI = bFieldDotECI;


  % Control system momentum management
  %-----------------------------------
 d.dipole     = -kd*diag(d.inertia).*Bdot; % Amp-turns m^2

 %Y:Why limit the dipole moment with the magnetometer's range?
 
  if abs(d.dipole(1)) > Sensors.magnetometer.MaxX
        d.dipole(1) = sign(d.dipole(1)).*Sensors.magnetometer.MaxX;
    end
    if abs(d.dipole(2)) > Sensors.magnetometer.MaxY
        d.dipole(2) = sign(d.dipole(2)).*Sensors.magnetometer.MaxY;
    end
    if abs(d.dipole(3)) > Sensors.magnetometer.MaxZ
        d.dipole(3) = sign(d.dipole(3)).*Sensors.magnetometer.MaxZ;
    end
 
 p.torqueDipole	= Cross(d.dipole,p.bFieldBody);

end

