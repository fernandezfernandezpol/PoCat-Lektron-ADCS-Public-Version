function p = Period( a, mu )

%--------------------------------------------------------------------------
%   Compute the period for any orbit.
%   You can specify a semi-major axis or a Cartesian position. The default
%   central body is the Earth.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   p = Period( a, mu )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   a            (1,1) or (6,1)  Semi-major axis (is inf for a parabola and -
%                                for a hyperbola) or [x;y;z;vX;vY;vZ]
%   mu           (1,1)           Gravitational parameter (default = 3.98600436e5)
%
%   -------
%   Outputs
%   -------
%   p            (1,1)           Period
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993-1999 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 2 )
  mu = 3.98600436e5;
end

if( length(a) == 6 )
  el = RV2El( a(1:3), a(4:6), mu );
  a  = el(1);
end

i = find( a <= 0 | a == inf );

if( ~isempty(i) )
  p(i) = inf*ones(size(i));
end

i = find( a > 0 & a < inf );

if( ~isempty(i) )
  p(i) = 2*pi*sqrt(a(i).^3/mu);
end

if( nargout == 0 )
  Plot2D(a,p,'Semi-major Axis','Period','Orbit Period')
  clear p
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-24 10:01:20 -0400 (Wed, 24 Jul 2013) $
% $Revision: 34577 $
