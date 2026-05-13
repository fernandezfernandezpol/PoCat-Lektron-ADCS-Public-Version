function t = StringToTokens( s, delimiters, noSpace )

%--------------------------------------------------------------------------
%   Converts a string to a list of tokens.
%
%   Since version 3.
%--------------------------------------------------------------------------
%   Form:
%   t = StringToTokens( s, delimiters, noSpace )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   s          (:)   String (may be a cell element)
%   delimiters (:)   List of delimiters added to whitespace
%   noSpace    (1,1) If entered will not use whitespace as a delimiter
%
%   -------
%   Outputs
%   -------
%   t          {}    Cell array of tokens
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin > 1 & nargin < 3 )
  delimiters = [9:13 32 delimiters];
elseif( nargin < 2 )
  delimiters = [9:13 32];
end

if( iscell( s ) )
  s = char( s );
end

k = 0;
t = {};
while( length(s) > 0 )
  k      = k + 1;
  [j, s] = strtok( s, delimiters );
  if( ~isempty(j) )
    t{k} = j;
  end
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-31 12:30:19 -0400 (Wed, 31 Jul 2013) $
% $Revision: 35253 $
