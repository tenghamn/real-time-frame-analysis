classdef Camera<handle
    %CAMERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cameraHandle
        
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
        
        % Camera settings
        numberOfAccumulations
        pixelReadoutRate
        overlapReadout
        spuriousNoiseFilter
        exposureTime
        cycleMode
        triggerMode
        simplePreAmpGainControl
        pixelEncoding
        fanSpeed
        electronicShutteringMode
        fastAOIFrameRateEnable
        metadataEnable
        metadataTimestampEnable
        horisontalBinning
        verticalBinning
        
        % Camera info
        cameraInfo
    end
    
    methods
        function obj = Camera()
            obj.initialiseCamera();
            obj.setInitialCameraSettings();
            obj.startAcquisition();
        end
        
        function temperature = get.sensorTemperature(obj)
            [rc,temperature] = AT_GetFloat(obj.cameraHandle,'SensorTemperature');
            AT_CheckWarning(rc);
        end
        
        function set.fanSpeed(obj,mode)
            if isequal(mode,'on')
                [rc] = AT_SetEnumIndex(obj.cameraHandle,'Fan Speed',1);
            elseif isequal(mode,'off')
                [rc] = AT_SetEnumIndex(obj.cameraHandle,'Fan Speed',0);
            end
            AT_CheckWarning(rc);
        end
        
        function mode = get.fanSpeed(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'Fan Speed');
            if index == 0
                mode = 'off';
            else
                mode = 'on';
            end
            AT_CheckWarning(rc);
        end
        
        function control = get.temperatureControl(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'Temperature Status ') 
            [rc,count] = AT_GetEnumCount(obj.cameraHandle,'Temperature Status ') 
            
            [rc,control] = AT_GetEnumStringByIndex(obj.cameraHandle,'Temperature Status ',index,10);
            AT_CheckWarning(rc);
        end
        
        function set.electronicShutteringMode(obj,mode)
            obj.stopAcquisition();
            if isequal(mode,'rolling')
                disp('Setting electronic shuttering mode to rolling')
                [rc] = AT_SetEnumIndex(obj.cameraHandle,'Electronic Shuttering Mode',0);
            else
                disp('Setting electronic shuttering mode to global')
                [rc] = AT_SetEnumIndex(obj.cameraHandle,'Electronic Shuttering Mode',1);
            end
            AT_CheckWarning(rc);
            obj.startAcquisition();
        end
        
        function mode = get.electronicShutteringMode(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'ElectronicShutteringMode');
            if index == 0
                mode = 'rolling';
            else
                mode = 'global';
            end
        end
        
        function set.exposureTime(obj,time)
            [rc] = AT_SetFloat(obj.cameraHandle,'ExposureTime',time);
            AT_CheckWarning(rc);
        end
        
        function time = get.exposureTime(obj)
            [rc,time] = AT_GetFloat(obj.cameraHandle,'ExposureTime');
            AT_CheckWarning(rc);
        end
        
        function set.fastAOIFrameRateEnable(obj,bool)
            obj.stopAcquisition();
            [rc] = AT_SetBool(obj.cameraHandle,'FastAOIFrameRateEnable',bool);
            AT_CheckWarning(rc);
            obj.startAcquisition();
        end
        
        function bool = get.fastAOIFrameRateEnable(obj)
            [rc,bool] = AT_GetBool(obj.cameraHandle,'FastAOIFrameRateEnable');
            AT_CheckWarning(rc);
        end
        
        function set.numberOfAccumulations(obj,number)
            obj.stopAcquisition();
            [rc] = AT_SetInt(obj.cameraHandle,'AccumulateCount',number);
            AT_CheckWarning(rc);
            obj.startAcquisition();
        end
        
        function number = get.numberOfAccumulations(obj)
            [rc,number] = AT_GetInt(obj.cameraHandle,'AccumulateCount');
            AT_CheckWarning(rc);
        end
        
        function frameRate = get.frameRate(obj)
            [rc,frameRate] = AT_GetFloat(obj.cameraHandle,'FrameRate');
            AT_CheckWarning(rc);
        end
        
        function binning = get.verticalBinning(obj)
            [rc,binning] = AT_GetInt(obj.cameraHandle,'AOIVBin');
            AT_CheckWarning(rc);
        end
        
        function set.verticalBinning(obj,binning)
            obj.stopAcquisition();
            [rc] = AT_SetInt(obj.cameraHandle,'AOIVBin',binning);
            AT_CheckWarning(rc);
            obj.getSettingsFromCamera();
            obj.startAcquisition();
        end
        
        function binning = get.horisontalBinning(obj)
            [rc,binning] = AT_GetInt(obj.cameraHandle,'AOIHBin');
            AT_CheckWarning(rc);
        end
        
        function set.horisontalBinning(obj,binning)
            obj.stopAcquisition();
            [rc] = AT_SetInt(obj.cameraHandle,'AOIHBin',binning);
            AT_CheckWarning(rc);
            obj.getSettingsFromCamera();
            obj.startAcquisition();
        end
        
        function frame = getNextFrame(obj)
            [rc] = AT_QueueBuffer(obj.cameraHandle,obj.cameraImageSize);
            AT_CheckWarning(rc);
            [rc] = AT_Command(obj.cameraHandle,'SoftwareTrigger');
            AT_CheckWarning(rc);
            [rc,buf] = AT_WaitBuffer(obj.cameraHandle,10000);
            AT_CheckWarning(rc);
            [rc,frame] = AT_ConvertMono32ToMatrix(buf,obj.cameraHeight,obj.cameraWidth,obj.cameraStride);
        end
        
        function close(obj)
            obj.stopAcquisition();
            [rc] = AT_Close(obj.cameraHandle);
            AT_CheckWarning(rc);
            [rc] = AT_FinaliseLibrary();
            AT_CheckWarning(rc);
            disp('Camera shutdown');
        end
        
        function setAreaOfInterest(obj,width,height,leftPosition,topPosition)
            obj.stopAcquisition();
            rc = AT_SetInt(obj.cameraHandle, 'AOIWidth', width);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOIHeight', height);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOILeft', leftPosition);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOITop', topPosition);
            AT_CheckWarning(rc);
            obj.getSettingsFromCamera();
            obj.startAcquisition();
        end
        
        function setMaxAreaOfInterest(obj)
            obj.stopAcquisition();
            [rc,obj.cameraHeight] = AT_GetIntMax(obj.cameraHandle,'AOIHeight');
            AT_CheckWarning(rc);
            [rc,obj.cameraWidth] = AT_GetIntMax(obj.cameraHandle,'AOIWidth');
            AT_CheckWarning(rc);
            [rc,obj.cameraLeftPosition] = AT_GetIntMax(obj.cameraHandle,'AOILeft');
            AT_CheckWarning(rc);
            [rc,obj.cameraTopPosition] = AT_GetIntMax(obj.cameraHandle,'AOITop');
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOIWidth', obj.cameraWidth);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOIHeight', obj.cameraHeight);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOILeft', obj.cameraLeftPosition);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOITop', obj.cameraTopPosition);
            AT_CheckWarning(rc);
            [rc,obj.cameraImageSize] = AT_GetInt(obj.cameraHandle,'ImageSizeBytes');
            AT_CheckWarning(rc);
            [rc,obj.cameraStride] = AT_GetInt(obj.cameraHandle,'AOIStride');
            AT_CheckWarning(rc);
            obj.startAcquisition();
        end
    end
    
    methods(Access=private)
        
        function initialiseCamera(obj)
            [rc] = AT_InitialiseLibrary();
            AT_CheckError(rc);
            [rc,obj.cameraHandle] = AT_Open(0);
            AT_CheckError(rc);
            disp('Camera initialized');
        end
        
        function setInitialCameraSettings(obj)
            [rc] = AT_SetFloat(obj.cameraHandle,'ExposureTime',0.000028);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.cameraHandle,'CycleMode','Continuous');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.cameraHandle,'TriggerMode','Software');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.cameraHandle,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(obj.cameraHandle,'PixelEncoding','Mono32');
            AT_CheckWarning(rc);
            obj.fanSpeed = 'off';
            obj.getSettingsFromCamera();
        end
        
        function getSettingsFromCamera(obj)
            [rc,obj.cameraHeight] = AT_GetInt(obj.cameraHandle,'AOIHeight');
            AT_CheckWarning(rc);
            [rc,obj.cameraWidth] = AT_GetInt(obj.cameraHandle,'AOIWidth');
            AT_CheckWarning(rc);
            [rc,obj.cameraLeftPosition] = AT_GetInt(obj.cameraHandle,'AOILeft');
            AT_CheckWarning(rc);
            [rc,obj.cameraTopPosition] = AT_GetInt(obj.cameraHandle,'AOITop');
            AT_CheckWarning(rc);
            [rc,obj.cameraImageSize] = AT_GetInt(obj.cameraHandle,'ImageSizeBytes');
            AT_CheckWarning(rc);
            [rc,obj.cameraStride] = AT_GetInt(obj.cameraHandle,'AOIStride');
            AT_CheckWarning(rc);
            [rc,obj.cameraImageSize] = AT_GetInt(obj.cameraHandle,'ImageSizeBytes');
            AT_CheckWarning(rc);
            [rc,obj.cameraStride] = AT_GetInt(obj.cameraHandle,'AOIStride');
            AT_CheckWarning(rc);
        end
        
        function startAcquisition(obj)
            disp('Starting acquisition...');
            [rc] = AT_Command(obj.cameraHandle,'AcquisitionStart');
            AT_CheckWarning(rc);
        end
        
        function stopAcquisition(obj)
            disp('Stopping acquisition...');
            [rc] = AT_Command(obj.cameraHandle,'AcquisitionStop');
            AT_CheckWarning(rc);
            [rc] = AT_Flush(obj.cameraHandle);
            AT_CheckWarning(rc);
        end
        
    end
end

