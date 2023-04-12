% clc, clear all, close all

% run("soundstage2.m"); 


mY=[mY(1:4:end), mY(2:4:end), mY(3:4:end), mY(4:4:end)];
% nY=iY;
len = length(mY(:,1));
micDist=1;
Y=mY;
close all

Y = abs(Y);
subplot(4,1,1);
plot(Y(:,1));
subplot(4,1,2);
plot(Y(:,2));
subplot(4,1,3);
plot(Y(:,3));
subplot(4,1,4);
plot(Y(:,4));


sY = Y;
n=1000;
Y=[zeros(n, length(Y(1,:))); Y];

for i=n:len
    for a = 1:length(Y(1,:))
        sY(i,a) = mean(Y(i-n+1:i,a));
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

figure(3);
% openfig('soundstage.fig');
% figure(3);
% openfig('selection.fig');
prevxy = [-2,1];

 Y_sum = zeros(1,len);
 Xs = []
 Ys = []
% delay1 = [];
% delay2 = [];
 index1 = [];
% index2 = [];
% index3 = [];
problems = 0;

step = 1000;

for j=1:step:len-step
    r = zeros(1,4);
    d = zeros(1,4);
    [A,I] = max(sY(j,:));
    valid = true;
    for i=1:4
        if i~=I
            [A, B]=xcorr(mY(j:1000+j,I), mY(j:1000+j,i),300);
            [r(i), IND] = max(A(1:300));
            d(i) = B(IND);
        end
    end
    
        [maxr,index] = max(r);
        r(index) = 0;
        [secondMaxr, secondIndex] = max(r);
% 
%         delay1 = [delay1,d(index)];
%         delay2 = [delay2,d(secondIndex)];
         index1 = [index1,I];
%         index2 = [index2,index];
%         index3 = [index3,secondIndex];

        deltaD1 = 343*d(index) ./48000;
        deltaD2 = 343*d(secondIndex) ./48000;


        syms x y
        %prevxy(1) = I-2.5;
        %prevxy(2) = 2;
        [solvex,solvey] = vpasolve([sqrt((x-(I-2.5))^2+y^2)-sqrt((x-index+2.5)^2+y^2) == deltaD1, sqrt((x-I+2.5)^2+y^2)-sqrt((x-secondIndex+2.5)^2+y^2) == deltaD2],[x,y],[prevxy(1),prevxy(2)]);
        if(solvex)
            prevxy(1) = double(solvex);
            prevxy(2) = double(solvey);
            Xs =  [Xs, double(solvex)];
            Ys =  [Ys, double(solvey)];
        
        else
            problems = problems +1;
        end

% %     if solvey == 0
% %         indexd1 = I
% %         indexd2 = index
% %         indexd3 = secondIndex
% %     end
%     hold on;
%     plot(solvex,abs(solvey),'o','color',[0,j/(len-10000),0]);
% 
%     ang = zeros(1,4);
%     for i=1:4
%         if(solvex)
%         ang(i) = atan(abs(solvey)/abs(solvex-i+2.5));    
%         end
%     end

%     subplot(3,1,1);
%     hold on;
%     plot(j,I,'x');
%     subplot(3,1,2);
%     hold on;
%     plot(j,index,'x');
%     subplot(3,1,3);
%     hold on;
%     plot(j,secondIndex,'x');

%     subplot(2,1,1);
%     plot(j,d(index),'o');
%     hold on;
%     subplot(2,1,2);
%     plot(j,d(secondIndex),'o');
%     
%    hold on;

end
%%
[stereoY, Fs] = audioread("test_dialog_mono.wav");
Y = stereoY(:,1);

gain = 0;

for j=step:step:len-step
    
    i = floor(j/step);
    if i < floor((len-step)/step) - problems
   %attenuation = 1/((index1(i) -2.5 -Xs(i))^2 + Ys(i)^2);
   attenuation = ((index1(i) -2.5 -Xs(i))^2 + Ys(i)^2);
   if attenuation > gain
       gain = gain + 0.1
    else
        gain = gain -0.1
   end
   


%    if abs(attenuation)>2
%        c = index1(i)
%    end

    end  
    Y_sum(j:j+step) = mY(j:j+step, index1(i))*gain;
    %Y_sum(j) = mY(j - (delay - targetDelay), index1(i)) + mY
    %Y_sum(j) = mY(j - delay2(i),index1(i)) + mY(j - (delay2(i)-delay1(i)),index2(i)) + mY(j,index3(i));
end

subplot(2,1,1);
plot(Y);
hold on;
subplot(2,1,2);
plot(Y_sum);
hold on;




%%
figure(4);
SampleLength=5000;
Overlap = 0.5*SampleLength;
g = bartlett(SampleLength);
F = logspace(0, log10(5000), 256);
[s,f,t] = spectrogram(Y,g,Overlap,F,Fs);
waterplot(s,f,t, 'cyan');
hold on
[s,f,t] = spectrogram(Y_sum,g,Overlap,F,Fs);
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

