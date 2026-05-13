function g = LoadOBJModel( file, path, kScale )

%--------------------------------------------------------------------------
%   Load a Wavefront OBJ file. The file can have an associated .mtl file.
%
%
%   If you call the function with no outputs it will draw the model. If you
%   call the function with no inputs you can select a file using the dialog
%   box.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   g = LoadOBJModel( file, path, kScale )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%
%   file        (1,:) Filename
%   path        (1,:) Path to the file
%   kScale      (1,1) Optional scale factor of the model
%
%   -------
%   Outputs
%   -------
%   g           (1,1) Data structure
%                     .name       (1,:)  Model name
%                     .component  (:)    Component structure
%                     .radius     (1,1)
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 1998-2000, 2009 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

% Input processing
%-----------------

if( nargin < 1 )
  file = '';
end

if( nargin < 2 )
  path = '';
end

if( nargin < 3 )
  kScale = [];
end

if( isempty(path) && ~isempty(file) )
  path = fileparts(which(file));
end

j = findstr( '.', file );

if( isempty(j) && ~isempty(file) )
  file = [file '.obj'];
end

% Open the file
%--------------
if( isempty(file) )
	c = cd;
    if( ~isempty(path) )
        cd( path );
    end
    [file, path] = uigetfile( '*.obj', 'Open 3D Data file');
    if( file ~= 0 )
        cd( path );
        fid    = fopen( file, 'rt' );
        g.name = file;
    else
        fid = -1;
    end
    cd( c );
else
    c = cd;
    if( ~isempty(path) )
        cd( path );
    end
    fid = fopen( file, 'rt' );
    g.name = file;  
end
 
if( fid < 0 )
  if(ischar(file) )
    disp(sprintf('%s: %s could not be found.',mfilename,file))
  end
  g = [];
  return;
end

g = GetDataOBJ(  fid, g, path );

fclose( fid );

if( isempty( g ) )
  return;
end

% Scale the drawing
%------------------
if( isempty( kScale ) )
  kScale = 1;
end

