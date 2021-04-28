s = serialport('COM7',9600);
s.DataBits = 8;
s.StopBits = 1;
s.Parity = 'even';

writeline(s,[char(00) char(00) char(00) char(00) ... 
    char(01) char(04) char(10) char(240) ...
     ...
    char(00) char(00) char(00) char(00)]); %#ok<*CHARTEN>





%%
% body integer로 변환 / 이후 정해진 값 (0x8005)로 나눠서 나머지
% 나머지 처리 시 2^16 (65536) 보다 크면 xor하여 crc 측정
% 이후 byte order 뒤집기
% function crc = CRC_calculate(body)
%     
% end

