function devices = devices_and_support(fs_list,buff_list)
    % find devices with ASIO support
    deviceReader = audioDeviceReader('Driver', 'ASIO');
    deviceList = getAudioDevices(deviceReader);
    deviceList(strcmp(deviceList, 'Default')) = [];
    
    
    % ---configuration caching ---
     % check if cache exists
    if exist("dev_conf_cache.mat","file")
        % load cache
        load("dev_conf_cache.mat","devices");
        % check if saved devices are the same
        if devices(1).names == string(deviceList)
            % if they are use cache
            return
        end
        % if they are not, check devices
    end

    

    % check and write all combinations
    for i = 1:length(deviceList)
        deviceName = deviceList{i};
        fprintf('\n Testing device: %s \n', deviceName);
        devices(1).names(i) = string(deviceName); 
        j = 1;
        for fs = fs_list
            fprintf('* Samplerate: %d Hz\n', fs);
            k = 1;
            for buf = buff_list
                    reader = audioDeviceReader( ...
                        'Driver', 'ASIO', ...
                        'Device', deviceName, ...
                        'SampleRate', fs, ...
                        'SamplesPerFrame', buf);
                try
                    setup(reader);  % Initialize device with settings
                    release(reader);
                    fprintf('* * Buffer %d samples: OK\n', buf);
                    devices(i).fs(j) = fs; 
                    devices(i).buffer(k) = buf; 
                catch ME
                    fprintf(' * * Buffer %d samples: error (%s)\n', buf, ME.message);
                end
                pause(0);
                k = k+1;
            end % buf = buff_list
            j = j+1;
        end % fs = fs_list
    end
    % cache result
    save("dev_conf_cache.mat","devices");
end