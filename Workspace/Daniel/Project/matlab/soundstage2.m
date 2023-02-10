clc, clear all, close all
[Y, Fs] = audioread("test_dialog_superStereo.wav");

micDist = 1; % distance between microphones (meters).

micCordX = micDist.*[-1.5, -0.5, 0.5, 1.5];
micCordY = [ 0,    0,   0,   0];
plot(micCordX, micCordY, 'o');
speakerX = ones(length(Y(:,1)), 2);
speakerY = ones(length(Y(:,1)), 2);
hold on

len= length(speakerX(:,1));
for i=1:len
    speakerX(i,1) = -2 + 4.*(i/len);
    speakerY(i,1) = 1- 0.1*sin((i/len));
    speakerX(i,2) = -0.6;
    speakerY(i,2) = 1.2;
    %Y(i,1) = 0.1*sin(440*i/Fs);
end
plot(speakerX(:,1), speakerY(:,1), 'X');


mY = zeros(length(Y(:,1)),4);

minAttenuation =0;
for b=1:len
    for i=1:4 % for each microphone
        for a=1:length(Y(1,:)) % for each speaker
            distance = (speakerX(b,a)-micCordX(i))^2;
            distance = distance + (speakerY(b,a)-micCordY(i))^2;
            distance = sqrt(distance);
            delayFs = Fs*distance/343;
            attenuation = distance^-2;
            if(b+delayFs < len)
                mY(b+floor(delayFs),i) = mY(b+floor(delayFs),i)+ (1-mod(delayFs,1))*attenuation*Y(b,a);
                mY(b+ceil(delayFs),i) = mY(b+ceil(delayFs),i)+ (mod(delayFs,1))*attenuation*Y(b,a);
            end
            if(attenuation > minAttenuation)
                minAttenuation = attenuation; 
            end
        end
    end
end
mY=mY./minAttenuation; % auto gain
figure(2)
subplot(2,1,1)
plot(Y);
subplot(2,1,2);
plot(mY(:, [2,3]))
%sound(mY(:, [1,4]), Fs)

