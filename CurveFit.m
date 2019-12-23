function varargout = CurveFit(varargin)
% CURVEFIT MATLAB code for CurveFit.fig
%      CURVEFIT, by itself, creates a new CURVEFIT or raises the existing
%      singleton*.
%
%      H = CURVEFIT returns the handle to a new CURVEFIT or the handle to
%      the existing singleton*.
%
%      CURVEFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CURVEFIT.M with the given input arguments.
%
%      CURVEFIT('Property','Value',...) creates a new CURVEFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CurveFit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CurveFit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CurveFit

% Last Modified by GUIDE v2.5 23-Nov-2019 14:25:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CurveFit_OpeningFcn, ...
                   'gui_OutputFcn',  @CurveFit_OutputFcn, ...
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


% --- Executes just before CurveFit is made visible.
function CurveFit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CurveFit (see VARARGIN)

% Choose default command line output for CurveFit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CurveFit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CurveFit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Excel.
function Excel_Callback(hObject, eventdata, handles)
% hObject    handle to Excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Select and import a file from disk
[filename,path] = uigetfile('*.xlsx;*.xls;*.csv'); % get the data
if isequal(filename,0)
   disp('User did not select a file')
else
   disp(['User selected: ', fullfile(path, filename)])
end
filename = xlsread(fullfile(path, filename)); % put data into a variable
handles.filename = filename;
guidata(hObject, handles);



% --- Executes on button press in optimize_initiator.
function optimize_initiator_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_initiator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

x = handles.filename(:,1); % Get independent variable from imported data
y = handles.filename(:,2); % Get dependent variable from imported data

switch get(handles.optimization_type,'Value')
  case 1 % Linear
    best = polyfit(x,y,1); % Linear fit
    yfit = polyval(best,x); % Best fitted line
    
  case 2 % Polynomial
    degree = str2num(get(handles.variable1,'String')); % Get the degree of polynomial to be fitted
    best = polyfit(x,y,degree); % Poly fit
    yfit = polyval(best,x); % Best fitted line

  case 3 % Single Exponential
    con=randn(1,3); % Give random initial guess for the optimization
    fun = @(con)ssevalED(con,x,y); % Define a function that make reference to function ssevalED with proper inputs 
    options = optimset; % the optimization routine
                               
    best = fminsearch(fun,con,options); % Optimization output
    FitA = best(1);
    Fitalpha = best(2);
    Fitc = best(3);
    yfit = FitA*exp(Fitalpha.*x)+Fitc; % Calculate the optimaized exponential decay
      
  case 4 % Double Exponential
    con=randn(1,4); % Give random initial guess for the optimization
    fun = @(con)sseval1(con,x,y); % Define a function that make reference to function sseval1 with proper inputs
    options = optimset; % the optimization routine
    
    best = fminsearch(fun,con,options); % Optimization output
    FitA = best(1);
    Fitalpha = best(2);
    FitB = best(3);
    Fitbeta = best(4);
    yfit = FitA*exp(Fitalpha.*x)+FitB*exp(Fitbeta.*x); % Calculate the optimaized double exponential decay
      
  case 5 % Gaussian Distribution
    con=randn(1,2); % Give random initial guess for the optimization
    fun = @(con)sseval2(con,x,y); % Define a function that make reference to function sseval2 with proper inputs
    options = optimset; % the optimization routine
    
    best = fminsearch(fun,con,options); % Optimization output
    Fitsig = best(1);
    Fitmiu = best(2);
    yfit = exp(-(x-Fitmiu).^2./(2.*Fitsig.^2))./Fitsig./sqrt(2*pi); % Calculate the optimaized function
    
  case 6 % Optimization routine
    ystr = get(handles.edit1,'String'); % get the function string 
    num = str2num(get(handles.constant_number,'String')); % get the number of variables
    
    % get constants
    c1 = get(handles.variable1,'String');
    c2 = get(handles.variable2,'String');
    c3 = get(handles.variable3,'String');
    c4 = get(handles.variable4,'String');
    c5 = get(handles.variable5,'String');
    conVar = {c1;c2;c3;c4;c5}; % array of constant variables
    
    varStr = ''; % define the starting string for the loop
    for ijk = 1:num % loop through the constants and put them into a string
        varStr = [varStr,conVar{ijk},','];
    end
    
    str=['@(',varStr,'x',')',ystr]; % put the function and the constants into a string
    f = str2func(str); % convert the string to function
    
    con = zeros(1,5); % define empty constant starting value array
        con(1) = str2num(get(handles.startval1,'String')); % get constant 1 starting value
    if num > 1
        con(2) = str2num(get(handles.startval2,'String')); % get constant 2 starting value
    end
    if num > 2
        con(3) = str2num(get(handles.startval3,'String')); % get constant 3 starting value
    end
    if num > 3
        con(4) = str2num(get(handles.startval4,'String')); % get constant 4 starting value
    end 
    if num > 4
        con(5) = str2num(get(handles.startval5,'String')); % get constant 5 starting value
    end
    
    fun = @(con)ssevalGUI(num,con,x,f,y); % Define a function that make reference to function ssevalGUI with proper inputs
    options = optimset; % the optimization routine
    best = fminsearch(fun,con,options); % Optimization output
    
    % Calculate the optimaized function
    if num == 1
        yfit = f(best(1),x);
    elseif num == 2
        yfit = f(best(1),best(2),x);
    elseif num == 3
        yfit = f(best(1),best(2),best(3),x);
    elseif num == 4
        yfit = f(best(1),best(2),best(3),best(4),x);
    elseif num == 5
        yfit = f(best(1),best(2),best(3),best(4),best(5),x);
    end
    otherwise