g.radius = 0;
if( isfield( g, 'component' ) )
  for k = 1:length(g.component)
    g.component(k).v = g.component(k).v*kScale;
    g.radius         = max([Mag(g.component(k).v') g.radius]);
  end

  if( nargout == 0 )
    DrawPicture( g );
  end
end


%---------------------------------------------------------------------------
%   Default component
%---------------------------------------------------------------------------
function c = DefaultComponent( k )

c.faceColor                = [1 1 1];
c.edgeColor                = c.faceColor;
c.diffuseStrength          = 0.3;
c.ambientStrength          = 1.0;
c.specularStrength         = 0.3;
c.specularExponent         = 10;
c.specularColorReflectance = 1;
c.v                        = [];
c.f                        = [];
c.a                        = [];
c.n                        = [];
c.r                        = [];
c.radius                   = [];
c.deviceInfo               = {};
c.class                    = '';
c.name                     = '';

%---------------------------------------------------------------------------
%   Draw the picture
%---------------------------------------------------------------------------
function DrawPicture( g )

NewFig( g.name )
axes('DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1] );

for k = 1:length(g.component)
  u(k).h = DrawMesh( g.component(k) );
end

XLabelS('X')
YLabelS('Y')
ZLabelS('Z')

grid
view(3)
rotate3d on
hold off

%---------------------------------------------------------------------------
%  Get the polygon data
%---------------------------------------------------------------------------
function g = GetDataOBJ( fid, g, path )

% Initialize counters
%--------------------
kV      = 0;
kVN     = 0;
kF      = 0;
nG      = 0;

% Read the file
%--------------
while( feof(fid) == 0)
  line = fgetl(fid);
  j    = 0;
  t    = cell(1,2);
 
  jX = findstr('\',line);
  if( ~isempty(jX) )
	line(jX) = '';
    hasContinuation = 1;
  else
	hasContinuation = 0;
  end

  while( ~isempty(line) )
    j = j + 1;
    [t{j}, line] = strtok( line );
  end

  while( hasContinuation )
	line = fgetl(fid);
    jX = findstr('\',line);
    if( ~isempty(jX))
      line(jX) = '';
      hasContinuation = 1;
	else
	  hasContinuation = 0;
    end
	while( ~isempty(line) )
       j = j + 1;
       [t{j}, line] = strtok( line );
    end
  end	 

  if( ~isempty(t{1}) )

    % The first token determines the action
    %--------------------------------------
    switch t{1}
      case '#'
        % A Comment
        %----------

      case 'v'
        kV      = kV + 1;
        v(kV,:) = [str2double(t{2}) str2double(t{3}) str2double(t{4}) ];

      case 'vn'

      case 'vt'
        % Texture map coordinates
        %------------------------

      case 'f'
        lT        = length(t) - 1;
        vT        = zeros(1,lT);
        for k = 1:lT
			if( ~isempty(t{k+1}) )
		      gVO = GetVertexOBJ(t{k+1});
		  
		      if( ~isempty(gVO) )
                vT(k) = gVO;
			  end
		    end
        end

        % Assign the faces to all groups
        %-------------------------------
        for k = 1:length(kG)
          j     = kG(k);
          kF(j) = kF(j) + 1;
          g.component(j).f(kF(j),1:lT) = vT;
        end

      case 'g'
         n = length(t) - 1;
         if( ~isempty( t{2} ) )
           kG = [];
           for j = 1:n
             isANewGroup = 1;
             if( nG > 0 )
               for i = 1:nG
                 if( strcmp( group{i}, t{j+1} ) )
                   isANewGroup = 0;
                   break;
                 end 
               end
               if( isANewGroup )
                 nG        = nG + 1;
                 kF(nG)    = 0;
                 group{nG} = t{j+1};
                 i         = nG;
               end
               kG = [kG i];
             else
               nG       = 1;
               kG       = 1;
               group{1} = t{2};
             end
           end
         end

      case 'usemtl'
          material(nG+1) = GetMaterial( t{2}, mtl );
          
          
	  case 'mtllib'
            mtl = LoadMTLLIB( t{2}, path );

      % Unknown command
	  %----------------
      otherwise
        disp(sprintf('%s: Line ''%s'' is not recognized',mfilename,t{1}));
    end
  end
end

% Sort into groups
%-----------------
kG = 0;
for k = 1:nG
  [n,m] = size( g.component(k).f );
  fC    = sort(reshape( g.component(k).f, n*m, 1 ));

  % Delete duplicates
  %------------------
  kDelete = find(fC == 0);
  fC(kDelete) = [];
  kDelete = [];
  for j = 2:length(fC)
    if( fC(j) == fC(j-1) )
      kDelete = [kDelete j];
    end
  end

  fC(kDelete) = [];
  if( ~isempty(fC) )
    kG = kG + 1;
    g.component(kG).v = v(fC,:);
    [rF,cF] = size( g.component(kG).f );
    for i = 1:rF
      for j = 1:cF
        if( g.component(kG).f(i,j) == 0 )
          break;
        else
          p = find( fC == g.component(kG).f(i,j) ); % Reindexing
          g.component(kG).f(i,j) = p;
        end
      end
      nM = find(g.component(kG).f(i,:) == 0);
      if( isempty(nM) )
        nM = length( g.component(kG).f(i,:) );
      else
        nM = min(nM) - 1;
      end
      g.component(kG).n(i) = nM; % The number of vertices per face
    end
    
    cV = ConvertOBJFileColorToMatlab( material(k) );
   
    g.component(kG).name                     = group{k};
    g.component(kG).faceColor                = cV.faceColor;
    g.component(kG).edgeColor                = cV.edgeColor;
    g.component(kG).diffuseStrength          = cV.diffuseStrength;
    g.component(kG).specularStrength         = cV.specularStrength;
    g.component(kG).ambientStrength          = cV.ambientStrength;
    g.component(kG).specularExponent         = cV.specularExponent;
    g.component(kG).specularColorReflectance = cV.specularColorReflectance;
  end
end

%---------------------------------------------------------------------------
%  Get the vertex from the face vertex list
%---------------------------------------------------------------------------
function v = GetVertexOBJ( t )

k = findstr(char(t),'/');

if( isempty(k) )
  v = str2num(t);
else
  k = k(1);
  v = str2num(t(1:(k-1)));
end

%---------------------------------------------------------------------------
%  Draw a mesh
%---------------------------------------------------------------------------
function h = DrawMesh( m )

kMax = max(m.n);
kMin = min(m.n);
i    = 1;
for k = kMin:kMax
	j = find( m.n == k );
	if( ~isempty(j) )
  	h(i) = patch( 'Vertices', m.v, 'Faces',   m.f(j,1:k),...
	      	      'FaceColor',                m.faceColor,...
                  'EdgeColor',                m.edgeColor,...
                  'ambientStrength',          m.ambientStrength,...
                  'SpecularExponent',         m.specularExponent,...
  				  'SpecularColorReflectance', m.specularColorReflectance,...
				  'EdgeLighting', 'phong',...
				  'FaceLighting', 'phong');
    i = i + 1;
	end
end


%---------------------------------------------------------------------------
%  Load a material library
%---------------------------------------------------------------------------

function mtl = LoadMTLLIB( file, path )

cd(path)
f = fopen( file, 'rt' );
j = 0;
while( feof(f) == 0)
	line = fgetl(f);
    t    = StringToTokens( line );
    if( isempty(t) )
        t{1} = 'blankline';
    end
    switch t{1}
        case 'newmtl'
            j = j + 1;
            mtl(j).name = t{2};
            
        case 'Kd'
            mtl(j).Kd = [str2double(t{2}) str2double(t{3}) str2double(t{4}) ];

        case 'Ns'
            mtl(j).Ns = str2double(t{2});

        case 'illum'
            mtl(j).illum = str2double(t{2});

        case 'Ks'
            mtl(j).Ks = [str2double(t{2}) str2double(t{3}) str2double(t{4}) ];

        case 'Ka'
            mtl(j).Ka = [str2double(t{2}) str2double(t{3}) str2double(t{4}) ];

        case 'd'
            mtl(j).d = str2double(t{2});

    end
        
end
fclose(f);


%---------------------------------------------------------------------------
%  Select a material library
%---------------------------------------------------------------------------

function material = GetMaterial( name, mtllib )

for k = 1:length(mtllib)
    if( strcmp(name, mtllib(k).name) )
        material = mtllib(k);
        return;
    end
end



%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-12 11:19:43 -0400 (Thu, 12 Mar 2015) $
% $Revision: 39864 $
