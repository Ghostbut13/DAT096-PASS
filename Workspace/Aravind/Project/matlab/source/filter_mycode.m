clc, clear all, close all
[stereoY, Fs] = audioread("test_dialog_mono.wav");
Y = stereoY(:,1);
m = max(abs(Y));
m = max(m);
Y = Y./(2*m);
%len_Y = size(Y)

figure(1)
title("Original sound from actors")
plot(Y);
xlabel("Time [sample]");
ylabel("Amplitude");

z1 = 0;
z2=0;
z3=0;

a1=0;
a2=0;
a3=0;

fc = 2000;
[n,d] = butter(3, fc/(48000/2), 'high')

fir_h = fir1(3, fc/(48000/2), 'high')

out = zeros(size(Y));

for i = 1:length(Y)
   % out(i) = n(1)*Y(i) + n(2)*z1 * n(2)*z2 - n(3)*z3 - d(2)*a1 -d(3)*a2 - d(4)*a3; 
     out(i) = n(1)*Y(i) + n(2)*z1 + n(3)*z2 + n(4)*z3 - d(2)*a1 - d(3)*a2 - d(4)*a3; 
    z3= z2;
    z2 = z1;
    z1 = Y(i);
    a3=a2;
    a2=a1;
    a1=out(i);
end

 %output = filtfilt(n,d,Y);
 output = filter(n,d,Y);
 % outputfir = filtfilt(fir_h, Y);


figure(2)
subplot(2,1,1);
plot(output);
subplot(2,1,2);
plot(out);
% 
% figure(3)
% plot(outputfir)

figure(3)
plot(output-out)