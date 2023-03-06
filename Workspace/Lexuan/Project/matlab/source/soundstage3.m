%%
clc, clear all, close all
map = "1.5mMic2";
[Y, Fs] = audioread(map + "/dat096 1-Audio.wav");
len = length(Y(:,1));
mY = zeros(len,4);
mY(:,1) = Y(:,1);
[Y, Fs] = audioread(map + "/dat096 2-Audio.wav");
mY(:,2) = Y(:,1);
[Y, Fs] = audioread(map + "/dat096 3-Audio.wav");
mY(:,3) = Y(:,1);
[Y, Fs] = audioread(map + "/dat096 4-Audio.wav");
mY(:,4) = Y(:,1);
micDist = 1;