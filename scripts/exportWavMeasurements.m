function exportWavMeasurements(data, Fs, exportFolder)
% exportWavMeasurements
% Export all microphone recordings as WAV files
%
% data.sig : [N x M] signal matrix
% data.az  : [1 x M] azimuths
% data.el  : [1 x M] elevations
% Fs       : sampling frequency
% exportFolder : destination folder

    if nargin < 3 || isempty(exportFolder)
        exportFolder = '../export';
    end

    if ~isfolder(exportFolder)
        mkdir(exportFolder)
    end

    % delete existing wav files
    wav_files = dir(fullfile(exportFolder, '*.wav'));
    for k = 1:numel(wav_files)
        delete(fullfile(exportFolder, wav_files(k).name));
    end

    sz = size(data.sig, 2);
    dateStr = datestr(datetime('now'),'yyyymmdd');

    for ind = 1:sz
        az = data.az(ind);
        el = data.el(ind);

        filename = sprintf('export_%s_%03d_az%.1f_el%.1f.wav', ...
                            dateStr, ind, az, el);

        fullpath = fullfile(exportFolder, filename);
        audiowrite(fullpath, data.sig(:,ind), Fs);
    end
end