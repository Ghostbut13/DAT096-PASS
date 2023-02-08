clear;
clc;
close;


%%% 



%%% write vectors to FPGA bytes by bytes
sp_list = serialportlist
sp = serialport(sp_list(2),9600)


%%% transmit 0-255 to FPGA per 2 seconds
%%% It will show on the LED in binary on FPGA board
for i = 0:2^8-1
    pause(2);
    value = i
    write(sp,value,'char')  
end
















