classdef EmptyTripleAxis<LiveAnalyzer
    properties(Constant)
        NAME = '';
        TYPE = 'Triple axis';
    end
    
    methods
        function obj = EmptyTripleAxis()
        end
        
        function plotOnTripleAxis(~,~,~,~)
            pause(0.0000001);
        end
        
        function resetZoom(~,~,~,~)
        end
    end
end

