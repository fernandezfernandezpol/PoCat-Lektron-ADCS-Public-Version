function [d,angleError3,x,p3] =SunPointingFunction(x,d,p3,jD)
 %% SunPointing Function for a CubeSat orbit and attitude dynamical model.
%
% Calculates the torque that the reaction wheels have to do to point the 
% desired axis to a the sun
% If the satellite is in eclipse no torque
% 
%   ------
%   Inputs
%   ------
%   x        (14,1)    [r;v;q;w;wRWA;b]
%   d          (.)     Data structure
%                      .jD0      (1,1) Julian date of epoch
%                      .mass     (1,1) Spacecraft mass (kg)
%                      .inertia  (3,3) Inertia matrix (kg-m2)
%                      .dipole   (3,1) Residual dipole (ATM^2)
%                      .power     (.)  Power data, see SolarCellPower 
%                      .aeroModel    * Handle, see CubeSatAero
%                      .opticalModel * Handle, see CubeSatRadiationPressure
%                      .surfData  (.)  optional; empty to skip drag/optical calcs
%                                      .cD    (3,1) Drag coefficient
%                                      .cM    (3,1) Center of mass (m)
%                                      .area  (1,n) Area (m2)
%                                      .nFace (3,n) Face normals
%                                      .rFace (3,n) Face locations (m)
%                                      .att    (.)  Attitude model
%                                      .sigma (3,n) Optical coefficients
%                                      .planet (1)  Planet effects flag
%                      .atm       (.) optional; empty to skip J70 and use AtmDens2
%                      .kWheels         (n), empty if no wheels, indices of wRWA
%                      .inertiaRWA     (1,1), optional, polar inertia (kg-m2)
%                      .tRWA           (3,1), optional, wheel torque (Nm)
%   p3          (1,1) Data structure
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
%   jD       (1,1)      Current Julian date
%
%   -------
%   Outputs
%   -------
%   d          (.)     Data structure
%                      .jD0      (1,1) Julian date of epoch
%                      .mass     (1,1) Spacecraft mass (kg)
%                      .inertia  (3,3) Inertia matrix (kg-m2)
%                      .dipole   (3,1) Residual dipole (ATM^2)
%                      .power     (.)  Power data, see SolarCellPower 
%                      .aeroModel    * Handle, see CubeSatAero
%                      .opticalModel * Handle, see CubeSatRadiationPressure
%                      .surfData  (.)  optional; empty to skip drag/optical calcs
%                                      .cD    (3,1) Drag coefficient
%                                      .cM    (3,1) Center of mass (m)
%                                      .area  (1,n) Area (m2)
%                                      .nFace (3,n) Face normals
%                                      .rFace (3,n) Face locations (m)
%                                      .att    (.)  Attitude model
%                                      .sigma (3,n) Optical coefficients
%                                      .planet (1)  Planet effects flag
%                      .atm       (.) optional; empty to skip J70 and use AtmDens2
%                      .kWheels         (n), empty if no wheels, indices of wRWA
%                      .inertiaRWA     (1,1), optional, polar inertia (kg-m2)
%                      .tRWA           (3,1), optional, wheel torque (Nm)
%   angleError3 (1,1)    Angle Error between p.eci_vector and the sun
%                       vector
%   x        (14,1)	   d[r;v;q;w;b]/dt
%   p3          (1,1) Data structure
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
%   torque  (3,1)    The torque that the RW have to do
%
% ------------------------------
%   Since version 1 (2017).



radToDeg        = 180/pi;

r = x(1:3);
v = x(4:6);
q = x(7:10);
w = x(11:13);

 qECIToBody   = x(7:10);


 %Sun Pointing__________________
 
  [s,distance_btw_Sun] = SunV1(jD,x(1:3));
  [s_earth,dESkm] = SunV1(jD,[0;0;0]);
  dESm = s_earth*dESkm*1000;
  Eclipse_state = Eclipse_Check(r,s_earth,1,dESm);
  
    if(Eclipse_state==0)
      
    p3.eci_vector=Unit(s*distance_btw_Sun-x(1:3));
    angleError3   = acos(Dot(p3.eci_vector,QTForm(qECIToBody,p3.body_vector)))*radToDeg;
    [torque3, p3]  = PID3Axis( qECIToBody, p3 );
    torque=torque3;
    d.tRWA       = -torque;
    
    elseif(Eclipse_state==2)
       
       d.tRWA = [0;0;0];
       angleError3   = acos(Dot(p3.eci_vector,QTForm(qECIToBody,p3.body_vector)))*radToDeg;
       
    elseif(Eclipse_state==1)
        
        d.tRWA = [0;0;0];
        angleError3   = acos(Dot(p3.eci_vector,QTForm(qECIToBody,p3.body_vector)))*radToDeg;
       
    end
    

end