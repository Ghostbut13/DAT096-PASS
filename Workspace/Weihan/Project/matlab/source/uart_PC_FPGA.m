<<<<<<< HEAD
=======
<<<<<<<< HEAD:Workspace/Weihan/Project/matlab/source/demo.m
clc
close
clear
========
>>>>>>> 345b79df065594bae422114d7dbb8daaf9043cda
clear;
clc;
close;


%%% 



%%% write vectors to FPGA bytes by bytes
sp_list = serialportlist
<<<<<<< HEAD
sp = serialport(sp_list(1),9600)



% %%% transmit 0-255 to FPGA per 2 seconds
% %%% It will show on the LED in binary on FPGA board
% for i = 0:2^8-1
%     pause(2);
%     value = i
%     write(sp,value,'char')  
% end

tmp1   = read(sp,18,'char');
tmp   = dec2bin(tmp1,8);
tmp1  = string(tmp1)
str   = string(tmp)
data  = string(dec2hex(bin2dec(str)))

if (str == "")
    disp("failed to read data from uart_rx");
    disp("check the code")
=======
sp = serialport(sp_list(2),9600)


%%% transmit 0-255 to FPGA per 2 seconds
%%% It will show on the LED in binary on FPGA board
for i = 0:2^8-1
    pause(2);
    value = i
    write(sp,value,'char')  
>>>>>>> 345b79df065594bae422114d7dbb8daaf9043cda
end













<<<<<<< HEAD
=======


>>>>>>>> 345b79df065594bae422114d7dbb8daaf9043cda:Workspace/Weihan/Project/matlab/source/uart_PC_FPGA.m

disp("bro, NOW we want know which mode you want configurate")
disp("1.which ")
>>>>>>> 345b79df065594bae422114d7dbb8daaf9043cda
