%% Test acquiring data at fast speed
clc
addpath('../source/Cameras')

camera = ZylaCamera();

% Start acquisition
camera.startAcquisition();

% Change electronic shuttering mode
disp('Initial electronic shuttering mode')
disp(camera.electronicShutteringMode);
disp('Changing to global');
camera.electronicShutteringMode = 'Global';
disp(camera.electronicShutteringMode);
disp('Changing to rolling');
camera.electronicShutteringMode = 'Rolling';
disp(camera.electronicShutteringMode);

% Change exposure time
disp('Initial exposure time')
disp(camera.exposureTime);
disp('Changing to 0.1');
camera.exposureTime = 0.1;
disp(camera.exposureTime);

% Change cycle mode
disp('Initial cycle mode')
disp(camera.cycleMode);
disp('Changing to fixed')
camera.cycleMode = 'Fixed';
disp(camera.cycleMode);
disp('Changing to Continous')
camera.cycleMode = 'Continous';
disp(camera.cycleMode);

% Change pixel readout rate
disp('Initial pixel readout rate')
disp(camera.pixelReadoutRate);
disp('Changing to 100 MHz')
camera.pixelReadoutRate = '100 MHz';
disp(camera.pixelReadoutRate);
disp('Changing to 280 MHz')
camera.pixelReadoutRate = '280 MHz';
disp(camera.pixelReadoutRate);

% Change trigger mode
disp('Initial trigger mode')
disp(camera.triggerMode);
disp('Changing to Software')
camera.triggerMode = 'Software';
disp(camera.triggerMode);
disp('Changing to Internal')
camera.triggerMode = 'Internal';
disp(camera.triggerMode);

% Change overlap readout
disp('Initial overlap readout')
disp(camera.overlapReadout);
disp('Changing to false')
camera.overlapReadout = false;
disp(camera.overlapReadout);
disp('Changing to true')
camera.overlapReadout = true;
disp(camera.overlapReadout);

% Change spurious noise filter
disp('Initial spurious noise filter')
disp(camera.spuriousNoiseFilter);
disp('Changing to false')
camera.spuriousNoiseFilter = false;
disp(camera.spuriousNoiseFilter);
disp('Changing to true')
camera.spuriousNoiseFilter = true;
disp(camera.spuriousNoiseFilter);

% Change Simple Pre Amp Gain Control
disp('Initial SimplePreAmpGainControl')
disp(camera.simplePreAmpGainControl);
disp('Changing to 12-bit (low noise)')
camera.simplePreAmpGainControl = '12-bit (low noise)';
disp(camera.simplePreAmpGainControl);
disp('Changing to 12-bit (high well capacity)')
camera.simplePreAmpGainControl = '12-bit (high well capacity)';
disp(camera.simplePreAmpGainControl);
disp('Changing to 16-bit (low noise & high well capacity)')
camera.simplePreAmpGainControl = '16-bit (low noise & high well capacity)';
disp(camera.simplePreAmpGainControl);

% Change pixel encoding
disp('Initial pixel encoding')
disp(camera.pixelEncoding);
disp('Changing to Mono12')
camera.pixelEncoding = 'Mono12';
disp(camera.pixelEncoding);
disp('Changing to Mono12Packed')
camera.pixelEncoding = 'Mono12Packed';
disp(camera.pixelEncoding);
disp('Changing to Mono16')
camera.pixelEncoding = 'Mono16';
disp(camera.pixelEncoding);
disp('Changing to Mono32')
camera.pixelEncoding = 'Mono32';
disp(camera.pixelEncoding);

% Change fan speed
disp('Initial fan speed')
disp(camera.fanSpeed);
disp('Changing to On')
camera.fanSpeed = 'On';
disp(camera.fanSpeed);
disp('Changing to Off')
camera.fanSpeed = 'Off';
disp(camera.fanSpeed);

% Change Fast AOI Frame Rate
disp('Initial Fast AOI Frame Rate')
disp(camera.fastAOIFrameRateEnable);
disp('Changing to false')
camera.fastAOIFrameRateEnable = false;
disp(camera.fastAOIFrameRateEnable);
disp('Changing to true')
camera.fastAOIFrameRateEnable = true;
disp(camera.fastAOIFrameRateEnable);

% Change should enable metadata
disp('Initial enable metadata')
disp(camera.metadataEnable);
disp('Changing to false')
camera.metadataEnable = false;
disp(camera.metadataEnable);
disp('Changing to true')
camera.metadataEnable = true;
disp(camera.metadataEnable);

% Start acquisition
camera.stopAcquisition();
camera.numberOfAccumulations = 1;
camera.startAcquisition();
disp(camera.exposureTime)
disp(camera.frameRate)

%%
clc
camera = ZylaCamera();
camera.startAcquisition();
camera.setAreaOfInterest(8,8,1000,1000);
camera.numberOfAccumulations = 3000;
camera.exposureTime = 0.000028;
disp(camera.frameRate);
disp(camera.maxInterfaceTransferRate);
disp(camera.frameRate > camera.maxInterfaceTransferRate);
disp(camera.exposureTime*camera.numberOfAccumulations);
%
disp('running test');

%camera = ZylaCamera();

tic
for n=1:2
    [frame,time] = camera.getNextFrame();
end
t = toc
disp('Expected frame rate');
disp(camera.frameRate);
disp('Actual frame rate');
disp(camera.numberOfAccumulations/t);
disp('done');
camera.close();
%% Stop acquisition
camera.stopAcquisition();

camera.close();