classdef ZylaCamera<handle
    %ZYLACAMERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cameraHandle
        
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
        latency
        
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
        softwareTrigger
        stoppingAcquisition
        computerTime
        sensorReadoutMode 
        
        % Camera info
        cameraInfo
    end
    
    properties(Constant)
        NAME = 'Zyla';
        ALLOWED_PIXEL_READ_OUT_RATES = {'100 MHz','280 MHz'};
        ALLOWED_CYCLE_MODES = {'Continuous','Fixed'};
        ALLOWED_FAN_SPEEDS = {'On','Off'};
        ALLOWED_TRIGGER_MODES = {'Software','Internal'};
        ALLOWED_SIMPLE_PRE_AMP_GAIN_CONTROLS = {'16-bit (low noise & high well capacity)','12-bit (low noise)','12-bit (high well capacity)'};
        ALLOWED_PIXEL_ENCODINGS = {'Mono12','Mono12Packed','Mono16','Mono32'};
        ALLOWED_ELECTRONIC_SHUTTERING_MODES = {'Global', 'Rolling'};
        ALLOWED_SENSOR_READOUT_MODES = {'Bottom Up Sequential', 'Bottom Up Simultaneous','Centre Out Simultaneous','Outside In Simultaneous','Top Down Sequential','Top Down Simultaneous'}
    end
    
    methods
        function obj = ZylaCamera()
            obj.initialiseAndorSDKLibrary();
            obj.connectToCamera();
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
                compose('pixelReadoutRate:\t%s\n',obj.pixelReadoutRate),...
                compose('overlapReadout:\t%d\n',obj.overlapReadout),...
                compose('spuriousNoiseFilter:\t%d\n',obj.spuriousNoiseFilter),...
                compose('cycleMode:\t%s\n',obj.cycleMode),...
                compose('triggerMode:\t%s\n',obj.triggerMode),...
                compose('simplePreAmpGainControl:\t%s\n',obj.simplePreAmpGainControl),...
                compose('pixelEncoding:\t%s\n',obj.pixelEncoding),...
                compose('fanSpeed:\t%s\n',obj.fanSpeed),...
                compose('electronicShutteringMode:\t%s\n',obj.electronicShutteringMode),...
                compose('fastAOIFrameRateEnable:\t%d\n',obj.fastAOIFrameRateEnable),...
                compose('frameRate:\t%f',obj.frameRate),...
                ];
            info = [info{:}];
        end
        
        function usePresets(obj,preset)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            obj.numberOfAccumulations = 1;
            width = str2num(regexp(preset,'(?<=imageWidth:[ \f\n\r\t\v]+)\d+','match','once'));
            height = str2num(regexp(preset,'(?<=imageHeight:[ \f\n\r\t\v]+)\d+','match','once'));
            leftPosition = str2num(regexp(preset,'(?<=imageLeftPosition:[ \f\n\r\t\v]+)\d+','match','once'));
            topPosition = str2num(regexp(preset,'(?<=imageTopPosition:[ \f\n\r\t\v]+)\d+','match','once'));
            if isinteger(width) && isinteger(height) && isinteger(leftPosition) && isinteger(topPosition)
                try
                    obj.setMaxAreaOfInterest();
                    setAreaOfInterest(obj,height,width,topPosition,leftPosition)
                catch
                end
            end
            try
                verticalBinning = str2num(regexp(preset,'(?<=verticalBinning:[ \f\n\r\t\v]+)\d+','match','once'));
                if isinteger(verticalBinning)
                    obj.verticalBinning = verticalBinning;
                end
                
                horisontalBinning = str2num(regexp(preset,'(?<=horisontalBinning:[ \f\n\r\t\v]+)\d+','match','once'));
                if isinteger(horisontalBinning)
                    obj.horisontalBinning = horisontalBinning;
                end
                
                numberOfAccumulations = str2num(regexp(preset,'(?<=numberOfAccumulations:[ \f\n\r\t\v]+)\d+','match','once'));
                if isinteger(numberOfAccumulations)
                    obj.numberOfAccumulations = numberOfAccumulations;
                end
                
                obj.simplePreAmpGainControl = regexp(preset,'(?<=simplePreAmpGainControl:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                obj.pixelEncoding = regexp(preset,'(?<=pixelEncoding:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                obj.triggerMode = regexp(preset,'(?<=triggerMode:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                obj.electronicShutteringMode = regexp(preset,'(?<=electronicShutteringMode:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                obj.overlapReadout = str2num(regexp(preset,'(?<=overlapReadout:[ \f\n\r\t\v]+)\d+','match','once')) == 1;
                obj.cycleMode = regexp(preset,'(?<=cycleMode:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                obj.exposureTime = str2double(regexp(preset,'(?<=exposureTime:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once'));
                
                obj.pixelReadoutRate = regexp(preset,'(?<=pixelReadoutRate:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                
                obj.spuriousNoiseFilter = str2num(regexp(preset,'(?<=spuriousNoiseFilter:[ \f\n\r\t\v]+)\d+','match','once')) == 1;
                obj.fanSpeed = regexp(preset,'(?<=fanSpeed:[ \f\n\r\t\v]+)[^\f\n\r\t\v]+','match','once');
                obj.fastAOIFrameRateEnable = str2num(regexp(preset,'(?<=fastAOIFrameRateEnable:[ \f\n\r\t\v]+)\d+','match','once')) == 1;
            catch
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function [frame,time] = getNextFrame(obj)
            if obj.stoppingAcquisition
                pause(0.01);
                frame = zeros(obj.imageHeightFast,obj.imageWidthFast);
                time = 0;
                return;
            end
            try
                if obj.softwareTrigger
                    [rc] = AT_Command(obj.cameraHandle,'SoftwareTrigger');
                end
                [rc,buf] = AT_WaitBuffer(obj.cameraHandle,10000);
                AT_CheckWarning(rc);
                AT_CheckError(rc);
                [rc,frame] = AT_ConvertMono32ToMatrix(buf,obj.imageWidthFast,obj.imageHeightFast,obj.imageStrideFast);
                AT_CheckWarning(rc);
                [rc] = AT_QueueBuffer(obj.cameraHandle,obj.imageSizeFast);
                AT_CheckWarning(rc);
                %Get timestamp and convert it into seconds
                [rc,ticks] = AT_GetTimeStamp(buf,obj.imageSizeFast);
                time = double(ticks)/double(obj.clockFrequencyFast);
                AT_CheckWarning(rc);
            catch error
                disp(error);
                frame = zeros(obj.imageHeightFast,obj.imageWidthFast);
                time = 0;
                obj.stopAcquisition();
                obj.startAcquisition();
            end
        end
        
        function resetTimeStamp(obj)
            [rc] = AT_Command(obj.cameraHandle, 'TimestampClockReset');
            AT_CheckWarning(rc);
        end
            
        function queueBuffer(obj)
            for n=1:10
                [rc] = AT_QueueBuffer(obj.cameraHandle,obj.imageSizeFast);
            end
        end
        
        function stopAcquisition(obj)
            if obj.isAcquiring
                disp('Stopping acquisition...');
                obj.stoppingAcquisition = true;
                [rc] = AT_Command(obj.cameraHandle,'AcquisitionStop');
                AT_CheckWarning(rc);
                [rc] = AT_Flush(obj.cameraHandle);
                AT_CheckWarning(rc);
                obj.stoppingAcquisition = false;
            end
        end
        
        function startAcquisition(obj)
            if ~obj.isAcquiring
                disp('Starting acquisition...');
                obj.setPropertiesForFasterAcquisition();
                
                [rc] = AT_Command(obj.cameraHandle, 'TimestampClockReset');
                AT_CheckWarning(rc);
                obj.queueBuffer();
                [rc] = AT_Command(obj.cameraHandle,'AcquisitionStart');
                
%                 AT_CheckWarning(rc);
%                 [rc] = AT_Command(obj.cameraHandle, 'TimestampClockReset');
                AT_CheckWarning(rc);
            end
        end
        
        function setPropertiesForFasterAcquisition(obj)
            obj.imageSizeFast = obj.imageSize;
            obj.imageHeightFast = obj.imageHeight;
            obj.imageWidthFast = obj.imageWidth;
            obj.imageStrideFast = obj.imageStride;
            obj.clockFrequencyFast = obj.clockFrequency;
        end
        
        function setAreaOfInterest(obj,height,width,topPosition,leftPosition)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            rc = AT_SetInt(obj.cameraHandle, 'AOIWidth', height);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOIHeight', width);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOILeft', topPosition);
            AT_CheckWarning(rc);
            rc = AT_SetInt(obj.cameraHandle, 'AOITop', leftPosition);
            AT_CheckWarning(rc);
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function set.sensorReadoutMode(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_SENSOR_READOUT_MODES{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SensorReadoutMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SENSOR_READOUT_MODES{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SensorReadoutMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SENSOR_READOUT_MODES{3})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SensorReadoutMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SENSOR_READOUT_MODES{4})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SensorReadoutMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SENSOR_READOUT_MODES{5})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SensorReadoutMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SENSOR_READOUT_MODES{6})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SensorReadoutMode',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function mode = get.sensorReadoutMode(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'SensorReadoutMode');
            [rc,mode] =  AT_GetEnumStringByIndex(obj.cameraHandle,'SensorReadoutMode',index,100);
            AT_CheckWarning(rc);
        end
        
        function setMaxAreaOfInterest(obj)
            obj.setAreaOfInterest(obj.imageMaxHeight,obj.imageMaxWidth,1,1);
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
        
        function set.exposureTime(obj,time)
            [rc] = AT_SetFloat(obj.cameraHandle,'ExposureTime',time);
            AT_CheckWarning(rc);
        end
        
        function time = get.exposureTime(obj)
            [rc,time] = AT_GetFloat(obj.cameraHandle,'ExposureTime');
            AT_CheckWarning(rc);
        end
        
        function rate = get.maxInterfaceTransferRate(obj)
            [rc,rate] = AT_GetFloat(obj.cameraHandle,'MaxInterfaceTransferRate');
            AT_CheckWarning(rc);
        end
        
        function set.cycleMode(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_CYCLE_MODES{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'CycleMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_CYCLE_MODES{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'CycleMode',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function mode = get.cycleMode(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'CycleMode');
            [rc,mode] =  AT_GetEnumStringByIndex(obj.cameraHandle,'CycleMode',index,100);
            AT_CheckWarning(rc);
        end
        
        function set.pixelReadoutRate(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_PIXEL_READ_OUT_RATES{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'PixelReadoutRate',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_PIXEL_READ_OUT_RATES{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'PixelReadoutRate',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function mode = get.pixelReadoutRate(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'PixelReadoutRate');
            [rc,mode] =  AT_GetEnumStringByIndex(obj.cameraHandle,'PixelReadoutRate',index,100);
            AT_CheckWarning(rc);
        end
        
        function overlap = get.overlapReadout(obj)
            [rc,result] = AT_GetBool(obj.cameraHandle,'Overlap');
            if result == 1
                overlap = true;
            else
                overlap = false;
            end
        end
        
        function set.overlapReadout(obj,shouldOverlap)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if shouldOverlap
                [rc] = AT_SetBool(obj.cameraHandle,'Overlap',1);
                AT_CheckWarning(rc);
            else
                [rc] = AT_SetBool(obj.cameraHandle,'Overlap',0);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function set.triggerMode(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_TRIGGER_MODES{1})
                obj.softwareTrigger = true;
                [rc] = AT_SetEnumString(obj.cameraHandle,'TriggerMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_TRIGGER_MODES{2})
                obj.softwareTrigger = false;
                [rc] = AT_SetEnumString(obj.cameraHandle,'TriggerMode',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function mode = get.triggerMode(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'TriggerMode');
            [rc,mode] =  AT_GetEnumStringByIndex(obj.cameraHandle,'TriggerMode',index,100);
            AT_CheckWarning(rc);
        end
        
        function set.electronicShutteringMode(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_ELECTRONIC_SHUTTERING_MODES{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'ElectronicShutteringMode',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_ELECTRONIC_SHUTTERING_MODES{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'ElectronicShutteringMode',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function mode = get.electronicShutteringMode(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'ElectronicShutteringMode');
            [rc,mode] =  AT_GetEnumStringByIndex(obj.cameraHandle,'ElectronicShutteringMode',index,100);
            AT_CheckWarning(rc);
        end
        
        function filter = get.spuriousNoiseFilter(obj)
            [rc,result] = AT_GetBool(obj.cameraHandle,'SpuriousNoiseFilter');
            if result == 1
                filter = true;
            else
                filter = false;
            end
        end
        
        function set.spuriousNoiseFilter(obj,shouldUseNoiseFilter)
            if shouldUseNoiseFilter
                [rc] = AT_SetBool(obj.cameraHandle,'SpuriousNoiseFilter',1);
                AT_CheckWarning(rc);
            else
                [rc] = AT_SetBool(obj.cameraHandle,'SpuriousNoiseFilter',0);
                AT_CheckWarning(rc);
            end
        end
        
        function set.simplePreAmpGainControl(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_SIMPLE_PRE_AMP_GAIN_CONTROLS{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SimplePreAmpGainControl',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SIMPLE_PRE_AMP_GAIN_CONTROLS{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SimplePreAmpGainControl',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_SIMPLE_PRE_AMP_GAIN_CONTROLS{3})
                [rc] = AT_SetEnumString(obj.cameraHandle,'SimplePreAmpGainControl',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function control = get.simplePreAmpGainControl(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'SimplePreAmpGainControl');
            [rc,control] =  AT_GetEnumStringByIndex(obj.cameraHandle,'SimplePreAmpGainControl',index,100);
            AT_CheckWarning(rc);
        end
        
        function set.pixelEncoding(obj,mode)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if isequal(mode,obj.ALLOWED_PIXEL_ENCODINGS{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'PixelEncoding',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_PIXEL_ENCODINGS{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'PixelEncoding',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_PIXEL_ENCODINGS{3})
                [rc] = AT_SetEnumString(obj.cameraHandle,'PixelEncoding',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_PIXEL_ENCODINGS{4})
                [rc] = AT_SetEnumString(obj.cameraHandle,'PixelEncoding',mode);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function encoding = get.pixelEncoding(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'PixelEncoding');
            [rc,encoding] =  AT_GetEnumStringByIndex(obj.cameraHandle,'PixelEncoding',index,100);
            AT_CheckWarning(rc);
        end
        
        function set.fanSpeed(obj,mode)
            if isequal(mode,obj.ALLOWED_FAN_SPEEDS{1})
                [rc] = AT_SetEnumString(obj.cameraHandle,'FanSpeed',mode);
                AT_CheckWarning(rc);
            elseif isequal(mode,obj.ALLOWED_FAN_SPEEDS{2})
                [rc] = AT_SetEnumString(obj.cameraHandle,'FanSpeed',mode);
                AT_CheckWarning(rc);
            end
        end
        
        function speed = get.fanSpeed(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'FanSpeed');
            [rc,speed] =  AT_GetEnumStringByIndex(obj.cameraHandle,'FanSpeed',index,100);
            AT_CheckWarning(rc);
        end
        
        function frameRateEnabled = get.fastAOIFrameRateEnable(obj)
            [rc,result] = AT_GetBool(obj.cameraHandle,'FastAOIFrameRateEnable');
            if result == 1
                frameRateEnabled = true;
            else
                frameRateEnabled = false;
            end
        end
        
        function set.fastAOIFrameRateEnable(obj,shouldEnableFastAOIFrameRate)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if shouldEnableFastAOIFrameRate
                [rc] = AT_SetBool(obj.cameraHandle,'FastAOIFrameRateEnable',1);
                AT_CheckWarning(rc);
            else
                [rc] = AT_SetBool(obj.cameraHandle,'FastAOIFrameRateEnable',0);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function metadataEnabled = get.metadataEnable(obj)
            [rc,result] = AT_GetBool(obj.cameraHandle,'MetadataEnable');
            if result == 1
                metadataEnabled = true;
            else
                metadataEnabled = false;
            end
        end
        
        function set.metadataEnable(obj,shouldEnableMetadata)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            if shouldEnableMetadata
                [rc] = AT_SetBool(obj.cameraHandle,'MetadataEnable',1);
                AT_CheckWarning(rc);
            else
                [rc] = AT_SetBool(obj.cameraHandle,'MetadataEnable',0);
                AT_CheckWarning(rc);
            end
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function isAcquiring = get.isAcquiring(obj)
            [rc,result] = AT_GetBool(obj.cameraHandle,'CameraAcquiring');
            if result == 1
                isAcquiring = true;
            else
                isAcquiring = false;
            end
        end
        
        function temperature = get.sensorTemperature(obj)
            [rc,temperature] = AT_GetFloat(obj.cameraHandle,'SensorTemperature');
            AT_CheckWarning(rc);
        end
        
        function control = get.temperatureControl(obj)
            [rc,index] = AT_GetEnumIndex(obj.cameraHandle,'Temperature Status ')
            [rc,control] = AT_GetEnumStringByIndex(obj.cameraHandle,'Temperature Status ',index,10);
            AT_CheckWarning(rc);
        end
        
        function binning = get.horisontalBinning(obj)
            [rc,binning] = AT_GetInt(obj.cameraHandle,'AOIVBin');
            AT_CheckWarning(rc);
        end
        
        function set.horisontalBinning(obj,binning)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            [rc] = AT_SetInt(obj.cameraHandle,'AOIVBin',binning);
            AT_CheckWarning(rc);
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function binning = get.verticalBinning(obj)
            [rc,binning] = AT_GetInt(obj.cameraHandle,'AOIHBin');
            AT_CheckWarning(rc);
        end
        
        function set.verticalBinning(obj,binning)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            [rc] = AT_SetInt(obj.cameraHandle,'AOIHBin',binning);
            AT_CheckWarning(rc);
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function frameRate = get.frameRate(obj)
            [rc,frameRate] = AT_GetFloat(obj.cameraHandle,'FrameRate');
            AT_CheckWarning(rc);
        end
        
        function set.numberOfAccumulations(obj,number)
            if obj.isAcquiring
                obj.stopAcquisition()
                wasAcquiring = true;
            else
                wasAcquiring = false;
            end
            [rc] = AT_SetInt(obj.cameraHandle,'AccumulateCount',number);
            AT_CheckWarning(rc);
            if wasAcquiring
                obj.startAcquisition();
            end
        end
        
        function number = get.numberOfAccumulations(obj)
            [rc,number] = AT_GetInt(obj.cameraHandle,'AccumulateCount');
            AT_CheckWarning(rc);
        end
        
        function clockFreq = get.clockFrequency(obj)
            [rc,clockFreq] = AT_GetInt(obj.cameraHandle,'TimestampClockFrequency');
            AT_CheckWarning(rc);
        end
        
        function height = get.imageHeight(obj)
            [rc,height] = AT_GetInt(obj.cameraHandle,'AOIWidth');
            AT_CheckWarning(rc);
        end
        
        function width = get.imageWidth(obj)
            [rc,width] = AT_GetInt(obj.cameraHandle,'AOIHeight');
            AT_CheckWarning(rc);
        end
        
        function height = get.imageMaxHeight(obj)
            [rc,height] = AT_GetIntMax(obj.cameraHandle,'AOIWidth');
            AT_CheckWarning(rc);
        end
        
        function width = get.imageMaxWidth(obj)
            [rc,width] = AT_GetIntMax(obj.cameraHandle,'AOIHeight');
            AT_CheckWarning(rc);
        end
        
        function height = get.imageTopPosition(obj)
            [rc,height] = AT_GetInt(obj.cameraHandle,'AOILeft');
            AT_CheckWarning(rc);
        end
        
        function width = get.imageLeftPosition(obj)
            [rc,width] = AT_GetInt(obj.cameraHandle,'AOITop');
            AT_CheckWarning(rc);
        end
        
        function size = get.imageSize(obj)
            [rc,size] = AT_GetInt(obj.cameraHandle,'ImageSizeBytes');
            AT_CheckWarning(rc);
        end
        
        function stride = get.imageStride(obj)
            [rc,stride] = AT_GetInt(obj.cameraHandle,'AOIStride');
            AT_CheckWarning(rc);
        end
        
        function metadataTimeStampEnabled = get.metadataTimestampEnable(obj)
            [rc,result] = AT_GetBool(obj.cameraHandle,'MetadataTimestamp');
            if result == 1
                metadataTimeStampEnabled = true;
            else
                metadataTimeStampEnabled = false;
            end
        end
        
        function set.metadataTimestampEnable(obj,shouldEnableMetadataTimeStamp)
            if shouldEnableMetadataTimeStamp
                [rc] = AT_SetBool(obj.cameraHandle,'MetadataTimestamp',1);
                AT_CheckWarning(rc);
            else
                [rc] = AT_SetBool(obj.cameraHandle,'MetadataTimestamp',0);
                AT_CheckWarning(rc);
            end
        end
        
        function close(obj)
            [rc] = AT_Close(obj.cameraHandle);
            AT_CheckWarning(rc);
            [rc] = AT_FinaliseLibrary();
            AT_CheckWarning(rc);
            disp('Camera shutdown');
        end
        
    end
    
    methods(Access=private)
        
        function initialiseAndorSDKLibrary(obj)
            [rc] = AT_InitialiseLibrary();
            AT_CheckError(rc);
        end
        
        function connectToCamera(obj)
            [rc,obj.cameraHandle] = AT_Open(0);
            AT_CheckError(rc);
            disp('Camera initialized');
        end
        
        function setInitialCameraSettings(obj)
            obj.setMaxAreaOfInterest();
            obj.simplePreAmpGainControl = '16-bit (low noise & high well capacity)';
            obj.electronicShutteringMode = 'Rolling';
            obj.cycleMode = 'Continuous';
            obj.triggerMode = 'Software';
            obj.pixelReadoutRate = '280 MHz';
            obj.overlapReadout = true;
            obj.spuriousNoiseFilter = true;
            obj.pixelEncoding = 'Mono32';
            obj.fanSpeed = 'Off';
            obj.fastAOIFrameRateEnable = true;
            obj.exposureTime = 0.2;
            obj.numberOfAccumulations = 1;
            obj.metadataEnable = true;
            obj.metadataTimestampEnable = true;
        end
    end
end

