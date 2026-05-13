function g = plus( e, f )

%--------------------------------------------------------------------------
%   Parallel connection of two state space systems.
%   The connection is
%   [ e ]
%   [ f ]
%--------------------------------------------------------------------------
%   Form:
%   g = plus( e, f )
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
%   g           (:)   Parallel connection
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

[a, b, c, d] = Parallel( e.a, e.b, e.c, e.d, f.a, f.b, f.c, f.d );

g = statespace( a, b, c, d, [e.name,' + ',f.name],...
                strvcat(e.states,f.states),...
                strvcat(e.inputs,f.inputs),...
                strvcat(e.outputs,f.outputs) );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
