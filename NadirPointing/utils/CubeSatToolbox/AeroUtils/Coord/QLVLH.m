function q = QLVLH( r, v )

%% Generate the quaternions that transform from ECI to LVLH coordinates.
% For LVLH coordinates;
% z is in the -r direction
% y is in the - rxv direction
% x completes the set; along v in a circular orbit
%
% Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   q = QLVLH( r, v )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   r          (3,n) Position vectors
%   v          (3,n) Velocity vectors
%
%   -------
%   Outputs
%   -------
%   q          (4,n) Quaternions
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1995 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

cR = size(r,2); 

y       = Unit( Cross( v, r ) );
z       = Unit( -r );
x       = Unit( Cross( y, z ) ); 

q       = zeros(4,cR);

for k = 1:cR
  m       = [x(:,k)';...
             y(:,k)';...
			 z(:,k)'];
  q(:,k)  = Mat2Q( m );
end

if( nargout == 0 )
  Plot2D(1:cR,q,'Sample','Quaternion','Q ECI To LVLH');
  clear q
end

% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:25:16 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41949 $
