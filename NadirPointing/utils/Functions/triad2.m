function [rotation_matrix] = triad2(reference1,reference2,body1,body2)

% rx=cross(reference1,reference2)/(norm(cross(reference1,reference2)));
% 
% bx=cross(body1,body2)/(norm(cross(body1,body2)));
% 
% rotation_matrix=body1*reference1'+(cross(body1,bx))*(cross(reference1,rx))'+bx*rx';
% 

    % Normalizar los vectores de entrada
    reference1 = reference1 / norm(reference1);
    reference2 = reference2 / norm(reference2);
    body1 = body1 / norm(body1);
    body2 = body2 / norm(body2);

    % Calcular r_x y b_x mediante el producto cruzado y normalizarlos
    rx = cross(reference1, reference2);
    rx = rx / norm(rx);
    bx = cross(body1, body2);
    bx = bx / norm(bx);

    % Calcular los otros dos vectores ortogonales
    ry = cross(rx, reference1);
    by = cross(bx, body1);

    %Calcular la matriz de rotacion
    rotation_matrix = body1*reference1' + by*ry' + bx*rx';

end

