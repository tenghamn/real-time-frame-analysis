classdef TestPlotterTripleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Test Plotter Triple';
        TYPE = 'Triple axis';
    end
    
    methods
        function obj = TestPlotterTripleAxis()
            
        end
        
        function plotOnTripleAxis(obj,mainAxis,bottomAxis,leftAxis)
            image(mainAxis,obj.currentFrame,'CDataMapping','scaled');
            colorbar(mainAxis);
        end
        
        function resetZoom(obj,mainAxis)
            
        end
    end
end

