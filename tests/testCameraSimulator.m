addpath('../source/Cameras')

AndorCameraSimulator = CameraSimulator();

frame = AndorCameraSimulator.getNextFrame();

image(frame,'CDataMapping','scaled')
%%
tic
for i=1:100
    image(AndorCameraSimulator.getNextFrame(),'CDataMapping','scaled');
    shg
    pause(0.01)
end
toc