function E = Nu2E( e, nu )

%--------------------------------------------------------------------------
%   Converts true anomaly to eccentric or hyperbolic anomaly.
%   For a demo plot use Nu2E( e ).
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   E = Nu2E( e, nu )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   e              (1,:)  or (1,1) Eccentricity
%   nu             (1,:)  True anomaly
%
%   -------
%   Outputs
%   -------
%   E              (1,:)  Eccentric or hyperbolic anomaly
%
%--------------------------------------------------------------------------
%   References: Wiesel, W. E., Spaceflight Dynamics, McGraw-Hill, 1988, pp. 57,60.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993-1998 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

k = find( e == 1, 1 );
if( ~isempty(k) )
  error('PSS:Nu2E:error','Eccentric anomaly is not defined for parabolas')
end

if( nargin < 2 )
  if( length(e) == 1 )
    if( e < 1 )
      nu = linspace(0,2*pi);
    else
	    nuMax = acos(-1/e);
	    nu = linspace(-nuMax,nuMax);
	  end
  else
    error('PSS:Nu2E:error','If e is not a scalar you must enter nu')
  end
end

if( length(e) == 1 )
  e = DupVect(e,length(nu))';
end

E = zeros(size(e));
	
k = find( e < 1 );
if( ~isempty(k) )
  E(k) = 2*atan( sqrt( (1-e(k))./(1+e(k)) ).*tan(0.5*nu(k)));
  yLbl = 'Eccentric';
else
  yLbl = [];
end

k = find( e > 1 );
if( ~isempty(k) )
  E(k) = 2*atanh( sqrt( (e(k)-1)./(1+e(k)) ).*tan(0.5*nu(k)));
  if( isempty(yLbl) )
    yLbl = 'Hyperbolic';
  else
    yLbl = [yLbl '/Hyperbolic'];
  end
end

if( nargout == 0 && length(nu) > 1 )
  Plot2D(nu,E,'True Anomaly',[yLbl, ' Anomaly'])
  clear E
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-05 13:07:14 -0500 (Thu, 05 Mar 2015) $
% $Revision: 39774 $
