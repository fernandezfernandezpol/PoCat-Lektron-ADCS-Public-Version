function g = and( e, f )

%--------------------------------------------------------------------------
%   Append two state space system
%   [ e ]
%   [ f ]
%--------------------------------------------------------------------------
%   Form:
%   g = and( e, f )
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
%   g           (:)   Appended
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1997 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( ~strcmp(e.sType,f.sType) )
	error(['Cannot combine a ',e.sType,' and a ',f.sTtype]);
end

[a, b, c, d] = Append( e.a, e.b, e.c, e.d, f.a, f.b, f.c, f.d );

g = statespace( a, b, c, d, [e.name,' + ',f.name],...
                strvcat(e.states,f.states),...
                strvcat(e.inputs,f.inputs),...
                strvcat(e.outputs,f.outputs) );

% PSS internal file version information
%--------------------------------------
% $Date: 2012-07-28 23:52:41 -0400 (Sat, 28 Jul 2012) $
% $Revision: 30112 $
