classdef LiveAnalyzer<handle
    %ANALYZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        previousTime
        currentTime
        currentFrame
        previousFrame
        SensingRegions
    end
    
    methods
        
        function set.currentTime(obj,time)
            obj.previousTime = obj.currentTime;
            obj.currentTime = time;
        end
        
        function set.currentFrame(obj,frame)
            obj.previousFrame = obj.currentFrame;
            obj.currentFrame = double(frame);
        end
        
        function initializeSingleAxis(obj,axis)
            cla(axis);
        end
        
        function initializeTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
            cla(mainAxis);
            cla(miniAxisLeft);
            cla(miniAxisBottom);
        end
        
        function resetZoomSingleAxis(obj,axis)
            set(axis,'xlimMode','auto');
            set(axis,'ylimMode','auto');
            set(axis,'zlimMode','auto');
        end
        
        function resetZoomTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
            set(mainAxis,'xlimMode','auto');
            set(mainAxis,'ylimMode','auto');
            set(mainAxis,'zlimMode','auto');
            
            set(miniAxisLeft,'xlimMode','auto');
            set(miniAxisLeft,'ylimMode','auto');
            set(miniAxisLeft,'zlimMode','auto');
            
            set(miniAxisBottom,'xlimMode','auto');
            set(miniAxisBottom,'ylimMode','auto');
            set(miniAxisBottom,'zlimMode','auto');
        end
        
        function openNewFigureWithCurrentPlot(obj)
            h = figure;
            ax = axes;
            try
                obj.plotOnSingleAxis(ax);
            catch
            end
        end
            
        
%         function plotOnSingleAxis(obj,axis,plotFunctionName,varargin)
%             if isequal(plotFunctionName,'Camera View')
%                 obj.plotCameraViewOnSingleAxis(axis,varargin);
%             elseif isequal(plotFunctionName,'Trace Mass')
%                 obj.plotTraceMassOnSingleAxis(axis,varargin);
%             end
%         end
%         
%         function plotOnTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom,plotFunctionName,varargin)
%             if isequal(plotFunctionName,'Camera View')
%                 obj.plotCameraViewOnTripleAxis(mainAxis, miniAxisLeft,miniAxisBottom,varargin);
%             elseif isequal(plotFunctionName,'Percentual change')
%                 obj.plotPercentualChangeOnTripleAxis(mainAxis, miniAxisLeft,miniAxisBottom,varargin);
%             end
%         end
    end
    
    methods(Access=private)
        
        function plotCameraViewOnSingleAxis(obj,axis,~)
            image(axis,obj.currentFrame,'CDataMapping','scaled');
            colorbar(axis);
        end
        
        function plotCameraViewOnTripleAxis(obj,mainAxis, miniAxisLeft,miniAxisBottom,varargin)
            image(mainAxis,obj.currentFrame,'CDataMapping','scaled');
            colorbar(mainAxis);
            averageInXDirection = obj.calculateAverageIntensityInXDirection(obj.currentFrame);
            averageInYDirection = obj.calculateAverageIntensityInYDirection(obj.currentFrame);
            plot(miniAxisBottom,averageInYDirection);
            plot(miniAxisLeft,averageInXDirection,1:size(averageInXDirection,1));
            
            xlimits = get(mainAxis,'xlim');
            ylimits = get(mainAxis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
        end
        
        function plotTraceMassOnSingleAxis(obj,axis,varargin)
            hold(axis,'on');
            averageInXDirection = obj.calculateAverageIntensityInXDirection(obj.currentFrame);
            massPosition = (1:1:length(averageInXDirection)) * averageInXDirection / sum(averageInXDirection);
            plot(axis,obj.currentTime,massPosition,'.k');
            hold(axis,'off');
        end
        
        function plotPercentualChangeOnTripleAxis(obj,mainAxis, miniAxisLeft,miniAxisBottom,varargin);
            diff = obj.currentFrame./obj.previousFrame-1;
            
            averageInXDirectionCurrentFrame = obj.calculateAverageIntensityInXDirection(obj.currentFrame);
            averageInXDirectionPreviousFrame = obj.calculateAverageIntensityInXDirection(obj.previousFrame);
            
            averageInYDirectionCurrentFrame = obj.calculateAverageIntensityInYDirection(obj.currentFrame);
            averageInYDirectionPreviousFrame = obj.calculateAverageIntensityInYDirection(obj.previousFrame);
            
            averageInXDirection = averageInXDirectionCurrentFrame./averageInXDirectionPreviousFrame -1;
            averageInYDirection = averageInYDirectionCurrentFrame./averageInYDirectionPreviousFrame -1;
            
            image(mainAxis,diff,'CDataMapping','scaled');
            colorbar(mainAxis);
            
            plot(miniAxisBottom,averageInYDirection);
            plot(miniAxisLeft,averageInXDirection,1:size(averageInXDirection,1));
            
            xlimits = get(mainAxis,'xlim');
            ylimits = get(mainAxis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
            
        end
        
        
        
    end

    methods(Static)
        
        function averageIntensity = calculateAverageIntensityInYDirection(frame)
            averageIntensity = mean(frame,1);
        end
        
        function averageIntensity = calculateAverageIntensityInXDirection(frame)
            averageIntensity = mean(frame,2);
        end
        
        function signalResponse = calculateSensorResponse(frame,SensingRegions,regionName)
            referenceIntensity = 0;
            nameOfLigthReferenceRegions = SensingRegions.getNamesOfAssociatedLightReferenceRegions(regionName);
            for n=1:length(nameOfLigthReferenceRegions)
                regionCoordinates = SensingRegions.getRegionCordinates(nameOfLigthReferenceRegions{n});
                regionIntensity = LiveAnalyzer.getIntensityInRegion(frame,regionCoordinates);
                referenceIntensity = referenceIntensity + mean(regionIntensity,'All');
            end
            intensity = LiveAnalyzer.getIntensityInRegion(frame,SensingRegions.getRegionCordinates(regionName));
            signalResponse = LiveAnalyzer.calculateAverageIntensityInXDirection(intensity)/referenceIntensity; 
        end
        
        function intensity = getIntensityInRegion(frame,regionCoordinates)
            intensity = frame(regionCoordinates(1,2):regionCoordinates(3,2),regionCoordinates(1,1):regionCoordinates(2,1));
        end
        
        function response = calculateResponse(signalIntensity,referenceIntensities,backgroundIntensities)
            response = LiveAnalyzer.calculateAverageIntensityInXDirection(signalIntensity);
            for n=1:length(referenceIntensities)
                response = response - mean(referenceIntensities{n},'all')/length(referenceIntensities);
            end
            for n=1:length(backgroundIntensities)
                response = response - mean(backgroundIntensities{n},'all')/length(backgroundIntensities);
            end
            response = response/mean(signalIntensity,'all');
        end
    end
end

