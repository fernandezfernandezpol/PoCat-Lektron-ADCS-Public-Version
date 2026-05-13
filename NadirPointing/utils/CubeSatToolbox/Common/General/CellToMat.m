function x = CellToMat( c )

%--------------------------------------------------------------------------
%   Converts a cell array to a matrix.
%
%   Since version 3.
%--------------------------------------------------------------------------
%   Form:
%   x = CellToMat( c )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   c	        {}    One dimensional cell array of strings
%
%   -------
%   Outputs
%   -------
%   x         (:)   Matrix
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( ~iscellstr( c ) )
  error( 'The input is not a cell array of strings' )
end

[rows, cols] = size( c );

if( rows > 1 & cols > 1 )
  error('Only one dimensional cell arrays are permitted')
end

if( isempty(c) )
  x = '';
else
  x = c{1};

  for k = 2:length(c)
    x = strvcat( x, c{k} );
  end
end

% PSS internal file version information
%--------------------------------------
% $Date: 2013-07-31 12:27:40 -0400 (Wed, 31 Jul 2013) $
% $Revision: 35247 $
