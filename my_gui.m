function varargout = my_gui(varargin)
% MY_GUI MATLAB code for my_gui.fig
%      MY_GUI, by itself, creates a new MY_GUI or raises the existing
%      singleton*.
%
%      H = MY_GUI returns the handle to a new MY_GUI or the handle to
%      the existing singleton*.
%
%      MY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MY_GUI.M with the given input arguments.
%
%      MY_GUI('Property','Value',...) creates a new MY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before my_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to my_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help my_gui

% Last Modified by GUIDE v2.5 06-Jun-2018 21:25:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @my_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @my_gui_OutputFcn, ...
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


% --- Executes just before my_gui is made visible.开始执行的函数
function my_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to my_gui (see VARARGIN)

% Choose default command line output for my_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);



% UIWAIT makes my_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = my_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.加载细胞信息的按钮
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=...
    uigetfile({'*.jpg';'*.bmp';'*.gif'},'选择图片');
str=[pathname,filename];
I=imread(str);
I=im2double(I);
%%%%%%%%%%%%%%%%%%%%%中值去噪
[m,n,~]=size(I);
for i=1:m
     for j=1:n
          for ind=1:3
                imax=min(i+1,m);
                jmax=min(j+1,n);
                imin=max(i-1,1);
                jmin=max(j-1,1);
                J(i,j,ind)=median([I(i,jmax,ind),I(imax,j,ind),I(imax,jmax,ind),I(imax,jmin,ind),I(imin,jmax,ind),I(i,jmin,ind),I(imin,j,ind),I(imin,jmin,ind)]);
          end
     end
 end
 
%%%%%%%%%%%%%%%%%%ostu值分割,BW为分割后的图像
for i=1:m
    for j=1:n
        J1(i,j)=max([J(i,j,1),J(i,j,2),J(i,j,3)]);
    end
end
g0=0;
T0=ostu(J1);%大津法
Jmax=max(J1(:));
Jmin=min(J1(:));
%T0=0.3471;
BW = im2bw(J1,T0);
BW=imfill(BW,'holes');
%figure(2);
%imshow(BW);
%%%%%%%%%%%%%%%%进行开运算;
se=strel('disk', 7);
bw=imopen(BW,se);
%figure(3);
%imshow(bw);
%%%%%%%%%%%%%%%%%%距离变换;
D = -bwdist(~bw);
%figure(4);
%imshow(D,[]);
%%%%%%%%%%%%%%%%%%水坝变换;
Ld = watershed(D);
%figure(5);
%imshow(label2rgb(Ld));

%
mask = imextendedmin(D,2);
%figure(6);
%imshowpair(bw,mask,'blend');

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw4 = bw;
bw4(Ld2 == 0) = 0;
%figure(7);
%imshow(bw4);

%%%%%%%%%%%%%%%抑制边界对象
bw5=imclearborder(bw4,4);
%figure(8);
%imshow(bw5);

[L,num] = bwlabel(bw5,4);

%figure(9);
%imshow(L);

B=bwboundaries(bw5,4);
cell_Area=[1:num;zeros(1,num)]';
%%%%%%计算每个细胞的面积
for i=1:m
    for j=1:n
        if L(i,j)>0
            cell_Area(L(i,j),2)=cell_Area(L(i,j),2)+1;
        end
    end
end
    
%%%%%%绘制每个细胞的边界
for i=1:num
      for j=1:size(B{i}(:,1),1)
        I(B{i}(j,1),B{i}(j,2),:)=1;
      end
end
%figure(10);
axes(handles.axes10);
imshow(I);

cell_L=[];

%%%%%%%%对每个小细胞进行编号，并获得每个细胞的周长
for i=1:num
    ix=round(0.5*(max(B{i}(:,1))+min(B{i}(:,1))));
    iy=round(0.5*(max(B{i}(:,2))+min(B{i}(:,2))));
    cell_L=[cell_L;L(ix,iy),size(B{i}(:,1),1)];
    Text=string(L(ix,iy));
    text(iy,ix,Text,'horiz','center','color','white','fontsize',15);
end

numnow=9;
handles.numnow = numnow;
guidata(hObject, handles);

handles.num = num;
guidata(hObject, handles);

handles.cell_L = cell_L;
guidata(hObject, handles);

