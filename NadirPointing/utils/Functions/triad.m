function [rotation_matrix] = triad(reference1,reference2,body1,body2)

% rx=cross(reference1,reference2)/(norm(cross(reference1,reference2)));
% 
% bx=cross(body1,body2)/(norm(cross(body1,body2)));
% 
% rotation_matrix=body1*reference1'+(cross(body1,bx))*(cross(reference1,rx))'+bx*rx';
rx=cross(reference1,reference2)/(norm(cross(reference1,reference2)));
bx=cross(body1,body2)/(norm(cross(body1,body2)));

v1=reference1/norm(reference1);
v2=rx;
v3=cross(reference1,rx);
v3=v3/norm(v3);

w1=body1/norm(body1);
w2=bx;
w3=cross(body1,bx);
w3=w3/norm(w3);

aux1=[v1 v2 v3];
aux2=[w1 w2 w3]';
rotation_matrix = aux1*aux2;
% (C8) FIX: Returns R s.t. R·w_i = v_i, i.e. body→ECI rotation. PSS quaternion
%           convention is ECI→body. Transpose to get ECI→body before extraction:
% rotation_matrix = rotation_matrix';


end

