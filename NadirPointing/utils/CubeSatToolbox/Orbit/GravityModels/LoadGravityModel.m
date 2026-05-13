function gravityModel = LoadGravityModel( action, fileName )

%--------------------------------------------------------------------------
%   Load a spherical harmonic gravity model from GSFC/University of Texas at Austin.
%   The coefficients returned from this file are unnormalized.
%
%   This routine works with GEMT1, JGM2 and JGM3. JGM3 is the most accurate
%   earth gravitational model currently available. JGM2 is used by Vallado
%   in his book. GEMT1 is also available within the toolbox by typing
%   LoadGEM. The gravity files all have the suffix '.geo'.
%
%   NOTE
%   ----
%   All these models are publicly available, however, the proper
%   authorizations to obtain the GEM-*, JGM-1, and JGM-2 models
%   should be directed to NASA/GSFC (Steve Klosko, internet:
%   klosko@ccmail.stx.com (Steve Klosko)).  The request for other models 
%   should be directed to UT/CSR (shum@csr.utexas.edu).
%
%--------------------------------------------------------------------------
%   Form:
%   gravityModel = LoadGravityModel( action, fileName )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   action          (1,:) 'get url' or 'load file'
%   fileName        (1,:) fileName
%
%   -------
%   Outputs
%   -------
%   gravityModel    (1,1) Data structure
%                         .name (1,:) Model name
%                         .mu   (1,1) Gravitational constant (km^3/sec^2)
%                         .a    (1,1) Model earth radius (km)
%                         .c    (n,n) Cosine coefficients
%                         .s    (n,n) Sine coefficients
%                         .j    (1,n) Zonal harmonics
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2000 Princeton Satellite Systems, Inc.
%   All rights reserved.
%--------------------------------------------------------------------------

if( nargin < 1 || isempty(action) )
  action = 'load file';
end

switch action
	case 'get url'
        gravityModel = 'ftp://geodesy.gsfc.nasa.gov/dist/GEM_Models/';
        return;
		
    case 'load file'
        oldPathName = cd;
        if( nargin < 2 )
            [fileName, pathName] = uigetfile('*.geo','Load Gravity Model');
            if( fileName == 0 )
                return;
            end
        else
            [pathName, fileName, ext] = fileparts( which(fileName) );
            fileName = [fileName  ext];
        end
	
        cd( pathName );
        [fId, msg] = fopen( fileName, 'rt' );
        if( fId == -1 )
            error(msg);
        end
		
        % The header
        %-----------
        if( findstr( 'WGS', fileName ) )
            f                        = fgetl( fId );
            f                        = fgetl( fId );
            gravityModel.name        = 'WGS-84';
            gravityModel.string      = '';
            gravityModel.mu          = str2num(f(25:44))/1e9;
            gravityModel.a           = str2num(f(45:59))/1e3;
            while ~feof( fId )
                f  = fgetl( fId );
                if( length(f) < 44 )
                    break;
                end
                i  = str2num(f( 8:17));
                j  = str2num(f(18:20));
                c1 = str2num(f(21:44));
                switch f(1:7)
                    case {'GCOEFC1'}
                        if( j == 0 )
                            gravityModel.j(i) = c1*sqrt(2*i+1);
                        else
                            gravityModel.c(i,j) = c1;
                        end
                    case {'GCOEFS1'}
                        if( j > 0 )
                            gravityModel.s(i,j) = c1;
                        end
                end
            end
        else
            f                        = fgetl( fId );
            f                        = fgetl( fId );
            gravityModel.name        = deblank(f( 1: 9));
            gravityModel.string      = deblank(f(10:24));
            gravityModel.mu          = str2num(f(25:44))/1e9;
            gravityModel.a           = str2num(f(45:60))/1e3; 
            f                        = strtok( fgetl( fId ) );
	
            while ~feof( fId )
                f  = fgetl( fId );
                if( length(f) < 52 )
                    break;
                end
                i  = str2num(f( 7: 8));
                j  = str2num(f( 9:10));
                c1 = str2num(f(11:31));
                c2 = str2num(f(32:52));
                switch f(1:6)
                    case {'RECOEF' 'TRUE' 'GEOCOE'}
                        if( j == 0 )
                            gravityModel.j(i) = c1*sqrt(2*i+1);
                        else
                            gravityModel.c(i,j) = c1;
                            gravityModel.s(i,j) = c2;
                        end
                end
            end
        end
		
        cd( oldPathName );
        
    otherwise
        error('Action not recognized')
        gravityModel = [];
	
end	

fclose(fId);

% Unnormalize
%------------
j     = length(gravityModel.j);
m     = DupVect(1:j,j);
n     = m';
fM    = n - m;
k     = find(fM < 0);
fM(k) = zeros(size(k));
fP    = n + m;

f              = sqrt( 2*(2*n + 1).*Factorl(fM)./Factorl(fP) );
gravityModel.c = f.*gravityModel.c;
gravityModel.s = f.*gravityModel.s;	

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2015-07-13 15:17:44 -0400 (Mon, 13 Jul 2015) $
% $Revision: 40426 $
