function s = GetListString( h )

%--------------------------------------------------------------------------
%   Get an element from a list uicontrol. Returns empty if there is no
%   string or the value of the uicontrol is 0.
%--------------------------------------------------------------------------
%   Form:
%   s = GetListString( h )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   h	       (1,1) Handle to the string
%
%   -------
%   Outputs
%   -------
%   s        (1,:) String
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%	  Copyright 1999 Princeton Satellite Systems, Inc. All rights reserved.
%--------------------------------------------------------------------------

style = get( h, 'style' );
x     = '';

if( strcmp( style, 'listbox' ) | strcmp( style, 'popupmenu' ) )
  x = get( h, 'string' );
else
  tag = get( h, 'tag' );
  if( strcmp( tag, 'UIElement' ) )
    ui = get( h, 'userdata' );
    if( isfield( ui, 'list' ) )
      h = ui.list;
      x = get( h, 'string' );
    end;
  end;
end;

    
if( isempty(x) )
  s = '';
  return;
end
 
k = get( h, 'value' );

if( k == 0 )
  s = '';
elseif iscell(x)
  s = DeBlankLT(x{k});
else
  s = DeBlankLT(x);
end

% PSS internal file version information
%--------------------------------------
% $Date: 2012-08-01 10:15:24 -0400 (Wed, 01 Aug 2012) $
% $Revision: 30229 $
