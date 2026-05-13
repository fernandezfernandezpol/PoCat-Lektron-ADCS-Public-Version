function [a, b, c, d] = ND2SS( num, den )

%--------------------------------------------------------------------------
%   Creates state-space model from numerator and denominator polynomials.
%
%   Creates state-space model given a denominator polynomial and
%   a set of numerator polynomials. The state-space model will be
%   of the form
%   .
%   x = ax + bu
%   y = cx + du
%
%   where each row of C corresponds to a row of num. The output is in
%   terms of phase variables, also known as the control canonical form.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [a, b, c, d] = ND2SS( num, den )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   num                 Numerator polynomial(s) one output per row
%   den                 Denominator polynomial
%
%   -------
%   Outputs
%   -------
%   a                   Plant matrix
%   b                   Input matrix
%   c                   Output matrix
%
%--------------------------------------------------------------------------
%   References: Schultz, D. G., J. L. Melsa, State Functions and Linear 
%               Control Systems, McGraw-Hill, New York, 1967, p. 40.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

[rc,cc] = size(num);
n       = length(den);

if ( cc > n ),
  error('The O(num) > O(den) therefore cannot create a state-space system')
end

den     = DelLZ(den);
num     = DelLZ(num);
n       = length(den);

an      = den/den(1);
bn      = num/den(1);

a       = diag(ones(n-2,1),-1);

if( n > 1 )
  a(1,:)  = -an(2:n);
else
  a       = [];
end 

b       = zeros(n-1,1);
b(1)    = 1; 

d       = zeros(rc,1); 

ns      = n - 1;

if( ~isempty(a) )
  for k=1:rc,
   bnk = DelLZ(bn(k,:)); 
   m   = length(bnk); 
    if ( m < n ),
     c(k,ns-m+1:ns) = bnk;
   else
      c(k,1:ns) = bnk(2:m)+bnk(1)*a(1,1:ns);
      d(k) = bnk(1);
    end
  end
else
  b = [];
  c = [];
  d = ones(size(num));
end

% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 13:30:31 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38048 $
