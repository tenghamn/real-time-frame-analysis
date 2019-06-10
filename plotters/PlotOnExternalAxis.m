classdef PlotOnExternalAxis<LiveAnalyzer
    
    properties
        axis
        figure
    end
    
    
    properties(Constant)
        NAME = 'Plot on external axis';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = TestPlotterSingleAxis()
            
        end
        
        function initializeSingleAxis(obj,ax)
            cla(ax);
            obj.figure = figure;
            obj.axis = axes;
        end
        
        function plotOnSingleAxis(obj,~)
            if ishandle(obj.figure) % Checks if the figure still exists, has not been closed
                image(obj.axis,obj.currentFrame,'CDataMapping','scaled');
                colorbar(obj.axis);
            end
        end
        
        function resetZoom(obj,axis)
            
        end
    end
end