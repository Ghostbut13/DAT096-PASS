clc, clear all, close all
%Programmable filters inside ADC. Filters can only be set before powering
%ADC-channel.


n = 2; % 1 biquad = 2nd order filter
Fs =  48000;

% biqaud 1
Fc = 200;
[numerator1,denominator1] = butter(n,Fc/(Fs/2), 'high');

%quantize filter coefficients to 32 bits (1.31 format)
numerator1 = round(numerator1*2^32)/2^32;
denominator1 = round(denominator1*2^32)/2^32;
%dec2hex(numerator1.*2^31, 32/4)
%dec2hex(denominator1(2:3)*2^31, 32/4)
G1 = tf(numerator1, denominator1, 1/Fs);
bode(G1, {20*pi*2, 20000*pi*2});
hold on;
% biqaud 2
Fc = 200;
[numerator2,denominator2] = butter(n,Fc/(Fs/2), 'high');
%quantize filter coefficients to 32 bits (1.31 format)
numerator2 = round(numerator2*2^32)/2^32;
denominator2 = round(denominator2*2^32)/2^32;
G2 = tf(numerator2, denominator2, 1/Fs);
bode(G2, {20*pi*2, 20000*pi*2});
hold on;
% biqaud 3
Fc = 7000;
[numerator3,denominator3] = butter(n,Fc/(Fs/2), 'low');
%quantize filter coefficients to 32 bits (1.31 format)
numerator3 = round(numerator3*2^32)/2^32;
denominator3 = round(denominator3*2^32)/2^32;
G3 = tf(numerator3, denominator3, 1/Fs);
bode(G3, {20*pi*2, 20000*pi*2});
grid on;


%%%%%%%%%%Test%%%%%%%
figure(2)

%t=1;
%F = 200;
%mY = linspace(1, F*t,t*Fs);
%mY = mod(mY,1);
%mY = round(mY);


[stereoY, Fs] = audioread("test_dialog_mono.wav");
mY = stereoY(:,1);

[y,t] = lsim(G1, mY);
[y,t] = lsim(G2, y);
[y,t] = lsim(G3, y);

plot(t, mY)
hold on;
plot(t,y);

% %%
% clc
% digits(64)
% te = 1-2^-31;
% %te = 1;
% %te = -0.9
% te = round(te*2^32)/2^32;
% %ToHex(te)
% dec2hex(te*2^31, 32/4)


%%

% we can't generate butter filters below certain frequencys as these will
% have coefficients above or equal to 1 and won't fit in the register of
% the ADC. We have to use filters below unity gain and compensate by
% gainstage.
clc, clear all, close all
n = 2
Fs = 48000
for i = 1:20000
    Fc = i;
    [numerator,denominator] = butter(n,Fc/(Fs/2), 'low');
    if max(abs([numerator, denominator(2:3)])) < 1
        break;
    end
end

%%
% generate VHDL from filter -v
[n,d] = filterDesigner

%%%%%%%%%%%%%%%%%%%%%%%
