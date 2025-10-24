function [moved, currPosition] = moveResp2NoLoad(respDevice, unitscale)
%moveResp2NoLoad Moves respiroception device to no load position (not
%touching tube), ~ position 20
%   Input:
%       respDevice       serial port, e.g. "COM5" (windows)
%       unitscale        units to scale. 0 percent (0-100), 1 mm (0-17)
% Niia Nikolova 01/10/2020


% Move to No Load position
if unitscale==1
    %newPosition = 5000; % custom edit for FND RRST device #1 (NG)
    newPosition = 0; % this is 50% compression as defined by mm ranges (1-17 mm)
elseif unitscale==0
    newPosition = 0; % corresponds to min, i.e. 5000 as defined in scale2motorstep.m
end
[moved, currPosition] = moveResp(respDevice, newPosition, unitscale);

end

 