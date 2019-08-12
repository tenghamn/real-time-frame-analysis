classdef TestPlotterSingleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Test Plotter Single';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = TestPlotterSingleAxis()
            
        end
        
        function initializeSingleAxis(obj,axis)
            cla(axis);
            colorbar(axis);
            set(axis,'xlim', [1,size(obj.currentFrame,2)]);
            set(axis,'ylim', [1,size(obj.currentFrame,1)]);
        end
        
        function plotOnSingleAxis(obj,axis)
            image(axis,obj.currentFrame,'CDataMapping','scaled');
            colorbar(axis);
        end
        
        function resetZoom(obj,axis)
            
        end
    end
end