function [torque, d] = PID3Axis( q_ECI_body, d )

%% A PID Based 3 axis controller for rigid body.
%	Use the call with one output to get the default data structure.
% q_target_last ??
%
% Type PID3Axis to demo all modes.
%
%--------------------------------------------------------------------------
% Forms:
%                 PID3Axis;
%             d = PID3Axis;
%   [torque, d] = PID3Axis( q_ECI_body, d )
%--------------------------------------------------------------------------
%
%   -----
%   Input
%   -----
%   q_ECI_body (4,1) ECI to body quaternion
%   d          (1,1) Data structure
%                    .a               (2,2) PID A Matrix
%                    .b               (2,1) PID B Matrix
%                    .c               (1,2) PID C Matrix
%                    .d               (1,1) PID D Matrix
%                    .x_roll          (2,1) PID roll state
%                    .x_yaw           (2,1) PID yaw state
%                    .x_pitch         (2,1) PID pitch stage
%                    .mode            (1,1) Three options:
%                                           Mode 0 = rotate about an axis
%                                           -requires d.q_desired_state 
%                                                     d.angle / d.axis
%                                           Mode 1 = align two vectors
%                                           -requires d.eci_vector 
%                                                     d.body_vector
%                                           Mode 2 = quaternion
%                                           -requires d.q_desired_state
%                    .inertia         (3,3) Inertia matrix
%                    .l               (2,1) Windup compensation matrix
%                    .accel_sat       (1,1) Saturation acceleration
%                    .max_angle       (1,1) Maximum incremental angle
%                    .axis_command    (3,1) Angle of rotation
%                    .body_vector     (3,1) Axis in body frame (mode ?)
%                    .eci_vector      (3,1) Axis in ECI frame
%                    .q_desired_state (4,1) Target quaternion
%          .         .q_target_last   (4,1) Last target
%
%   ------
%   Output
%   ------
%
%   torque     (3,1) Control torque
%   d          (1,1) Data structure
%   
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2010 Princeton Satellite Systems.  
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since version 9.
%--------------------------------------------------------------------------

