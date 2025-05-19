function devices = devices_and_support(fs_list,buff_list)
    deviceReader = audioDeviceReader('Driver', 'ASIO');
    deviceList = getAudioDevices(deviceReader);
    deviceList(strcmp(deviceList, 'Default')) = [];
    for i = 1:length(deviceList)
        deviceName = deviceList{i};
        fprintf('\n=== Testuji zařízení: %s ===\n', deviceName);
        devices(1).names(i) = string(deviceName); 
        j = 1;
        for fs = fs_list
            fprintf('Vzorkovací frekvence: %d Hz\n', fs);
            k = 1;
            for buf = buff_list
                    reader = audioDeviceReader( ...
                        'Driver', 'ASIO', ...
                        'Device', deviceName, ...
                        'SampleRate', fs, ...
                        'SamplesPerFrame', buf);
                try
                    setup(reader);  % Inicializace zařízení
                    release(reader);
                    fprintf('  ✔ Buffer %d vzorků: OK\n', buf);
                    devices(i).fs(j) = fs; 
                    devices(i).buffer(k) = buf; 
                catch ME
                    fprintf('  ✘ Buffer %d vzorků: Chyba (%s)\n', buf, ME.message);
                end
                k = k+1;
            end
            j = j+1;
        end
    end

end