end

Rsqrt = 1-sum((y-yfit).^2)/sum((y-mean(y)).^2); % calculate the r-sqrt value
set(handles.display_error,'String',num2str(Rsqrt)); % output r-sqrt
set(handles.funOutput,'String',num2str(best)); % output the fitted constants
plot(handles.data_plot,x,y,'Marker','+','LineStyle','none','Color',[0.85,0.65,0.12]) % Plot noisy data
hold on
plot(handles.data_plot,x,yfit,'LineWidth',1); % Plot the fitted line
legend('Data with noise','Best fitted line') % Create legend
xlabel('X [Arb. Units]','fontsize',13) % Create x axis label
ylabel('Y [Arb. Units]','fontsize',13) % Create y axis label
hold off




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initial_x_Callback(hObject, eventdata, handles)
% hObject    handle to initial_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initial_x as text
%        str2double(get(hObject,'String')) returns contents of initial_x as a double


% --- Executes during object creation, after setting all properties.
function initial_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initial_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function final_x_Callback(hObject, eventdata, handles)
% hObject    handle to final_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of final_x as text
%        str2double(get(hObject,'String')) returns contents of final_x as a double


% --- Executes during object creation, after setting all properties.
function final_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to final_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in optimization_type.
function optimization_type_Callback(hObject, eventdata, handles)
% hObject    handle to optimization_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(handles.optimization_type,'Value')
    case 1 % Linear
        set(handles.edit1,'visible','on');
        set(handles.edit1,'String','y = ax+b, constants: a,b'); % output the funtion form on the interface
        % make other elements invisible 
        set(handles.constant_number,'visible','off');
        set(handles.variable1,'visible','off');
        set(handles.startval1,'visible','off');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    case 2 % polynomial 
        set(handles.variable1,'visible','on');
        set(handles.variable1,'String','Degree of Polynomial'); % ask for degree of polynomial
        set(handles.edit1,'visible','on');
        set(handles.edit1,'String','y = ax^n+bx^(n-1)+...+z, constants: a,b,...,z'); % output the funtion form on the interface
        % make other elements invisible
        set(handles.constant_number,'visible','off');
        set(handles.startval1,'visible','off');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    case 3 % Single exponential
        set(handles.edit1,'visible','on');
        set(handles.edit1,'String','y = a*exp(b*x)+c, constants: a,b,c'); % output the funtion form on the interface
        % make other elements invisible
        set(handles.constant_number,'visible','off');
        set(handles.variable1,'visible','off');
        set(handles.startval1,'visible','off');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    case 4 % Double exponential
        set(handles.edit1,'visible','on');
        set(handles.edit1,'String','y = a*exp(b*x)+c*exp(d*x), constants: a,b,c,d'); % output the funtion form on the interface
        % make other elements invisible
        set(handles.constant_number,'visible','off');
        set(handles.variable1,'visible','off');
        set(handles.startval1,'visible','off');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    case 5 % Gaussian distribution
        set(handles.edit1,'visible','on');
        set(handles.edit1,'String','y = exp[-(x-miu)^2/(2*sig^2)]/[sig*sqrt(2*pi)], constants: miu,sig'); % output the funtion form on the interface
        % make other elements invisible
        set(handles.constant_number,'visible','off');
        set(handles.variable1,'visible','off');
        set(handles.startval1,'visible','off');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    case 6
        set(handles.edit1,'visible','on');
        set(handles.constant_number,'visible','on');
        set(handles.variable1,'visible','off');
        set(handles.variable1,'String','Variable 1');
        set(handles.startval1,'visible','off');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    otherwise
end

