function varargout = analyseCalciumSignalsGUI(varargin)
% ANALYSECALCIUMGUI MATLAB code for analyseCalciumGUI.fig
%      ANALYSECALCIUMGUI, by itself, creates a new ANALYSECALCIUMGUI or raises the existing
%      singleton*.
%
%      H = ANALYSECALCIUMGUI returns the handle to a new ANALYSECALCIUMGUI or the handle to
%      the existing singleton*.
%
%      ANALYSECALCIUMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSECALCIUMGUI.M with the given input arguments.
%
%      ANALYSECALCIUMGUI('Property','Value',...) creates a new ANALYSECALCIUMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analyseCalciumGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to analyseCalciumGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analyseCalciumGUI

% Last Modified by GUIDE v2.5 29-May-2013 12:14:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analyseCalciumSignalsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @analyseCalciumSignalsGUI_OutputFcn, ...
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


% --- Executes just before analyseCalciumGUI is made visible.
function analyseCalciumSignalsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to analyseCalciumGUI (see VARARGIN)
handles.handleToCalciumGUI=hObject;
set(handles.handleToCalciumGUI,'Toolbar','figure')

handles.NCalciumSignal=varargin{1};

handles.JayPeg=varargin{2};

handles.FinalImage = varargin{3};






imagesc(handles.JayPeg);axis ij;                                            %displays the ROI overview Image in the axes of the GUI

try
    StackSlider(handles.FinalImage);                                                % opens the StackSlider
catch
    'StackSlider doesnt work restart matlab might help'
end

    % handles.table = figure('name','spikes','Position',[1000 100 700 900]);
    % cnames{1}='0';
    % cnames{2}='45';
    % cnames{3}='90';
    % cnames{4}='135';
    % cnames{5}='180';
    % cnames{6}='225';
    % cnames{7}='270';
    % cnames{8}='315';
    % t=uitable('Parent',handles.table,'ColumnName',cnames,'Data',[zeros(2,8);handles.spikes],'Position',[20 20 640 860]);
    % set(handles.table, 'HandleVisibility', 'off');
% set(hObject,'handlevisibility','off') %attempt to make the GUI unclosable
% Choose default command line output for analyseCalciumGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analyseCalciumGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = analyseCalciumSignalsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function neuron_Callback(hObject, eventdata, handles)
% hObject    handle to neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.neuron=str2num(get(hObject,'String'));

guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of neuron as text
%        str2double(get(hObject,'String')) returns contents of neuron as a double


% --- Executes during object creation, after setting all properties.
function neuron_CreateFcn(hObject, eventdata, handles)
% hObject    handle to neuron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.neuron>size(handles.NCalciumSignal,2)
    'number specified exceeds number of ROIs'
else    
    plotNeuronTraces(handles.neuron,handles.NCalciumSignal);
    
end






% --- Executes on key press with focus on neuron and none of its controls.
function neuron_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to neuron (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Key,'return');
    pushbutton1_Callback(hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.handleToCalciumGUI, 'HandleVisibility', 'off');
close all;
set(handles.handleToCalciumGUI, 'HandleVisibility', 'on');


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StackSlider(handles.FinalImage,'uint16');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.handleToCalciumGUI, 'HandleVisibility', 'off');
set(gcf,'Toolbar','figure','menubar','figure');
set(handles.handleToCalciumGUI, 'HandleVisibility', 'on');


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for fig=1:size(handles.figureNumbers,2)
    h=handles.figureNumbers(fig);
    filename=get(h,'name');
    set(h, 'Toolbar', 'figure','menubar','figure');
    if handles.figureFormat==2
        hgsave(h,filename);    
    else
        if handles.figureFormat==3
            format= '-dtiffn';
        else
            format= '-djpeg';
        end
        print(h,format,filename);
    end
    set(h, 'Toolbar', 'none','menubar','none');
end

%save figure

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject,'Value');
handles.figureFormatList=str;
handles.figureFormat=val; %as an integer 2:matlab figure 3:tif 4:jpeg
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.figureNumbers=str2num(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plotIndividualTraces(handles.neuron-2,handles.backgroundfiltered,handles.orientation,handles.initialFramesToDiscard,...
            handles.FramesPerOrientation,handles.framesDuringStim,handles.blackFramesBeforeStim,handles.orientationData);


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.orientation=str2num(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try 
    handles.FinalImage=openTifStack;
catch
    'tif stack couldnt be openend'
end
StackSlider(handles.FinalImage,'uint16');
guidata(hObject, handles);
