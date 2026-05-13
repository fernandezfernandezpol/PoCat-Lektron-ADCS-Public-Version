function t = TorqueHysteresisDamper( u, b, v, bE, r )

%--------------------------------------------------------------------------
%   Torque from a hysteresis damper.
%
%   See MagneticHysteresis.
%
%   Since version 10.
%--------------------------------------------------------------------------
%   Form:
%   t = TorqueHysteresisDamper( u, b, v, bE )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   u                  (3,1) Damper unit vector in the body frame
%   b                  (1,1) Damper axial flux density (T)
%   v                  (1,1) Volume of damper (m^3)
%   bE                 (3,1) Earth's magnetic field in the body frame (T)
%
%   -------
%   Outputs
%   -------
%   t                  (3,1) Torque
%
%--------------------------------------------------------------------------
%   Reference: Kumar R., Mazanek, D. and Heck, M., "Simulation and Shuttle
%              Hitchhiker Validation of Passive Satellite
%              Aerostabilization," Journal of Spacecraft and 
%              Rockets, Vol. 32, No. 5, September-October 1995.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2011, 2014 Princeton Satellite Systems, Inc.
%   All Rights Reserved
%--------------------------------------------------------------------------

mu0 	= 4e-7*pi;
t     = v * b * Cross(u, bE) / mu0;

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-11 14:11:51 -0400 (Wed, 11 Mar 2015) $
% $Revision: 39857 $



