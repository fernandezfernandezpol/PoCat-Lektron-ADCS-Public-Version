function status = HysteresisOutput(t,y,flag,d)

%--------------------------------------------------------------------------
% Gather output from the hysteresis damping simulation
%--------------------------------------------------------------------------
% status = HysteresisOutput(t,y,flag,d)
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2014 Princeton Satellite Systems, Inc.
%   All Rights Reserved
%--------------------------------------------------------------------------

persistent xP zP tP kF

status  = 0;
degToRad = pi/180;

if isempty(flag)
  nP = size(y,2);
  n0 = length(tP);
  tP = [tP zeros(1,nP)];
  xP = [xP zeros(23,nP)];
  zP = [zP zeros(size(zP,1),nP)];
  for k = 1:size(y,2)
    x = y(:,k);
    tP(n0+k) = t(k);
    [xD, p] = RHSRigidBodyWithDamping(x,t(k),d);
    uECI    = QTForm(x(7:10),d.uDipole);
    angle   = real(acos(Dot(uECI, Unit(p.bFieldECI))))/degToRad;
    xP(:,n0+k) = [x(1:13);p.torqueDamper;p.torqueDipole;angle;p.bFieldECI*1e9];

    if( length(x)>13 )
      zP(:,n0+k) = [x(14:end);p.hMag;p.hDotMag];
    end
  end
  if t(end) > (kF+1)*d.end/10
    kF = kF+1;
    fprintf('%d0%% finished\n',kF);
  end
elseif strcmp(flag,'init')
  tP = 0;
  xP = [y(1:13); zeros(10,1)];
  z  = y(14:end);
  zP = zeros(3*length(z),1);
  kF = 0;
elseif strcmp(flag,'done')
elseif strcmp(flag,'x')
  status = xP;
elseif strcmp(flag,'z')
  status = zP;
elseif strcmp(flag,'t')
  status = tP;
end


%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2014-07-03 14:30:11 -0400 (Thu, 03 Jul 2014) $
% $Revision: 38056 $