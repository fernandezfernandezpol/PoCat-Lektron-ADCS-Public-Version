function [y,k] = WrapSegments( x, tol )

% 
%--------------------------------------------------------------------------
%   Separate a wrapped vector into a series of segments in cells.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   [y,k] = WrapSegments( x, tol )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x       (1,:)    Vector of data points
%   tol     (1,1)    Jump tolerance. 
%                    If x(k+1)-x(k) > tol, the segment ends at x(k).
%   
%   -------
%   Outputs
%   -------
%   y       {1,n}    Cell array of segments. 
%                    Each segment "i" is 1 x m(i) array and sum(m)=n
%   k       {1,n}    Cell array of index values so that: y{j} = x( k{j} );
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
if( nargin<2 )
   tol = pi;
end

dx = diff(x);
jump = find(abs(dx)>=tol);
jump = [jump,length(x)];

k{1}=1:jump(1);
y{1}=x(k{1});
for i=2:length(jump)
   k{i} = jump(i-1)+1:jump(i);
   y{i} = x(k{i});
end

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 11:19:43 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39864 $
