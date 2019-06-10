classdef SensingRegions<handle
    %SensingRegions Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        regions
        namesOfAllRegions
        namesOfSignalRegions
        namesOfReferenceRegions
        namesOfBackgroundRegions
        associations
        nRegions
    end
    
    methods
        
        function region = getRegion(obj,name)
            region = obj.regions.(name);
        end
        
        function nRegions = get.nRegions(obj)
            nRegions = size(obj.namesOfAllRegions,2);
        end
        
        function names = get.namesOfAllRegions(obj)
            if isempty(obj.regions)
                names = '';
            else
                names = fieldnames(obj.regions)';
            end
        end
        
        function signalRegions = get.namesOfSignalRegions(obj)
            signalRegions = {};
            for n=1:obj.nRegions
                if isequal(obj.getRegionType(obj.namesOfAllRegions{n}),'signal')
                    signalRegions{end+1} = obj.namesOfAllRegions{n};
                end
            end
        end
        
        function referenceRegions = get.namesOfReferenceRegions(obj)
            referenceRegions = {};
            for n=1:obj.nRegions
                if isequal(obj.getRegionType(obj.namesOfAllRegions{n}),'reference')
                    referenceRegions{end+1} = obj.namesOfAllRegions{n};
                end
            end
        end
        
        function backgroundRegions = get.namesOfBackgroundRegions(obj)
            backgroundRegions = {};
            for n=1:obj.nRegions
                if isequal(obj.getRegionType(obj.namesOfAllRegions{n}),'background')
                    backgroundRegions{end+1} = obj.namesOfAllRegions{n};
                end
            end
        end 
    end
    
    methods(Access=public)
        function obj = SensingRegions()
        end
        
        function name = addNewRegion(obj,name)
            switch nargin
                case 2
                    if ~obj.regionNameExists(name)
                        obj.regions.(name) = Region();
                        obj.associations.(name) = {};
                    else
                        error('Name already exists');
                    end
                case 1
                    name = obj.createNewRegionName();
                    obj.regions.(name) = Region();
                    obj.associations.(name) = {};
            end
        end
        
        function setRegionType(obj,name,type)
            obj.regions.(name).type = type;
            if isequal(type,'reference') || isequal(type,'background')
                obj.removeAssociations(name);
            else
                obj.associations.(name) = {};
            end
        end
        
        function type = getRegionType(obj,name)
            type = obj.regions.(name).type;
        end

        function editRegionName(obj,oldName,newName)
            if obj.regionNameExists(oldName) && ~obj.regionNameExists(newName)
                obj.regions.(newName) = obj.regions.(oldName);
                obj.editNameInAssociations(oldName,newName);
                obj.removeRegion(oldName);
            elseif ~obj.regionNameExists(oldName)
                error('Region name does not exist');
            elseif obj.regionNameExists(newName)
                error('Region with that name already exists')
            end
        end
        
        function exists = regionNameExists(obj,name)
            exists = isfield(obj.regions,name);
        end
        
        function removeRegion(obj,name)
            obj.regions = rmfield(obj.regions,name);
        end
        
        function coordinates = coordinates(obj,name)
            coordinates = obj.regions.(name).coordinates();   
        end
        
        function setxPositionOfRegion(obj,name,position)
            obj.regions.(name).xPosition = position;
        end
        
        function setyPositionOfRegion(obj,name,position)
            obj.regions.(name).yPosition = position;
        end
        
        function setWidthOfRegion(obj,name,width)
            obj.regions.(name).width = width; 
        end
        
        function setHeightOfRegion(obj,name,height)
            obj.regions.(name).height = height; 
        end
        
        function position = getxPositionOfRegion(obj,name)
            position = obj.regions.(name).xPosition;
        end
        
        function position = getyPositionOfRegion(obj,name)
            position = obj.regions.(name).yPosition;
        end
        
        function width = getWidthOfRegion(obj,name)
            width = obj.regions.(name).width;
        end
        
        function height = getHeightOfRegion(obj,name)
            height = obj.regions.(name).height;
        end
        
        function associateRegionWithSignal(obj,regionName,signalName)
            if isequal(obj.getRegionType(signalName),'signal') && ~obj.associationExists(signalName,regionName)
                obj.associations.(signalName){end +1} = regionName;
            end
        end
        
        function exists = associationExists(obj,signalName,regionName)
            exists = any(strcmp(obj.associations.(signalName),regionName));
        end
        
        function associations = associationsOfRegion(obj,name)
            if isequal(obj.getRegionType(name),'signal')
                associations = obj.associations.(name);
            else
                associations = {};
            end
        end
        
        function [x,y] = getRegionFillCoordinates(obj,name)
            [x,y] = obj.regions.(name).getFillCoordinates();
        end
        
        function names = getNamesOfAssociatedReferenceRegions(obj,name)
            names = obj.associationsOfRegion(name);
            n=1;
            while n<length(names)+0.5
                if ~isequal(obj.getRegionType(names{n}),'reference')
                    names(n) = [];
                else
                    n=n+1;
                end
            end
        end
        
        function names = getNamesOfAssociatedBackgroundRegions(obj,name)
            names = obj.associationsOfRegion(name);
            n=1;
            while n<length(names)+0.5
                if ~isequal(obj.getRegionType(names{n}),'background')
                    names(n) = [];
                else
                    n=n+1;
                end
            end
        end
        
        function removeAssociationsOfRegion(obj,name)
            if isequal(obj.getRegionType(name),'signal')
                obj.associations.(name) = {};
            end
        end

        
    end
    
    methods(Access=private)
        
        function name = createNewRegionName(obj)
            for n=1:obj.nRegions+1
                name = strcat('region_',num2str(n));
                if ~obj.regionNameExists(name)
                    break
                end
            end
        end 
        
        function editNameInAssociations(obj,oldName,newName)
            if isequal(obj.getRegionType(newName),'signal')
                obj.associations.(newName) = obj.associations.(oldName);
                obj.removeAssociations(oldName);
            else
                for n=1:length(obj.namesOfSignalRegions)
                    index = strcmp(obj.associations.(obj.namesOfSignalRegions{n}),oldName);
                    if sum(index)>0.5
                        obj.associations.(obj.namesOfSignalRegions{n}){index} = newName;
                    end
                end
            end
        end
        
        function removeAssociations(obj,name)
            if isequal(obj.getRegionType(name),'signal')
                obj.associations = rmfield(obj.associations,name);
            end
        end
        
    end
    
end

