clc
addpath('../source/Cameras')

% Test initialising the camera and getting a frame
camera = Camera();
frame = camera.getNextFrame();
assert(isequal(size(frame),[2560,2160]));

% Test setting the area of interest
width = 100;
height = 8;
leftPosition = 10;
topPosition = 10;
camera.setAreaOfInterest(width,height,leftPosition,topPosition);
frame = camera.getNextFrame();
%assert(isequal(size(frame),[100,100]));

% Test setting the exposure time
time = 0.001;
camera.exposureTime = time;
assert(abs(camera.exposureTime-time) < 0.0001);
disp(camera.frameRate)
clc
disp(camera.temperatureControl)
camera.close();

%%

disp('Stopping acquisition...');
[rc] = AT_Command(camera.cameraHandle,'AcquisitionStop');
AT_CheckWarning(rc);
[rc] = AT_Flush(camera.cameraHandle);
AT_CheckWarning(rc);


[rc,index] = AT_GetEnumIndex(camera.cameraHandle,'Temperature Control ') 
[rc,count] = AT_GetEnumCount(camera.cameraHandle,'Temperature Control ')
[rc,control] = AT_GetEnumStringByIndex(camera.cameraHandle,'Temperature Control ',0,10)

[rc] = AT_SetEnumIndex(camera.cameraHandle,'Temperature Control ',1)
AT_CheckWarning(rc);


disp('Starting acquisition...');
[rc] = AT_Command(camera.cameraHandle,'AcquisitionStart');
AT_CheckWarning(rc);


%% Test setting the accumulation count
camera.exposureTime = 0.0001;
camera.numberOfAccumulations = 1000;
tic
frame = camera.getNextFrame();
toc
%%


% 
% tic
% for n=1:100
%     frame = camera.getNextFrame();
% %     fwrite(fileID,frame);
%     imagesc(frame,'CDataMapping','scaled');
%     drawnow
%     shg
% end

camera.close();

%%
tic
for n=1:1000
    frame = camera.getNextFrame();
%     fwrite(fileID,frame);
    imagesc(frame,'CDataMapping','scaled');
    drawnow
    shg
end
toc
camera.close();
% fclose(fileID);

%%

fileID = fopen('testCamera.txt','r');
A = fread(fileID,[2660,2160],'uint8');
imagesc(frame,'CDataMapping','scaled');

%% Test acquiring data at fast speed


camera = Camera();

%% Set AOI
width = 30;
height = 100;
leftPosition = 1;
topPosition = 1;
camera.setAreaOfInterest(width,height,leftPosition,topPosition);

%% Set binning
camera.verticalBinning = 1;
camera.horisontalBinning = 1;

%% Enable fast frame rate
camera.fastAOIFrameRateEnable = 1;
disp(camera.fastAOIFrameRateEnable)

%% Set exposure time
camera.exposureTime = 0.000028;
disp(camera.exposureTime)
disp(camera.frameRate)

%% Set number of accumulations
camera.numberOfAccumulations = 7000;

% Set electronic shuttering mode
camera.electronicShutteringMode = 'rolling';
disp(camera.electronicShutteringMode);

%% Test acquiring frames without saving the data
tic
for n=1:1
    frame = camera.getNextFrame();
end
t=toc;
disp(t)
disp('Number of frames per second: ')
disp(1/(t));



%% Test acquiring frames and saving the data
fileId = fopen('test_1.txt','w');

tic
for n=1:10
    frame = camera.getNextFrame();
    fprintf(fileId,'%f;',frame(:));
    fprintf(fileId,'\n');
end
t=toc
disp('Number of frames per second: ')
disp(1/(t));

fclose(fileId);







%% Close

camera.close();

%%
for n=1:1000
    frame = camera.getNextFrame();
end