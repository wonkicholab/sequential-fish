clear;
slCharacterEncoding('US-ASCII');

s = serialport('COM3',9600);
s.DataBits = 7;
s.StopBits = 1;
s.Parity = 'odd';
configureTerminator(s, "CR");

%% Parameters
% Nhybridization ~ # of hybridization buffers 
% min : 14 (if you want to do experiment with under 14 buffers, need to change the code) 
% max : 18 (if you want to do experiment with over 16 buffers, need to buy more MVP devices)
N_hybridization = 16;

% Nterm0 ~ Term between fill up the wash buffer into the tube set. / sec
Nterm0 = 10;

% Nterm1 ~ Term for hybridization buffers / sec
Nterm1 = 5;

% Nterm2 ~ Term for Other (imaging, washing, bleaching) buffers / sec
Nterm2 = 10;
%% Auto-addressing
writeline(s, '1a');

%% Initialize the devices
writeline(s, 'aLXR')
writeline(s, 'bLXR')
writeline(s, 'cLXR')

msgbox('Press initialize button of the devices!');
pause(30);

%% Actual valve control
message = '1 : 1 / 2 : 1 / 3 : 1';
% step 0: fill up the wash buffer
for i = 1: (N_hybridization+4)
    [N_hyb_1,N_hyb_2] = quorem(sym(i),sym(7));
    if N_hyb_1 == 0
        writeline(s, ['aLP0' char(48+N_hyb_2) 'R']);
        message(5) = char(48+N_hyb_2);
    else    
        if N_hyb_1 == 1
            writeline(s, ['aLP0' char(48+8) 'R']);
            writeline(s, ['bLP0' char(48+N_hyb_2) 'R']);
            message(5) = char(48+8);
            message(13) = char(48+N_hyb_2);
        else
            writeline(s, ['aLP0' char(48+8) 'R']);
            writeline(s, ['bLP0' char(48+8) 'R']);
            writeline(s, ['cLP0' char(48+N_hyb_2) 'R']);
            message(5) = char(48+8);
            message(13) = char(48+8);
            message(21) = char(48+N_hyb_2);
        end
    end
    disp('device state:');
    disp(message);

    disp(['waiting ' num2str(Nterm0) ' second...']);
    pause(Nterm0);
end



[~,N_hyb_terminal] = quorem(sym(N_hybridization),sym(7));
for i  = 1:N_hybridizaiton
    % step 1: hybridization buffers
    
    [N_hyb_1,N_hyb_2] = quorem(sym(i),sym(7));
    if N_hyb_1 == 0
        writeline(s, ['aLP0' char(48+N_hyb_2) 'R']);
        message(5) = char(48+N_hyb_1);
    else    
        if N_hyb_1 == 1
            writeline(s, ['aLP0' char(48+8) 'R']);
            writeline(s, ['bLP0' char(48+N_hyb_2) 'R']);
            message(5) = char(48+8);
            message(13) = char(48+N_hyb_2);
        else
            writeline(s, ['aLP0' char(48+8) 'R']);
            writeline(s, ['bLP0' char(48+8) 'R']);
            writeline(s, ['cLP0' char(48+N_hyb_2) 'R']);
            message(5) = char(48+8);
            message(13) = char(48+8);
            message(21) = char(48+N_hyb_2);
        end
    end

    disp('device state:');
    disp(message);

    disp(['waiting ' num2str(Nterm1) ' second...']);
    pause(Nterm1);


    % step 2: Washing - Imaging - Bleaching - Washing
    for j = 1:4
        writeline(s, ['aLP0' char(48+8) 'R']);
        writeline(s, ['bLP0' char(48+8) 'R']);
        writeline(s, ['cLP0' char(48+N_hyb_terminal+j) 'R']);
        message(5) = char(48+8);
        message(13) = char(48+8);
        message(21) = char(48+N_hyb_terminal+j);
    
        disp('device state:');
        disp(message);

        disp(['waiting ' num2str(Nterm2) ' second...']);
        pause(Nterm2);
    end
    disp([char(48+i) ' / ' char(48+N_hybridization) ' Step End...']);
end

% step 3: Washing whole devices
pause(180); % waiting time for changing buffers to device clean-up buffer

for i = 1: (N_hybridization+4)
    [N_hyb_1,N_hyb_2] = quorem(sym(i),sym(7));
    if N_hyb_1 == 0
        writeline(s, ['aLP0' char(48+N_hyb_2) 'R']);
        message(5) = char(48+N_hyb_2);
    else    
        if N_hyb_1 == 1
            writeline(s, ['aLP0' char(48+8) 'R']);
            writeline(s, ['bLP0' char(48+N_hyb_2) 'R']);
            message(5) = char(48+8);
            message(13) = char(48+N_hyb_2);
        else
            writeline(s, ['aLP0' char(48+8) 'R']);
            writeline(s, ['bLP0' char(48+8) 'R']);
            writeline(s, ['cLP0' char(48+N_hyb_2) 'R']);
            message(5) = char(48+8);
            message(13) = char(48+8);
            message(21) = char(48+N_hyb_2);
        end
    end
    disp('device state:');
    disp(message);

    disp(['waiting ' num2str(Nterm0) ' second...']);
    pause(Nterm0);
end

disp('Device Clean-up End...');

disp('------ MINA End ------');
