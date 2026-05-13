function x = set( x, y, s )

%--------------------------------------------------------------------------
%   Set an element of the class statespace
%--------------------------------------------------------------------------
%   Form:
%   x = set( x, y, s )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x           (:)   Object of class statespace
%   y           (:)   Value of element
%   s           (1,:) Element of class statespace
%                     
%
%   -------
%   Outputs
%   -------
%   x           (:)   Object of class statespace
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997-1998 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 2 )
	disp('Possible inputs: a, b, c, d, name, states, inputs, outputs');
else
	switch s
		case 'a'
			x.a = y;
      x.n = length(y);
		case 'b'
			x.b = y;
      x.nI = size(y,2);
		case 'c'
			x.c = y;
      x.nO = size(y,1);
		case 'd'
			x.d = y;
		case 'name'
			x.name = y;
		case 'states'
			x.states = y;
		case 'inputs'
			x.inputs = y;
		case 'outputs'
			x.outputs = y;
		case 'type'
			x.sType = y;
		case 'dT'
			x.dT = y;
  	otherwise
    	error('No such field in acstate')
	end
end

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