% Hints: contents = cellstr(get(hObject,'String')) returns optimization_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from optimization_type


% --- Executes during object creation, after setting all properties.
function optimization_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimization_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function variable1_Callback(hObject, eventdata, handles)
% hObject    handle to variable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variable1 as text
%        str2double(get(hObject,'String')) returns contents of variable1 as a double


% --- Executes during object creation, after setting all properties.
function variable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function constant_number_Callback(hObject, eventdata, handles)
% hObject    handle to constant_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(handles.constant_number,'String')
    case '1'
        set(handles.variable1,'visible','on');
        set(handles.startval1,'visible','on');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
        set(handles.variable2,'visible','off');
        set(handles.startval2,'visible','off');
    case '2'
        set(handles.variable1,'visible','on');
        set(handles.startval1,'visible','on');
        set(handles.variable2,'visible','on');
        set(handles.startval2,'visible','on');
        set(handles.variable3,'visible','off');
        set(handles.startval3,'visible','off');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
    case '3'
        set(handles.variable1,'visible','on');
        set(handles.startval1,'visible','on');
        set(handles.variable2,'visible','on');
        set(handles.startval2,'visible','on');
        set(handles.variable3,'visible','on');
        set(handles.startval3,'visible','on');
        set(handles.variable4,'visible','off');
        set(handles.startval4,'visible','off');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
    case '4'
        set(handles.variable1,'visible','on');
        set(handles.startval1,'visible','on');
        set(handles.variable2,'visible','on');
        set(handles.startval2,'visible','on');
        set(handles.variable3,'visible','on');
        set(handles.startval3,'visible','on');
        set(handles.variable4,'visible','on');
        set(handles.startval4,'visible','on');
        set(handles.variable5,'visible','off');
        set(handles.startval5,'visible','off');
    case '5'
        set(handles.variable1,'visible','on');
        set(handles.startval1,'visible','on');
        set(handles.variable2,'visible','on');
        set(handles.startval2,'visible','on');
        set(handles.variable3,'visible','on');
        set(handles.startval3,'visible','on');
        set(handles.variable4,'visible','on');
        set(handles.startval4,'visible','on');
        set(handles.variable5,'visible','on');
        set(handles.startval5,'visible','on');
    otherwise
end

% Hints: get(hObject,'String') returns contents of constant_number as text
%        str2double(get(hObject,'String')) returns contents of constant_number as a double


% --- Executes during object creation, after setting all properties.
function constant_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constant_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startval1_Callback(hObject, eventdata, handles)
% hObject    handle to startval1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startval1 as text
%        str2double(get(hObject,'String')) returns contents of startval1 as a double


% --- Executes during object creation, after setting all properties.
function startval1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startval1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function variable2_Callback(hObject, eventdata, handles)
% hObject    handle to variable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variable2 as text
%        str2double(get(hObject,'String')) returns contents of variable2 as a double


% --- Executes during object creation, after setting all properties.
function variable2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function variable3_Callback(hObject, eventdata, handles)
% hObject    handle to variable3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variable3 as text
%        str2double(get(hObject,'String')) returns contents of variable3 as a double


% --- Executes during object creation, after setting all properties.
function variable3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variable3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function variable4_Callback(hObject, eventdata, handles)
% hObject    handle to variable4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variable4 as text
%        str2double(get(hObject,'String')) returns contents of variable4 as a double


% --- Executes during object creation, after setting all properties.
function variable4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variable4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function variable5_Callback(hObject, eventdata, handles)
% hObject    handle to variable5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variable5 as text
%        str2double(get(hObject,'String')) returns contents of variable5 as a double


% --- Executes during object creation, after setting all properties.
function variable5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variable5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startval2_Callback(hObject, eventdata, handles)
% hObject    handle to startval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startval2 as text
%        str2double(get(hObject,'String')) returns contents of startval2 as a double


% --- Executes during object creation, after setting all properties.
function startval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startval3_Callback(hObject, eventdata, handles)
% hObject    handle to startval3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startval3 as text
%        str2double(get(hObject,'String')) returns contents of startval3 as a double


% --- Executes during object creation, after setting all properties.
function startval3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startval3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startval4_Callback(hObject, eventdata, handles)
% hObject    handle to startval4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startval4 as text
%        str2double(get(hObject,'String')) returns contents of startval4 as a double


% --- Executes during object creation, after setting all properties.
function startval4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startval4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startval5_Callback(hObject, eventdata, handles)
% hObject    handle to startval5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startval5 as text
%        str2double(get(hObject,'String')) returns contents of startval5 as a double


% --- Executes during object creation, after setting all properties.
function startval5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startval5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
