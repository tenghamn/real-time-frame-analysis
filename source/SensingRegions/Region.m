classdef Region<handle
    %REGION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xOffset
        yOffset
        width
        height
        yPosition
        xPosition
        left
        top
        coordinates
        type
    end
    
    properties(Constant)
        ALLOWED_TYPES = {'signal','reference','background'};
    end
    
    methods
        function obj = Region()
            obj.xOffset = 0;
            obj.yOffset = 0;
            obj.width = 1;
            obj.height = 1;
            obj.xPosition = 2;
            obj.yPosition = 2;
            obj.type = 'signal';
        end
        
        function left = get.left(obj)
            left = obj.xPosition - round(obj.width/2);
        end
        
        function top = get.top(obj)
            top = obj.yPosition - round(obj.height/2);
        end
        
        function set.width(obj,width)
            if width>0.5
                obj.width = width;
            else
                obj.width = 1;
            end
        end
        
        function set.height(obj,height)
            if height>0.5
                obj.height = height;
            else
                obj.height = 1;
            end
        end
        
        function set.xPosition(obj,xPosition)
            obj.xPosition = xPosition;
        end
        
        function set.yPosition(obj,yPosition)
            obj.yPosition = yPosition;
        end
        
        function set.type(obj,type)
            if any(strcmp(obj.ALLOWED_TYPES,type))
                obj.type = type;
            end
        end
        
        function coordinates = get.coordinates(obj)
            halfWidthLeft = round(obj.width/2+0.1);
            halfWidthRight = round(obj.width/2-0.1);
            halfHeightTop = round(obj.height/2+0.1);
            halfHeightBottom = round(obj.height/2-0.1);
            coordinates = [
                [obj.xOffset + obj.xPosition-halfWidthLeft, obj.yOffset + obj.yPosition-halfHeightTop];
                [obj.xOffset + obj.xPosition+halfWidthRight, obj.yOffset + obj.yPosition-halfHeightTop];
                [obj.xOffset + obj.xPosition+halfWidthRight, obj.yOffset + obj.yPosition+halfHeightBottom];
                [obj.xOffset + obj.xPosition-halfWidthLeft, obj.yOffset + obj.yPosition+halfHeightBottom]
            ];
        end
        
        function position = get.xPosition(obj)
            position = obj.xPosition;
        end
        
        function position = get.yPosition(obj)
            position = obj.yPosition;
        end
        
        function width = get.width(obj)
            width = obj.width;
        end
        
        function height = get.height(obj)
            height = obj.height;
        end
        
        function type = get.type(obj)
            type = obj.type;
        end
        
        function [x,y] = getFillCoordinates(obj)
            x = [obj.coordinates(:,1);obj.coordinates(1,1)];
            y = [obj.coordinates(:,2);obj.coordinates(1,2)];
        end
        
        function data = getDataInRegion(obj,frame)
            data = frame(obj.top:obj.top + obj.height,obj.left:obj.left+obj.width);
        end
        
    end
end

