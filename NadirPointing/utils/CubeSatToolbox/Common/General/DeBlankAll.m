function s = DeBlankAll( s )

%--------------------------------------------------------------------------
%   Delete all blanks including spaces, new lines, carriage returns,
%   tabs, vertical tabs, and formfeeds.
%--------------------------------------------------------------------------
%   Form:
%   s = DeBlankAll( s )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   s      (1,:)   Character string
%
%   -------
%   Outputs
%   -------
%   s      (1,:)   Character string
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

if( ~isempty(s) )
  k = find( isspace( s ) == 1 );
  s(k) = [];
end;

% PSS internal file version information
%--------------------------------------
% $Date: 2012-08-01 10:15:24 -0400 (Wed, 01 Aug 2012) $
% $Revision: 30229 $
