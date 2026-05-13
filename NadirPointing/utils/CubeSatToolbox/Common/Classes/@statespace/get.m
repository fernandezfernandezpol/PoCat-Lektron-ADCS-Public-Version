function y = get( x, s )

%--------------------------------------------------------------------------
%   Get an element of the class statespace
%--------------------------------------------------------------------------
%   Form:
%   y = get( x, s )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x           (:)   Object of class statespace
%   s           (1,:) Element of class statespace
%                     
%
%   -------
%   Outputs
%   -------
%   y           (:)   Output
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 2 )
	disp('Possible inputs: a, b, c, d, name, states, inputs, outputs');
else
	switch s
		case 'a'
			y = x.a;
		case 'b'
			y = x.b;
		case 'c'
			y = x.c;
		case 'd'
			y = x.d;
		case 'states'
			y = x.states;
		case 'inputs'
			y = x.inputs;
		case 'outputs'
			y = x.outputs;
		case 'n'
			y = x.n;
		case 'nI'
			y = x.nI;
		case 'nO'
			y = x.nO;
		case 'name'
			y = x.name;
		case 'type'
			y = x.sType;
 		case 'dT'
			y = x.dT;
 	  otherwise
    	y = [];
	end
end

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
