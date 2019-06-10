classdef TripleAxisExternal<LiveAnalyzer
    
    properties
        axis
        figure
    end
    
    properties(Constant)
        NAME = 'Camera View  external';
        TYPE = 'Triple axis';
    end
    
    methods
        function obj = TripleAxisExternal()
            
        end
        
        function initializeTripleAxis(obj,mainaxis,miniAxisLeft,miniAxisBottom)
            cla(mainaxis);
            cla(miniAxisLeft);
            cla(miniAxisBottom);
            obj.figure = figure;
            obj.axis = axes;
            
            set(obj.axis,'xlim', [1,size(obj.currentFrame,2)]);
            set(obj.axis,'ylim', [1,size(obj.currentFrame,1)]);
            set(obj.axis,'zlimMode', 'auto');
            
            xlimits = get(obj.axis,'xlim');
            ylimits = get(obj.axis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
            colorbar(obj.axis);
    
        end
        
        function plotOnTripleAxis(obj,mainaxis,miniAxisLeft,miniAxisBottom)
            image(obj.axis,obj.currentFrame,'CDataMapping','scaled');
            averageInXDirection = obj.calculateAverageIntensityInXDirection(obj.currentFrame);
            averageInYDirection = obj.calculateAverageIntensityInYDirection(obj.currentFrame);
            plot(miniAxisBottom,averageInYDirection);
            plot(miniAxisLeft,averageInXDirection,1:size(averageInXDirection,1));
            
            set(obj.axis,'zlimMode', 'auto');
            
            xlimits = get(obj.axis,'xlim');
            ylimits = get(obj.axis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
            colorbar(obj.axis);
            set(obj.axis,'CLim',[min(min(obj.currentFrame)),max(max(obj.currentFrame))]);
        end
        
        function resetZoomTripleAxis(obj,mainaxis,miniAxisLeft,miniAxisBottom)
            set(obj.axis,'xlim', [1,size(obj.currentFrame,2)]);
            set(obj.axis,'ylim', [1,size(obj.currentFrame,1)]);
            set(obj.axis,'zlimMode', 'auto');
            
            xlimits = get(obj.axis,'xlim');
            ylimits = get(obj.axis,'ylim');
            
            set(miniAxisLeft,'ylim',ylimits);
            set(miniAxisLeft,'Ydir','reverse');
            set(miniAxisBottom,'xlim',xlimits);
        end
    end
end

