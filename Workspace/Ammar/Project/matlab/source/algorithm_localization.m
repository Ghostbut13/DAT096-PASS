clc, clear all, close all

run("soundstage2.m"); 
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
delay1 = [];
delay2 = [];
index1 = [];
index2 = [];
index3 = [];

for j=1:10000:len-10000
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

        delay1 = [delay1,d(index)];
        delay2 = [delay2,d(secondIndex)];
        index1 = [index1,I];
        index2 = [index2,index];
        index3 = [index3,secondIndex];

%         deltaD1 = 343*d(index) ./48000;
%         deltaD2 = 343*d(secondIndex) ./48000;
% 
% 
%         syms x y
%         [solvex,solvey] = vpasolve([sqrt((x-(I-2.5))^2+y^2)-sqrt((x-index+2.5)^2+y^2) == deltaD1, sqrt((x-I+2.5)^2+y^2)-sqrt((x-secondIndex+2.5)^2+y^2) == deltaD2],[x,y],[prevxy(1),prevxy(2)]);
%         if(solvex)
%             prevxy(1) = solvex;
%             prevxy(2) = solvey;
%         end
% 
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

[stereoY, Fs] = audioread("test_dialog_mono.wav");
Y = stereoY(:,1);

for j=10000:len-10000

    i = floor(j/10000);
    Y_sum(j) = mY(j - delay2(i),index1(i)) + mY(j - (delay2(i)-delay1(i)),index2(i)) + mY(j,index3(i));
end

subplot(2,1,1);
plot(Y);
hold on;
subplot(2,1,2);
plot(Y_sum);
hold on;

%sound(out, Fs);

