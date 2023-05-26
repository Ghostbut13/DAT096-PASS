clc, close all
run("soundstageSim.m"); close all
%load("movingactor4-1_reading_70dB_lecroom");
%load("movingactorYaxis4_reading_70dB_lecroom")

load("LUTv");
maxD = 5;
res = 64;


% HIGHPASS Filter
fY = zeros(length(mY(:,1)),4);
fc = 1000;
[n,d] = butter(3, fc/(48000/2), 'high');
sys = tf(n,d, 1/48000);
fY(:,1) = lsim(sys, mY(:,1), []);
fY(:,2) = lsim(sys, mY(:,2), []);
fY(:,3) = lsim(sys, mY(:,3), []);
fY(:,4) = lsim(sys, mY(:,4), []);
mY = fY;


micDistance = 1; % meters
len = length(mY(:,1));
% force shorter simulation {
len = 48000;
% len = 66671;
% }
d = ceil(48000/343);
signalAcc = zeros(10000,4);

crossAcc = zeros(2*d,3);
crossAcc2 = zeros(2*2*d,2);
crossAcc3 = zeros(3*2*d,1);
choords= zeros(2,ceil(len/20));
for i=2:len
    %BRAM
    signalAcc(:,1) = [mY(i,1); signalAcc(1:end-1,1)]; 
    signalAcc(:,2) = [mY(i,2); signalAcc(1:end-1,2)]; 
    signalAcc(:,3) = [mY(i,3); signalAcc(1:end-1,3)]; 
    signalAcc(:,4) = [mY(i,4); signalAcc(1:end-1,4)]; 

    %crosscorrelation
    crossAcc(:,1) = mycrossCorre(crossAcc(:,1), signalAcc(:,1),signalAcc(:,2),floor(length(crossAcc(:,1))/2)); % crosscorr mic 1 and 2
    crossAcc(:,2) = mycrossCorre(crossAcc(:,2), signalAcc(:,2),signalAcc(:,3),floor(length(crossAcc(:,2))/2)); % mic 2 and 3
    crossAcc(:,3) = mycrossCorre(crossAcc(:,3), signalAcc(:,3),signalAcc(:,4),floor(length(crossAcc(:,3))/2)); % mic 3 and 4
   
    
   if mod(i,20) == 1 % only run every 20 samples
    
    % pictureFrame 1
    Array1 = zeros(res*2+2, res+1);
    for lag=-d:d-1
        val = crossAcc(lag+d+1,1);
        for a  = 1:length(LUTv(:,1,1))
            x=LUTv(a, 1, lag+d+1);
            y=LUTv(a, 2, lag+d+1);
            if val > Array1(x+res+1,y+1)
                Array1(x+res+1,y+1) = val;
            end
        end
    end
    
    % pictureFrame 2
    Array2 = zeros(res*2+2, res+1);
    for lag=-d:d-1
        val = crossAcc(lag+d+1,2);
        for a  = 1:length(LUTv(:,1,1))
            x=LUTv(a, 1, lag+d+1);
            y=LUTv(a, 2, lag+d+1);
            if val > Array2(x+res+1,y+1)
                Array2(x+res+1,y+1) = val;
            end
        end
    end
    
    % pictureFrame 3
    Array3 = zeros(res*2+2, res+1);
    for lag=-d:d-1
        val = crossAcc(lag+d+1,3);
        for a  = 1:length(LUTv(:,1,1))
            x=LUTv(a, 1, lag+d+1);
            y=LUTv(a, 2, lag+d+1);
            if val > Array3(x+res+1,y+1)
                Array3(x+res+1,y+1) = val;
            end
        end
    end
    
    % sum the pictureFrames in to one image
    SumArray = zeros(res*4+2, res+1);
    xZero = round(res+1 -res/maxD);
    SumArray(xZero:xZero+2*res+1, :) = SumArray(xZero:xZero+2*res+1, :) + Array1;
    xZero = res+1;
    SumArray(xZero:xZero+2*res+1, :) = SumArray(xZero:xZero+2*res+1, :) + Array2;
    xZero = round(res+1 +res/maxD);
    SumArray(xZero:xZero+2*res+1, :) = SumArray(xZero:xZero+2*res+1, :) + Array3;
    
    % take the brightest pixel and retrieve the coordinates
    [A,X] = max(SumArray');
    [~,Y] = max(A);
    X = X(Y);
    choords(1,floor(i/20)+1) = X;
    choords(2,floor(i/20)+1) = Y;

   end
end

% save coordinates
save("tmpchoords", "choords");

%%
close all
load("tmpchoords.mat")
A= choords(1,:);
B = choords(2,:);
choords = [B;A];

% optional filtering of the choordinates {
%     fChoords = choords;
%     fc = 1;
%     [n,d] = butter(3, fc/(48000/2), 'low');
%     sys = tf(n,d, 1/48000);
%     fChoords(1,:) = lsim(sys, choords(1,:), []);
%     fChoords(2,:) = lsim(sys, choords(2,:), []);
% }

% plot output coordinates {
    figure
    plot(1:20:len, maxD*(choords(1,:)-2*res)/res) % meters
    % plot(1:20:len, choords(1,:)-64); % pixels
    hold on
    plot(1:20:len, maxD*choords(2,:)/res) % meters
    % plot(1:20:len, choords(2,:)) % pixels
    grid on
    xlabel("time (sample)")
    ylabel("position (m)")
    legend("X","Y")
    axis([0, len,-3,3])
    title("Calculated coordinates")
% } end of plot

% plot y coordinate {
    figure
    plot(0,0);
    plot(1:20:len, 5*choords(2,:)/64)
    xlabel("time (sample)")
    ylabel("position y (m)")
    grid on
    title("Calculated Y position")
% } end of plot

% plot sumed image {
    figure
    hold on
    sf=surf(SumArray');
    XD = get(sf, 'XData');
    YD = get(sf, 'YData');
    ZD = get(sf, 'ZData');
    close
    figure
    surf(5*XD/res -10, 5*YD/res -5/res, ZD)
    axis([-4, 4,0,5,0, max(max(SumArray))])
    xlabel("position x (m)")
    ylabel("position y (m)")
    zlabel("correlation")
    title("Summed correlation pictures")
% } end of plot


%create output sound
Y=zeros(len,1);
for i=1:len-20
    Y(i)=mY(i,1) + mY(i,2) +mY(i,3) + mY(i,4);
    Y(i) = Y(i)*maxD*choords(2,floor(i/20)+1)/res;
end

% plot unfiltered output sound compared to input {
    figure
    hold on
    plot(Y)
    plot(mY)
    grid on
    title("Unfiltered output compared to microphone inputs")
    xlabel("time (sample)")
    legend("Complex algo output", "mic 1", "mic 2", "mic 3", "mic 4")
% } end of plot

% LOW PASS filter
fc = 7000;
[n,d] = butter(8, fc/(48000/2), 'low');
sys = tf(n,d, 1/48000);
fY = lsim(sys, Y, []);
%normalize output
normY=fY/max(abs(fY));

% plot final output sound {
    figure
    plot(normY)
    title("Final output")
    xlabel("time (sample)")
% } end of plot

% play sound
% sound(normY, Fs)

function newAcc = mycrossCorre(acc, X, Y, maxlag)
    for l=1-maxlag:maxlag
        %new = X(lag)*Y(1); % simplification for non negative lag values
        new = X(maxlag+l).*Y(maxlag); % to accept negative lag values we need to delay the signal with the amount of max negative lag
    
        old = X(end-maxlag + l).*Y(end-maxlag);
    
        acc(l+maxlag) = acc(l+maxlag) + new - old;
    end
    newAcc = acc;
end
