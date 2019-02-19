function varargout = MEMTEST_GUI(varargin)
% MEMTEST_GUI MATLAB code for MEMTEST_GUI.fig
%      MEMTEST_GUI, by itself, creates a new MEMTEST_GUI or raises the existing
%      singleton*.
%
%      H = MEMTEST_GUI returns the handle to a new MEMTEST_GUI or the handle to
%      the existing singleton*.
%
%      MEMTEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEMTEST_GUI.M with the given input arguments.
%
%      MEMTEST_GUI('Property','Value',...) creates a new MEMTEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MEMTEST_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MEMTEST_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MEMTEST_GUI

% Last Modified by GUIDE v2.5 08-Nov-2018 23:09:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MEMTEST_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MEMTEST_GUI_OutputFcn, ...
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


% --- Executes just before MEMTEST_GUI is made visible.
function MEMTEST_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MEMTEST_GUI (see VARARGIN)

% Choose default command line output for MEMTEST_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MEMTEST_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MEMTEST_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in F2C.
function F2C_Callback(hObject, eventdata, handles)
% hObject    handle to F2C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
group_code = str2double(get(handles.group_code,'string'));
subject_code = str2double(get(handles.subject_code,'string'));
set(handles.F2C,'BackgroundColor','g');
%==========================%
F2C(group_code, subject_code);



% --- Executes on button press in SPST.
function SPST_Callback(hObject, eventdata, handles)
% hObject    handle to SPST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
group_code = str2double(get(handles.group_code,'string'));
subject_code = str2double(get(handles.subject_code,'string'));
set(handles.SPST,'BackgroundColor','g');
%==========================%
SPST(group_code, subject_code);


% --- Executes on button press in RK.
function RK_Callback(hObject, eventdata, handles)
% hObject    handle to RK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
group_code = str2double(get(handles.group_code,'string'));
subject_code = str2double(get(handles.subject_code,'string'));
set(handles.RK,'BackgroundColor','g');
%==========================%
RK(group_code, subject_code);
