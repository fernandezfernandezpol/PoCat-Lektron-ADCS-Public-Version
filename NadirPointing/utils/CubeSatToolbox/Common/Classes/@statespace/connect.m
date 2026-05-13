function g = connect( e, f, c )

%--------------------------------------------------------------------------
%   Connection of two state space systems. The connection is
%
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
%   c is [uF;yE]
%
%   Empty c implies parallel connection with separate inputs and outputs:
%
%      -------
%   -  |  f  | --
%      -------
%
%      -------
%   -  |  e  | --
%      -------
%   
%--------------------------------------------------------------------------
%   Form:
%   g = connect( e, f, c )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   e           (:)     Object of class statespace
%   f           (:)     Object of class statespace
%   c           (:,2)   Connection matrix
%
%   -------
%   Outputs
%   -------
%   g           (:)   Series connection
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%  Copyright (c) 2000 Princeton Satellite Systems, Inc.
%  All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 3 )
  c = [];
end

if( isempty(f) )
  g = e;
  return;
elseif( isempty(e) )
  g = f;
  return;
end

if( ~strcmp(e.sType,f.sType) )
  error(['Cannot connect a ',e.sType,' to a ',f.sType]);
end

if( e.dT ~= f.dT )
  error('Time steps must be the same for each system');
end

% e -> f
%-------
nE = length(e.a);
nF = length(f.a);
m(size(f.d,2),size(e.d,1)) = 0;
yE = 1:size(e.d,1);
uF = 1:size(f.d,2);
if( ~isempty(c) )
  uF(c(:,1)) = [];
  yE(c(:,2)) = [];
end
lUF = length(uF);
lYE = length(yE);

for k = 1:size(c,1)
  m(c(k,1),c(k,2)) = 1;
end

% Assemble the matrices
%----------------------
a  = [e.a            zeros(nE,nF);...
	  f.b*m*e.c      f.a         ];
b  = [e.b       zeros(nE,lUF);...
      f.b*m*e.d f.b(:,uF)];
c  = [e.c(yE,:)  zeros(lYE,size(f.c,2));...
	  f.d*m*e.c  f.c                   ];
d  = [ e.d(yE,:)  zeros( lYE, lUF);...
	   f.d*m*e.d  f.d(:,uF)       ];
	
% Assemble the names
%-------------------
inputs  = strvcat( e.inputs,        f.inputs(uF,:) );
outputs = strvcat( e.outputs(yE,:), f.outputs      );
name    = [e.name,' * ',f.name];
states  = strvcat(e.states,f.states);

g = statespace( a, b, c, d, name, states, inputs, outputs, e.sType, e.dT  );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
