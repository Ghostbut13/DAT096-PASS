clc, clear all, close all

% choose input file to be read {
    InputFile = "simMic_1.txt";
    % InputFile = "Correct_DAC.txt";
    % InputFile = "Ylog.log";
    % InputFile = "PanningLOG.log";
% }

vhdlFile = 1; % if file is output from modelsim set it to 1, if it is from MATLAB set to 0
q=16; % Set the number of bits of the vectors


% read file
fileId = fopen(InputFile, 'r');
txt = fread(fileId, 'char*1');
fclose(fileId);

len = length(txt)/(q+1+ vhdlFile);
dY = zeros(len,1);

oune = char(49);
zerou = char(48);
for i=1:len
    val = 0;
    for b=1:q
        if txt((i-1)*(q+1 + vhdlFile) +b) == oune
            val = val + 2^(q-b);
        end
    end
    dY(i) = val;
end


% 2s compliment conversion
% dY = mod(dY, 2^(q-1)) -(2^(q-1))*floor(dY./(2^(q-1)));

% Normal plot function {
    plot(dY);
% } end of plot

% plot indexer {
    % plot(dY./(2^13))
    % xlabel("time (sample)")
    % ylabel("Panning indexer")
    % grid on;
% } end of plot

% plot Y position {
    % plot(5*dY/64);
    % xlabel("time (sample)")
    % ylabel("position y (m)")
    % grid on
% } end of plot
