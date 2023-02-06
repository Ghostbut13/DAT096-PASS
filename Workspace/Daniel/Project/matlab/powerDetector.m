clc, clear all, close all

CLK = 48000; % 48kHz sampling rate for ADC
t = 0.1; % 100ms long simulation
SingFreq = 440; % test signal frequency

%********generate signal*********%
X = linspace(0, t, CLK*t); % vector with each sampling points in time
Y = sin(2*pi.*X*SingFreq); % generate signal
qY = uint16((Y+1).*2^15); % quantize signal to 16 bit (matlab doesn't have 
%24bit like the ADC has, but close enough)

%plot(X,qY, '-o'); %<------

%********end of generate signal*********%





%********Complicated way of rectifying (abs) the input signal**********
% This method is easy to implement in VHDL/circuit.
% in essence it takes the 2s compliment of the signal if MSB is low.
% Thereby it folds the signal at the MSB/midpoint back in amplitude.


MSB = qY./(2^16); %extract MSB from each sample

%plot(X, 2^16*MSB); %<-----

pY=qY; % power vector
for i=1:length(X)
    if MSB(i)
        
    else
        pY(i) = bitcmp(pY(i)) +1; % returns the bit-wise compliment,
        %or inversion if you like.
        % if the resolution is hight then we most likely can ignore +1 as
        % it would be very small
    end
end
pY = pY - 2^15;

%plot(X, pY); % <-------

%****** End of rectify *******





%****** Smooth power signal *****
% rolling average

num = 100; % amount of samples to be used for averageing.

a = uint16((1:num) .*0);
spY = pY; % smoothen power vector
for i=1:length(X)
    
    a = [a(2:num), pY(i)]; % shift in new power value and discard the oldest one
    spY(i) = mean(a); 
end

plot(X,spY, '-o'); %<-------
hold on



