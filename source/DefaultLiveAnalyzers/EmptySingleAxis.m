classdef EmptySingleAxis<LiveAnalyzer
    properties(Constant)
        NAME = '';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = EmptySingleAxis()
        end
        
        function plotOnSingleAxis(~,~)
            pause(0.0000001);
        end
        
        function resetZoomSingleAxis(~,~)
        end
    end
end

