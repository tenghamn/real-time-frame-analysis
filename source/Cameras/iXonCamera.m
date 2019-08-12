classdef iXonCamera<handle
    
    properties
        
        % Sensor properties
        sensorWidth
        sensorHeight
        sensorCoordinates
        
        % Image properties (read only)
        imageHeight
        imageWidth
        imageLeftPosition
        imageTopPosition
        imageSize
        imageStride
        imageMaxHeight
        imageMaxWidth
        
        
        % Image properties saved in obj for faster acquisition
        imageSizeFast
        imageHeightFast
        imageWidthFast
        imageStrideFast
        clockFrequencyFast
        
        % Camera properties (read only)
        isAcquiring
        sensorTemperature
        temperatureControl
        frameRate
        clockFrequency
        maxInterfaceTransferRate
        acquisitionProgress
        acquisitionTimings
        latency
        
        % Camera settings (read and set)
        numberOfAccumulations
        %         pixelReadoutRate
        %         overlapReadout
        %         spuriousNoiseFilter
        exposureTime
        %         cycleMode
        triggerMode
        %         simplePreAmpGainControl
        %         pixelEncoding
        %         fanSpeed
        %         electronicShutteringMode
        %         fastAOIFrameRateEnable
        %         metadataEnable
        %         metadataTimestampEnable
        horisontalBinning
        verticalBinning
        acquisitionMode
        cooler
        coolerMode
        readMode
        emGainMode
        emCCDGain
        numberOfAcquiredFrames
        
        
        % Camera info
        cameraInfo
    end
    
    properties(Constant)
        NAME = 'iXon';
        ALLOWED_COOLER_OPTIONS = {'On', 'Off'};
        ALLOWED_COOLER_MODES = {'Keep temperature','Return to ambient'};
        ALLOWED_ACQUISITION_MODES = {'Single Scan', 'Accumulate', 'Kinetics', 'Fast Kinetics', 'Run till abort'};
        ALLOWED_READ_MODES = {'Full Vertical Binning','Multi-Track','Random-Track','Single-Track','Image'};
        ALLOWED_EM_GAIN_MODES = {'DAC, range 0-255', 'DAC, range 0-4095','Linear mode','Real EM gain'};
        ALLOWED_TRIGGER_MODES = {'Internal','External','External Start','External Exposure', 'External FVB EM','Software Trigger','External Charge Shifting'};
    end
    
    methods
        function obj = iXonCamera()
            obj.stopAcquisition();
            obj.initialiseCamera();
            obj.setInitialCameraSettings();
        end
        
        function info = get.cameraInfo(obj)
            info = [
                compose('imageHeight:\t%d\n',obj.imageHeight),...
                compose('imageWidth:\t%d\n',obj.imageWidth),...
                compose('imageLeftPosition:\t%d\n',obj.imageLeftPosition),...
                compose('imageTopPosition:\t%d\n',obj.imageTopPosition),...
                compose('verticalBinning:\t%d\n',obj.verticalBinning),...
                compose('horisontalBinning:\t%d\n',obj.horisontalBinning),...
                compose('exposureTime:\t%f\n',obj.exposureTime),...
                compose('numberOfAccumulations:\t%d\n',obj.numberOfAccumulations),...
                compose('sensorTemperature:\t%d\n',obj.sensorTemperature),...
                compose('emGainMode:\t%s\n',obj.emGainMode),...
                compose('emCCDGain:\t%d\n',obj.emCCDGain),...
                compose('frameRate:\t%f\n',obj.frameRate),...
                ];
            info = [info{:}];
        end
        
        function width = get.sensorWidth(obj)
            width = obj.imageMaxWidth;
        end
        
        function height = get.sensorHeight(obj)
            height = obj.imageMaxHeight;
        end
        
        function coordinates = get.sensorCoordinates(obj)
            coordinates = [
               [1,1];
               [1+obj.sensorWidth,1];
               [1+obj.sensorWidth,1+obj.sensorHeight];
               [1,1+obj.sensorHeight]
               ];
        end
        
        function latency = get.latency(obj)
            latency = obj.acquisitionProgress.series - obj.numberOfAcquiredFrames;
        end
        
        function width = get.imageMaxWidth(obj)
            width = round(1024/obj.horisontalBinning);
        end
        
        function height = get.imageMaxHeight(obj)
            height = round(1024/obj.verticalBinning);
        end
        
        function resetAreaOfInterest(obj)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            [ret] = SetImage(1,1,1,1024, 1, 1024);
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.horisontalBinning = 1;
                obj.verticalBinning = 1;
                obj.imageLeftPosition = 1;
                obj.imageTopPosition = 1;
                obj.imageWidth = 1024;
                obj.imageHeight = 1024;
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function setAreaOfInterest(obj,verticalBinning,horisontalBinning,width,height,leftPosition,topPosition)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            [ret] = SetImage(verticalBinning,...
                horisontalBinning,...
                (obj.imageMaxHeight - topPosition - height + 1)*obj.verticalBinning + 1,...
                (obj.imageMaxHeight - topPosition+1)*obj.verticalBinning,...
                leftPosition*obj.horisontalBinning,...
                (leftPosition + width - 1)*obj.horisontalBinning);
            
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.imageWidth = round(width*obj.horisontalBinning/horisontalBinning);
                obj.imageHeight = round(height*obj.verticalBinning/verticalBinning);
                obj.horisontalBinning = horisontalBinning;
                obj.verticalBinning = verticalBinning;
                obj.imageLeftPosition = leftPosition;
                obj.imageTopPosition = topPosition;
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function [frame,time] = getNextFrame(obj)
            if isequal(obj.acquisitionMode,'Software trigger')
                [ret] = SendSoftwareTrigger();
                CheckWarning(ret);
            end
            frame = 0;
            if obj.latency > obj.numberOfAccumulations*2
                for n=1:obj.numberOfAccumulations
                    [ret, imageData] = GetOldestImage(obj.imageSizeFast);
                    CheckWarning(ret);
                    while ret ~= atmcd.DRV_SUCCESS
                        disp('in while');
                        [ret, frame] = GetOldestImage(obj.imageSizeFast);
                        CheckWarning(ret);
                    end
                    frame=frame + reshape(imageData, obj.imageWidthFast, obj.imageHeight);
                    obj.numberOfAcquiredFrames = obj.numberOfAcquiredFrames + 1;
                end
            else
                for n=1:obj.numberOfAccumulations
                    [ret] = WaitForAcquisition();
                    CheckWarning(ret);
                    [ret, imageData] = GetOldestImage(obj.imageSizeFast);
                    CheckWarning(ret);
                    while ret ~= atmcd.DRV_SUCCESS
                        disp('in while');
                        [ret, frame] = GetOldestImage(obj.imageSizeFast);
                        CheckWarning(ret);
                    end
                    frame=frame + reshape(imageData, obj.imageWidthFast, obj.imageHeight);
                    obj.numberOfAcquiredFrames = obj.numberOfAcquiredFrames + 1;
                end
            end
            [ret,~,time] = GetMetaDataInfo(obj.numberOfAcquiredFrames - 1);
            frame = rot90(frame',2);
            time = time*1e-3;
            CheckWarning(ret);
        end
        
        function startAcquisition(obj)
            obj.setPropertiesForFasterAcquisition();
            [ret]=SetShutter(1, 1, 0, 0);
            CheckWarning(ret);
            [ret] = StartAcquisition();
            CheckWarning(ret);
            obj.isAcquiring = true;
            obj.numberOfAcquiredFrames = 0;
        end
        
        function stopAcquisition(obj)
            disp('Stopping acquisition...');
            [ret]=AbortAcquisition;
            CheckWarning(ret);
            [ret]=SetShutter(1, 2, 1, 1);
            CheckWarning(ret);
            obj.isAcquiring = false;
        end
        
        function set.numberOfAccumulations(obj,nAccumulations)
            [ret] = SetNumberAccumulations(nAccumulations)
            CheckWarning(ret);
            obj.numberOfAccumulations = nAccumulations;
        end
        
        function progress = get.acquisitionProgress(obj)
            progress = {};
            [ret, progress.('accumulations'), progress.('series')] = GetAcquisitionProgress();
            CheckWarning(ret)
        end
        
        function temperature = get.sensorTemperature(obj)
            [ret, temperature] = GetTemperature();
            CheckWarning(ret);
        end
        
        function set.sensorTemperature(obj,temperature)
            [ret] = SetTemperature(temperature);
            CheckWarning(ret);
        end
        
        function set.cooler(obj,option)
            if isequal(option,obj.ALLOWED_COOLER_OPTIONS{1})
                disp('Starting Cooler');
                [ret]=CoolerON();
                CheckWarning(ret);
                obj.cooler = option;
            elseif isequal(option,obj.ALLOWED_COOLER_OPTIONS{2})
                disp('Turning off Cooler');
                [ret]=CoolerOFF();
                CheckWarning(ret);
                obj.cooler = option;
            end
        end
        
        function set.coolerMode(obj,mode)
            if isequal(mode,obj.ALLOWED_COOLER_MODES{1})
                [ret] = SetCoolerMode(1);
                CheckWarning(ret);
                obj.coolerMode = mode;
            elseif isequal(mode,obj.ALLOWED_COOLER_MODES{2})
                [ret] = SetCoolerMode(0);
                CheckWarning(ret);
                obj.coolerMode = mode;
            end
        end
        
        function set.acquisitionMode(obj,mode)
            if isequal(mode,obj.ALLOWED_ACQUISITION_MODES{1})
                [ret] = SetAcquisitionMode(1);
                CheckWarning(ret);
                obj.acquisitionMode = mode;
            elseif isequal(mode,obj.ALLOWED_ACQUISITION_MODES{2})
                [ret] = SetAcquisitionMode(2);
                CheckWarning(ret);
                obj.acquisitionMode = mode;
            elseif isequal(mode,obj.ALLOWED_ACQUISITION_MODES{3})
                [ret] = SetAcquisitionMode(3);
                CheckWarning(ret);
                obj.acquisitionMode = mode;
            elseif isequal(mode,obj.ALLOWED_ACQUISITION_MODES{4})
                [ret] = SetAcquisitionMode(4);
                CheckWarning(ret);
                obj.acquisitionMode = mode;
            elseif isequal(mode,obj.ALLOWED_ACQUISITION_MODES{5})
                [ret] = SetAcquisitionMode(5);
                CheckWarning(ret);
                obj.acquisitionMode = mode;
            end
        end
        
        function set.exposureTime(obj,time)
            [ret] = SetExposureTime(time);
            CheckWarning(ret);
        end
        
        function time = get.exposureTime(obj)
            time = obj.acquisitionTimings.exposureTime;
        end
        
        function rate = get.frameRate(obj)
            rate = 1/(obj.acquisitionTimings.kineticCycleTime * obj.numberOfAccumulations);
        end
        
        function timings = get.acquisitionTimings(obj)
            timings = {};
            [ret,timings.exposureTime,~,timings.kineticCycleTime] = GetAcquisitionTimings();
            CheckWarning(ret);
        end
        
        function set.readMode(obj,mode)
            if isequal(mode,obj.ALLOWED_READ_MODES{1})
                [ret] = SetReadMode(0);
                CheckWarning(ret);
                obj.readMode = mode;
            elseif isequal(mode,obj.ALLOWED_READ_MODES{2})
                [ret] = SetReadMode(1);
                CheckWarning(ret);
                obj.readMode = mode;
            elseif isequal(mode,obj.ALLOWED_READ_MODES{3})
                [ret] = SetReadMode(2);
                CheckWarning(ret);
                obj.readMode = mode;
            elseif isequal(mode,obj.ALLOWED_READ_MODES{4})
                [ret] = SetReadMode(3);
                CheckWarning(ret);
                obj.readMode = mode;
            elseif isequal(mode,obj.ALLOWED_READ_MODES{5})
                [ret] = SetReadMode(4);
                CheckWarning(ret);
                obj.readMode = mode;
            end
        end
        
        function set.emGainMode(obj,mode)
            if isequal(mode,obj.ALLOWED_EM_GAIN_MODES{1})
                [ret] = SetEMGainMode(0);
                CheckWarning(ret);
                obj.emGainMode = mode;
            elseif isequal(mode,obj.ALLOWED_EM_GAIN_MODES{2})
                [ret] = SetEMGainMode(1);
                CheckWarning(ret);
                obj.emGainMode = mode;
            elseif isequal(mode,obj.ALLOWED_EM_GAIN_MODES{3})
                [ret] = SetEMGainMode(2);
                CheckWarning(ret);
                obj.emGainMode = mode;
            elseif isequal(mode,obj.ALLOWED_EM_GAIN_MODES{4})
                [ret] = SetEMGainMode(3);
                CheckWarning(ret);
                obj.emGainMode = mode;
            end
        end
        
        function set.emCCDGain(obj,gain)
            [ret] = SetEMCCDGain(gain);
            CheckWarning(ret);
            obj.emCCDGain = gain;
        end
        
        function set.triggerMode(obj,mode)
            if isequal(mode,obj.ALLOWED_TRIGGER_MODES{1})
                [ret] = SetTriggerMode(0);
                CheckWarning(ret);
                obj.triggerMode = mode;
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{2})
                [ret] = SetTriggerMode(1);
                CheckWarning(ret);
                obj.triggerMode = mode;
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{3})
                [ret] = SetTriggerMode(6);
                CheckWarning(ret);
                obj.triggerMode = mode;
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{4})
                [ret] = SetTriggerMode(7);
                CheckWarning(ret);
                obj.triggerMode = mode;
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{5})
                [ret] = SetTriggerMode(9);
                CheckWarning(ret);
                obj.triggerMode = mode;
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{6})
                [ret] = SetTriggerMode(10);
                CheckWarning(ret);
                obj.triggerMode = mode;
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{7})
                [ret] = SetTriggerMode(12);
                CheckWarning(ret);
                obj.triggerMode = mode;
            end
        end
        
        function close(obj)
            obj.stopAcquisition();
            obj.cooler = 'Off';
            while obj.sensorTemperature <-20
                disp('Waiting for temperature to set')
                disp(['Temp:' num2str(obj.sensorTemperature) ' C'])
                pause(1);
            end
            [ret]=AndorShutDown;
            CheckWarning(ret);
            disp('Camera shutdown Complete');
        end
        
        function size = get.imageSize(obj)
            size = obj.imageHeight * obj.imageWidth;
        end
        
        function setPropertiesForFasterAcquisition(obj)
            obj.imageSizeFast = obj.imageSize;
            obj.imageHeightFast = obj.imageHeight;
            obj.imageWidthFast = obj.imageWidth;
        end
    end
    
    methods(Access=private)
        
        function initialiseCamera(obj)
            disp('Initialising Camera');
            ret=AndorInitialize('');
            CheckError(ret);
            disp('Camera initialized');
        end
        
        function setInitialCameraSettings(obj)
            obj.cooler = 'On';
            obj.coolerMode = 'Keep temperature';
            obj.sensorTemperature = -40;
            obj.acquisitionMode = 'Run till abort';
            obj.exposureTime = 0.1;
            obj.readMode = 'Image';
            obj.emGainMode = 'DAC, range 0-255';
            obj.emCCDGain = 2;
            obj.triggerMode = 'Internal';
            obj.numberOfAccumulations = 1;
            obj.verticalBinning = 1;
            obj.horisontalBinning = 1;
            obj.setAreaOfInterest(1,1,1024,1024,1,1);
            disp('Settings Done');
        end
        
    end
end

