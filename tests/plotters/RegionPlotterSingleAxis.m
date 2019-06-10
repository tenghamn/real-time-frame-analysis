classdef RegionPlotterSingleAxis<LiveAnalyzer
    
    % Class properties. Variables that can be reached in any function that
    % has obj as the first argument. Use obj.propertyName to access the variable.
    properties
        control
        singleAxis
    end
    
    % Name of the plotter and type, can either be "Single axis" or "Triple axis" 
    properties(Constant)
        NAME = 'Region Plotter';
        TYPE = 'Single axis';
    end
    
    methods
        function obj = TestPlotterSingleAxis()
            
        end
        
        % This function is called when the plotter is chosen
        function initializeSingleAxis(obj,axis)
            
            % Save the axis as class property so we can access it in the
            % regionChange function
            obj.singleAxis = axis;
            cla(obj.singleAxis);
            
            % Create a dropdown menu
            f = figure;
            obj.control = uicontrol(f,'Style','popupmenu');
            obj.control.Position = [20 100 100 20]; % [left bottom width height]
            obj.control.String = obj.SensingRegions.namesOfAllRegions;
            obj.control.Callback = @obj.regionChange; % Defines a function that is called when the dropdown value is changed
            
%             obj.control.String = obj.SensingRegions.namesOfSignalRegions;
%             obj.control.String = obj.SensingRegions.namesOfReferenceRegions;
%             obj.control.String = obj.SensingRegions.namesOfBackgroundRegions;

            % Set initial axis settings
            region = obj.SensingRegions.getRegion(obj.SensingRegions.namesOfAllRegions{1});
            data = region.getDataInRegion(obj.currentFrame);
            set(obj.singleAxis,'xlim', [1,size(data,2)]);
            set(obj.singleAxis,'ylim', [1,size(data,1)]);
            colorbar(obj.singleAxis);
        end
        
        % This function is called whenever a new frame is available
        % Available properties are the ones defined in the top of the file
        % but also 
        % obj.currentFrame
        % obj.currentTime
        % obj.previousFrame
        % obj.previousTime
        % obj.SensingRegions
        function plotOnSingleAxis(obj,axis)
            
            selectedRegion = obj.control.String{obj.control.Value};
            region = obj.SensingRegions.getRegion(selectedRegion);
            
            data = region.getDataInRegion(obj.currentFrame);
            
            image(axis,data,'CDataMapping','scaled');
            colorbar(axis);
        end
        
        % This function is called when the value in the dropdown is changed
        function regionChange(obj,src,event)
            selectedRegion = obj.control.String{obj.control.Value};
            region = obj.SensingRegions.getRegion(selectedRegion);
            data = region.getDataInRegion(obj.currentFrame);
            
            set(obj.singleAxis,'xlim', [1,size(data,2)]);
            set(obj.singleAxis,'ylim', [1,size(data,1)]);
        end
        
        
        % This function is called when the reset zoom button is pressed
        function resetZoom(obj,axis)
            selectedRegion = obj.control.String{obj.control.Value};
            region = obj.SensingRegions.getRegion(selectedRegion);
            data = region.getDataInRegion(obj.currentFrame);
            set(axis,'xlim', [1,size(data,2)]);
            set(axis,'ylim', [1,size(data,1)]);
        end
    end
end


