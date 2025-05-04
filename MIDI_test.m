device = mididevice("3- MIDISPORT Uno Out"); % set midi device

test = 3;
B = hex2dec(strcat("0","0")); % bank/device ID, 7Fh to broadcast
if test == 1
    % this message sets gain for channel 1 to 21 dB
    M = hex2dec("20"); % mm - message type
    N = hex2dec("00"); % nn - parameter number
    O = 30; % oo - data byte
elseif test == 2
    % this message reads gain from channel 1
    M = hex2dec("10"); % mm - message type
    N = hex2dec("00"); % nn - parameter number
    O = 30; % oo - data byte
elseif test == 3
    % this message sets gain for channel 1 to -9 dB
    M = hex2dec("20"); % mm - message type
    N = hex2dec("00"); % nn - parameter number
    O = 0; % oo - data byte    
end
% 10h - request data
% 20h - set value - nn oo can be repeated freely
% SysEx header, manufacturer ID, model ID, bank, message,
% parameter number, data byte, EOX
sysexMsg = uint8([240 0 32 13 104 B M N O 247]); % 240=F0, 247=F7
midisend(device, sysexMsg);
%while true
%   msgs = midireceive(device);
%   msgs
%end