function tag = GetNewTag( name )

%--------------------------------------------------------------------------
%   Get a new tag to uniquely identify a figure. 
%   Uses clock and rand to generate a unique string.
%--------------------------------------------------------------------------
%   Form:
%   tag = GetNewTag( name )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   name        (1,:)  Name of the figure
%
%   -------
%   Outputs
%   -------
%   tag         (1,:)  Tag
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2000 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

t   = clock;
tag = [name num2str([t(5:6) 100*rand])];


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2012-08-01 10:15:24 -0400 (Wed, 01 Aug 2012) $
% $Revision: 30229 $
