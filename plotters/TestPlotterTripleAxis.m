classdef TestPlotterTripleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Test Plotter Triple';
        TYPE = 'Triple axis';
    end
    
    methods
        function obj = TestPlotterTripleAxis()
            
        end
        
        function plot(obj,axis)
            image(axis,obj.currentFrame,'CDataMapping','scaled');
            colorbar(axis);
        end
        
        function resetZoom(obj,axis)
            
        end
    end
end

