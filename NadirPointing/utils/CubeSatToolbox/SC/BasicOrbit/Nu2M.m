function [meanAnom,eccAnom] = Nu2M( e, nu )

%--------------------------------------------------------------------------
%   Converts true anomaly to mean anomaly.
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   [meanAnom,eccAnom] = Nu2M( e, nu )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   e             (1,1)  Eccentricity
%   nu            (1,:)  True anomaly
%
%   -------
%   Outputs
%   -------
%   meanAnom       (1,:)  Mean anomaly
%   eccAnom        (1,:)  Eccentric anomaly
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993-1998 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 2 )
  if( e ~= 1 )
    if( e < 1 )
      nu = linspace(0,2*pi);
	  else
	    nuMax = acos(-1/e);
	    nu = 0.75*linspace(-nuMax,nuMax);
	  end
  else
	  nu = 0.75*linspace(-pi,pi);
  end
end

if( e ~= 1 )
  eccAnom  = Nu2E( e, nu );
  meanAnom = E2M( e, eccAnom );
else
  eccAnom = 0;
  meanAnom = tan(0.5*nu) + tan(0.5*nu).^3/3;
end

if( nargout == 0 )
  Plot2D(nu,meanAnom,'True Anomaly','Mean Anomaly')
  clear meanAnom
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-04-03 11:35:40 -0400 (Fri, 03 Apr 2015) $
% $Revision: 39958 $
