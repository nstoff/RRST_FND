function calibrateResp(respDevice)
%calibrateResp Calibrates the device. Wedge moves slowly (backwards then forwrads)
% until it reaches the switch.

%   Input:
%       respDevice       serial port, e.g. "COM5" (windows)
% Niia Nikolova 05/2022

% NG: 
% implemented the calibration in the Arduino code already
% -> for that, move to position <0 and it will calibrate again
% using the switch

calibrateCmd = '-10'; % position <0 so that the homing procedure is run (Arduino)

%calibrateCmd     = sprintf('c');
writeline(respDevice, calibrateCmd);

end
