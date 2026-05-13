function savePlotAsPNG(figHandle, folderPath, fileName, resolution)
% savePlotAsPNG Guarda una figura de MATLAB como PNG en una carpeta.
%
%   savePlotAsPNG(figHandle, folderPath, fileName) guarda la figura indicada
%   por el handle figHandle en la carpeta folderPath con nombre fileName.png
%   y resolución por defecto de 300 dpi.
%
%   savePlotAsPNG(figHandle, folderPath, fileName, resolution) permite
%   especificar la resolución en dpi (p. ej. 150, 300, 600).
%
%   Ejemplo:
%       f = figure; plot(rand(10,1));
%       savePlotAsPNG(f, 'Resultados/Gráficas', 'mi_plot', 300);

    % Parámetro por defecto para la resolución
    if nargin < 4 || isempty(resolution)
        resolution = 300;
    end

    % Asegurarse de que folderPath existe; si no, crearla
    if ~exist(folderPath, 'dir')
        mkdir(folderPath);
    end

    % Construir la ruta completa al archivo
    fullFileName = fullfile(folderPath, [fileName, '.png']);

    % Ajustar tamaño de la figura para que el guardado refleje lo que ves
    set(figHandle, 'PaperPositionMode', 'auto');

    % Guardar con el comando print a la resolución indicada
    print(figHandle, fullFileName, '-dpng', ['-r', num2str(resolution)]);

    fprintf('Guardado: %s\n', fullFileName);
end
