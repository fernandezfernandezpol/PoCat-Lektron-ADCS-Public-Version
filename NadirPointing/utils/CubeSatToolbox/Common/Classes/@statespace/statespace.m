function g = statespace( a, b, c, d, name, states, inputs, outputs, sType, dT )

%--------------------------------------------------------------------------
%   Create a state space object. Everything after c is optional.
%   dx/dt = ax + bu
%       y = cx + du
%--------------------------------------------------------------------------
%   Form:
%   g = statespace( a, b, c, d, name, states, inputs, outputs, sType, dT )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   a                          State transition matrix
%   b                          State input matrix
%   c                          State output matrix
%   d                          State feedthrough matrix
%   name     (1,:)             Name of the system
%   states   (:,:)   or {:}    State  names
%   inputs   (:,:)   or {:}    Input names
%   outputs  (:,:)   or {:}    Outputs
%   sType    (1,:)             's', 'z', 'delta' 
%   dT       (1,1)             Time step
%
%   -------
%   Outputs
%   -------
%   g			  (:)     Plant
%                   g.a       State transition matrix
%                   g.b       State input matrix
%                   g.c       State output matrix
%                   g.d       State feedthrough matrix
%                   g.n       Number of states
%                   g.nI      Number of inputs
%                   g.nO      Number of outputs
%                   g.states  Names of states
%                   g.inputs  Names of inputs
%                   g.outputs Names of outputs
%                   g.sType   's', 'z', 'delta' 
%                   g.dT      Time step
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997-1998 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 10 )
	dT = [];
end

if( nargin < 9 )
	sType = [];
end

if( nargin < 8 )
	outputs = [];
end

if( nargin < 7 )
	inputs = [];
end

if( nargin < 6 )
	states = [];
end

if( nargin < 5 )
	name = [];
end

if( nargin < 4 )
	 d   = [];
end
 
if( nargin < 3 )
	c = [];
end

if( nargin < 2 )
	a = [];
  b = [];
end

if( isempty(c) )
  c = eye(size(a));
end

nO = size(c,1);
nI = size(b,2);
n  = length(a);

if( isempty(d) )
	d = zeros(nO,nI);
end

if( iscell(states) )
	states = CellToMat( states );
end

if( iscell(inputs) )
	inputs = CellToMat( inputs );
end

if( iscell(outputs) )
	outputs = CellToMat( outputs );
end

% Strings
%--------
if( isempty(states) )
	states = '';
	for k = 1:n
		states = strvcat( states, sprintf('State %i', k ) );
	end
end

if( isempty(inputs) )
	inputs = '';
	for k = 1:nI
		inputs = strvcat( inputs, sprintf('Input %i', k ) );
	end
end

if( isempty(outputs) )
	outputs = '';
	for k = 1:nO
		outputs = strvcat( outputs, sprintf('Output %i', k ) );
	end
end

if( isempty(sType) )
  sType = 's';
end

if( isempty(dT) )
  if( ~strcmp(sType,'s') )
    error('You must include a dT with a discrete time model')
  else
    dT = 0;
  end
end

s = struct( 'a', a, 'b', b, 'c', c, 'd', d,...
            'states', states, 'inputs', inputs,...
            'outputs', outputs, 'name', name,...
            'n', n, 'nI', nI, 'nO', nO, 'sType', sType, 'dT', dT );
g = class( s, 'statespace' );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
