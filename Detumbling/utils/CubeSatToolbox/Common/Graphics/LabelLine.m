function LabelLine( x, t, n, f )

%--------------------------------------------------------------------------
%   Labels a line.
%   x must have at least 2 rows. 
%   The format string is any standard matlab format such as 't = %12.4f'
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   LabelLine( x, t, n, f )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   x          (2,:)   [x;y]
%   t          (1,:)   Numbers for labels
%   n          (1,1)   Number of labels
%   f          (1,:)   Format string
%
%   -------
%   Outputs
%   -------
%   None
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------


if( nargin < 2 )
    error('PSS:minrhs','Must have at least 2 arguments.')
end

if( nargin < 3 )
    n = [];
end

if( nargin < 4 )
    f = '%8.4f';
end

if( isempty(n) )
    n = 5;
end

m = length(t);

% Compute the arc length
%-----------------------
s  = Mag(x(:,2:end) - x(:,1:end-1));
tS = sum(s);
dS = tS/n;

% Put labels at equal arclengths
%-------------------------------
text(x(1,1),x(2,1),sprintf(f,t(1,1)) );

zL = 0;
z  = 0;
for k = 1:(m-1)
    z = z + s(k);
    if( z - zL > dS )
        zL = z;
        text( x(1,k), x(2,k), sprintf(f, t(1,k)) );
    end
end

text(x(1,end),x(2,end),sprintf(f,t(1,end)) );


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $

