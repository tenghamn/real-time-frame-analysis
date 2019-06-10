classdef CameraSimulator<handle
    %CAMERASIMULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Unique properties for camera
        time
        
        cameraHandle
        
        % Image properties (read only)
        imageMaxHeightWithoutBinning
        imageMaxWidthWithoutBinning
        imageHeightWithoutBinning
        imageWidthWithoutBinning
        imageLeftPositionWithoutBinning
        imageTopPositionWithoutBinning
        fullImageHeight
        imageHeight
        imageWidth
        imageLeftPosition
        imageTopPosition
        imageSize
        imageStride
        imageMaxHeight
        imageMaxWidth
        sensorWidth
        sensorHeight
        sensorCoordinates
        sensorTemperature = 0;
        
        % Image properties saved in obj for faster acquisition
        imageSizeFast
        imageHeightFast
        imageWidthFast
        imageStrideFast
        clockFrequencyFast
        
        % Camera properties (read only)
        isAcquiring
        frameRate
        clockFrequency
        maxInterfaceTransferRate
        
        % Camera settings
        numberOfAccumulations
        exposureTime
        horisontalBinning
        verticalBinning
        
        % Camera info
        cameraInfo
    end
    
    properties(Constant)
        NAME = 'Simulator';
    end

    properties(Access=private)
        Frames
        CurrentFrameIndex
    end
    
    methods
        function obj = CameraSimulator()
            obj.initialiseCamera();
        end
        
        function info = get.cameraInfo(obj)
            info = [
                compose('imageHeight:\t%d\n',obj.imageHeight),...
                compose('imageWidth:\t%d\n',obj.imageWidth),...
                compose('imageLeftPosition:\t%d\n',obj.imageLeftPosition),...
                compose('imageTopPosition:\t%d',obj.imageTopPosition),...
                ];
            info = [info{:}];
            
        end
        
        function resetTimeStamp(ob)
            obj.time = 0;
        end
        
        function coordinates = get.sensorCoordinates(obj)
           coordinates = [
               [1,1];
               [1+obj.sensorWidth,1];
               [1+obj.sensorWidth,1+obj.sensorHeight];
               [1,1+obj.sensorHeight]
               ];
        end
        
        function height = get.sensorHeight(obj)
            height = obj.imageMaxHeight;
        end
        
        function width = get.sensorWidth(obj)
            width = obj.imageMaxWidth;
        end
        
        function height = get.imageMaxHeight(obj)
            height = floor(size(obj.Frames(:,:,1),1)/obj.verticalBinning);
        end
        
        function width = get.imageMaxWidth(obj)
            width = floor(size(obj.Frames(:,:,1),2)/obj.horisontalBinning);
        end
        
        function set.exposureTime(obj,time)
            obj.exposureTime = time;
        end
        
        function time = get.exposureTime(obj)
            time = obj.exposureTime + rand(1)*0.1*obj.exposureTime;
        end
        
        function set.numberOfAccumulations(obj,number)
            obj.stopAcquisition();
            obj.numberOfAccumulations = number;
            obj.startAcquisition();
        end
        
        function number = get.numberOfAccumulations(obj)
            number = obj.numberOfAccumulations;
        end
        
        function frameRate = get.frameRate(obj)
            frameRate = 1/obj.exposureTime;
        end
        
        function binning = get.verticalBinning(obj)
            binning = obj.verticalBinning;
        end
        
        function set.verticalBinning(obj,binning)
            obj.stopAcquisition();
            obj.verticalBinning = binning;
            obj.imageHeight = floor(obj.imageHeightWithoutBinning/binning);
            obj.imageTopPosition = floor(obj.imageTopPositionWithoutBinning/binning);
            obj.imageMaxHeight = floor(obj.imageMaxHeightWithoutBinning/binning);
            obj.startAcquisition();
        end
        
        function binning = get.horisontalBinning(obj)
            binning = obj.horisontalBinning;
        end
        
        function set.horisontalBinning(obj,binning)
            obj.stopAcquisition();
            obj.horisontalBinning = binning;
            obj.imageWidth = floor(obj.imageWidthWithoutBinning/binning);
            obj.imageLeftPosition = floor(obj.imageLeftPosition/binning);
            obj.imageMaxWidth = floor(obj.imageMaxWidthWithoutBinning/binning);
            obj.startAcquisition();
        end
        
        function [frame,time] = getNextFrame(obj)
            obj.goToNextFrameIndex();
            frame = obj.Frames(obj.imageTopPosition:obj.horisontalBinning:obj.imageTopPosition+obj.imageHeight-1,obj.imageLeftPosition:obj.horisontalBinning:obj.imageLeftPosition + obj.imageWidth-1,obj.CurrentFrameIndex);
            time = obj.time;
            obj.time = obj.time +1;
        end
        
        function close(obj)
            disp('Camera shutdown');
        end
        
        function setAreaOfInterest(obj,width,height,leftPosition,topPosition)
            obj.stopAcquisition();
            obj.imageWidthWithoutBinning = width * obj.horisontalBinning;
            obj.imageHeightWithoutBinning = height * obj.verticalBinning;
            obj.imageLeftPositionWithoutBinning = leftPosition * obj.horisontalBinning;
            obj.imageTopPositionWithoutBinning = topPosition * obj.verticalBinning;
            obj.imageHeight = height;
            obj.imageWidth = width;
            obj.imageLeftPosition = leftPosition;
            obj.imageTopPosition = topPosition;
            obj.startAcquisition();
        end
        
        function setMaxAreaOfInterest(obj)
            obj.stopAcquisition();
            obj.imageHeight = size(obj.Frames(:,:,1),1);
            obj.imageWidth = size(obj.Frames(:,:,1),2);
            obj.imageLeftPosition = 1;
            obj.imageTopPosition = 1;
            obj.startAcquisition();
        end
        
        function startAcquisition(obj)
            disp('Starting acquisition...');
            obj.time = 0;
        end
        
        function stopAcquisition(obj)
            disp('Stopping acquisition...');
        end
        
    end
    
    methods(Access = private)
        
        function goToNextFrameIndex(obj)
            obj.CurrentFrameIndex = (obj.CurrentFrameIndex < 10) * obj.CurrentFrameIndex + 1;
        end
        
        function initialiseCamera(obj)
            obj.Frames = importdata('ten_camera_frames.mat');
            obj.CurrentFrameIndex = 1;
            obj.imageMaxHeightWithoutBinning = size(obj.Frames(:,:,1),1);
            obj.imageMaxHeightWithoutBinning = size(obj.Frames(:,:,1),2);
            obj.imageHeightWithoutBinning = size(obj.Frames(:,:,1),1);
            obj.imageWidthWithoutBinning = size(obj.Frames(:,:,1),2);
            obj.imageHeight = size(obj.Frames(:,:,1),1);
            obj.imageWidth = size(obj.Frames(:,:,1),2);
            obj.imageLeftPosition = 1;
            obj.imageTopPosition = 1;
            obj.imageLeftPositionWithoutBinning = 1;
            obj.imageTopPositionWithoutBinning = 1;
            obj.imageSize = size(obj.Frames(:,:,1),1)*size(obj.Frames(:,:,1),2);
            obj.verticalBinning = 1;
            obj.horisontalBinning = 1;
            obj.exposureTime = 1e-3;
            obj.numberOfAccumulations = 1;
            disp('Camera initialized');
        end
    end
end

