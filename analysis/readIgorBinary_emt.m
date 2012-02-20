function [data, info] = readIgorBinary_emt(varargin)
%
% [data, info] = readIgorBinary(varargin) reads the selected files and
% outputs the data as an [nSamples x nChannels] array and a structure info,
% with the information about the recording setup
%
% (c) bnaecker@stanford.edu
% edited 1/31/12 - etrautmann@stanford.edu to make callable from script

try
    %% Parse input (nothing yet)
    if nargin == 0
        [fname, pathname, findex] = ...
            uigetfile('*.bin', 'Pick some binary files to load', ...
            'MultiSelect', 'on');
        if ~findex
            return
        end
    elseif nargin > 1
        error('readIgorBinary:tooManyInputArgs', ...
            'Too many input arguments');
    end
    
    %% Design output based on number of files chosen
%     nFiles = length(fname);
    nFiles = 1;
    dataBuffer = cell(nFiles, 1);
    info = struct('headerSize', {}, ...
        'type', {}, ...
        'version', {}, ...
        'nSamples', {}, ...
        'nChannels', {}, ...
        'channel', {}, ...
        'sampleRate', {}, ...
        'blockSize', {}, ...
        'gain', {}, ...
        'offset', {}, ...
        'dateSize', {}, ...
        'dateStr', {}, ...
        'timeSize', {}, ...
        'timeStr', {}, ...
        'roomSize', {}, ...
        'roomStr', {});
    
    %% Load the binary files
    for fileI = 1:nFiles
        
        % Open the file, rewind
        info(fileI).fileName = fullfile(pathname, fname{fileI});
        fId = fopen(info(fileI).fileName, 'r', 'b', 'windows-1252');
        frewind(fId);
        
        % Read the header information
        info(fileI).headerSize = fread(fId, 1, 'int32', 'b');
        info(fileI).type = fread(fId, 1, 'int16', 'b');
        info(fileI).version = fread(fId, 1, 'int16', 'b');
        info(fileI).nSamples = fread(fId, 1, 'int32', 'b');
        info(fileI).nChannels = fread(fId, 1, 'int32', 'b');
        info(fileI).channel = fread(fId, 1, 'int16', 'b');
        info(fileI).sampleRate = fread(fId, 1, 'float32', 'b');
        info(fileI).blockSize = fread(fId, 1, 'int32', 'b');
        info(fileI).scaleMultiplier = fread(fId, 1, 'float32', 'b');
        info(fileI).scaleOffset = fread(fId, 1, 'float32', 'b');
        info(fileI).dateSize = fread(fId, 1, 'uint32', 'b');
        info(fileI).dateStr = ...
            fread(fId, info(fileI).dateSize, 'char*1', 'b');
        info(fileI).timeSize = fread(fId, 1, 'uint32', 'b');
        info(fileI).timeStr = ...
            fread(fId, info(fileI).timeSize, 'char*1', 'b');
        info(fileI).roomSize = fread(fId, 1, 'uint32', 'b');
        info(fileI).roomStr = ...
            fread(fId, info(fileI).roomSize, 'char*1', 'b');
        
        % Read data
        dataBuffer{fileI} = nan .* ones(info(fileI).nSamples, ...
            info(fileI).nChannels);
        fseek(fId, info(fileI).headerSize, 'bof');
        skip = (info(fileI).nChannels - 1) * info(fileI).blockSize * 2;
        for c = 1:info(fileI).nChannels
            dataBuffer{fileI}(:, c) = ...
                fread(fId, info(fileI).nSamples, 'uint16', skip, 'b');
        end
        
        % Close the file
        fclose(fId);
    end
    
    %% Concatenate data into the desired format
    data = vertcat(dataBuffer{:});
    
catch me
    data = me;
end