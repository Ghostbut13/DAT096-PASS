clc, clear all, close all

run("soundstage2.m"); 
%%
close all


n=1000;
SRY = zeros(n,4); % shift register for audio value
SRI = ones(n,3); % shift register for Indexing loudest microphones
maxLag = 800;
CrossCorr = zeros(maxLag,2);
powY = zeros(len,4);


MicList = zeros(len,3); % for debugg
correl = zeros(len,1);
for i=2:len
    % shift register
    for m = 1:4
        SRY(mod(i-1,n)+1,m) = mY(i,m);
    end
    % calculate mean of abs, analog with RMS
    for m = 1:4
        powY(i,m) = powY(i-1,m) + abs(mY(i,m)) - abs(SRY(mod(i,n)+1,m));
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
    SRI(mod(i,n)+1, 1) = Index1; %save the indexes in shift register
    SRI(mod(i,n)+1, 2) = Index2;
    SRI(mod(i,n)+1, 3) = Index3;
    
    MicList(i,1) = Index1; % for debugg only
    MicList(i,2) = Index2; %
    MicList(i,3) = Index3; %    
    
    %Crosscorrelation
    for L=-maxLag:-1
        
        
        OldIndex1= SRI(mod(i+1,n)+1, 1);
        OldIndex2= SRI(mod(i+1,n)+1, 2);
        OldIndex3= SRI(mod(i+1,n)+1, 3);
        newVal = SRY(mod(i+L,n)+1,Index1)*SRY(mod(i,n)+1,Index2);
        oldVal = SRY(mod(i+L,n)+1,OldIndex1)*SRY(mod(i,n)+1,OldIndex2);
        CrossCorr(-L,1) = CrossCorr(-L,1) + newVal - oldVal;
        newVal = SRY(mod(i+L,n)+1,Index1)*SRY(mod(i,n)+1,Index3);
        oldVal = SRY(mod(i+L,n)+1,OldIndex1)*SRY(mod(i,n)+1,OldIndex3);
        CrossCorr(-L,2) = CrossCorr(-L,2) + newVal - oldVal;
    end
    if i == 10000
        plot(CrossCorr(:,1));
        hold on
        %plot(CrossCorr(:,2));
        A = xcorr(SRY(:,2), SRY(:,1), maxLag);
        plot(A);
    end
end
%plot(powY(:,1));
%plot(correl);
%%
subplot(3,1,1);
plot(MicList(:,1));
subplot(3,1,2);
plot(MicList(:,2));
subplot(3,1,3);
plot(MicList(:,3));

%%
close all  
L = 10000;
n = 1000
A = xcorr(mY(L:L+n,1),mY(L:L+n,2))

plot(A);

for i=1:n*2
    sum = 0;
    for a = 1:n
        if i+a >n & i+a < 2*n
            sum = sum + mY(L+a,2)*mY(L+a-n+i,1);
        end
    end
    A(i) = sum;
end
hold on;
plot(A);





%%%%%%% FPGA version
% for i=2:len
%     for m=1:4
%         powY(i,m) = powY(i-1,m) + abs(mY(i,m)) - abs(SR(1,m));
%     end
%     
%     for m=1:4
%         SR(:,m) = [SR(2:n,m); mY(i,m)];
%     end
% end
