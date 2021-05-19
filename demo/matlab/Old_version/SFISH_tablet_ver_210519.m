classdef SFISH_tablet < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        figure                   matlab.ui.Figure
        title                    matlab.ui.control.Label
        Portbox                  matlab.ui.container.Panel
        text2                    matlab.ui.control.Label
        text17                   matlab.ui.control.Label
        text5                    matlab.ui.control.Label
        text17_2                 matlab.ui.control.Label
        portmvp                  matlab.ui.control.EditField
        portpump                 matlab.ui.control.EditField
        portlaser_1              matlab.ui.control.EditField
        portlaser_2              matlab.ui.control.EditField
        initialize               matlab.ui.control.Button
        Autoparameterbox         matlab.ui.container.ButtonGroup
        ofbuffersEditFieldLabel  matlab.ui.control.Label
        autonumbuf               matlab.ui.control.EditField
        EditField1Label          matlab.ui.control.Label
        EditField1               matlab.ui.control.EditField
        EditField2Label          matlab.ui.control.Label
        EditField2               matlab.ui.control.EditField
        EditField3Label          matlab.ui.control.Label
        EditField3               matlab.ui.control.EditField
        EditField4Label          matlab.ui.control.Label
        EditField4               matlab.ui.control.EditField
        UseLaser2SwitchLabel     matlab.ui.control.Label
        UseLaser2Switch          matlab.ui.control.Switch
        UseShutterSwitchLabel    matlab.ui.control.Label
        UseShutterSwitch         matlab.ui.control.Switch
        Runauto                  matlab.ui.control.Button
        MVP1box                  matlab.ui.container.ButtonGroup
        mvp1pos                  matlab.ui.control.EditField
        mvp1move                 matlab.ui.control.Button
        text8                    matlab.ui.control.Label
        MVP2box                  matlab.ui.container.ButtonGroup
        text12                   matlab.ui.control.Label
        mvp2pos                  matlab.ui.control.EditField
        mvp2move                 matlab.ui.control.Button
        MVP3box                  matlab.ui.container.ButtonGroup
        mvp3pos                  matlab.ui.control.EditField
        mvp3move                 matlab.ui.control.Button
        text13                   matlab.ui.control.Label
        Pumpbox                  matlab.ui.container.ButtonGroup
        text14                   matlab.ui.control.Label
        text15                   matlab.ui.control.Label
        pumptime                 matlab.ui.control.EditField
        pumpflow                 matlab.ui.control.EditField
        pumpmove                 matlab.ui.control.Button
        Laserbox                 matlab.ui.container.ButtonGroup
        text18                   matlab.ui.control.Label
        text19                   matlab.ui.control.Label
        text22                   matlab.ui.control.Label
        text23                   matlab.ui.control.Label
        minpower                 matlab.ui.control.Label
        maxpower                 matlab.ui.control.Label
        text24                   matlab.ui.control.Label
        text25                   matlab.ui.control.Label
        laserDropDown            matlab.ui.control.DropDown
        laserpower               matlab.ui.control.EditField
        lasermove                matlab.ui.control.Button
        Label                    matlab.ui.control.Label
        laserOnoff               matlab.ui.control.RockerSwitch
        Shutterbox               matlab.ui.container.Panel
        shutterswitch            matlab.ui.control.Switch
        text17_3                 matlab.ui.control.Label
        portshutter              matlab.ui.control.EditField
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function tablet_OpeningFcn(app, varargin)
            % Sequential FISH control tablet 
            % A program for controlling devices used in MERFISH
            % Devices are linked by serial communication (except pump; MODBUS)
            % You can manipulate the devices by button boxes,
            % and also run automatically by inputting auto parameters 
            % and press "Run automatically"
            %
            % The program is from Wonkicho Lab.
            % Github: https://github.com/wonkicholab/sequential-fish
            % Site: https://www.wonkicholab.com/
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app); %#ok<ASGLU>

            % Choose default command line output for Test
            handles.output = hObject;
            movegui(hObject,"center");
            
            % Assign spaces for the communication port objects of devices
            handles.MVPport = '-';
            handles.Pumpport = '-';
            handles.Laserport_1 = '-';
            handles.Laserport_2 = '-';
            handles.Shutterport = '-';
            
            % Update handles structure
            guidata(hObject, handles);
        end

        % Button pushed function: initialize
        function initialize_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            slCharacterEncoding('utf-8');

            % init MVP devices
            if handles.MVPport ~= '-'
                try
                    s1 = serialport(['COM' handles.MVPport],9600);
                    s1.DataBits = 7;
                    s1.StopBits = 1;
                    s1.Parity = 'odd';
                    configureTerminator(s1, "CR");
                    writeline(s1, '1a');
                
                    writeline(s1, 'aLXR');
                    writeline(s1, 'bLXR');
                    writeline(s1, 'cLXR');
                
                    msgbox('Press initialize button of MVP devices!');
                    pause(18);
                
                    handles.MVPport = s1;
                catch
                    msgbox('MVP port number is not correct!');
                    app.portmvp.Value = '-';
                    handles.MVPport = '-';
                end
            end
            
            % init Pump 
            if handles.Pumpport ~= '-'
                try
                    s2 = modbus('serialrtu',['COM' handles.Pumpport],'Parity','even');
                    handles.Pumpport = s2;

                    write(s2,'holdingregs',4018,2,'uint16');
                    write(s2,'holdingregs',4169,double(typecast(single(str2double('50')),'uint16')),'uint16');
                    write(s2,'holdingregs',4171,100,'uint16');
                    write(s2,'holdingregs',4172,1,'uint16');
                    write(s2,'holdingregs',4173,1,'uint16');
                    write(s2,'holdingregs',4174,1,'uint16');
                    
                    write(s2,'holdingregs',4026,1,'uint16');
                    pause(2);
                    write(s2,'holdingregs',4171,5990,'uint16');
                catch
                    msgbox('Pump port number is not correct!');
                    app.portpump.Value = '-';
                    handles.Pumpport = '-';
                end
            end
            
            % init Laser
            if handles.Laserport_1 ~= '-'
                try
                    s3 = serialport(['COM' handles.Laserport_1],9600);
                    s3.DataBits = 8;
                    s3.StopBits = 1;
                    s3.Parity = 'none';
                    configureTerminator(s3, "CR");
                    writeline(s3, 'SOURce:POWer:LIMit:LOW?');
                    pause(1);
                    temp = read(s3,s3.NumBytesAvailable,'char');
                    set(handles.minpower,'string',sprintf('%d',str2double(temp(1:length(temp)-6))*1000));
                    writeline(s3, 'SOURce:POWer:LIMit:HIGH?');
                    pause(1);
                    temp = read(s3,s3.NumBytesAvailable,'char');
                    set(handles.maxpower,'string',sprintf('%d',str2double(temp(1:length(temp)-6))*1000));
                    
                    writeline(s3, 'SOURce:AM:STATe ON');
                    handles.Laserport_1 = s3;
                catch
                    msgbox('Laser #1 port number is not correct!');
                    app.portlaser_1.Value = '-';
                    handles.Laserport_1 = '-';
                end
            end
            
            if handles.Laserport_2 ~= '-'
                try
                    s4 = serialport(['COM' handles.Laserport_2],9600);
                    s4.DataBits = 8;
                    s4.StopBits = 1;
                    s4.Parity = 'none';
                    configureTerminator(s4, "CR");
    
                
                    handles.Laserport_2 = s4;
                catch
                    msgbox('Laser #2 port number is not correct!');
                    app.portlaser_2.Value = '-';
                    handles.Laserport_2 = '-';
                end
            end
            
            if (handles.MVPport == '-' || handles.Pumpport == '-' || handles.Laserport_1 == '-')
                msgbox(["For sequencial FISH, we need at least three devices!"; ...
                    "        ( MVP, Pump, and Laser )"; ...
                    "Please check the connected ports of them!"]);
            end
            
            guidata(hObject, handles);
        end

        % Button pushed function: Runauto
        function RunautoButtonPushed(app, event)
