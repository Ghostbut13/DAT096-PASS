%  clc, clear all, close all;
% 
% fc = 2000;
% [n,d] = butter(3, fc/(48000/2), 'high')
% 
% 
% 
% % n(n<0) = 
% % mY = (n*2^13)
% mY=-2
% a= (2-1.9075016)*2^30
% 
% a=dec2bin(round(a))
% q = 2;
% mY = dec2bin(mod(mY, 2^(q-1)) -(2^(q-1))*floor(mY./(2^(q-1))),q)
% dyY = bin2dec(mY)
% ------------------------------------



clc, close all, clear all;
fc = 1000;
[n,d] = butter(3, fc/(48000/2), 'high')
%10000000000001010100110010001010

int = 3;
fra = 29;

n=n* (2^fra);
q=int+fra;
n = mod(n, 2^(q-1)) -(2^(q-1))*floor(n./(2^(q-1)))
dec2bin(n)

d=d* (2^fra);
q=int+fra;
d = mod(d, 2^(q-1)) -(2^(q-1))*floor(d./(2^(q-1)))
dec2bin(d)