% LEPP 150F, Lab Scitech
m = modbus('serialrtu','COM7','Parity','even');

%%
% 1 register holds 2 bytes data each.

% unsigned short int (2bytes) == uint16
% unsigned long int (4bytes) == uint32
% float (4bytes) == single
% unsigned char (10bytes) == uint16*5

% input register - read only
% holding register - read/write

% bit-wise / decimal / hexadecimal 주의

i1 = read(m,'inputregs',1023,5); % manufactorer
ret1 = double.empty;
for i = 1:length(i1)
    ret1(2*i-1) = rem(i1(i),256);
    ret1(2*i) = fix(i1(i)/256);
end
ret1 = char(ret1);

%%
h1 = read(m,'holdingregs',4022,1,'uint16'); % flow unit
h2 = read(m,'holdingregs',4023,1,'uint16'); % direction
h3 = read(m,'holdingregs',4029,1,'uint16'); % baud rate
h4 = read(m,'holdingregs',4025,1,'uint16'); % running
h5 = read(m,'holdingregs',4024,1,'uint16'); % full speed

% read(m,'holdingregs', 4017,1,'uint16')

% write(m,'holdingregs',4025,1,'uint16'); % run
% write(m,'holdingregs',4025,0,'uint16'); % stop

% swapbytes(typecast(uint16(500),'single'));
%%
write(m,'holdingregs',4169,double(typecast(single(str2double('300')),'uint16')),'uint16');

