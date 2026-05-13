function s = DeBlankLT( s )

%--------------------------------------------------------------------------
%   Delete leading and trailing blanks.
%
%   Since version 3.
%--------------------------------------------------------------------------
%   Form:
%   s = DeBlankLT( s )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   s      (1,:)   Character string or cell array
%
%   -------
%   Outputs
%   -------
%   s      (1,:)   Character string or cell array
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998-2000 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------

if( iscell(s) )
  for j = 1:length(s)
    k     = min(find( isspace( s{j} ) == 0 ) );
    s{j}  = deblank(s{j}(k:end));
  end
else  
  n = isspace(s);
  if( ~isempty(n) )
    k = min(find( n == 0 ) );
    s = deblank(s(k:end));
  end
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-31 12:29:05 -0400 (Wed, 31 Jul 2013) $
% $Revision: 35250 $
