function power = DBSignalToPower( dB )

%--------------------------------------------------------------------------
%   Convert decibels to power.
%
%   Type DBSignalToPower for a demo.
%
%--------------------------------------------------------------------------
%   Form:
%   power = DBSignalToPower( dB )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   powerDB       (1,:)  Power (dB)
%                        
%   -------
%   Outputs
%   -------
%   power         (1,:)  Power (W)
%                        
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998-2001 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 1 )
  dB = -7:18;
end

power = 10.^(0.1*dB);

if( nargout == 0 )
  Plot2D( dB, power, 'dB', 'Power', 'DB Signal to Power', 'ylog' );
  clear power
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2012-08-02 12:03:26 -0400 (Thu, 02 Aug 2012) $
% $Revision: 30297 $
