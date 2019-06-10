classdef PercentualChangeOnTripleAxis<LiveAnalyzer
    properties(Constant)
        NAME = 'Percentual change';
        TYPE = 'Triple axis';
    end
    
    methods
        function obj = PercentualChangeOnTripleAxis()
            
        end
        
        function initializeTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
            cla(mainAxis);
            cla(miniAxisLeft);
            cla(miniAxisBottom);
            
            set(mainAxis,'xlim', [1,size(obj.currentFrame,2)]);
            set(mainAxis,'ylim', [1,size(obj.currentFrame,1)]);
            set(mainAxis,'zlimMode', 'auto');
            
            xlimits = get(mainAxis,'xlim');
            ylimits = get(mainAxis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
            colorbar(mainAxis);
        end
        
        function plotOnTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
            diff = obj.currentFrame./obj.previousFrame-1;
            averageInYDirection = obj.calculateAverageIntensityInYDirection(obj.currentFrame)./obj.calculateAverageIntensityInYDirection(obj.previousFrame)-1;
            averageInXDirection = obj.calculateAverageIntensityInXDirection(obj.currentFrame)./obj.calculateAverageIntensityInXDirection(obj.previousFrame)-1;
            
            image(mainAxis,diff,'CDataMapping','scaled');
            
            xlimits = get(mainAxis,'xlim');
            ylimits = get(mainAxis,'ylim');
            plot(miniAxisBottom,averageInYDirection);
            plot(miniAxisLeft,averageInXDirection,1:size(averageInXDirection,1));
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse')
            set(miniAxisBottom,'xlim',xlimits);
            
        end
        
        function resetZoomTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
            set(mainAxis,'xlim', [1,size(obj.currentFrame,2)]);
            set(mainAxis,'ylim', [1,size(obj.currentFrame,1)]);
            set(mainAxis,'zlimMode', 'auto');
            
            xlimits = get(mainAxis,'xlim');
            ylimits = get(mainAxis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
        end
    end
end
