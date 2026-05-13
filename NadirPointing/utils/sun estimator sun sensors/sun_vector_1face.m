function sun_position = sun_vector_1face(sunface)
    % This function estimates the sun position in the case where only
    % one face is pointing to the sun.
    %
    % sunface: This variable represents the face that is receiving sunlight.
    %          It is an integer value ranging from 0 to 5, where:
    %          0: +Z, 1: -Z, 2: +X, 3: +Y, 4: -X, 5: -Y
    %
    % sun_position: A 3-element vector representing the sun's position in
    %               the form [X component; Y component; Z component].

    % Initialize the sun position vector
    sun_position = zeros(3, 1);  % [X; Y; Z]

    % Determine the sun position based on the face receiving sunlight
    switch sunface
        case 0  % +Z
            sun_position = [0; 0; 1];
        case 1  % -Z
            sun_position = [0; 0; -1];
        case 2  % +X
            sun_position = [1; 0; 0];
        case 3  % +Y
            sun_position = [0; 1; 0];
        case 4  % -X
            sun_position = [-1; 0; 0];
        otherwise  % -Y (default case)
            sun_position = [0; -1; 0];
    end
end

