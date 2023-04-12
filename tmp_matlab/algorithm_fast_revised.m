% clc, clear all, close all

% run("soundstage2.m"); 
%%%

mY=[mY(1:4:end), mY(2:4:end), mY(3:4:end), mY(4:4:end)];
% nY=iY;
len = length(mY(:,1));
micDist=1;
close all


n=10000;
SR = zeros(n,4); % shift register for audio value
SRI = ones(n,3); % shift register for Indexing loudest microphones
maxLag = floor(2*micDist/343*48000);
CrossCorr = zeros(maxLag,2);
powY = zeros(len,4);

stage_depth = 3;
%len=1100000

figure(1);
%openfig('soundstage.fig');

Y_sum = zeros(len,1);
gain = 0;


%%%%%%% FPGA version
for i=2:len
    for m=1:4
        powY(i,m) = powY(i-1,m) + abs(mY(i,m)) - abs(SR(1,m));
    end
    
    for m=1:4
        SR(:,m) = [SR(2:n,m); mY(i,m)];
    end

    % tier microphones in list of the 3 loudest
    Index1 = 1;
    Index2 = 1;
    Index3 = 1;
    maxVal1 = 0;
    maxVal2 = 0;
    maxVal3 = 0;
    for m = 1:4
        if powY(i,m) > maxVal1
            maxVal3 = maxVal2;
            maxVal2 = maxVal1;
            maxVal1 = powY(i,m);
            Index3 = Index2;
            Index2 = Index1;
            Index1 = m;
           
        elseif powY(i,m) > maxVal2
            maxVal3 = maxVal2;
            maxVal2 = powY(i,m);
            Index3 = Index2;
            Index2 = m;
           
        elseif powY(i,m) > maxVal3
            maxVal3 = powY(i,m);
            Index3 = m;
        end
    end

    for lag = 1 : maxLag
        newValue = SR(n-lag,Index1)*SR(n,Index2);
        oldValue = SR(maxLag+1-lag,Index1)*SR(maxLag+1,Index2);
        CrossCorr(lag,1) = CrossCorr(lag,1) + newValue - oldValue;

        newValue = SR(n-lag,Index1)*SR(n,Index3);
        oldValue = SR(maxLag-lag+1,Index1)*SR(maxLag+1,Index3);
        CrossCorr(lag,2) = CrossCorr(lag,2) + newValue - oldValue;
        
    end

%      if i == 10000
%         plot(CrossCorr(:,1));
%         hold on
%         plot(CrossCorr(:,2));
% %         A = xcorr(SR(:,2), SR(:,1), maxLag);
% %         plot(A);
%      end


     [maxxcorr1,delay1] = max(CrossCorr(:,1));
     [maxxcorr2,delay2] = max(CrossCorr(delay1:end,2));


     delay2 = 343*(delay2+delay1)/48000;
     delay1 = 343*delay1/48000;

     A = Index2 - Index1;
     B = Index3 - Index1;

     x = -(B^2/delay2 - delay2- A^2/delay1 + delay1)/(2*(A/delay1 - B/delay2));
    
     D = ((-2*A-2*B)*x+ A^2 + B^2 - delay1^2 - delay2^2)/(2*(delay1 + delay2));

     y = sqrt(D^2 - x^2);

     x = Index1 -2.5 + x;

     if mod(i,100) == 0 
     hold on;
     plot(x,y,'o','color',[0,i/len,0]); 
     end

     if D < 5
     attenuation = D^2;

      if attenuation > gain
       gain = gain + 0.0001;
    else
        gain = gain -0.0001;
      end

     end
     Y_sum(i) = mY(i,Index1) * gain;



end

 figure(3);
subplot(2,1,1);
% plot(Y);
hold on;
subplot(2,1,2);
plot(Y_sum);
hold on;


