function R = quat2rotm(q)
% (m9) NOTE: This local function shadows MATLAB's built-in quat2rotm.
%            Both happen to share scalar-first convention here, but the
%            coexistence is fragile. Consider renaming (e.g. pss_quat2rotm).
% QUAT2ROTM Convert quaternion to rotation matrix
%   R = QUAT2ROTM(q) computes the 3x3 rotation matrix R corresponding to
%   the unit quaternion q = [q0, q1, q2, q3] (q0 is scalar part)
%
%   The rotation matrix is computed as:
%   R = [1-2q2²-2q3²     2(q1q2-q3q0)     2(q1q3+q2q0)
%        2(q1q2+q3q0)   1-2q1²-2q3²       2(q2q3-q1q0)
%        2(q1q3-q2q0)     2(q2q3+q1q0)   1-2q1²-2q2²]

% Normalize quaternion if not already normalized
q = q/norm(q);

% Extract components
q0 = q(1);
q1 = q(2);
q2 = q(3);
q3 = q(4);

% Compute rotation matrix elements
R = [1 - 2*q2^2 - 2*q3^2,   2*(q1*q2 - q3*q0),   2*(q1*q3 + q2*q0);
     2*(q1*q2 + q3*q0),   1 - 2*q1^2 - 2*q3^2,   2*(q2*q3 - q1*q0);
     2*(q1*q3 - q2*q0),     2*(q2*q3 + q1*q0), 1 - 2*q1^2 - 2*q2^2];
end