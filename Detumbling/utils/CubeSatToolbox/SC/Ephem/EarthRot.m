function [g, gMST, gAST] = EarthRot( T, eOfECalc )

%--------------------------------------------------------------------------
%   Computes the Earth greenwich matrix that transforms from ECI to EF.
%   Any input of eOfECalc will cause it to include the equation of the 
%   equinoxes.
%
%   Type EarthRot for a demo.
%
%--------------------------------------------------------------------------
%   Form:
%   [g, gMST, gAST] = EarthRot( T, eOfECalc )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   T           (1,1) Julian centuries of 86400s dynamical time from j2000.0
%   eOfECalc    (1,1) Calculate the equation of the equinoxes
%
%   -------
%   Outputs
%   -------
%   g           (3,3) Greenwich matrix
%   gMST        (1,1) Greenwich mean sidereal time (deg)
%   gAST        (1,1) Greenwich apparent sidereal time (deg)
%
%--------------------------------------------------------------------------
%   See also: GMSTime, EOfE, JD2T
%--------------------------------------------------------------------------
%   References:	Seidelmann, P. K., The Explanatory Supplement to the 
%               Astronomical Almanac,  University Science Books, 1992, p. 20.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1993, 2015 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since 1.1
%--------------------------------------------------------------------------

if( nargin < 1 )
  T = [];
end

if( isempty( T ) )
  T = JD2T(Date2JD);
end

% Find Greenwich Mean Sidereal Time
%----------------------------------	
gMST = GMSTime(36525*T + 2451545);

% Add the equation of the equinoxes to get apparent sidereal time
%----------------------------------------------------------------	
if( nargin == 2 )
  gAST = gMST + EOfE( T );
else
  gAST = gMST;
end


gAST = (pi/180)*gAST; % Convert to radians
	
sGAST = sin( gAST );
cGAST = cos( gAST );

g     = [cGAST, sGAST, 0; -sGAST, cGAST, 0; 0, 0, 1];


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-15 15:32:35 -0400 (Tue, 15 Mar 2016) $
% $Revision: 41893 $
