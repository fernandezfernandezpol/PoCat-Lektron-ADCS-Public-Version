function q = U2Q( u, v )

%--------------------------------------------------------------------------
%   Finds the quaternion that aligns a unit vector with a second vector.
%
%   Type U2Q for a demo.
%
%--------------------------------------------------------------------------
%   Form:
%   q = U2Q( u, v )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   u                   (3,:)    Vector
%   v                   (3,:)    Where vector is after rotation
%
%   -------
%   Outputs
%   -------
%   Q                   (4,:)    Quaternion that rotates u into v
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1994-2001 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since version 1.
%--------------------------------------------------------------------------

if( nargin == 0 )
  nTests = 100;
  u      = [  eye(3) rand(3,nTests)];
  v      = [ -eye(3) rand(3,nTests)];
  U2Q(u,v);
end

cU  = size(u,2);
cV  = size(v,2);

if( cU == 1 && cV > 1 )
  u  = DupVect(u,cV);
  cU = cV;
elseif( cV == 1 && cU > 1 )
  v  = DupVect(v,cU);
  cV = cU;
elseif( cV ~= cU )
  error('Number of columns of u must equal the number of columns of v or 1')
end

u        = Unit( u );
v        = Unit( v );

c        = Cross( u, v ); 
d        = Dot( u, v );

j        = find( d ~= -1 );
s        = sqrt( 2*(1 + d(j)) );

if( ~isempty(j) )
  q(:,j)    = [ 0.5*s;...
                c(1,j)./s;...
                c(2,j)./s;...
                c(3,j)./s];
end

j        = find( d == -1 );

p        = Unit(Perpendicular( u(:,j) ));
q(:,j)   = [zeros(1,length(j));p];

if( nargout == 0 && nargin == 0 )
  err = norm(u - QTForm(q,v));
  fprintf(1,'The norm error after %i tests (including aligned vectors) is %12.4e',nTests+3,err);
  disp(q)
end

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-18 15:02:51 -0400 (Fri, 18 Mar 2016) $
% $Revision: 41948 $