% % Examples how to make the devices
% % moving mvp part
% app.mvp1pos.Value = '7';
% mvp1move_Callback(app,event);
%  
% % moving pump part
% app.pumptime.Value = '4';
% app.pumpflow.Value = '500';
% pumpmoveButtonPushed(app,event);
%            
% % moving laser part
% app.laserDropDown.Value = '1';
% app.laserpower.Value = '66';
% lasermove_Callback(app,event);
            
            % auto parameters control
            % Where we have to actually implement
            % -- not complete implementation -- 
            
            % Parameters parsing
            N_of_buf = str2double(app.autonumbuf.Value);
            
            if app.UseLaser2Switch.Value == "Off"
                % Use only laser #1
            else
                % Use both laser #1 and laser #2
            end
            
            
            msgbox(["Not implemented / Should be implemented"; ...
                "For run automatically, you should implement this part"; ...
                "       and auto parameter box"]);
        end

        % Value changed function: autonumbuf
        function autonumbufValueChanged(app, event)
            try 
                temp = str2double(app.autonumbuf.Value);
                if temp>19
                    app.autonumbuf.Value = '19';
                    msgbox('Max number of buffer is 19');
                elseif temp<1
                    app.autonumbuf.Value = '1';
                    msgbox('Min number of buffer is 1');
                end
                temp = str2double(app.autonumbuf.Value);
                if floor(temp) ~= temp
                    msgbox("You need to input the integer value");
                    app.autonumbuf.Value = sprintf('%d', floor(temp));
                end
            catch
                msgbox('Should input the integer!');
            end
        end

        % Value changed function: laserDropDown
        function laserDropDown_callback(app, event)
            value = app.laserDropDown.Value;
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if value == '1'
                stemp = handles.Laserport_1;
            else
                stemp = handles.Laserport_2;
            end
            if stemp ~= '-'
                writeline(stemp, 'SOURce:POWer:LIMit:LOW?');
                pause(1);
                temp = read(stemp,stemp.NumBytesAvailable,'char');
                set(handles.minpower,'string',sprintf('%d',str2double(temp(1:length(temp)-6))*1000));
                writeline(stemp, 'SOURce:POWer:LIMit:HIGH?');
                pause(1);
                temp = read(stemp,stemp.NumBytesAvailable,'char');
                set(handles.maxpower,'string',sprintf('%d',str2double(temp(1:length(temp)-6))*1000));
                guidata(hObject, handles);
            else
                if value == '1'
                    msgbox({'The program does not initialized.'; ...
                        'Please run the program after "Initialize"'});
                else
                    msgbox({'Laser #2 is not used or still not set to use!'; ...
                        'If you want, input the connected port of Laser #2 and do "Initialize"'});
                    app.laserDropDown.Value = '1';
                    
                end
            end
        end

        % Button pushed function: lasermove
        function lasermove_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if app.laserpower.Value ~= '-'
                if app.laserDropDown.Value == '1'
                    if handles.Laserport_1 ~= '-'
                    writeline(handles.Laserport_1,...
                        ['SOURce:POWer:LEVel:IMMediate:AMPLitude ' sprintf('%f',str2double(app.laserpower.Value)*0.001)]);
                    pause(1);
                    else
                        msgbox('Please run the program after "Initialize"!');
                    end
                else
                    if handles.Laserport_2 ~= '-'
                        writeline(handles.Laserport_2,...
                            ['SOURce:POWer:LEVel:IMMediate:AMPLitude ' sprintf('%f',str2double(app.laserpower.Value)*0.001)]);
                        pause(1);
                    else
                        msgbox('Please run the program after "Initialize"!!');
                    end
                end
            else
                msgbox('Please input the value (mW) you want to set as laser power');
            end
        end

        % Value changed function: laserpower
        function laserpower_Callback(app, event)
            try 
                if str2double(app.laserpower.Value) < str2double(app.minpower.Text)
                    app.laserpower.Value = app.minpower.Text;
                else
                    if str2double(app.laserpower.Value) > str2double(app.maxpower.Text) 
                        app.laserpower.Value = app.maxpower.Text; 
                    end 
                end
            catch 
                msgbox('Please run the program after "Initialize"');
            end

        end

        % Button pushed function: mvp1move
        function mvp1move_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if (floor(str2double(app.mvp1pos.Value)) ~= str2double(app.mvp1pos.Value))
                msgbox("Input value should be integer!");
                app.mvp1pos.Value = '1';
            elseif (str2double(app.mvp1pos.Value)>8 || str2double(app.mvp1pos.Value)<1)
                msgbox('MVP position should be from 1 to 8!');
                app.mvp1pos.Value = '1';
            else
                try
                    writeline(handles.MVPport, ['aLP0' app.mvp1pos.Value 'R']);
                catch
                    msgbox(["Error! Check the followings: "; "1. Please run the program after 'Initialize'"; ...
                        "2. Please check the MVP line is still connected"]);
                end
            end
        end

        % Value changed function: mvp1pos
        function mvp1pos_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.MVP1pos = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Button pushed function: mvp2move
        function mvp2move_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if (floor(str2double(app.mvp2pos.Value)) ~= str2double(app.mvp2pos.Value))
                msgbox("Input value should be integer!");
                app.mvp2pos.Value = '1';
            elseif (str2double(app.mvp2pos.Value)>8 || str2double(app.mvp2pos.Value)<1)
                msgbox('MVP position should be from 1 to 8!');
                app.mvp2pos.Value = '1';
            else
                try
                    app.mvp1pos.Value = '8';
                    writeline(handles.MVPport, 'aLP08R');
                    writeline(handles.MVPport, ['bLP0' app.mvp2pos.Value 'R']);
                catch
                    msgbox(["Error! Check the followings: "; "1. Please run the program after 'Initialize'"; ...
                        "2. Please check the MVP line is still connected"]);
                end
            end
        end

        % Value changed function: mvp2pos
        function mvp2pos_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.MVP2pos = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Button pushed function: mvp3move
        function mvp3move_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if (floor(str2double(app.mvp3pos.Value)) ~= str2double(app.mvp3pos.Value))
                msgbox("Input value should be integer!");
                app.mvp3pos.Value = '1';
            elseif (str2double(app.mvp3pos.Value)>8 || str2double(app.mvp3pos.Value)<1)
                msgbox('MVP position should be from 1 to 8!');
                app.mvp3pos.Value = '1';
            else
                try
                    app.mvp1pos.Value = '8';
                    app.mvp2pos.Value = '8';
                    writeline(handles.MVPport, 'aLP08R');
                    writeline(handles.MVPport, 'bLP08R');
                    writeline(handles.MVPport, ['cLP0' app.mvp3pos.Value 'R']);
                catch
                    msgbox(["Error! Check the followings: "; "1. Please run the program after 'Initialize'"; ...
                        "2. Please check the MVP line is still connected"]);
                end
            end
        end

        % Value changed function: mvp3pos
        function mvp3pos_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.MVP3pos = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: portlaser_1
        function portlaser_1_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.Laserport_1 = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: portlaser_2
        function portlaser_2_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.Laserport_2 = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: portmvp
        function portmvp_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.MVPport = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: portpump
        function portpump_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.Pumpport = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: pumpflow
        function pumpflow_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.PumpFlow = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Button pushed function: pumpmove
        function pumpmoveButtonPushed(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            modbus_pump = handles.Pumpport;
            write(modbus_pump,'holdingregs',4169,double(typecast(single(str2double(app.pumpflow.Value)),'uint16')),'uint16');
            write(modbus_pump,'holdingregs',4173,str2double(app.pumptime.Value),'uint16');
            write(modbus_pump,'holdingregs',4026,1,'uint16');
            pause(str2double(app.pumptime.Value)*60);
            
        end

        % Value changed function: pumptime
        function pumptime_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.PumpTime = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: laserOnoff
        function laserOnoffValueChanged(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if app.laserOnoff.Value == "On"
                if app.laserDropDown.Value == '1'
                    if handles.Laserport_1 ~= '-'
                    writeline(handles.Laserport_1,'SOURce:AM:STATe ON');
                    pause(1);
                    else
                        msgbox('Please run the program after "Initialize"!');
                    end
                else
                    if handles.Laserport_2 ~= '-'
                        writeline(handles.Laserport_2,'SOURce:AM:STATe ON');
                        pause(1);
                    else
                        msgbox('Please run the program after "Initialize"!!');
                    end
                end
            else
                if app.laserDropDown.Value == '1'
                    if handles.Laserport_1 ~= '-'
                    writeline(handles.Laserport_1,'SOURce:AM:STATe OFF');
                    pause(1);
                    else
                        msgbox('Please run the program after "Initialize"!');
                    end
                else
                    if handles.Laserport_2 ~= '-'
                        writeline(handles.Laserport_2,'SOURce:AM:STATe OFF');
                        pause(1);
                    else
                        msgbox('Please run the program after "Initialize"!!');
                    end
                end
            end
            
        end

        % Value changed function: portshutter
        function portshutterValueChanged(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            try
                s5 = serialport(['COM' app.portshutter.Value],9600);
                s5.DataBits = 8;
                s5.StopBits = 1;
                s5.Parity = 'none';
                configureTerminator(s5, "CR");

                handles.Shutterport = s5;
            catch
                msgbox('Shutter port number is not correct!');
                app.portshutter.Value = '-';
                handles.Shutterport = '-';
            end
            guidata(hObject, handles);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create figure and hide until all components are created
            app.figure = uifigure('Visible', 'off');
            app.figure.Position = [680 635 498 614];
            app.figure.Name = 'FISH tablet';
            app.figure.Resize = 'off';
            app.figure.HandleVisibility = 'callback';
            app.figure.Tag = 'figure';

            % Create title
            app.title = uilabel(app.figure);
            app.title.Tag = 'title';
            app.title.HorizontalAlignment = 'center';
            app.title.VerticalAlignment = 'top';
            app.title.FontSize = 27;
            app.title.FontWeight = 'bold';
            app.title.Position = [18 552 462 51];
            app.title.Text = 'Sequential FISH control tablet';

            % Create Portbox
            app.Portbox = uipanel(app.figure);
            app.Portbox.Title = 'Connected ports';
            app.Portbox.Tag = 'uipanel1';
            app.Portbox.FontSize = 11;
            app.Portbox.Position = [18 513 368 51];

            % Create text2
            app.text2 = uilabel(app.Portbox);
            app.text2.Tag = 'text2';
            app.text2.HorizontalAlignment = 'right';
            app.text2.FontSize = 11;
            app.text2.Position = [-15 6 54 22];
            app.text2.Text = 'MVP';

            % Create text17
            app.text17 = uilabel(app.Portbox);
            app.text17.Tag = 'text17';
            app.text17.HorizontalAlignment = 'right';
            app.text17.FontSize = 11;
            app.text17.Position = [175 6 54 22];
            app.text17.Text = 'Laser #1';

            % Create text5
            app.text5 = uilabel(app.Portbox);
            app.text5.Tag = 'text5';
            app.text5.HorizontalAlignment = 'right';
            app.text5.FontSize = 11;
            app.text5.Position = [80 6 54 22];
            app.text5.Text = 'Pump';

            % Create text17_2
            app.text17_2 = uilabel(app.Portbox);
            app.text17_2.Tag = 'text17';
            app.text17_2.HorizontalAlignment = 'right';
            app.text17_2.FontSize = 11;
            app.text17_2.Position = [269 6 54 22];
            app.text17_2.Text = 'Laser #2';

            % Create portmvp
            app.portmvp = uieditfield(app.Portbox, 'text');
            app.portmvp.ValueChangedFcn = createCallbackFcn(app, @portmvp_Callback, true);
            app.portmvp.Tag = 'portmvp';
            app.portmvp.HorizontalAlignment = 'center';
            app.portmvp.FontSize = 11;
            app.portmvp.Position = [42 6 38 23];
            app.portmvp.Value = '-';

            % Create portpump
            app.portpump = uieditfield(app.Portbox, 'text');
            app.portpump.ValueChangedFcn = createCallbackFcn(app, @portpump_Callback, true);
            app.portpump.Tag = 'portpump';
            app.portpump.HorizontalAlignment = 'center';
            app.portpump.FontSize = 11;
            app.portpump.Position = [137 6 38 23];
            app.portpump.Value = '-';

            % Create portlaser_1
            app.portlaser_1 = uieditfield(app.Portbox, 'text');
            app.portlaser_1.ValueChangedFcn = createCallbackFcn(app, @portlaser_1_Callback, true);
            app.portlaser_1.Tag = 'portlaser';
            app.portlaser_1.HorizontalAlignment = 'center';
            app.portlaser_1.FontSize = 11;
            app.portlaser_1.Position = [232 6 38 23];
            app.portlaser_1.Value = '-';

            % Create portlaser_2
            app.portlaser_2 = uieditfield(app.Portbox, 'text');
            app.portlaser_2.ValueChangedFcn = createCallbackFcn(app, @portlaser_2_Callback, true);
            app.portlaser_2.Tag = 'portlaser';
            app.portlaser_2.HorizontalAlignment = 'center';
            app.portlaser_2.FontSize = 11;
            app.portlaser_2.Position = [326 6 38 23];
            app.portlaser_2.Value = '-';

            % Create initialize
            app.initialize = uibutton(app.figure, 'push');
            app.initialize.ButtonPushedFcn = createCallbackFcn(app, @initialize_Callback, true);
            app.initialize.Tag = 'initialize';
            app.initialize.FontSize = 11;
            app.initialize.Position = [396 521 75 35];
            app.initialize.Text = 'Initialize';

            % Create Autoparameterbox
            app.Autoparameterbox = uibuttongroup(app.figure);
            app.Autoparameterbox.Title = 'Auto parameters';
            app.Autoparameterbox.Tag = 'uibuttongroup8';
            app.Autoparameterbox.FontSize = 11;
            app.Autoparameterbox.Position = [264 61 216 370];

            % Create ofbuffersEditFieldLabel
            app.ofbuffersEditFieldLabel = uilabel(app.Autoparameterbox);
            app.ofbuffersEditFieldLabel.HorizontalAlignment = 'right';
            app.ofbuffersEditFieldLabel.Position = [18 314 65 22];
            app.ofbuffersEditFieldLabel.Text = '# of buffers';

            % Create autonumbuf
            app.autonumbuf = uieditfield(app.Autoparameterbox, 'text');
            app.autonumbuf.ValueChangedFcn = createCallbackFcn(app, @autonumbufValueChanged, true);
            app.autonumbuf.HorizontalAlignment = 'center';
            app.autonumbuf.Position = [98 314 100 22];
            app.autonumbuf.Value = '16';

            % Create EditField1Label
            app.EditField1Label = uilabel(app.Autoparameterbox);
            app.EditField1Label.HorizontalAlignment = 'right';
            app.EditField1Label.Position = [21 253 62 22];
            app.EditField1Label.Text = 'Edit Field1';

            % Create EditField1
            app.EditField1 = uieditfield(app.Autoparameterbox, 'text');
            app.EditField1.Position = [98 253 100 22];

            % Create EditField2Label
            app.EditField2Label = uilabel(app.Autoparameterbox);
            app.EditField2Label.HorizontalAlignment = 'right';
            app.EditField2Label.Position = [21 192 62 22];
            app.EditField2Label.Text = 'Edit Field2';

            % Create EditField2
            app.EditField2 = uieditfield(app.Autoparameterbox, 'text');
            app.EditField2.Position = [98 192 100 22];

            % Create EditField3Label
            app.EditField3Label = uilabel(app.Autoparameterbox);
            app.EditField3Label.HorizontalAlignment = 'right';
            app.EditField3Label.Position = [21 131 62 22];
            app.EditField3Label.Text = 'Edit Field3';

            % Create EditField3
            app.EditField3 = uieditfield(app.Autoparameterbox, 'text');
            app.EditField3.Position = [98 131 100 22];

            % Create EditField4Label
            app.EditField4Label = uilabel(app.Autoparameterbox);
            app.EditField4Label.HorizontalAlignment = 'right';
            app.EditField4Label.Position = [21 70 62 22];
            app.EditField4Label.Text = 'Edit Field4';

            % Create EditField4
            app.EditField4 = uieditfield(app.Autoparameterbox, 'text');
            app.EditField4.Position = [98 70 100 22];

            % Create UseLaser2SwitchLabel
            app.UseLaser2SwitchLabel = uilabel(app.Autoparameterbox);
            app.UseLaser2SwitchLabel.HorizontalAlignment = 'center';
            app.UseLaser2SwitchLabel.Position = [14 10 77 22];
            app.UseLaser2SwitchLabel.Text = 'Use Laser #2';

            % Create UseLaser2Switch
            app.UseLaser2Switch = uiswitch(app.Autoparameterbox, 'slider');
            app.UseLaser2Switch.Position = [132 11 47 21];

            % Create UseShutterSwitchLabel
            app.UseShutterSwitchLabel = uilabel(app.Autoparameterbox);
            app.UseShutterSwitchLabel.HorizontalAlignment = 'center';
            app.UseShutterSwitchLabel.Position = [18 38 69 22];
            app.UseShutterSwitchLabel.Text = 'Use Shutter';

            % Create UseShutterSwitch
            app.UseShutterSwitch = uiswitch(app.Autoparameterbox, 'slider');
            app.UseShutterSwitch.Position = [132 39 47 21];

            % Create Runauto
            app.Runauto = uibutton(app.figure, 'push');
            app.Runauto.ButtonPushedFcn = createCallbackFcn(app, @RunautoButtonPushed, true);
            app.Runauto.Tag = 'Runauto';
            app.Runauto.FontSize = 11;
            app.Runauto.Position = [321 17 102 35];
            app.Runauto.Text = 'Run automatically';

            % Create MVP1box
            app.MVP1box = uibuttongroup(app.figure);
            app.MVP1box.Title = 'MVP #1';
            app.MVP1box.Tag = 'uibuttongroup2';
            app.MVP1box.FontSize = 11;
            app.MVP1box.Position = [21 442 232 58];

            % Create mvp1pos
            app.mvp1pos = uieditfield(app.MVP1box, 'text');
            app.mvp1pos.ValueChangedFcn = createCallbackFcn(app, @mvp1pos_Callback, true);
            app.mvp1pos.Tag = 'mvp1pos';
            app.mvp1pos.HorizontalAlignment = 'center';
            app.mvp1pos.FontSize = 11;
            app.mvp1pos.Position = [60 10 62 20];
            app.mvp1pos.Value = '1';

            % Create mvp1move
            app.mvp1move = uibutton(app.MVP1box, 'push');
            app.mvp1move.ButtonPushedFcn = createCallbackFcn(app, @mvp1move_Callback, true);
            app.mvp1move.Tag = 'mvp1move';
            app.mvp1move.FontSize = 11;
            app.mvp1move.Position = [168 5 55 30];
            app.mvp1move.Text = 'Move';

            % Create text8
            app.text8 = uilabel(app.MVP1box);
            app.text8.Tag = 'text8';
            app.text8.HorizontalAlignment = 'center';
            app.text8.VerticalAlignment = 'top';
            app.text8.FontSize = 11;
            app.text8.Position = [7 12 52 16];
            app.text8.Text = 'Position';

            % Create MVP2box
            app.MVP2box = uibuttongroup(app.figure);
            app.MVP2box.Title = 'MVP #2';
            app.MVP2box.Tag = 'uibuttongroup4';
            app.MVP2box.FontSize = 11;
            app.MVP2box.Position = [21 373 232 58];

            % Create text12
            app.text12 = uilabel(app.MVP2box);
            app.text12.Tag = 'text12';
            app.text12.HorizontalAlignment = 'center';
            app.text12.VerticalAlignment = 'top';
            app.text12.FontSize = 11;
            app.text12.Position = [5 13 52 16];
            app.text12.Text = 'Position';

            % Create mvp2pos
            app.mvp2pos = uieditfield(app.MVP2box, 'text');
            app.mvp2pos.ValueChangedFcn = createCallbackFcn(app, @mvp2pos_Callback, true);
            app.mvp2pos.Tag = 'mvp2pos';
            app.mvp2pos.HorizontalAlignment = 'center';
            app.mvp2pos.FontSize = 11;
            app.mvp2pos.Position = [58 11 62 20];
            app.mvp2pos.Value = '1';

            % Create mvp2move
            app.mvp2move = uibutton(app.MVP2box, 'push');
            app.mvp2move.ButtonPushedFcn = createCallbackFcn(app, @mvp2move_Callback, true);
            app.mvp2move.Tag = 'mvp2move';
            app.mvp2move.FontSize = 11;
            app.mvp2move.Position = [168 6 55 30];
            app.mvp2move.Text = 'Move';

            % Create MVP3box
            app.MVP3box = uibuttongroup(app.figure);
            app.MVP3box.Title = 'MVP #3';
            app.MVP3box.Tag = 'uibuttongroup5';
            app.MVP3box.FontSize = 11;
            app.MVP3box.Position = [21 305 232 58];

            % Create mvp3pos
            app.mvp3pos = uieditfield(app.MVP3box, 'text');
            app.mvp3pos.ValueChangedFcn = createCallbackFcn(app, @mvp3pos_Callback, true);
            app.mvp3pos.Tag = 'mvp3pos';
            app.mvp3pos.HorizontalAlignment = 'center';
            app.mvp3pos.FontSize = 11;
            app.mvp3pos.Position = [59 11 62 20];
            app.mvp3pos.Value = '1';

            % Create mvp3move
            app.mvp3move = uibutton(app.MVP3box, 'push');
            app.mvp3move.ButtonPushedFcn = createCallbackFcn(app, @mvp3move_Callback, true);
            app.mvp3move.Tag = 'mvp3move';
            app.mvp3move.FontSize = 11;
            app.mvp3move.Position = [168 6 55 30];
            app.mvp3move.Text = 'Move';

            % Create text13
            app.text13 = uilabel(app.MVP3box);
            app.text13.Tag = 'text13';
            app.text13.HorizontalAlignment = 'center';
            app.text13.VerticalAlignment = 'top';
            app.text13.FontSize = 11;
            app.text13.Position = [6 13 52 16];
            app.text13.Text = 'Position';

            % Create Pumpbox
            app.Pumpbox = uibuttongroup(app.figure);
            app.Pumpbox.Title = 'Pump';
            app.Pumpbox.Tag = 'uibuttongroup6';
            app.Pumpbox.FontSize = 11;
            app.Pumpbox.Position = [21 187 232 104];

            % Create text14
            app.text14 = uilabel(app.Pumpbox);
            app.text14.Tag = 'text14';
            app.text14.HorizontalAlignment = 'center';
            app.text14.FontSize = 11;
            app.text14.Position = [13 52 68 22];
            app.text14.Text = 'Time (min)';

            % Create text15
            app.text15 = uilabel(app.Pumpbox);
            app.text15.Tag = 'text15';
            app.text15.HorizontalAlignment = 'center';
            app.text15.FontSize = 11;
            app.text15.Position = [13 14 68 22];
            app.text15.Text = 'Flow (ul/min)';

            % Create pumptime
            app.pumptime = uieditfield(app.Pumpbox, 'text');
            app.pumptime.ValueChangedFcn = createCallbackFcn(app, @pumptime_Callback, true);
            app.pumptime.Tag = 'pumptime1';
            app.pumptime.HorizontalAlignment = 'center';
            app.pumptime.FontSize = 11;
            app.pumptime.Position = [99 52 62 22];
            app.pumptime.Value = '4';

            % Create pumpflow
            app.pumpflow = uieditfield(app.Pumpbox, 'text');
            app.pumpflow.ValueChangedFcn = createCallbackFcn(app, @pumpflow_Callback, true);
            app.pumpflow.Tag = 'pumptime2';
            app.pumpflow.HorizontalAlignment = 'center';
            app.pumpflow.FontSize = 11;
            app.pumpflow.Position = [99 14 62 22];
            app.pumpflow.Value = '500';

            % Create pumpmove
            app.pumpmove = uibutton(app.Pumpbox, 'push');
            app.pumpmove.ButtonPushedFcn = createCallbackFcn(app, @pumpmoveButtonPushed, true);
            app.pumpmove.Tag = 'pumptime1move';
            app.pumpmove.FontSize = 11;
            app.pumpmove.Position = [168 33 55 24];
            app.pumpmove.Text = 'Move';

            % Create Laserbox
            app.Laserbox = uibuttongroup(app.figure);
            app.Laserbox.Title = 'Laser';
            app.Laserbox.Tag = 'uibuttongroup7';
            app.Laserbox.FontSize = 11;
            app.Laserbox.Position = [20 16 233 158];

            % Create text18
            app.text18 = uilabel(app.Laserbox);
            app.text18.Tag = 'text18';
            app.text18.HorizontalAlignment = 'center';
            app.text18.FontSize = 11;
            app.text18.Position = [22 27 64 15];
            app.text18.Text = 'Minimum: ';

            % Create text19
            app.text19 = uilabel(app.Laserbox);
            app.text19.Tag = 'text19';
            app.text19.HorizontalAlignment = 'center';
            app.text19.FontSize = 11;
            app.text19.Position = [22 4 64 15];
            app.text19.Text = 'Maximum: ';

            % Create text22
            app.text22 = uilabel(app.Laserbox);
            app.text22.Tag = 'text22';
            app.text22.HorizontalAlignment = 'center';
            app.text22.FontSize = 11;
            app.text22.Position = [162 27 35 15];
            app.text22.Text = 'mW';

            % Create text23
            app.text23 = uilabel(app.Laserbox);
            app.text23.Tag = 'text23';
            app.text23.HorizontalAlignment = 'center';
            app.text23.FontSize = 11;
            app.text23.Position = [162 4 35 15];
            app.text23.Text = 'mW';

            % Create minpower
            app.minpower = uilabel(app.Laserbox);
            app.minpower.Tag = 'minpower';
            app.minpower.HorizontalAlignment = 'center';
            app.minpower.FontSize = 11;
            app.minpower.Position = [84 25 66 17];
            app.minpower.Text = '-';

            % Create maxpower
            app.maxpower = uilabel(app.Laserbox);
            app.maxpower.Tag = 'maxpower';
            app.maxpower.HorizontalAlignment = 'center';
            app.maxpower.FontSize = 11;
            app.maxpower.Position = [84 3 66 17];
            app.maxpower.Text = '-';

            % Create text24
            app.text24 = uilabel(app.Laserbox);
            app.text24.Tag = 'text24';
            app.text24.HorizontalAlignment = 'center';
            app.text24.FontSize = 11;
            app.text24.Position = [29 80 42 15];
            app.text24.Text = 'Power';

            % Create text25
            app.text25 = uilabel(app.Laserbox);
            app.text25.Tag = 'text25';
            app.text25.HorizontalAlignment = 'center';
            app.text25.VerticalAlignment = 'top';
            app.text25.FontSize = 11;
            app.text25.Position = [156 80 35 15];
            app.text25.Text = 'mW';

            % Create laserDropDown
            app.laserDropDown = uidropdown(app.Laserbox);
            app.laserDropDown.Items = {'1', '2'};
            app.laserDropDown.ValueChangedFcn = createCallbackFcn(app, @laserDropDown_callback, true);
            app.laserDropDown.Position = [41 107 60 22];
            app.laserDropDown.Value = '1';

            % Create laserpower
            app.laserpower = uieditfield(app.Laserbox, 'text');
            app.laserpower.ValueChangedFcn = createCallbackFcn(app, @laserpower_Callback, true);
            app.laserpower.Tag = 'laserpower';
            app.laserpower.HorizontalAlignment = 'center';
            app.laserpower.FontSize = 11;
            app.laserpower.Position = [78 79 66 17];
            app.laserpower.Value = '-';

            % Create lasermove
            app.lasermove = uibutton(app.Laserbox, 'push');
            app.lasermove.ButtonPushedFcn = createCallbackFcn(app, @lasermove_Callback, true);
            app.lasermove.Tag = 'lasermove';
            app.lasermove.FontSize = 11;
            app.lasermove.Position = [70 48 79 23];
            app.lasermove.Text = 'Move';

            % Create Label
            app.Label = uilabel(app.Laserbox);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [7 111 16 15];
            app.Label.Text = '#';

            % Create laserOnoff
            app.laserOnoff = uiswitch(app.Laserbox, 'rocker');
            app.laserOnoff.Orientation = 'horizontal';
            app.laserOnoff.ValueChangedFcn = createCallbackFcn(app, @laserOnoffValueChanged, true);
            app.laserOnoff.Position = [157 108 45 20];
            app.laserOnoff.Value = 'On';

            % Create Shutterbox
            app.Shutterbox = uipanel(app.figure);
            app.Shutterbox.Title = 'Shutter';
            app.Shutterbox.FontSize = 11;
            app.Shutterbox.Position = [264 442 216 58];

            % Create shutterswitch
            app.shutterswitch = uiswitch(app.Shutterbox, 'slider');
            app.shutterswitch.Position = [133 11 45 20];

            % Create text17_3
            app.text17_3 = uilabel(app.Shutterbox);
            app.text17_3.Tag = 'text17';
            app.text17_3.HorizontalAlignment = 'right';
            app.text17_3.FontSize = 11;
            app.text17_3.Position = [-1 8 63 22];
            app.text17_3.Text = 'Shutter port';

            % Create portshutter
            app.portshutter = uieditfield(app.Shutterbox, 'text');
            app.portshutter.ValueChangedFcn = createCallbackFcn(app, @portshutterValueChanged, true);
            app.portshutter.Tag = 'portlaser';
            app.portshutter.HorizontalAlignment = 'center';
            app.portshutter.FontSize = 11;
            app.portshutter.Position = [65 8 38 23];
            app.portshutter.Value = '-';

            % Show the figure after all components are created
            app.figure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SFISH_tablet(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.figure)

            % Execute the startup function
            runStartupFcn(app, @(app)tablet_OpeningFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.figure)
        end
    end
end

