function wV = WReson( lmin, lmax, n, w )

%--------------------------------------------------------------------------
%   Creates a frequency vector with points around resonances.
%   The resonances are specified in the vector w. 
%   Only complex values of w will be used.
%   Those with negative imaginary parts will be
%   ignored. Thus you can enter the output of eig as an input
%   to this function.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   wV = WReson( lmin, lmax, n, w )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   lmin                Log of minimum frequency
%   lmax                Log of maximum frequency
%   n                   Number of logarithmically spaced points
%   w                   Resonances (complex) 
%
%   -------
%   Outputs
%   -------
%   wV                  Frequency vector
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1996 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

% Find eigenvalues with significant imaginary parts
% and ignore half of the complex conjugate pairs
%-----------------------------------------------
if ( nargin < 3 ),
  n = [];
end

if( nargin < 4 ),
  w = [];
end

if( isempty(n) )
  n = 50;
end

wV = logspace(lmin,lmax,n); 

i           = find( imag(w) > eps*abs(w) ); 
w           = w(i);
[zeta,w,wR] = S2Damp(w);

% Find pure imaginary resonances
%-------------------------------
i     = find( zeta < eps );
if( length(i) > 0 )
  wR(i) = 0.99*wR(i);
end

for k = 1:length(w);
  wV = [wV linspace(0.9*wR(k),1.1*wR(k),10) wR(k)];
end

wV = sort( wV );

% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 13:30:31 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38048 $
