clear
clc
close
% % % % 
devoiceReader = audioDeviceReader(...
    'Driver', 'ASIO',...
    'Device', 'Texas Instruments USB Audio ...',...
    'SampleRate', 48000,...
    'NumChannels', 8,...
    'BitDepth', '32-bit float',...
    'OutputDataType', 'double');
% % % % %
setup(deviceReader);
info = audioinfo(infile_name);
fileReader = dsp.AudioFileReader(infile_name);
fileInfo = audioinfo(infile_name);

% % % % % 
fileWriter = dsp.AudioFileWriter(outfile_name, 'SampleRate',...
    deviceReader.SampleRate, 'DataType', 'int32');
audioOut = audioDeviceWriter(...
    'SampleRate', fileInfo.SampleRate);

% % % % % 
setup(audioOut, zeros(deviceReader.SamplesPerFrame, fileInfo.NumChannels));

% % % % % 
while ~isDone(fileReader)
    audioToPlay = fileReader();
    audioOut(audioToPlay);
    [audioRead, numOverrun] = deviceReader();
    fileWriter(audioRead);
end
release(audioOut);
release(fileReader);
release(fileWriter);
release(deviceReader);