run("soundstage2.m")

%normalize
a = max(max(mY));   
mY = mY/a;
noiseStrength = 0.0001;
%mY = mY+noiseStrength*randn(length(mY(:,1)),length(mY(1,:)));

%% pure summing
X = mY(:,1) + mY(:,2) +mY(:,3) + mY(:,4);

close all
% plot(linspace(-1.5, 1.5, len),X.^2)
plot(linspace(3, 1, len),X.^2)
xlabel("position x (m)")
ylabel("power")
figure
snr(X,Fs)


Y = fft(X);
P2 = abs(Y/len);
P1 = P2(1:len/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(len/2))/len;
P1 = 20*log(P1);
figure
semilogx(f,P1) 
xlabel("f (Hz)")
ylabel("|P1(f)| (dB)")


%% delay compensation
close all
load("choords_simY");
x = 5*(choords(1,:)-128)/64;
y = 5*choords(2,:)/64;
% plot(x);
% hold on
% plot(y);

figure
hold on
len = length(mY(:,1));
for i=1:len-20
    %mic 1
    a = floor(i/20)+1;
    d = sqrt((x(a)+1.5)^2 + y(a)^2); % mic 1
    d = d*140;
    if d < i
        X(i) = mY(i-round(d),1);
    end
    d = sqrt((x(a)+0.5)^2 + y(a)^2); % mic 2
    d = d*140;
    if d < i
        X(i) = X(i) + mY(i-round(d),2);
    end
    
    d = sqrt((x(a)-0.5)^2 + y(a)^2); % mic 3
    d = d*140;
    if d < i
        X(i) = X(i) + mY(i-round(d),3);
    end
    
    d = sqrt((x(a)-1.5)^2 + y(a)^2); % mic 4
    d = d*140;
    if d < i
        X(i) = X(i) + mY(i-round(d),4);
    end
end


plot(linspace(-1.5, 1.5, len),X.^2)
% plot(linspace(3, 1, len),X.^2)
xlabel("position (m)")
ylabel("power")
figure
snr(X,Fs)
Y = fft(X);
P2 = abs(Y/len);
P1 = P2(1:len/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(len/2))/len;
P1 = 20*log(P1);
figure
semilogx(f,P1) 
xlabel("f (Hz)")
ylabel("|P1(f)| (dB)")

%% attenuation compensation
close all
load("choords_simY");
% load("choords_simX");
x = 5*(choords(1,:)-128)/64;
% y = 5*choords(2,:)/64;
y = choords(2,:);
g = y*bin2dec("1000");
g(g<bin2dec("000110010")) = 2^6;
g = g./(2^6);

len = length(mY(:,1));
X = mY(:,1) + mY(:,2) +mY(:,3) + mY(:,4);
for i=1:len-20
    a = floor(i/20)+1;
    X(i) = X(i)*(g(a)^1);
end

% plot(linspace(-1.5, 1.5, len),X.^2)
plot(linspace(3, 1, len),X.^2)
% axis([-1.5, 1.5, 0, 150])
%axis([1, 3, 0, 8])
xlabel("position y (m)")
ylabel("power")
figure
snr(X,Fs)

Y = fft(X);
P2 = abs(Y/len);
P1 = P2(1:len/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(len/2))/len;
P1 = 20*log(P1);
figure
semilogx(f,P1) 
xlabel("f (Hz)")
ylabel("|P1(f)| (dB)")

%% simple max
run("algorithm_simple_max.m");
close all
X = out;
% plot(linspace(-1.5, 1.5, len),X.^2)
plot(linspace(3, 1, len),X.^2)
xlabel("position y (m)")
ylabel("power")
figure
snr(X,Fs)

Y = fft(X);
P2 = abs(Y/len);
P1 = P2(1:len/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(len/2))/len;
P1 = 20*log(P1);
figure
semilogx(f,P1) 
xlabel("f (Hz)")
ylabel("|P1(f)| (dB)")

