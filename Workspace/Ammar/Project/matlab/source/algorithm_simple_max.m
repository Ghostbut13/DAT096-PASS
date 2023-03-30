clc, clear all, close all

%run("soundstage2.m"); 
run("soundExporter.m");
iY=mY;
close all

iY = abs(iY);
subplot(4,1,1);
plot(iY(:,1));
subplot(4,1,2);
plot(iY(:,2));
subplot(4,1,3);
plot(iY(:,3));
subplot(4,1,4);
plot(iY(:,4));

sY = iY;
n=100;
iY=[zeros(n, length(iY(1,:))); iY];

for i=n:len
    for a = 1:length(iY(1,:))
        sY(i,a) = mean(iY(i-n+1:i,a));
    end
end

figure(2)
subplot(4,1,1);
plot(sY(:,1));
subplot(4,1,2);
plot(sY(:,2));
subplot(4,1,3);
plot(sY(:,3));
subplot(4,1,4);
plot(sY(:,4));


phase = 2.5;
phaseA = zeros(1, len);
delta = 0.0001
out = zeros(1, len);

for i=1:len
    [A,I] = max(sY(i,:));
    if phase > I
        phase = phase - delta; 
    else
        phase = phase + delta;
    end
    
    if phase < 2
        out(i) = (phase-1)*mY(i,2) + (2-phase)*mY(i,1);
    elseif phase < 3
        out(i) = (phase-2)*mY(i,3) + (3-phase)*mY(i,2);
    else
        out(i) = (phase-3)*mY(i,4) + (4-phase)*mY(i,3);
    end
    phaseA(i) = phase;
end
%%
figgy = figure(3);
plot(phaseA, 'blue');
grid on;
tstart= 625000;
tstop = 650000;
margint=10000;
marginY = 0.1;
xlabel("time [Sample]")
ylabel("Indexer");
B = annotation('rectangle', 'LineStyle','--');
B.Parent = figgy.CurrentAxes;
B.Position = [tstart-margint, phaseA(tstart)-marginY, tstop-tstart+2*margint, phaseA(tstop) - phaseA(tstart)+2*marginY];
a2 = axes();
a2.Position = [0.2 0.65 0.2 0.2]; % xlocation, ylocation, xsize, ysize
plot(a2,tstart:tstop,phaseA(tstart:tstop), 'blue');
axis([tstart,tstop,phaseA(tstart)-marginY,phaseA(tstop)+marginY])
grid on;





figure(4)
plot(out);

%%
figure(5);
SampleLength=5000;
Overlap = 0.2*SampleLength;
g = bartlett(SampleLength);
F = logspace(0, log10(5000), 256);
[s,f,t] = spectrogram(Y,g,Overlap,F,Fs);
waterplot(s,f,t, 'cyan');
hold on
[s,f,t] = spectrogram(out,g,Overlap,F,Fs);
waterplot(s,f,t+((t(2)-t(1))/2), 'r');
axis([0,5000,0,26,0,2000]);


function waterplot(s,f,t, color)
% Waterfall plot of spectrogram
    P = waterfall(f,t,abs(s)'.^2);
    P.EdgeColor = color;
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
end
%sound(out, Fs);

