function s = ColumnSizeCellArray( m, f )

%--------------------------------------------------------------------------
%   Outputs the size of each column of a cell array.
%   Elements of m can be strings or scalars.
%
%   Since version 9.
%--------------------------------------------------------------------------
%   Form:
%   s = ColumnSizeCellArray( m, f )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   m               (n,m)  Cell array
%   f               (1,1)  Width of number fields
%
%   -------
%   Outputs
%   -------
%   f               (1,m)  Maximum width of each column
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 2010 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------


% Demo
%-----
if( nargin < 1 )
    m = {'a' 1 'c';'bb' 32 'c2'}
    f = 3;
    ColumnSizeCellArray(m,f)
    return
end


[r,c] = size(m);

s = zeros(1,c);

for k = 1:c
    for j = 1:r
        if( ischar(m{j,k}) )
            s(k) = max(s(k),length(m{j,k}));
        else
            s(k) = max(s(k), f );
        end
    end
end



% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