% Demo
%-----
if( nargin < 1 )
  d = DefaultData;
  if nargout == 1
    torque = d;
    return;
  end
  dT                   = 1;
  nSim                 = 500;
  [d.a, d.b, d.c, d.d] = PIDMIMO(1,1,0.01,200,0.05,dT);
  
  disp('Using the axis rotation mode about z')
  x                    = [1;0;0;0;0;0;0];
  d.q_target_last      = x(1:4);
  xP                   = zeros(11,nSim+1);
  dQ                   = QError( x(1:4), d );
  xP(:,1)              = [x;0;0;0;dQ];
  for k = 1:nSim
    [torque, d]   = PID3Axis( x(1:4), d );
    d.torque      = torque;
    x             = RK4(@RHS,x,dT,0,d);
    xP(:,k+1)     = [x;torque;QError(x(1:4),d)];
  end
  [t,tL] = TimeLabl( (0:nSim)*dT );
  Plot2D( t, xP([1: 4,11],:), tL, {'q_s' 'q_x' 'q_y' 'q_z' 'dQ (rad)'},'Quaternion: Axis Rotation');
  Plot2D( t, xP(8:10,:),      tL, {'T_x' 'T_y' 'T_z'      }, 'Torque: Axis Rotation'   );
    
	disp('Using the axis align mode')
    d.mode               = 1;
    t                    = (0:nSim)*dT;
    x                    = [1;0;0;0;0;0;0];
    d.eci_vector         = [0;1;0];
    d.body_vector        = [1;0;0];
    angle                = acos(d.eci_vector'*QTForm( x(1:4), d.body_vector ) );
    xP(:,1)              = [x;0;0;0;angle];
    for k = 1:nSim
        [torque, d]     = PID3Axis( x(1:4), d );
        d.torque        = torque;
        x               = RK4(@RHS,x,dT,0,d);
        angle           = acos(d.eci_vector'*QTForm( x(1:4), d.body_vector ) );
        xP(:,k+1)       = [x;torque;angle];
    end
    [t,tL] = TimeLabl( (0:nSim)*dT );
    Plot2D( t, xP([1: 4,11],:), tL, {'q_s' 'q_x' 'q_y' 'q_z' 'Angle Error (rad)'},'Quaternion: Vector Align');
    Plot2D( t, xP(5: 7,:),      tL, {'\omega_x' '\omega_y' '\omega_z'},           'Body Rate: Vector Align');
    Plot2D( t, xP(8:10,:),      tL, {'T_x' 'T_y' 'T_z'      },                    'Torque: Vector Align'   );
    Plot2D( t, d.eci_vector,    tL, {'x' 'y' 'z'},                                'ECI Vector: Vector Align' );
    
	disp('Using the quaternion target mode')
    d.mode               = 2;
    x                    = [1;0;0;0;0;0;0];
    qTarget              = [0;1;0;0];
    xP                   = zeros(14,nSim+1);
    xP(:,1)              = [x;0;0;0;qTarget];
    d.q_desired_state    = qTarget;
    for k = 1:nSim
        [torque, d]   = PID3Axis( x(1:4), d );
        d.torque      = torque;
        x             = RK4(@RHS,x,dT,0,d);
        xP(:,k+1)     = [x;torque;qTarget];
    end
    k = [1:4 11:14];
    [t,tL] = TimeLabl( (0:nSim)*dT );
    Plot2D( t, xP(k,:), tL, {'q_s' 'q_x' 'q_y' 'q_z'},'Quaternion: Quaternion Target',...
            'lin',{'[1 5]' '[2 6]' '[3 7]' '[4 8]'});
    Plot2D( t, xP(8:10,:), tL, {'T_x' 'T_y' 'T_z'}, 'Torque: Quaternion Target'   );

    clear torque
    return
end


% Reset PID states
%-----------------
if( d.reset )
	d.x_roll  = [0;0];
	d.x_yaw   = [0;0];
	d.x_pitch	= [0;0];
end

% Declare local params: delta quaternion, angle and unit vector
%--------------------------------------------------------------
switch( d.mode )
  case 0
    q_target = QMult( d.q_desired_state, AU2Q( d.angle, d.axis ) );
  case 1
    q_target = U2Q( d.eci_vector, d.body_vector );
  case 2
    q_target = d.q_desired_state;
end

if (isempty(d.q_target_last))
  d.q_target_last = q_ECI_body;
end

% Calculate the total delta quaternion, convert to angle/unit vector form
%------------------------------------------------------------------------
delta_q = QMult( QPose(d.q_target_last), q_target);
[angle, u] = Q2AU( delta_q );
	
% If the requested change is large, increment the target slowly
%--------------------------------------------------------------
if (abs(unwrap(angle)) > d.max_angle)
  if (angle < 0.0)
    delta_q  = AU2Q(-d.max_angle, u);
  else
    delta_q  = AU2Q(d.max_angle, u);
  end % max_angle 1st check
  q_target = QMult(d.q_target_last, delta_q);
end % max_angle 2nd check

% Memory of incremental target quaternion
%----------------------------------------
d.q_target_last = q_target;
	
% Compute the achievable target, q_target_body
%---------------------------------------------
q_target_body = QPose(QMult(QPose(q_ECI_body), q_target));
    
% maintain sign convention
%-------------------------
if (q_target_body(1,1) < 0.0)
  q_target_body = -q_target_body;
end


% Convert to angular error using small angle convention
%------------------------------------------------------
angle_error = -2.0*q_target_body(2:4);
	
% Calculate commanded acceleration for each axis
%-----------------------------------------------
accel(1,1)         = d.c*d.x_roll + d.d*angle_error(1,1);
[a,b,l,accel(1,1)] = Windup( accel(1,1), d.accel_sat(1,1), d );
d.x_roll           = a*d.x_roll + b*angle_error(1,1) + l*accel(1,1);

accel(2,1)         = d.c*d.x_pitch + d.d*angle_error(2,1);
[a,b,l,accel(2,1)] = Windup( accel(2,1), d.accel_sat(2,1), d );
d.x_pitch          = a*d.x_pitch + b*angle_error(2,1) + l*accel(2,1);

accel(3,1)         = d.c*d.x_yaw + d.d*angle_error(3,1);
[a,b,l,accel(3,1)] = Windup( accel(3,1), d.accel_sat(3,1), d );	
d.x_yaw            = a*d.x_yaw + b*angle_error(3,1) + l*accel(3,1);
	
torque             = -d.inertia*accel;


%--------------------------------------------------------------------------
%	Windup compensation
%--------------------------------------------------------------------------
function [a,b,l,accel] = Windup( accel, accel_sat, d )

if( accel > accel_sat )
    a = d.a - d.l*d.c;
    b = d.b - d.l*d.d;
    l = d.l;
else
    a = d.a;
    b = d.b;
    l = [0;0];
end

if( accel > accel_sat )
	accel = accel_sat;
elseif( accel < -accel_sat )
	accel = -accel_sat;
end


%--------------------------------------------------------------------------
%	Simulation
%--------------------------------------------------------------------------
function xDot = RHS( x, ~, d )

q = x(1:4);
w = x(5:7);

xDot = [QIToBDot( q, w );d.inertia\d.torque];


%--------------------------------------------------------------------------
%	Vector error
%--------------------------------------------------------------------------
function dQ = QError( q, d )

dQ  = acos(Dot(d.eci_vector,QTForm(q,d.body_vector)));


%--------------------------------------------------------------------------
%	Data structure format
%--------------------------------------------------------------------------
function d = DefaultData

dT                   = 1;
[d.a, d.b, d.c, d.d] = PIDMIMO(1,1,0.01,200,0.05,dT);
d.inertia            = eye(3);
d.max_angle          = 0.01;
d.accel_sat          = [100;100;100];
d.mode               = 0;
d.l                  = [0;0];
d.x_roll             = [0;0];
d.x_pitch            = [0;0];
d.x_yaw              = [0;0];
d.q_target_last      = [];
d.q_desired_state    = [0;0;0;1];
d.reset              = 0;
d.eci_vector         = [1;0;0];
d.body_vector        = [0;0;1];
d.angle              = pi/2;
d.axis               = [0;0;1];

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-24 16:18:36 -0400 (Thu, 24 Mar 2016) $
% $Revision: 42057 $