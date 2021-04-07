function varargout = Test(varargin)
% Test MATLAB code for Test.fig
%      Test, by itself, creates a new Test or raises the existing
%      singleton*.
%
%      H = Test returns the handle to a new Test or the handle to
%      the existing singleton*.
%
%      Test('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Test.M with the given input arguments.
%
%      Test('Property','Value',...) creates a new Test or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test

% Last Modified by GUIDE v2.5 07-Apr-2021 13:24:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Test is made visible.
function Test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test (see VARARGIN)

% Choose default command line output for Test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function portmvp_Callback(hObject, eventdata, handles)
% hObject    handle to portmvp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MVPport = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function portmvp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portmvp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.MVPport = get(hObject, 'String');
guidata(hObject, handles);


function portpump_Callback(hObject, eventdata, handles)
% hObject    handle to portpump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Pumpport = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function portpump_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portpump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Pumpport = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes on button press in initialize.
function initialize_Callback(hObject, eventdata, handles)
% hObject    handle to initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

slCharacterEncoding('utf-8');

% init MVP devices
if handles.MVPport ~= '-'
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
end

% init Pump
% - Must be modified!!!!
if handles.Pumpport ~= '-'
    s2 = serialport(['COM' handles.Pumpport],9600);
    
    handles.Pumpport = s2;
end

% init Laser
if handles.Laserport ~= '-'
    s3 = serialport(['COM' handles.Laserport],9600);
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
    
    handles.Laserport = s3;
end

% % init shutter
if handles.Shutterport ~= '-'
    s4 = serialport(['COM' handles.Shutterport],9600);
    
    handles.Shutterport = s4;
end
guidata(hObject, handles);



% --------------------------------------------------------------------
function uibuttongroup2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in mvp1move.
function mvp1move_Callback(hObject, eventdata, handles)
% hObject    handle to mvp1move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

writeline(handles.MVPport, ['aLP0' handles.MVP1pos 'R']);



function pumptime1_Callback(hObject, eventdata, handles)
% hObject    handle to pumptime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PumpTime1 = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pumptime1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumptime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.PumpTime1 = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes on button press in pumptime1move.
function pumptime1move_Callback(hObject, eventdata, handles)
% hObject    handle to pumptime1move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on button press in pumptime2move.
function pumptime2move_Callback(hObject, eventdata, handles)
% hObject    handle to pumptime2move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pumptime3move.
function pumptime3move_Callback(hObject, eventdata, handles)
% hObject    handle to pumptime3move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pumptime2_Callback(hObject, eventdata, handles)
% hObject    handle to pumptime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PumpTime2 = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pumptime2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumptime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.PumpTime2 = get(hObject, 'String');
guidata(hObject, handles);



function pumptime3_Callback(hObject, eventdata, handles)
% hObject    handle to pumptime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.PumpTime3 = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pumptime3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumptime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.PumpTime3 = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes on button press in mvp3move.
function mvp3move_Callback(hObject, eventdata, handles)
% hObject    handle to mvp3move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
writeline(handles.MVPport, 'aLP08R');
writeline(handles.MVPport, 'bLP08R');
writeline(handles.MVPport, ['cLP0' handles.MVP3pos 'R']);



function mvp3pos_Callback(hObject, eventdata, handles)
% hObject    handle to mvp3pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.MVP3pos = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function mvp3pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mvp3pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.MVP3pos = get(hObject, 'String');
guidata(hObject, handles);



function mvp2pos_Callback(hObject, eventdata, handles)
% hObject    handle to mvp2pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MVP2pos = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function mvp2pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mvp2pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.MVP2pos = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes on button press in mvp2move.
function mvp2move_Callback(hObject, eventdata, handles)
% hObject    handle to mvp2move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
writeline(handles.MVPport, 'aLP08R');
writeline(handles.MVPport, ['bLP0' handles.MVP2pos 'R']);



function mvp1pos_Callback(hObject, eventdata, handles)
% hObject    handle to mvp1pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MVP1pos = get(hObject, 'String');
guidata(hObject, handles);



function portlaser_Callback(hObject, eventdata, handles)
% hObject    handle to portlaser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Laserport = get(hObject, 'String');
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function portlaser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portlaser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Laserport = get(hObject, 'String');
guidata(hObject, handles);




function laserpower_Callback(hObject, eventdata, handles)
% hObject    handle to laserpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LaserPower = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function laserpower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserpower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.LaserPower = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes on button press in lasermove.
function lasermove_Callback(hObject, eventdata, handles)
% hObject    handle to lasermove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if LaserPower ~= '-'
    writeline(handles.Laserport,...
        ['SOURce:POWer:LEVel:IMMediate:AMPLitude ' sprintf('%f',str2double(handles.LaserPower)*0.001)]);
    pause(1);
end
% change laser power to the value same with laserpower (LaserPower)


% --- Executes on button press in Runauto.
function Runauto_Callback(hObject, eventdata, handles)
% hObject    handle to Runauto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function portshutter_Callback(hObject, eventdata, handles)
% hObject    handle to portshutter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Shutterport = get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function portshutter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portshutter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.Shutterport = get(hObject, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function mvp1pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mvp1pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.MVP1pos = get(hObject, 'String');
guidata(hObject, handles);
