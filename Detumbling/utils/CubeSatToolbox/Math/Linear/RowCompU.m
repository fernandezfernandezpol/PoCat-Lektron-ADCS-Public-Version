function [r, uh, ac] = RowCompU( a, neps )

%--------------------------------------------------------------------------
%   Computes the upper row compression of a matrix. Compresses the 
%   matrix a so that
%
%   comp(a) = [ r ]
%             [ 0 ]
%
%   r is of full row rank, i.e. the rows are linearly independent.
%   Zero rows are determined by the singular values.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form: 
%   [r, uh, ac] = RowCompU( a, neps )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   a                   Matrix
%   neps                Multiple of machine epsilon to be used
%                       as the tolerance for a zero row
%
%   -------
%   Outputs
%   -------
%   r                   Upper row compression of a
%   uh                  ac = uh*a
%   ac                  a compressed
%
%--------------------------------------------------------------------------
%   References: Maciejowski, J.M., Multivariable Feedback Design, Addison-
%               Wesley, 1989, pp. 366.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 1993 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

[u,s,v] = svd(a);

sd      = diag(s); 

if ( nargin==2 ), 
  tol = neps*eps*norm(sd);
else
  tol = eps*norm(sd);
end 

i       = max(find(sd>tol)); 

ac      = u'*a;

r       = ac(1:i,:);

uh      = u';


% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-29 09:39:44 -0400 (Mon, 29 Jul 2013) $
% $Revision: 34890 $
