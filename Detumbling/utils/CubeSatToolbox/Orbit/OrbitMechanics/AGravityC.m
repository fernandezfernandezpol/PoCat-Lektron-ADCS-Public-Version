function [aG, aS, aZ, aT] = AGravityC( r, nN, nM, s, c, j, mu, a, ~ )

%--------------------------------------------------------------------------
%   Compute the gravitational acceleration in cartesian coordinates. 
%   Acceleration vectors are a [ aX;aY;aZ ].
%
%   To use normalized coefficients, enter a 9th input.
%--------------------------------------------------------------------------
%   Form:
%   [aG, aS, aZ, aT] = AGravityC( r, nN, nM, s, c, j, mu, a, normM )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   r           (3,:)    Position vector
%   nN          (1,1)    Highest zonal harmonic (m = 0)
%                        (empty gives the max #) 
%   nM          (1,1)    Highest sectorial and tesseral harmonic 
%                        (empty gives the max #) 
%   s           (:,:)    S terms
%   c           (:,:)    C terms
%   j             (:)    m = 0 terms
%   mu          (1,1)    Spherical gravitational potential
%   a           (1,1)    Planet radius
%   normM       (1,1)    Normalization matrix to be generated
%
%   -------
%   Outputs
%   -------
%   aG           (3,:)   Total gravitational acceleration km/sec^2
%   aS           (3,:)   Spherical term                   km/sec^2
%   aZ           (3,:)   Zonal term                       km/sec^2
%   aT           (3,:)   Tesseral term                    km/sec^2
%
%--------------------------------------------------------------------------
%	 Reference:   Bond, V. R. and M. C. Allman (1996.) Modern Astrodynamics.
%               Princeton. pp. 212-213.
%               Lerch, F. J., Klosko, S. M., Labuscher, R. E., Wagner,
%               C.A., "Gravity Model Improvement GEOS-3 (GEM 9 & 10)," 
%               N78-10645, September, 1977.
%               Gottlieb, R. G., "Fast Gravity, Gravity Partials,
%               Normalized Gravity, Gravity Graident Torque and Magnetic
%               Field: Derivation, Code and Data, NASA CR 188243, February,
%               1993.
%--------------------------------------------------------------------------
%   See also GravityNormalized, AGravity (which outputs in spherical
%   coordinates).
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1996-2001 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

persistent rNM

if( nargin < 1 )
  %         m  1        2        3        4
  gEM10.c = [ 0.00104  2.43404  0.0      0.0           % 2
              2.02855  0.89272  0.70028  0.0           % 3
             -0.53521  0.35208  0.98850 -0.19531   ];  % 4
            
                      
  gEM10.s = [-0.00243 -1.39907  0.0      0.0           % 2
              0.25197 -0.62346  1.41250  0.0           % 3
             -0.46926  0.66404 -0.20179  0.29883   ];  % 4 
            
  gEM10.c   = [zeros(2,4);gEM10.c]*1e-6;
  gEM10.s   = [zeros(2,4);gEM10.s]*1e-6;
            
  gEM10.j   = [0 0 -484.16544 0.95838 0.54112]*1e-6;
  gEM10.mu  = 398600.47e9;
  gEM10.a   = 6378139.0;
  r         = [5489150;802222;3140916];
  aRef      = [-8.44269212018857;-1.23393633785485;-4.84659352346614];

  gEM10U    = UnnormalizeGravity( gEM10 );
  aTotalC   = AGravityC( r, 5, 5, gEM10U.s, gEM10U.c, gEM10U.j, gEM10U.mu, gEM10U.a );

  fprintf(1,'Ref:       [%24.16f %24.16f %24.16f]\n',aRef);
  fprintf(1,'AGravityC: [%24.16f %24.16f %24.16f]\n',aTotalC);
  fprintf(1,'Delta:     [%24.16f %24.16f %24.16f]\n',aTotalC-aRef);
  return
end



if( isempty( nN ) )
  nN = size(s,1);
end

if( isempty( nM ) )
  nM = size(s,2);
end

nN = nN - 1;
nM = nM - 1;

if( isinf(factorial(nM+nN)))
  error('The order is beyond the floating point capabilities of MATLAB');
end


if( isempty(rNM) )
  if( nargin > 8 )
    rNM   = 1./NormalizationMatrix(nN,nM);
  else
    rNM   = ones(nM+1,nM+2);
  end
end


% Lump the j terms into c
%------------------------
c = [j' c];
s = [zeros(length(j),1), s];

cHat = zeros(1,nN);
sHat = zeros(1,nN);

nV   = size(r,2);
aS   = zeros(3,nV);
aZ   = zeros(3,nV);
aT   = zeros(3,nV);
aG   = zeros(3,nV);
dVDR = zeros(3,nV);
for k = 1:nV
  rG        = r(:,k);
  rMag      = sqrt(rG'*rG);
  rMagSq    = rMag^2;
  u         = rG/rMag;
  aOR       =  a/rMag;
  nu        = u(3);
  
  % C and S Hat are functions of r only
  %------------------------------------
  cHat(1) = 1;
  sHat(1) = 0;
  cHat(2) = u(1);
  sHat(2) = u(2);
  for m = 2:nM
	  mI       = m + 1;
	  cHat(mI) = cHat(2)*cHat(mI-1) - sHat(2)*sHat(mI-1);
	  sHat(mI) = sHat(2)*cHat(mI-1) + cHat(2)*sHat(mI-1);
  end

  % p(n,m) is a function of nu only
  %--------------------------------
  p      = zeros(nN+1,nM+2);
  p(1,1) = 1;   % n = 0, m = 0
  p(2,1) = nu;  % n = 1, m = 0
  p(1,2) = 0;  	% n = 0, m = 1
  p(2,2) = 1;  	% n = 1, m = 1
  
  % m = 0
  for n = 2:nN
    nI      = n + 1;
    p(nI,1)	= ((2*n-1)*nu*p(nI-1,1) - (n-1)*p(nI-2,1))/n;
  end
    
  % m > 0
  for n = 2:nN
	  nI = n + 1;
	  for m = 1:nM+1
	    mI        = m + 1;
	    p(nI,mI)  = p(nI-2,mI) + (2*n-1)*p(nI-1,mI-1);
    end
  end

  dVNM = [0;0;0];
  dVMZ = [0;0;0];

  for n = 2:nN
    nI      = n + 1;
	  
    % m = 0
    %------
    m       = 0;
    mI      = m + 1;
    cS      = c(nI,mI)*cHat(mI) + s(nI,mI)*sHat(mI);
    rK      = rNM(nI,mI);
    hNM     =         cS*(rK*p(nI,mI+1));
    bNM     = (n+m+1)*cS*(rK*p(nI,mI));
    dVM     = -u*(nu*hNM + bNM) + [0;0;hNM];
    dVMZ    = dVMZ + dVM*aOR^n;
    dVM     = [0;0;0];

    % m > 0
    %------
    for m = 1:n 
      mI  = m + 1;
      rK	= rNM(nI,mI);

      cNM = c(nI,mI);
      sNM = s(nI,mI);
      pNM = rK*p(nI,mI);
      cM1 = cHat(mI-1);
      sM1 = sHat(mI-1);
      cS  = cNM*cHat(mI) + sNM*sHat(mI);

      hNM =          cS*(rK*p(nI,mI+1));
      bNM =  (n+m+1)*cS*pNM;
      eNM = -m*(cNM*sM1 - sNM*cM1)*pNM;
      dNM =  m*(cNM*cM1 + sNM*sM1)*pNM;
      
      dVM = dVM - u*(nu*hNM + bNM) + [dNM;eNM;hNM];

    end
    dVNM = dVNM + dVM*aOR^n;
  end
  aZ(:,k)   =  mu*dVMZ/rMagSq;
  aS(:,k)   = -mu*   u/rMagSq;
  aT(:,k)   =  mu*dVNM/rMagSq;
  dVDR(:,k) = aS(:,k) + aT(:,k) + aZ(:,k);
end

if( nargout == 0 )
  Plot2D(1:size(r,2),dVDR,'Step',['aX';'aY';'aZ'],'Gravitational Acceleration');
else
  aG = dVDR;
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-28 12:43:59 -0400 (Mon, 28 Mar 2016) $
% $Revision: 42107 $
