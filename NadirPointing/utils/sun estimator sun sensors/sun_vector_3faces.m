function sun_position = sun_vector_3faces(faces, sunfaces)
    % This function calculates the sun position vector based on three faces receiving sunlight.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    % sunfaces: A vector of length 3 containing the indices of the faces receiving sunlight.
    %           The indices are 0-based (e.g., [0, 2, 3] corresponds to +Z, +X, +Y).
    %
    % sun_position: A 3-element vector representing the sun's position in
    %               the form [X component; Y component; Z component].


    % Initialize variables
    face_x = 0;
    face_y = 0;
    face_z = 0;

    % Identify which axis corresponds to each face
    for i = 1:3
        if ismember(sunfaces(i), [1, 2])  % Z faces (+Z or -Z)
            face_z = sunfaces(i);
        elseif ismember(sunfaces(i), [3, 5])  % X faces (+X or -X)
            face_x = sunfaces(i);
        elseif ismember(sunfaces(i), [4, 6])  % Y faces (+Y or -Y)
            face_y = sunfaces(i);
        end
    end

    % Calculate phi and theta using the phi_calc and theta_calc functions
    phi = phi_calc(faces, face_x, face_y);  % Adjust indices for phi_calc
    theta = theta_calc(faces, face_z, face_y, phi);  % Adjust indices for theta_calc

    % Calculate the sun position vector
    sun_position = [sin(theta) * cos(phi); sin(theta) * sin(phi); cos(theta)];
    % sun_position = [sin(theta) * sin(phi); sin(theta) * cos(phi); cos(theta)];
end


