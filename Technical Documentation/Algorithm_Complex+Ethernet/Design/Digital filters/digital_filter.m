%To generate the filter coefficients
fc = 1000;
fc_l = 7000;
[n,d] = butter(10, fc/(48000/2), 'high')

[b,a] = butter(3,fc_l/(48000/2))
-----------------------------------------------------------
%To represent them in fixed-point representation
% Highpass
int = 3;
fra = 29;

n=n* (2^fra);
q1=int+fra;
n = mod(n, 2^(q1-1)) -(2^(q1-1))*floor(n./(2^(q-1)))
n_d = dec2bin(n);

d=d* (2^fra);
q2=int+fra;
d = mod(d, 2^(q2-1)) -(2^(q2-1))*floor(d./(2^(q2-1)));
d_d = dec2bin(d);

% ---------------------------------------------------------------------------
% Lowpass

int_l = 2;
fra_l = 30;
b=b* (2^fra_l);
q_l1=int_l+fra_l;
b = mod(b, 2^(q_l1-1)) -(2^(q_l1-1))*floor(b./(2^(q_1-1)))
b_d = dec2bin(n);


a=a* (2^fra);
q_l=int_l+fra_l;
a = mod(a, 2^(q-1)) -(2^(q-1))*floor(a./(2^(q-1)))
a_d = dec2bin(d);

% __-------------------------------------------------------------------------------

% To read the audio files and normalize the values
[stereoY, Fs] = audioread("filtered.wav");
Y = stereoY(:,1);
m = max(abs(Y))
Y = Y./(2*m);

figure(1)
% subplot(1,2,1)
plot(Y,'blue');
axis([0,length(Y),-.1,0.1])
 hold on;

x=filter(n,d,Y);
z=filter(b,a,Y);
plot(z,'red')
legend('X(n)','Y(n)');
 hold off;
 
 figure(2)
% subplot(1,2,2)
plot(Y,'blue');
axis([0,length(Y),-.1,0.1])
hold on;
plot(x,'red')
legend('X(n)','Y(n)');

hold off;

