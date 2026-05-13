function g = getsub( x, kS, kI, kO, name )

%--------------------------------------------------------------------------
%   Get the state space matrices
%--------------------------------------------------------------------------
%   Form:
%   g = getsub( x, kS, kI, kO, name )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x           (:)   Object of class statespace
%   kS          (1,:) States
%   kI          (1,:) Inputs
%   kO          (1,:) Outputs
%   name        (1,:) Name
%                     
%
%   -------
%   Outputs
%   -------
%   g           (:)   Object of class statespace
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 2 )
  kS = [];
end

if( nargin < 3 )
  kI = [];
end

if( nargin < 4 )
  kO = [];
end

if( nargin < 5 )
  name = x.name;
end

if( isempty(kS) )
  kS = 1:x.n;
end

if( isempty(kI) )
  kI = 1:x.nI;
end

if( isempty(kO) )
  kO = 1:x.nO;
end

a = x.a(kS,kS);
b = x.b(kS,kI);
c = x.c(kO,kS);
d = x.d(kO,kI);

g = statespace( a, b, c, d, name, x.states(kS,:), x.inputs(kI,:), x.outputs(kO,:), x.sType, x.dT );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
