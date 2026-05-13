function [f, g] = C2DelZOH( a, b, T )

%--------------------------------------------------------------------------
%   Create a discrete time systems using the delta operator.
%
%   Given
%   .
%   x = ax + bu
%
%   Find f and g where
%
%   x(k+1) = x + fx(k) + gu(k)
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [f, g] = C2DelZOH( a, b, T )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   a            (n,n)  Continuous plant matrix
%   b            (n,m)  Input matrix
%   T            (1,1)  Time step
%
%   -------
%   Outputs
%   -------
%   f            (n,n)  Discrete plant matrix
%   g            (n,m)  Discrete input matrix
%
%--------------------------------------------------------------------------
%   References:  Van Loan, C.F., Computing Integrals Involving the Matrix
%                Exponential, IEEE Transactions on Automatic Control
%                Vol. AC-23, No. 3, June 1978, pp. 395-404.
%
%                Middleton, R.H. and G.C. Goodwin, Digital Control and
%                Estimation: A Unified Approach, Prentice-Hall, 1986
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1994 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% Check the inputs
%-----------------
[ra,ca] = size(a); 
[rb,cb] = size(b);

if ( ra ~= rb ),
  error('The number of rows in a must equal the number of rows in b')
end

if ( ra ~= ca ),
  error('a must be square')
end

q  = expm([a*T b*T;zeros(cb,ra+cb)]);

f  = (q(1:ra,1:ra)-eye(size(a)));
g  = q(1:ra,ra+1:ra+cb); 

% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 13:30:31 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38048 $
