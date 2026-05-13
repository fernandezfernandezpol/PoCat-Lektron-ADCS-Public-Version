function [quaternion,theta] = rotmatrix2quat(rotmatrix)
    theta = acosd((trace(rotmatrix)-1)/2);
    % theta= 1/cos((trace(rotmatrix)-1)/2);
    
    auxvec=[rotmatrix(2,3)-rotmatrix(3,2); rotmatrix(3,1)-rotmatrix(1,3); rotmatrix(1,2)-rotmatrix(2,1)];
    e=1/(2*sind(theta))*auxvec;
    e=e/norm(e);
    epsilon= e*sind(theta/2);
    quaternion=[cosd(theta/2);epsilon];
    

end

