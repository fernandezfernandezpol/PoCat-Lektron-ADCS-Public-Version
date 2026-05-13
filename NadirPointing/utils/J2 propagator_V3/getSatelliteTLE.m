function [TLE] = getSatelliteTLE()
%% *purpose*
% return the TLE for Satellite based on epoch
%% *outputs*
%  TLE - the two line element set corresponding to the satellite at that
%        epoch
TLE = { ...
        'LEKTRON'; ...
        '1 41731U 16051A   23363.09069254  .00007725  00000+0  23616-3 0  9992'; ...
        '2 41731  99.0000  271.1908 0012471  113.5977 246.6577 15.24069756410432'};
end




