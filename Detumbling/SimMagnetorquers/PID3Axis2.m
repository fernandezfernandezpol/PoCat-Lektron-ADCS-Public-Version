function [moment,q_target] = PID3Axis2( q_ECI_body, d, bf, anglevel, alfa, beta)

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

m_max = 0.0069;%0.000924*32/22;
if( nargin < 1 )
  d = DefaultData;
  if nargout == 1
    moment = d;
    return;
  end
end
% Declare local params: delta quaternion, angle and unit vector
%--------------------------------------------------------------

  q_target = U2Q( d.eci_vector, d.body_vector);

% Compute the achievable target, q_target_body
%---------------------------------------------
q_target_body = QMult(QPose(q_ECI_body), q_target); %% it's q_body_target

% maintain sign convention
%-------------------------
if (q_target_body(1,1) < 0.0)
  q_target_body = -q_target_body;
end

moment = (alfa*(cross(bf,q_target_body(2:4)))-beta*(cross(bf,anglevel)))/(norm(bf));
if  max(abs(moment)) > m_max
      disp('pre');
d.dipole = moment*m_max/max(abs(moment));
end


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
d.u2q                = 0;
d.angle              = 0;
%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2016-03-24 16:18:36 -0400 (Thu, 24 Mar 2016) $
% $Revision: 42057 $