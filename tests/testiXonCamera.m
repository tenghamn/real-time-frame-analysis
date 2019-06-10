clc, clear
addpath('../source/Cameras')

try
camera = iXonCamera();
catch
end
camera.acquisitionTimings.kineticCycleTime
camera.frameRate
%%

%camera.acquisitionMode = 'Accumulate';
camera.acquisitionMode = 'Run till abort';

camera.numberOfAccumulations = 10;
SetMetaData(1);
camera.startAcquisition();

figure
tic
for n=1:10
[frame,time]=camera.getNextFrame();
disp(camera.acquisitionProgress);
disp(time);
disp(toc)
imagesc(frame)
colorbar;
drawnow;
end
imagesc(frame)
colorbar;
drawnow;


imagesc(frame)
colorbar;
drawnow;
camera.stopAcquisition();

%camera.close();