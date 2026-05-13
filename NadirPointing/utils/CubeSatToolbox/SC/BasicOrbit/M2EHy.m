function eccAnom = M2EHy( e, meanAnom, tol, nMax )

%--------------------------------------------------------------------------
%   Eccentric anomaly for a hyperbola.
%   Computed from the mean anomaly and the eccentricity. 
%
%   For a demo plot use  M2EHy( e ).
%
%   Since version 1.
%--------------------------------------------------------------------------
%   Form:
%   eccAnom = M2EHy( e, meanAnom, tol, nMax )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   e             (1,:)  Eccentricity
%   meanAnom      (1,:)  Mean anomaly
%   tol           (1,1)  Tolerance
%   nMax          (1,1)  Maximum number of iterations
%
%   -------
%   Outputs
%   -------
%   eccAnom       (1,:)   Eccentric anomaly
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1994, 2014 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% If mean anomaly is not input, compute for a range of mean anomalies
%--------------------------------------------------------------------
if( nargin < 2 )
  meanAnom = linspace(0,2*pi);
end

if( nargin < 3 )
  tol = 1.e-8;
end

% Initial error checks
%---------------------
if( e <= 1 )
  error('PSS:M2EHy:error','The eccentricity must be greater than 1')
end

% First guess
%------------
eccAnom = zeros(1,length(meanAnom));

% Iterate
%--------
delta = tol + 1; 
n     = 0;

while( max(abs(delta)) >= tol )

  delta    = (meanAnom + eccAnom - e.*sinh(eccAnom)) ./ (e.*cosh(eccAnom) - 1); 
  eccAnom  = eccAnom + delta;
  n        = n + 1;
  if( nargin == 4 )
    if( n == nMax )
      break
    end
  end
  
end
	
% If no outputs, plot
%--------------------
if( nargout == 0 )
  Plot2D( meanAnom, eccAnom, 'Mean Anomaly (rad)', 'Eccentric Anomaly (rad)', 'Eccentric Anomaly' );
  clear eccAnom
end

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-05 13:07:14 -0500 (Thu, 05 Mar 2015) $
% $Revision: 39774 $
