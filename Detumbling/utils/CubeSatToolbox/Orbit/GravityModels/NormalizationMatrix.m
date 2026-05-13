function f = NormalizationMatrix( nN, nM )

%% Generate a normalization matrix for spherical harmonics
% c unnormalized * f = c normalized
% s unnormalized * f = s normalized
% p normalized   = p unnormalized / f
%--------------------------------------------------------------------------
%   Form:
%   f = NormalizationMatrix( nN, nM )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   nN	(1,1)  Rows
%   nN 	(1,1)  Columns
%
%   -------
%   Outputs
%   -------
%   f	(nN,mM)   State derivatives 
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2016 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 2016.1
%--------------------------------------------------------------------------


if( nargin < 1 )  
  NormalizationMatrix( 4, 4 )
  return
end

f = zeros(nN+1,nM+1);
for n = 0:nN
  f(n+1,1) = 1/sqrt(2*n+1);
end

for m = 1:nM
	mI = m + 1;
  for n = 0:nN
    nI = n + 1;
    if( m <= n )
      f(nI,mI) = sqrt( FactorialRatio(n,m)/(2*(2*n + 1)) );
    end
  end
end

j = f==0;
f(j) = 1;

function r = FactorialRatio(n,m)

r = 1;
for k = n-m+1:n+m
  r = r*k;
end
  
%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-24 16:18:36 -0400 (Thu, 24 Mar 2016) $
% $Revision: 42057 $
