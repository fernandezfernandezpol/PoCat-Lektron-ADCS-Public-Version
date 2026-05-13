function faces_number = number_faces_pointing_sun(faces)
    % This function determines the number of faces of the satellite that are
    % receiving light.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    %        In each position will be stored the received power from
    %        the photodiodes of all outer boards.
    
    faces_number = 0;  % Initialize the counter for faces receiving sunlight
    
    % This loop traverses the faces array searching for faces that receive sunlight
    for i = 1:6
        % If the position of the array is different from zero, it means that face is receiving sunlight
        if faces(i) ~= 0
            % When a face is detected, the counter increases by one
            faces_number = faces_number + 1;
        end
    end
end
