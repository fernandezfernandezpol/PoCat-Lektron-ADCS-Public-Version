function g = mtimes( e, f )

%--------------------------------------------------------------------------
%   Series connection of two state space systems. The connection is
%   e -> f
%   The inputs to e are the system inputs and the outputs
%   of f are the system outputs
%--------------------------------------------------------------------------
%   Form:
%   g = mtimes( e, f )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   e           (:)   Object of class statespace
%   f           (:)   Object of class statespace
%
%   -------
%   Outputs
%   -------
%   g           (:)   Series connection
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( ~strcmp(e.sType,f.sType) )
	error(['Cannot connect a ',e.sType,' to a ',f.sType]);
end

if( e.dT ~= f.dT )
	error('Time steps must be the same for each system');
end

[a, b, c, d] = Series( e.a, e.b, e.c, e.d, f.a, f.b, f.c, f.d );

name   = [e.name,' * ',f.name];
states = strvcat(e.states,f.states);

g = statespace( a, b, c, d, name, states, e.inputs, f.outputs,...
                e.sType, e.dT  );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
