function [m,mA] = TotalMassProps( mA, center )

%--------------------------------------------------------------------------
%   Add mass properties. The center of mass and inertia of every part are
%   defined with respect to a common coordinate system. By default, the
%   output coordinate system is the same as the common coordinate system 
%   for each part. If "center" is set to 1, the output coordinate system is
%   moved to the system center of mass.
%
%   Type TotalMassProps to return the default data structure.
%
%   Since version 8.
%--------------------------------------------------------------------------
%   Form:
%   m = TotalMassProps( mA );
%   m = TotalMassProps( mA, center );
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   mA          (:)    Mass data structure array
%                       .mass    (1,1) Mass
%                       .cM      (3,1) Center-of-mass w.r.t. common frame
%                       .inertia (3,3) Inertia matrix about common frame
%
%   center      (1)    Optional flag, default 0. Set to 1 to place output
%                      coordinate system at system CM.
%   
%   -------
%   Outputs
%   -------
%   m           (.)    Mass data structure for total mass properties
%                      .mass    (1,1) Mass
%                      .cM      (3,1) Center-of-mass w.r.t. output frame
%                      .inertia (3,3) Inertia matrix about output frame
%
%   mA          (:)    Mass data structure array. CM and inertia will be
%                       updated to be defined with respect to system CM if
%                       the "center" input is true.
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2009 Princeton Satellite Systems, Inc.
%   sAll rights reserved.
%--------------------------------------------------------------------------

% Default data structure
%-----------------------
if( nargin == 0 )
  m = struct( 'mass', 0, 'cM', [0;0;0], 'inertia', zeros(3,3) );
  return;
end

if( nargin < 2 )
   center = 0;
end

m.mass    = mA(1).mass;
m.cM      = mA(1).mass*mA(1).cM;
m.inertia = zeros(3,3);

% compute total mass
for k = 2:length(mA)
  m.mass = m.mass + mA(k).mass;
end

% compute total CM
for k = 2:length(mA)
  m.cM = m.cM + mA(k).mass*mA(k).cM;
end
if( m.mass > eps )
  m.cM = m.cM/m.mass;
else
  m.cM = [0;0;0];
end

% compute total inertia about coord frame origin
for k = 1:length(mA)
  m.inertia = m.inertia + mA(k).inertia; % - mA(k).mass*SkewSq(mA(k).cM - m.cM);
end

% inertia about CM
m.inertiaCM = m.inertia + m.mass*SkewSq(m.cM);

% principal moments of inertia about CM
[rot,m.inertiaP] = eig(m.inertiaCM);
m.P = rot';


% put origin at system CM?
if( center )
   
   % store initial cM for later use
   cM0 = m.cM;
      
   % recompute system mass props
   m2 = TransRotMassProps( m, -m.cM, eye(3) );
   
   % recompute mass props of input mass array
   for k=1:length(mA)
      mA(k) = TransRotMassProps( mA(k), -cM0, eye(3) );
   end
   
   check = 1;  % set this to 1 to check results of centering at CM
   
   if( check )
      % check new cM, mass and inertia
      if( norm(m2.cM)>10*eps )
         error('Non-zero CM found after centering at CM.');
      end
      if( norm(m2.mass-m.mass)>10*eps )
         error('New mass does not match original mass after centering at CM.');
      end
      if( norm(m2.inertia - m.inertiaCM)>10*eps )
         error('New inertia does not match inertia about CM after centering at CM.');
      end
      
      % check that same system mass props can be found with new mA
      sys = TotalMassProps( mA );
      if( norm(sys.cM)>10*eps )
         error('Non-zero CM found after centering at CM with offset array.');
      end
      if( norm(sys.mass-m.mass)>10*eps )
         error('New mass does not match original mass after centering at CM with offset array.');
      end
      if( norm(sys.inertia - m.inertiaCM)>10*eps )
         error('New inertia does not match inertia about CM after centering at CM with offset array.');
      end
   end
   
   % output recomputed system mass props
   m = m2;
   
end

% PSS internal file version information
%--------------------------------------
% $Date: 2015-03-13 12:29:00 -0400 (Fri, 13 Mar 2015) $
% $Revision: 39887 $
