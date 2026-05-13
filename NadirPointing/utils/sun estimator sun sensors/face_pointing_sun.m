function number = face_pointing_sun(faces)
    % This function determines which face is receiving light. It is already known that
    % there is only one face receiving sunlight.
    %
    % faces: Each position of the vector is one face of the satellite.
    %        The vector has 6 positions, from 1 to 6.
    %
    %        [  +Zpower   ,  -Zpower   ,  +Xpower   ,  +Ypower   ,  -Xpower   ,  -Ypower   ]
    %              1            2            3            4            5           6
    %
    %        In each position will be stored the received power from
    %        the photodiodes of all outer boards.
    
    number = 0;  % Initialize the variable to store the face number
    
    % This loop traverses the faces array searching for the face that receives sunlight
    for i = 1:6
        % If the position of the array is different from zero, it means that face is receiving sunlight
        if faces(i) ~= 0
            % When the face is detected, the position of the array is stored and returned
            number = i;
            break;  % Exit the loop once the face is found
        end
    end
end
