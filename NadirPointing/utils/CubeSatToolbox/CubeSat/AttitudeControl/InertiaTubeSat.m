function inertia = InertiaTubeSat( l, mass )

%% Compute the inertia of a TubeSat. 
% This assumes a cylindrical shape  and the mass is uniformly distributed
% throught the volume. This is a good first cut.
%
% Type InertiaTubeSat for a demo. See also TubeSatFaces.
%------------------------------------------------------------------------
%   Form:
%   inertia = InertiaCubeSat( type, mass )
%------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   l      (1,1)     Either (1,2,3,4) for single, double, triple or quad
%   mass   (1,1)     Mass (kg)
%
%   -------
%   Outputs
%   -------
%   inertia (3,3)     Inertia matrix (kg-m^2)
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%------------------------------------------------------------------------
% Since version 11.
%------------------------------------------------------------------------

% Demo
%-----
if( nargin < 1 )
    InertiaTubeSat(1,0.5);
    return
end

if isnumeric(l)
  if length(l)~=1
    error('Please provide a single factor.')
  end
else
  error('Input must be a scalar factor');
end

L = 0.127*l;   % Standard length
OD = 0.0894*l; % Outer diameter
R = OD/2;

% Calculation
%------------
inertia = Inertias( mass, [R L],'cylinder', 1 );

% Default output
%---------------
if( nargout < 1 )
    disp(sprintf('CubeSatInertia\n---------------------'))
    disp(sprintf('Mass = %12.2f kg',mass));
    disp(sprintf('Ixx  = %8.2e kg-m^2', inertia(1,1) ))
    disp(sprintf('Iyy  = %8.2e kg-m^2', inertia(2,2) ))
    disp(sprintf('Izz  = %8.2e kg-m^2', inertia(3,3) ))
    disp(sprintf('Ixy  = %8.2e kg-m^2', inertia(1,2) ))
    disp(sprintf('Ixz  = %8.2e kg-m^2', inertia(1,3) ))
    disp(sprintf('Iyz  = %8.2e kg-m^2', inertia(2,3) ))
    clear d;
end
    


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 14:16:11 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41946 $
