classdef CameraViewOnSingleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Camera View';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = CameraViewOnSingleAxis()
            
        end
        
        function initializeSingleAxis(obj,axis)
            cla(axis);
            colorbar(axis);
            set(axis,'xlim', [1,size(obj.currentFrame,2)]);
            set(axis,'ylim', [1,size(obj.currentFrame,1)]);
        end
        
        function plotOnSingleAxis(obj,axis)
            image(axis,obj.currentFrame,'CDataMapping','scaled');
        end
        
        function resetZoomSingleAxis(obj,axis)
            set(axis,'xlim', [1,size(obj.currentFrame,2)]);
            set(axis,'ylim', [1,size(obj.currentFrame,1)]);
            set(axis,'zlimMode', 'auto');
        end
    end
end

