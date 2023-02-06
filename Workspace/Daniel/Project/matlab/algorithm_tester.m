clc, clear all, close all

run("soundstage.m"); 
Y=mY(:,[1,4]);
close all

%[Y, Fs] = audioread("test_dialog_stereo.wav");
%sound(Y,Fs);
subplot(2,1,1);
plot(Y);

pY=abs(Y);
%hold on
%plot(pY);


num = 100; % amount of samples to be used for averageing.
avgElements = zeros(num,2);
spY = pY;

for i=2:length(pY)
    spY(i,1) = spY(i-1,1) - avgElements(1,1) + pY(i,1);
    spY(i,2) = spY(i-1,2) - avgElements(1,2) + pY(i,2);
    
    avgElements(:,1)= [avgElements(2:num,1); pY(i,1)];
    avgElements(:,2)= [avgElements(2:num,2); pY(i,2)];
    
end

subplot(2,1,2);
plot(spY);

%%
Y2=[]
pannerPhase = 0.25;
pInc = 0.00001
phase = []
for i=1:length(pY)
    if spY(i,1) > spY(i,2)
        if pannerPhase < 0.5
            pannerPhase = pannerPhase +pInc;
        end
    else
        if pannerPhase > 0
            pannerPhase = pannerPhase -pInc;
        end
    end
    phase(i)=pannerPhase;
    Y2(i) = sin(pannerPhase*pi)*Y(i,1) + cos(pannerPhase*pi)*Y(i,2);
end
figure(2)
%sound(Y2,Fs); %----
plot(Y2);
figure(3);
plot(sin(phase*pi));
hold on
plot(cos(phase*pi));

