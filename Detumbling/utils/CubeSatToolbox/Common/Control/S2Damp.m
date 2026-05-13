function [zeta, w, wR] = S2Damp( s )

%--------------------------------------------------------------------------
%   Eigenvalues to damping and natural frequency.

%   Computes the damping ratios and natural frequency for a set
%   of eigenvalues of a continuous time plant.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [zeta, w, wR] = S2Damp( s )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   s                   Eigenvalues
%
%   -------
%   Outputs
%   -------
%   zeta                Damping ratio
%   w                   Natural frequency
%   wR                  Resonant frequency
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

k    = find((abs(imag(s))>eps*real(s)) & (abs(s) > eps)); 
w    = s;
wR   = s;
zeta = zeros(size(s)); 

if ( length(k) > 0 ),

  w(k)     =   abs(s(k));  
  zeta(k)  = - real(s(k))./w(k); 
  asq      =   1-2*zeta(k).^2; 
  inr      =   find(asq<10*eps); 
  Linr     =   length(inr); 
  if ( Linr > 0 ),
    if ( Linr > 1 ), 
      asq(inr) = ones(size(inr));
    else
      asq(inr) = 1;
    end
  end
  wR(k) = w(k).*sqrt(asq);

end

% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 13:30:31 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38048 $
