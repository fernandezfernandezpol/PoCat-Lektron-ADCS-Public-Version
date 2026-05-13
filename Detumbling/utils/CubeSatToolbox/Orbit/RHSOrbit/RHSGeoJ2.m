function xDot = RHSGeoJ2( x, t, d )

%--------------------------------------------------------------------------
%   Computes the right hand side for Earth gravity with J2.
%
%   Since version 2014.
%--------------------------------------------------------------------------
%   Form:
%   xDot = RHSGeoHarm( x, t, d )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x           (6,1)    Position vector [rECI (km); vECI (km)];
%   t           (1,1)    Time since start Julian Date (s) 
%   d           (1,1)    Highest sectorial and tesseral harmonic 
%                        .j2    (1,1)	J2 term
%                        .mu    (1,1)	Spherical gravitational potential
%                        .a     (1,1)	Planet radius
%                        .jD0	  (1,1) Start Julian Date                    
%
%   -------
%   Outputs
%   -------
%   xDot        (6,1)   [rDot;vDot]
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	 Copyright (c) 2011 Princeton Satellite Systems, Inc.
%    All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 1 )
  x  = [6.935199226610737e+03; 6.935199226610738e+03; 1.950903220161282e+03;0;0;0];
  t  = 0;
end

if nargin < 3
  % GEM-T1 coefficients
  d.j2  = 0.00108262563430956;
  d.a   = 6378.137;
  d.mu  = 398600.436;
  d.jD0 = 2451545;
end

jD = d.jD0 + t/86400;

mECIToEF = ECIToEF( JD2T( jD ) );

rEF = mECIToEF*x(1:3);

[aG, aS, aZ] = AGravityC( rEF, d );

xDot = [x(4:6);mECIToEF'*aG];

if( nargout == 0 )
  aG
  aS
  aZ
end

%--------------------------------------------------------------------------
%   Compute the gravitational acceleration in cartesian coordinates. 
%   Acceleration vectors are a [ aX;aY;aZ ].
%--------------------------------------------------------------------------
%	 Reference: Bond, V. R. and M. C. Allman (1996.) Modern Astrodynamics.
%               Princeton. pp. 212-213.
%--------------------------------------------------------------------------
function [aG, aS, aZ] = AGravityC( r, d )

% Lump the j terms into c
%------------------------
j = [0 -d.j2];
c = [0 0; -2.19469056285087e-09 1.57432125443316e-06];
s = [0 0; 1.53628339399561e-09 -9.03592640909998e-07];
% c = zeros(2,2);
% s = zeros(2,2);
c = [j' c];
s = [zeros(2,1), s];
nN = 2;
nM = 0;

cHat = zeros(1,2);
sHat = zeros(1,2);

aS   = zeros(3,1);
aZ   = zeros(3,1);
aG   = zeros(3,1);
dVDR = zeros(3,1);

rMag      = sqrt(r'*r);
rMagSq    = rMag^2;
u         = r/rMag;
aOR       = d.a/rMag;
nu        = u(3);
  
% C and S Hat are functions of r only
%------------------------------------
cHat(1) = 1;
sHat(1) = 0;
cHat(2) = u(1);
sHat(2) = u(2);

% p(n,m) is a function of nu only
%--------------------------------
p      = zeros(nN+1,nM+2);
p(1,1) = 1;
p(2,1) = nu;
p(1,2) = 0;
p(2,2) = 1;  
p(3,1) = (3*nu*p(2,1) - p(1,1))/2;
p(3,2) = p(1,2) + 3*p(2,1);

dVMZ = [0;0;0];

% m = 0
%------
cS      = c(2,1)*cHat(1) + s(2,1)*sHat(1);
hNM     =        cS*p(3,2);
bNM     = 3*cS*p(3,1);
dVM     = -u*(nu*hNM + bNM) + [0;0;hNM];
dVMZ    = dVMZ + dVM*aOR^2;

aZ   =  d.mu*dVMZ/rMagSq;
aS   = -d.mu*u/rMagSq;
aG   = aS + aZ;


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-12-23 11:35:13 -0500 (Tue, 23 Dec 2014) $
% $Revision: 39306 $



