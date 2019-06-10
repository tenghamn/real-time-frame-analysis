classdef TraceYMassOnSingleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Trace Mass (y-value)';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = TraceYMassOnSingleAxis()
            
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
            averageInXDirection = obj.calculateAverageIntensityInXDirection(obj.currentFrame);
            massPosition = (1:1:length(averageInXDirection)) * averageInXDirection / sum(averageInXDirection);
            plot(axis,obj.currentTime,massPosition,'.k');
        end
        
        function resetZoomSingleAxis(obj,axis)
            set(axis,'xlimMode','auto');
            set(axis,'ylimMode','auto');
            set(axis,'zlimMode','auto');
        end
    end
end

