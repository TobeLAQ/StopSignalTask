
function varargout = StopSignal_GUI(varargin)

% % ???????????????????
% filename = mfilename();
% % ??????????? ?pathstr????name????
% [pathstr,name,ext]= fileparts(filename);
% cd(pathstr);

% STOPSIGNAL_GUI MATLAB code for StopSignal_GUI.fig
%      STOPSIGNAL_GUI, by itself, creates a new STOPSIGNAL_GUI or raises the existing
%      singleton*.
%
%      H = STOPSIGNAL_GUI returns the handle to a new STOPSIGNAL_GUI or the handle to
%      the existing singleton*.
%
%      STOPSIGNAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STOPSIGNAL_GUI.M with the given input arguments.
%
%      STOPSIGNAL_GUI('Property','Value',...) creates a new STOPSIGNAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StopSignal_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StopSignal_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StopSignal_GUI

% Last Modified by GUIDE v2.5 08-Nov-2018 22:43:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StopSignal_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StopSignal_GUI_OutputFcn, ...
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


% --- Executes just before StopSignal_GUI is made visible.
function StopSignal_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StopSignal_GUI (see VARARGIN)

% Choose default command line output for StopSignal_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StopSignal_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StopSignal_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function group_code_Callback(hObject, eventdata, handles)
% hObject    handle to group_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of group_code as text
%        str2double(get(hObject,'String')) returns contents of group_code as a double


% --- Executes during object creation, after setting all properties.
function group_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function subject_code_Callback(hObject, eventdata, handles)
% hObject    handle to subject_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subject_code as text
%        str2double(get(hObject,'String')) returns contents of subject_code as a double


% --- Executes during object creation, after setting all properties.
function subject_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subject_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in subinform_confirm.
function subinform_confirm_Callback(hObject, eventdata, handles)
% hObject    handle to subinform_confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subject_code = str2double(get(handles.subject_code,'string'));
group_code = str2double(get(handles.group_code,'string'));
if size(group_code,2)==0 || group_code<=0 || isnan(group_code)==1
    msgbox('error in GROUP number');
    set(handles.group_code,'string',0);
end
if size(subject_code,2)==0 || subject_code<=0 || isnan(subject_code)==1
    msgbox('error in Subject number');
    set(handles.subject_code,'string',0);
end


% --- Executes on button press in subinform_clear.
function subinform_clear_Callback(hObject, eventdata, handles)
% hObject    handle to subinform_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.group_code,'string',0);
set(handles.subject_code,'string',0);

% --- Executes on button press in practice.
function practice_Callback(hObject, eventdata, handles)
% hObject    handle to practice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

group_code = str2double(get(handles.group_code,'string'));
subject_code = str2double(get(handles.subject_code,'string'));
set(handles.practice,'BackgroundColor','g');
%==========================%
stopsignal_prac(group_code, subject_code);
%==========================%


% --- Executes on button press in formal.
function formal_Callback(hObject, eventdata, handles)
% hObject    handle to formal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
group_code = str2double(get(handles.group_code,'string'));
subject_code = str2double(get(handles.subject_code,'string'));
set(handles.formal,'BackgroundColor','g');
%==========================%
stopsignal_formal(group_code, subject_code);
