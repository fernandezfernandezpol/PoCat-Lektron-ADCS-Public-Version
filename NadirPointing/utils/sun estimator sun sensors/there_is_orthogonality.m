function orthogonality = there_is_orthogonality(faces, face1, face2, face3)
    % This function checks if there is orthogonality between the faces receiving sunlight.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    % face1: Id of a face receiving sunlight.
    % face2: Id of a face receiving sunlight.
    % face3: Id of a face receiving sunlight.
    %
    % orthogonality: 1 if there is orthogonality, 0 otherwise.

    % Check if +Z and -Z faces are receiving sunlight
    if faces(1) ~= 0 && faces(2) ~= 0
        % There is orthogonality
        orthogonality = 1;
    % Check if +X and -X faces are receiving sunlight
    elseif faces(3) ~= 0 && faces(5) ~= 0
        % There is orthogonality
        orthogonality = 1;
    % Check if +Y and -Y faces are receiving sunlight
    elseif faces(4) ~= 0 && faces(6) ~= 0
        % There is orthogonality
        orthogonality = 1;
    else
        % There is no orthogonality
        orthogonality = 0;
    end
end