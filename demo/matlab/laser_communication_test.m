% 1. port 구성 
% 2. port가 켜는 순서대로 배정되는가
% 3. 안 켜진 것들은 port가 배정이 안되는건가
% 4. 개별 지시 (*IDN(n)?)
% 5. power값 차이 확인


slCharacterEncoding('utf-8');
s = serialport('COM4',9600);
s.DataBits = 8;
s.StopBits = 1;
s.Parity = "none";
configureTerminator(s, "CR");

%%
writeline(s,'*IDN?');
pause(1);
if s.NumBytesAvailable ~= 0
    disp(read(s,s.NumBytesAvailable,'char'));
end

%%
writeline(s,'SOUR:POW:LIM:HIGH?');
pause(1);
if s.NumBytesAvailable ~= 0
    out1 = read(s,s.NumBytesAvailable,'char');
    disp(sscanf(out1,'%fOK'));
end


writeline(s,'SOUR:POW:LIM:LOW?');
pause(1);
if s.NumBytesAvailable ~= 0
    out2 = read(s,s.NumBytesAvailable,'char');
    disp(sscanf(out2,'%fOK'));
end

%%
disp('End.');
clear;
