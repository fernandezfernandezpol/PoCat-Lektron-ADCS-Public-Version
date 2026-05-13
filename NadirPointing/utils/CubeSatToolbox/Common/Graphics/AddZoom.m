function AddZoom( h )

%--------------------------------------------------------------------------
%   Add zoom-in (CTRL+I) and zoom-out (CTRL+O) accelerators to a figure.
%--------------------------------------------------------------------------
%   Form:
%
%   AddZoom( h )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   h 	(:)  Handle to the figure (optional, default is gcf)
%
%   -------
%   Outputs
%   -------
%   none
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2005 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 1 )
   h = gcf;
end

zoomMenu = uimenu('Label','&Zoom'); 
zoomIn   = uimenu(zoomMenu, 'Label','Zoom &In',  'Callback','camzoom(1.2)', 'enable','on'); 
zoomOut  = uimenu(zoomMenu, 'Label','Zoom &Out', 'Callback','camzoom(0.8)', 'enable','on'); 

% accelerators for zooming in and out
%------------------------------------ 
set(0,'showhiddenhandles','on') 
op = findobj('label','&Open...'); 
set(op,'accelerator',''); 
set(zoomIn,'accelerator','i') 
set(zoomOut,'accelerator','o') 
set(0,'showhiddenhandles','off') 


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 15:24:25 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38060 $
