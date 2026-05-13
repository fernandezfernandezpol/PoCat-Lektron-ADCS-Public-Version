function g = series( e, f, m )

%--------------------------------------------------------------------------
%   Connection of two state space systems. The connection is
%   e -> f
%
%   The connection matrix is lists the indices of the matching outputs
%   of e and inputs of f. For example
%
%   u       (4,1)           y (3,1)
%    f                       e
%
%   c might be [1 1;1 3] which means that output 1 of y goes into input 1
%   of u. Output 3 of y also goes into 1 of u. 
%   
%--------------------------------------------------------------------------
%   Form:
%   g = series( e, f, c )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   e           (:)     Object of class statespace
%   f           (:)     Object of class statespace
%   m           (:,2)   Connection matrix
%
%   -------
%   Outputs
%   -------
%   g           (:)     Series connection
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%  Copyright (c) 2000,2005 Princeton Satellite Systems, Inc.
%  All rights reserved.
%--------------------------------------------------------------------------

if( isempty(f) )
    g = e;
	return;
elseif( isempty(e) )
	g = f;
	return;
end

if( nargin < 3 )
  m = [];
end

if( ~strcmp(e.sType,f.sType) )
  error(['Cannot connect a ',e.sType,' to a ',f.sType]);
end

if( isempty(m) )
  [a, b, c, d] = Series( e.a, e.b, e.c, e.d, f.a, f.b, f.c, f.d );
else
  n = zeros(size(f.b,2),size(e.c,1));
  for k = 1:size(m,1)
    n(m(k,1),m(k,2)) = 1.0;
  end
   
  [a, b, c, d] = Series( e.a, e.b, n*e.c, n*e.d, f.a, f.b, f.c, f.d );
end

name   = [e.name,' * ',f.name];
states = strvcat(e.states,f.states);

g = statespace( a, b, c, d, name, states, e.inputs, f.outputs,...
                e.sType, e.dT  );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
