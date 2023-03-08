clc, close all, clear all
run("soundstage2.m"); 
%%
close all;
%global n
n=1000;
%global SR
SR = zeros(len+n, 4);
powAcc = zeros(4,1);

%global t
for t=2:len %for the length of the audio file.
    
    setSR(mY(t,1), 0,1);
    setSR(mY(t,2), 0,2);
    setSR(mY(t,3), 0,3);
    setSR(mY(t,4), 0,4);
    
    powAcc(1) = powerEstimation(getSR(0,1), getSR(1,1), powAcc(1));
    powAcc(2) = powerEstimation(getSR(0,2), getSR(1,2), powAcc(2));
    powAcc(3) = powerEstimation(getSR(0,3), getSR(1,3), powAcc(3));
    powAcc(4) = powerEstimation(getSR(0,4), getSR(1,4), powAcc(4));
    
    if mod(t,1000) == 0
        hold on;
        plot(t, myMax(powAcc), 'x');
    end
    
end


function out = getSR(i,m)
    global SR
    global t
    global n
    %out = SR(mod(i+t,n)+1,m);
    out = SR(t-(i*n)+n,m);
end

function setSR(val,i,m)
    global SR
    global t
    global n
    %SR(mod(i+t,n)+1,m) = val;
    SR(t-(i*n)+n,m) = val;
end

function out = powerEstimation(newSample, oldSample, acc)
    out= acc + abs(newSample) - abs(oldSample);
end

function indOut = myMax(samples)
    maxval = 0;
    maxind = 0;
    for i=1:length(samples)
        if samples(i) > maxval
            maxval = samples(i);
            maxind = i;
        end
    end
    indOut = maxind;
end

function out = crossCorr(newSample1,newSample2,oldSample1,oldSample2,acc)
    out = acc + newSample1*newSample2 - oldSample1*oldSample2;
end