handles.cell_Area = cell_Area;
guidata(hObject, handles);
%%%%%%%%获得每个小细胞的图片
for i=1:num
    for x=min(B{i}(:,1)):max(B{i}(:,1))
        for y=min(B{i}(:,2)):max(B{i}(:,2))
            cell{i}(x-min(B{i}(:,1))+1,y-min(B{i}(:,2))+1,:)=(L(x,y)==i)*I(x,y,:);
        end
    end
end
for i=1:num
    cell{i}(cell{i}==0)=1;
end

handles.cell=cell;
guidata(hObject, handles);
L=mean(cell_L(:,2));
AREA=mean(cell_Area(:,2));
c=['颗粒物个数为：',num2str(num),' 平均周长为：',num2str(roundn(L,-2)),' 平均面积为：',num2str(roundn(AREA,-2))];
set(handles.text10,'string',c);

for i=1:9
    str=['no.',num2str(i),'   周长：',num2str(cell_L(i,2)),'  面积为：',num2str(cell_Area(i,2))];
    eval(['set(handles.text',num2str(mod(i,9)),',','''','string','''',',str);']);
    eval(['axes(handles.axes',num2str(mod(i,9)),')',';']);
    eval(['imshow(cell{',num2str(i),'});']);
end
a=ceil(num/9);
handles.a=a;
guidata(hObject, handles);
c=['第 1/',num2str(a),'页'];
set(handles.text15,'string',c);






% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes on button press in togglebutton1.翻到上一页的按钮
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cell_L=handles.cell_L;
cell_Area=handles.cell_Area;
m=handles.a;
for i=1:9
    str=' ';
    eval(['set(handles.text',num2str(mod(i,9)),',','''','string','''',',str);']);
    eval(['axes(handles.axes',num2str(mod(i,9)),')',';']);
    cla reset;
end
cell=handles.cell;
numnow=handles.numnow;
if numnow>9
    numnow=numnow-9;
    handles.numnow=numnow;
    guidata(hObject, handles);
else
    numnow=9;
end
c=['第',num2str(round(numnow/9)),'/',num2str(m),'页'];
set(handles.text15,'string',c);

for i=numnow-8:numnow
    str=['no.',num2str(i),'   周长：',num2str(cell_L(i,2)),'  面积为：',num2str(cell_Area(i,2))];
    eval(['set(handles.text',num2str(mod(i,9)),',','''','string','''',',str);']);
    eval(['axes(handles.axes',num2str(mod(i,9)),')',';']);
    eval(['imshow(cell{',num2str(i),'});']);
end


% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cell_L=handles.cell_L;
cell_Area=handles.cell_Area;
m=handles.a;
for i=1:9
    str=' ';
    eval(['set(handles.text',num2str(mod(i,9)),',','''','string','''',',str);']);
    eval(['axes(handles.axes',num2str(mod(i,9)),')',';']);
    cla reset;
end
    
    
cell=handles.cell;
numnow=handles.numnow;
num=handles.num;
if numnow+9<=num
    numnow=numnow+9;
    handles.numnow=numnow;
    guidata(hObject, handles);
    a=numnow;
    b=a-8;
elseif numnow+9>num&&numnow<num
    b=numnow+1;
    numnow=numnow+9;
    handles.numnow=numnow;
    guidata(hObject, handles);
    a=num;
else
    b=numnow-8;
    a=num;
end
c=['第',num2str(round(numnow/9)),'/',num2str(m),'页'];
set(handles.text15,'string',c);
for i=b:a
    str=['no.',num2str(i),'   周长：',num2str(cell_L(i,2)),'  面积为：',num2str(cell_Area(i,2))];
    eval(['set(handles.text',num2str(mod(i,9)),',','''','string','''',',str);']);
    eval(['axes(handles.axes',num2str(mod(i,9)),')',';']);
    eval(['imshow(cell{',num2str(i),'});']);
end

% Hint: get(hObject,'Value') returns toggle state of togglebutton2


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --------------------------------------------------------------------
function uipanel1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4


% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes5



function edit0_Callback(hObject, eventdata, handles)
% hObject    handle to edit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit0 as text
%        str2double(get(hObject,'String')) returns contents of edit0 as a double


% --- Executes during object creation, after setting all properties.
function edit0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
