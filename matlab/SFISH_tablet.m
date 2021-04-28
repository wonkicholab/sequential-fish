classdef SFISH_tablet < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        figure                   matlab.ui.Figure
        title                    matlab.ui.control.Label
        uipanel1                 matlab.ui.container.Panel
        text26                   matlab.ui.control.Label
        text2                    matlab.ui.control.Label
        text17                   matlab.ui.control.Label
        text5                    matlab.ui.control.Label
        text17_2                 matlab.ui.control.Label
        portmvp                  matlab.ui.control.EditField
        portpump                 matlab.ui.control.EditField
        portlaser_1              matlab.ui.control.EditField
        portlaser_2              matlab.ui.control.EditField
        portshutter              matlab.ui.control.EditField
        initialize               matlab.ui.control.Button
        uibuttongroup8           matlab.ui.container.ButtonGroup
        ofbuffersEditFieldLabel  matlab.ui.control.Label
        autonumbuf               matlab.ui.control.EditField
        EditFieldLabel           matlab.ui.control.Label
        EditField                matlab.ui.control.EditField
        EditField2Label          matlab.ui.control.Label
        EditField2               matlab.ui.control.EditField
        EditField3Label          matlab.ui.control.Label
        EditField3               matlab.ui.control.EditField
        EditField4Label          matlab.ui.control.Label
        EditField4               matlab.ui.control.EditField
        Runauto                  matlab.ui.control.Button
        uibuttongroup2           matlab.ui.container.ButtonGroup
        mvp1pos                  matlab.ui.control.EditField
        mvp1move                 matlab.ui.control.Button
        text8                    matlab.ui.control.Label
        uibuttongroup4           matlab.ui.container.ButtonGroup
        text12                   matlab.ui.control.Label
        mvp2pos                  matlab.ui.control.EditField
        mvp2move                 matlab.ui.control.Button
        uibuttongroup5           matlab.ui.container.ButtonGroup
        mvp3pos                  matlab.ui.control.EditField
        mvp3move                 matlab.ui.control.Button
        text13                   matlab.ui.control.Label
        uibuttongroup6           matlab.ui.container.ButtonGroup
        text14                   matlab.ui.control.Label
        text15                   matlab.ui.control.Label
        text16                   matlab.ui.control.Label
        pumptime1                matlab.ui.control.EditField
        pumptime1move            matlab.ui.control.Button
        pumptime2                matlab.ui.control.EditField
        pumptime2move            matlab.ui.control.Button
        pumptime3                matlab.ui.control.EditField
        pumptime3move            matlab.ui.control.Button
        uibuttongroup7           matlab.ui.container.ButtonGroup
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
        uibuttongroup9           matlab.ui.container.ButtonGroup
        Switch                   matlab.ui.control.Switch
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function tablet_OpeningFcn(app, varargin)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app); %#ok<ASGLU>

            % Choose default command line output for Test
            handles.output = hObject;
            movegui(hObject,"center");
            
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
                
                    msgbox('Press initialize button of the devices!');
                    pause(30);
                
                    handles.MVPport = s1;
                catch
                    msgbox('MVP port number is not correct!');
                    app.portmvp.Value = '-';
                    handles.MVPport = '-';
                end
            end
            
            %%% init Pump %%%
            % - Must be modified!!!!
            if handles.Pumpport ~= '-'
                try
                    s2 = serialport(['COM' handles.Pumpport],9600);
                
                    handles.Pumpport = s2;
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
            % % init shutter
            if handles.Shutterport ~= '-'
                try
                    s5 = serialport(['COM' handles.Shutterport],9600);
            
                    handles.Shutterport = s5;
                catch
                    msgbox('Shutter port number is not correct!');
                    app.portshutter.Value = '-';
                    handles.Shutterport = '-';
                end
            end
            
            if (handles.MVPport == '-' || handles.Pumpport == '-' || handles.Laserport_1 == '-')
                msgbox({'For sequencial FISH, we need all three devices ( MVP, Pump, and Laser ) !'; ...
                    'Please check the connected ports of them!'});
            end
            
            guidata(hObject, handles);
        end

        % Button pushed function: lasermove
        function lasermove_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if app.laserpower.Value ~= '-'
                if app.laserDropDown == 1
                    if handles.Laserport_1 ~= '-'
                    writeline(handles.Laserport_1,...
                        ['SOURce:POWer:LEVel:IMMediate:AMPLitude ' sprintf('%f',str2double(app.laserpower.Value)*0.001)]);
                    pause(1);
                    else
                        msgbox('Please run the program after "Initialize"');
                    end
                else
                    if handles.Laserport_2 ~= '-'
                        writeline(handles.Laserport_2,...
                            ['SOURce:POWer:LEVel:IMMediate:AMPLitude ' sprintf('%f',str2double(app.laserpower.Value)*0.001)]);
                        pause(1);
                    else
                        msgbox('Please run the program after "Initialize"');
                    end
                end
            else
                msgbox('Please input the value (mW) you want to set as laser power');
            end
        end

        % Value changed function: laserpower
        function laserpower_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.LaserPower = get(hObject, 'String');
            try str2double(app.minpower.text);
                if str2double(handles.LaserPower) < str2double(app.minpower.text)
                    handles.LaserPower = app.minpower.text;
                else
                    if str2double(handles.LaserPower) > str2double(app.maxpower.text) 
                        handles.LaserPower = app.maxpower.text; 
                    end 
                end
                app.laserpower = handles.LaserPower;
            catch 
                msgbox('Please run the program after "Initialize"');
            end

            guidata(hObject, handles);
        end

        % Button pushed function: mvp1move
        function mvp1move_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            if (str2double(app.mvp1pos.Value)>8 || str2double(app.mvp1pos.Value)<1)
                msgbox('MVP position should be from 1 to 8!');
            else
                try
                    writeline(handles.MVPport, ['aLP0' app.mvp1pos.Value 'R']);
                catch
                    msgbox(['Error! Check the followings: ', '1. Please run the program after "Initialize"   ', ...
                        '2. Please check the MVP line is still connected']);
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
            if (str2double(app.mvp2pos.Value)>8 || str2double(app.mvp2pos.Value)<1)
                msgbox('MVP position should be from 1 to 8!');
            else
                try
                    app.mvp1pos.Value = '8';
                    writeline(handles.MVPport, 'aLP08R');
                    writeline(handles.MVPport, ['bLP0' app.mvp2pos.Value 'R']);
                catch
                    msgbox(['Error! Check the followings: ', '1. Please run the program after "Initialize"   ', ...
                        '2. Please check the MVP line is still connected']);
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
            if (str2double(app.mvp3pos.Value)>8 || str2double(app.mvp3pos.Value)<1)
                msgbox('MVP position should be from 1 to 8!');
            else
                try
                    app.mvp1pos.Value = '8';
                    app.mvp2pos.Value = '8';
                    writeline(handles.MVPport, 'aLP08R');
                    writeline(handles.MVPport, 'bLP08R');
                    writeline(handles.MVPport, ['cLP0' app.mvp3pos.Value 'R']);
                catch
                    msgbox(['Error! Check the followings: ', '1. Please run the program after "Initialize"   ', ...
                        '2. Please check the MVP line is still connected']);
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

        % Value changed function: portshutter
        function portshutter_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.Shutterport = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: pumptime1
        function pumptime1_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.PumpTime1 = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: pumptime2
        function pumptime2_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.PumpTime2 = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Value changed function: pumptime3
        function pumptime3_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.PumpTime3 = get(hObject, 'String');
            guidata(hObject, handles);
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
                    
                end
            end
        end

        % Value changed function: portlaser_2
        function portlaser_2_Callback(app, event)
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            handles.Laserport_2 = get(hObject, 'String');
            guidata(hObject, handles);
        end

        % Button pushed function: Runauto
        function RunautoButtonPushed(app, event)
            msgbox('Not implemented / Should be implemented');
        end

        % Value changed function: autonumbuf
        function autonumbufValueChanged(app, event)
            msgbox('Not implemented / Should be implemented');
        end

        % Value changed function: Switch
        function SwitchValueChanged(app, event)
            msgbox('Not implemented / Should be implemented');
        end

        % Button pushed function: pumptime1move
        function pumptime1moveButtonPushed(app, event)
            msgbox('Not implemented / Should be implemented');
        end

        % Button pushed function: pumptime2move
        function pumptime2moveButtonPushed(app, event)
            msgbox('Not implemented / Should be implemented');
        end

        % Button pushed function: pumptime3move
        function pumptime3moveButtonPushed(app, event)
            msgbox('Not implemented / Should be implemented');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create figure and hide until all components are created
            app.figure = uifigure('Visible', 'off');
            app.figure.Position = [680 635 498 614];
            app.figure.Name = 'Main';
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
            app.title.Text = 'Sequencial FISH control tablet';

            % Create uipanel1
            app.uipanel1 = uipanel(app.figure);
            app.uipanel1.Title = 'Connected ports';
            app.uipanel1.Tag = 'uipanel1';
            app.uipanel1.FontSize = 11;
            app.uipanel1.Position = [18 513 462 51];

            % Create text26
            app.text26 = uilabel(app.uipanel1);
            app.text26.Tag = 'text26';
            app.text26.HorizontalAlignment = 'center';
            app.text26.FontSize = 11;
            app.text26.Position = [369 9 54 21];
            app.text26.Text = 'Shutter';

            % Create text2
            app.text2 = uilabel(app.uipanel1);
            app.text2.Tag = 'text2';
            app.text2.HorizontalAlignment = 'center';
            app.text2.FontSize = 11;
            app.text2.Position = [2 9 54 21];
            app.text2.Text = 'MVP';

            % Create text17
            app.text17 = uilabel(app.uipanel1);
            app.text17.Tag = 'text17';
            app.text17.HorizontalAlignment = 'center';
            app.text17.FontSize = 11;
            app.text17.Position = [181 8 54 22];
            app.text17.Text = 'Laser #1';

            % Create text5
            app.text5 = uilabel(app.uipanel1);
            app.text5.Tag = 'text5';
            app.text5.HorizontalAlignment = 'center';
            app.text5.FontSize = 11;
            app.text5.Position = [94 9 54 21];
            app.text5.Text = 'Pump';

            % Create text17_2
            app.text17_2 = uilabel(app.uipanel1);
            app.text17_2.Tag = 'text17';
            app.text17_2.HorizontalAlignment = 'center';
            app.text17_2.FontSize = 11;
            app.text17_2.Position = [273 8 54 22];
            app.text17_2.Text = 'Laser #2';

            % Create portmvp
            app.portmvp = uieditfield(app.uipanel1, 'text');
            app.portmvp.ValueChangedFcn = createCallbackFcn(app, @portmvp_Callback, true);
            app.portmvp.Tag = 'portmvp';
            app.portmvp.HorizontalAlignment = 'center';
            app.portmvp.FontSize = 11;
            app.portmvp.Position = [43 6 38 23];
            app.portmvp.Value = '-';

            % Create portpump
            app.portpump = uieditfield(app.uipanel1, 'text');
            app.portpump.ValueChangedFcn = createCallbackFcn(app, @portpump_Callback, true);
            app.portpump.Tag = 'portpump';
            app.portpump.HorizontalAlignment = 'center';
            app.portpump.FontSize = 11;
            app.portpump.Position = [137 6 38 23];
            app.portpump.Value = '-';

            % Create portlaser_1
            app.portlaser_1 = uieditfield(app.uipanel1, 'text');
            app.portlaser_1.ValueChangedFcn = createCallbackFcn(app, @portlaser_1_Callback, true);
            app.portlaser_1.Tag = 'portlaser';
            app.portlaser_1.HorizontalAlignment = 'center';
            app.portlaser_1.FontSize = 11;
            app.portlaser_1.Position = [231 6 38 23];
            app.portlaser_1.Value = '-';

            % Create portlaser_2
            app.portlaser_2 = uieditfield(app.uipanel1, 'text');
            app.portlaser_2.ValueChangedFcn = createCallbackFcn(app, @portlaser_2_Callback, true);
            app.portlaser_2.Tag = 'portlaser';
            app.portlaser_2.HorizontalAlignment = 'center';
            app.portlaser_2.FontSize = 11;
            app.portlaser_2.Position = [324 6 38 23];
            app.portlaser_2.Value = '-';

            % Create portshutter
            app.portshutter = uieditfield(app.uipanel1, 'text');
            app.portshutter.ValueChangedFcn = createCallbackFcn(app, @portshutter_Callback, true);
            app.portshutter.Tag = 'portshutter';
            app.portshutter.HorizontalAlignment = 'center';
            app.portshutter.FontSize = 11;
            app.portshutter.Position = [417 6 38 23];
            app.portshutter.Value = '-';

            % Create initialize
            app.initialize = uibutton(app.figure, 'push');
            app.initialize.ButtonPushedFcn = createCallbackFcn(app, @initialize_Callback, true);
            app.initialize.Tag = 'initialize';
            app.initialize.FontSize = 11;
            app.initialize.Position = [83 472 102 35];
            app.initialize.Text = 'Initialize';

            % Create uibuttongroup8
            app.uibuttongroup8 = uibuttongroup(app.figure);
            app.uibuttongroup8.Title = 'Auto parameters';
            app.uibuttongroup8.Tag = 'uibuttongroup8';
            app.uibuttongroup8.FontSize = 11;
            app.uibuttongroup8.Position = [264 175 216 288];

            % Create ofbuffersEditFieldLabel
            app.ofbuffersEditFieldLabel = uilabel(app.uibuttongroup8);
            app.ofbuffersEditFieldLabel.HorizontalAlignment = 'right';
            app.ofbuffersEditFieldLabel.Position = [16 230 65 22];
            app.ofbuffersEditFieldLabel.Text = '# of buffers';

            % Create autonumbuf
            app.autonumbuf = uieditfield(app.uibuttongroup8, 'text');
            app.autonumbuf.ValueChangedFcn = createCallbackFcn(app, @autonumbufValueChanged, true);
            app.autonumbuf.HorizontalAlignment = 'center';
            app.autonumbuf.Position = [96 230 100 22];
            app.autonumbuf.Value = '16';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.uibuttongroup8);
            app.EditFieldLabel.HorizontalAlignment = 'right';
            app.EditFieldLabel.Position = [25 177 56 22];
            app.EditFieldLabel.Text = 'Edit Field';

            % Create EditField
            app.EditField = uieditfield(app.uibuttongroup8, 'text');
            app.EditField.Position = [96 177 100 22];

            % Create EditField2Label
            app.EditField2Label = uilabel(app.uibuttongroup8);
            app.EditField2Label.HorizontalAlignment = 'right';
            app.EditField2Label.Position = [19 124 62 22];
            app.EditField2Label.Text = 'Edit Field2';

            % Create EditField2
            app.EditField2 = uieditfield(app.uibuttongroup8, 'text');
            app.EditField2.Position = [96 124 100 22];

            % Create EditField3Label
            app.EditField3Label = uilabel(app.uibuttongroup8);
            app.EditField3Label.HorizontalAlignment = 'right';
            app.EditField3Label.Position = [19 71 62 22];
            app.EditField3Label.Text = 'Edit Field3';

            % Create EditField3
            app.EditField3 = uieditfield(app.uibuttongroup8, 'text');
            app.EditField3.Position = [96 71 100 22];

            % Create EditField4Label
            app.EditField4Label = uilabel(app.uibuttongroup8);
            app.EditField4Label.HorizontalAlignment = 'right';
            app.EditField4Label.Position = [19 18 62 22];
            app.EditField4Label.Text = 'Edit Field4';

            % Create EditField4
            app.EditField4 = uieditfield(app.uibuttongroup8, 'text');
            app.EditField4.Position = [96 18 100 22];

            % Create Runauto
            app.Runauto = uibutton(app.figure, 'push');
            app.Runauto.ButtonPushedFcn = createCallbackFcn(app, @RunautoButtonPushed, true);
            app.Runauto.Tag = 'Runauto';
            app.Runauto.FontSize = 11;
            app.Runauto.Position = [334 472 102 35];
            app.Runauto.Text = 'Run automatically';

            % Create uibuttongroup2
            app.uibuttongroup2 = uibuttongroup(app.figure);
            app.uibuttongroup2.Title = 'MVP #1';
            app.uibuttongroup2.Tag = 'uibuttongroup2';
            app.uibuttongroup2.FontSize = 11;
            app.uibuttongroup2.Position = [21 405 232 58];

            % Create mvp1pos
            app.mvp1pos = uieditfield(app.uibuttongroup2, 'text');
            app.mvp1pos.ValueChangedFcn = createCallbackFcn(app, @mvp1pos_Callback, true);
            app.mvp1pos.Tag = 'mvp1pos';
            app.mvp1pos.HorizontalAlignment = 'center';
            app.mvp1pos.FontSize = 11;
            app.mvp1pos.Position = [60 10 62 20];
            app.mvp1pos.Value = '1';

            % Create mvp1move
            app.mvp1move = uibutton(app.uibuttongroup2, 'push');
            app.mvp1move.ButtonPushedFcn = createCallbackFcn(app, @mvp1move_Callback, true);
            app.mvp1move.Tag = 'mvp1move';
            app.mvp1move.FontSize = 11;
            app.mvp1move.Position = [168 5 55 30];
            app.mvp1move.Text = 'Move';

            % Create text8
            app.text8 = uilabel(app.uibuttongroup2);
            app.text8.Tag = 'text8';
            app.text8.HorizontalAlignment = 'center';
            app.text8.VerticalAlignment = 'top';
            app.text8.FontSize = 11;
            app.text8.Position = [7 12 52 16];
            app.text8.Text = 'Position';

            % Create uibuttongroup4
            app.uibuttongroup4 = uibuttongroup(app.figure);
            app.uibuttongroup4.Title = 'MVP #2';
            app.uibuttongroup4.Tag = 'uibuttongroup4';
            app.uibuttongroup4.FontSize = 11;
            app.uibuttongroup4.Position = [21 328 232 58];

            % Create text12
            app.text12 = uilabel(app.uibuttongroup4);
            app.text12.Tag = 'text12';
            app.text12.HorizontalAlignment = 'center';
            app.text12.VerticalAlignment = 'top';
            app.text12.FontSize = 11;
            app.text12.Position = [5 13 52 16];
            app.text12.Text = 'Position';

            % Create mvp2pos
            app.mvp2pos = uieditfield(app.uibuttongroup4, 'text');
            app.mvp2pos.ValueChangedFcn = createCallbackFcn(app, @mvp2pos_Callback, true);
            app.mvp2pos.Tag = 'mvp2pos';
            app.mvp2pos.HorizontalAlignment = 'center';
            app.mvp2pos.FontSize = 11;
            app.mvp2pos.Position = [58 11 62 20];
            app.mvp2pos.Value = '1';

            % Create mvp2move
            app.mvp2move = uibutton(app.uibuttongroup4, 'push');
            app.mvp2move.ButtonPushedFcn = createCallbackFcn(app, @mvp2move_Callback, true);
            app.mvp2move.Tag = 'mvp2move';
            app.mvp2move.FontSize = 11;
            app.mvp2move.Position = [168 6 55 30];
            app.mvp2move.Text = 'Move';

            % Create uibuttongroup5
            app.uibuttongroup5 = uibuttongroup(app.figure);
            app.uibuttongroup5.Title = 'MVP #3';
            app.uibuttongroup5.Tag = 'uibuttongroup5';
            app.uibuttongroup5.FontSize = 11;
            app.uibuttongroup5.Position = [21 251 232 58];

            % Create mvp3pos
            app.mvp3pos = uieditfield(app.uibuttongroup5, 'text');
            app.mvp3pos.ValueChangedFcn = createCallbackFcn(app, @mvp3pos_Callback, true);
            app.mvp3pos.Tag = 'mvp3pos';
            app.mvp3pos.HorizontalAlignment = 'center';
            app.mvp3pos.FontSize = 11;
            app.mvp3pos.Position = [59 11 62 20];
            app.mvp3pos.Value = '1';

            % Create mvp3move
            app.mvp3move = uibutton(app.uibuttongroup5, 'push');
            app.mvp3move.ButtonPushedFcn = createCallbackFcn(app, @mvp3move_Callback, true);
            app.mvp3move.Tag = 'mvp3move';
            app.mvp3move.FontSize = 11;
            app.mvp3move.Position = [168 6 55 30];
            app.mvp3move.Text = 'Move';

            % Create text13
            app.text13 = uilabel(app.uibuttongroup5);
            app.text13.Tag = 'text13';
            app.text13.HorizontalAlignment = 'center';
            app.text13.VerticalAlignment = 'top';
            app.text13.FontSize = 11;
            app.text13.Position = [6 13 52 16];
            app.text13.Text = 'Position';

            % Create uibuttongroup6
            app.uibuttongroup6 = uibuttongroup(app.figure);
            app.uibuttongroup6.Title = 'Pump';
            app.uibuttongroup6.Tag = 'uibuttongroup6';
            app.uibuttongroup6.FontSize = 11;
            app.uibuttongroup6.Position = [21 16 232 150];

            % Create text14
            app.text14 = uilabel(app.uibuttongroup6);
            app.text14.Tag = 'text14';
            app.text14.HorizontalAlignment = 'center';
            app.text14.FontSize = 11;
            app.text14.Position = [9 97 61 18];
            app.text14.Text = 'Time #1 (s)';

            % Create text15
            app.text15 = uilabel(app.uibuttongroup6);
            app.text15.Tag = 'text15';
            app.text15.HorizontalAlignment = 'center';
            app.text15.FontSize = 11;
            app.text15.Position = [9 58 61 18];
            app.text15.Text = 'Time #2 (s)';

            % Create text16
            app.text16 = uilabel(app.uibuttongroup6);
            app.text16.Tag = 'text16';
            app.text16.HorizontalAlignment = 'center';
            app.text16.FontSize = 11;
            app.text16.Position = [9 20 61 18];
            app.text16.Text = 'Time #3 (s)';

            % Create pumptime1
            app.pumptime1 = uieditfield(app.uibuttongroup6, 'text');
            app.pumptime1.ValueChangedFcn = createCallbackFcn(app, @pumptime1_Callback, true);
            app.pumptime1.Tag = 'pumptime1';
            app.pumptime1.HorizontalAlignment = 'center';
            app.pumptime1.FontSize = 11;
            app.pumptime1.Position = [76 96 62 20];
            app.pumptime1.Value = '300';

            % Create pumptime1move
            app.pumptime1move = uibutton(app.uibuttongroup6, 'push');
            app.pumptime1move.ButtonPushedFcn = createCallbackFcn(app, @pumptime1moveButtonPushed, true);
            app.pumptime1move.Tag = 'pumptime1move';
            app.pumptime1move.FontSize = 11;
            app.pumptime1move.Position = [166 94 55 24];
            app.pumptime1move.Text = 'Move';

            % Create pumptime2
            app.pumptime2 = uieditfield(app.uibuttongroup6, 'text');
            app.pumptime2.ValueChangedFcn = createCallbackFcn(app, @pumptime2_Callback, true);
            app.pumptime2.Tag = 'pumptime2';
            app.pumptime2.HorizontalAlignment = 'center';
            app.pumptime2.FontSize = 11;
            app.pumptime2.Position = [76 56 62 22];
            app.pumptime2.Value = '300';

            % Create pumptime2move
            app.pumptime2move = uibutton(app.uibuttongroup6, 'push');
            app.pumptime2move.ButtonPushedFcn = createCallbackFcn(app, @pumptime2moveButtonPushed, true);
            app.pumptime2move.Tag = 'pumptime2move';
            app.pumptime2move.FontSize = 11;
            app.pumptime2move.Position = [166 55 55 24];
            app.pumptime2move.Text = 'Move';

            % Create pumptime3
            app.pumptime3 = uieditfield(app.uibuttongroup6, 'text');
            app.pumptime3.ValueChangedFcn = createCallbackFcn(app, @pumptime3_Callback, true);
            app.pumptime3.Tag = 'pumptime3';
            app.pumptime3.HorizontalAlignment = 'center';
            app.pumptime3.FontSize = 11;
            app.pumptime3.Position = [76 18 62 22];
            app.pumptime3.Value = '300';

            % Create pumptime3move
            app.pumptime3move = uibutton(app.uibuttongroup6, 'push');
            app.pumptime3move.ButtonPushedFcn = createCallbackFcn(app, @pumptime3moveButtonPushed, true);
            app.pumptime3move.Tag = 'pumptime3move';
            app.pumptime3move.FontSize = 11;
            app.pumptime3move.Position = [166 17 55 24];
            app.pumptime3move.Text = 'Move';

            % Create uibuttongroup7
            app.uibuttongroup7 = uibuttongroup(app.figure);
            app.uibuttongroup7.Title = 'Laser';
            app.uibuttongroup7.Tag = 'uibuttongroup7';
            app.uibuttongroup7.FontSize = 11;
            app.uibuttongroup7.Position = [264 16 216 150];

            % Create text18
            app.text18 = uilabel(app.uibuttongroup7);
            app.text18.Tag = 'text18';
            app.text18.HorizontalAlignment = 'center';
            app.text18.FontSize = 11;
            app.text18.Position = [34 29 64 15];
            app.text18.Text = 'Minimum: ';

            % Create text19
            app.text19 = uilabel(app.uibuttongroup7);
            app.text19.Tag = 'text19';
            app.text19.HorizontalAlignment = 'center';
            app.text19.FontSize = 11;
            app.text19.Position = [34 7 64 15];
            app.text19.Text = 'Maximum: ';

            % Create text22
            app.text22 = uilabel(app.uibuttongroup7);
            app.text22.Tag = 'text22';
            app.text22.HorizontalAlignment = 'center';
            app.text22.FontSize = 11;
            app.text22.Position = [145 29 35 15];
            app.text22.Text = 'mW';

            % Create text23
            app.text23 = uilabel(app.uibuttongroup7);
            app.text23.Tag = 'text23';
            app.text23.HorizontalAlignment = 'center';
            app.text23.FontSize = 11;
            app.text23.Position = [145 7 35 15];
            app.text23.Text = 'mW';

            % Create minpower
            app.minpower = uilabel(app.uibuttongroup7);
            app.minpower.Tag = 'minpower';
            app.minpower.HorizontalAlignment = 'center';
            app.minpower.FontSize = 11;
            app.minpower.Position = [95 29 53 15];
            app.minpower.Text = '-';

            % Create maxpower
            app.maxpower = uilabel(app.uibuttongroup7);
            app.maxpower.Tag = 'maxpower';
            app.maxpower.HorizontalAlignment = 'center';
            app.maxpower.FontSize = 11;
            app.maxpower.Position = [95 8 53 15];
            app.maxpower.Text = '-';

            % Create text24
            app.text24 = uilabel(app.uibuttongroup7);
            app.text24.Tag = 'text24';
            app.text24.HorizontalAlignment = 'center';
            app.text24.VerticalAlignment = 'top';
            app.text24.FontSize = 11;
            app.text24.Position = [27 81 53 15];
            app.text24.Text = 'Power';

            % Create text25
            app.text25 = uilabel(app.uibuttongroup7);
            app.text25.Tag = 'text25';
            app.text25.HorizontalAlignment = 'center';
            app.text25.VerticalAlignment = 'top';
            app.text25.FontSize = 11;
            app.text25.Position = [145 81 35 15];
            app.text25.Text = 'mW';

            % Create laserDropDown
            app.laserDropDown = uidropdown(app.uibuttongroup7);
            app.laserDropDown.Items = {'1', '2'};
            app.laserDropDown.ValueChangedFcn = createCallbackFcn(app, @laserDropDown_callback, true);
            app.laserDropDown.Position = [78 104 100 22];
            app.laserDropDown.Value = '1';

            % Create laserpower
            app.laserpower = uieditfield(app.uibuttongroup7, 'text');
            app.laserpower.ValueChangedFcn = createCallbackFcn(app, @laserpower_Callback, true);
            app.laserpower.Tag = 'laserpower';
            app.laserpower.HorizontalAlignment = 'center';
            app.laserpower.FontSize = 11;
            app.laserpower.Position = [82 80 66 17];
            app.laserpower.Value = '-';

            % Create lasermove
            app.lasermove = uibutton(app.uibuttongroup7, 'push');
            app.lasermove.ButtonPushedFcn = createCallbackFcn(app, @lasermove_Callback, true);
            app.lasermove.Tag = 'lasermove';
            app.lasermove.FontSize = 11;
            app.lasermove.Position = [64 50 79 23];
            app.lasermove.Text = 'Move';

            % Create Label
            app.Label = uilabel(app.uibuttongroup7);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [38 104 25 22];
            app.Label.Text = '#';

            % Create uibuttongroup9
            app.uibuttongroup9 = uibuttongroup(app.figure);
            app.uibuttongroup9.Title = 'Shutter';
            app.uibuttongroup9.Tag = 'uibuttongroup9';
            app.uibuttongroup9.FontSize = 11;
            app.uibuttongroup9.Position = [21 175 232 58];

            % Create Switch
            app.Switch = uiswitch(app.uibuttongroup9, 'slider');
            app.Switch.Items = {'Close', 'Open'};
            app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
            app.Switch.Position = [94 10 45 20];
            app.Switch.Value = 'Close';

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

