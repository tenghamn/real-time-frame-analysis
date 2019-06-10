classdef TraceXMassOnSingleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Trace Mass (x-value)';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = TraceXMassOnSingleAxis()
            
        end
        
        function initializeSingleAxis(obj,axis)
            cla(axis);
            hold(axis,'on');
            colorbar(axis,'off');
            set(axis,'xlimMode','auto');
            set(axis,'ylimMode','auto');
            set(axis,'zlimMode','auto');
        end
        
        function plotOnSingleAxis(obj,axis)
            averageInYDirection = obj.calculateAverageIntensityInYDirection(obj.currentFrame)';
            massPosition = (1:1:length(averageInYDirection)) * averageInYDirection / sum(averageInYDirection);
            plot(axis,obj.currentTime,massPosition,'.k');
        end
        
        function resetZoomSingleAxis(obj,axis)
            set(axis,'xlimMode','auto');
            set(axis,'ylimMode','auto');
            set(axis,'zlimMode','auto');
        end
    end
end

