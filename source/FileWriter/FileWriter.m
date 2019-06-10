classdef FileWriter<handle
    %FILEWRITER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileId
    end
    
    methods
        function obj = FileWriter(outputPath,sensingRegions,cameraInfo)
            obj.initialiseOutputFile(outputPath)
            obj.writeHeaderToFile(sensingRegions,cameraInfo)
        end
      
        function closeFile(obj)
            fclose(obj.fileId);
        end
        
        function writeFrameToFiles(obj,frame,time)
            fprintf(obj.fileId,'%f,',time);
            fprintf(obj.fileId,'%d;',frame(:));
            fprintf(obj.fileId,'\n');
        end    
    end
    
    methods(Access=private)
        
        function initialiseOutputFile(obj,outputPath)
            fileName = [strrep(strrep(datestr(datetime),' ','_'),':','-'), '.txt'];
            obj.fileId = fopen([outputPath,fileName],'w');
        end
        
        function writeHeaderToFile(obj,sensingRegions,cameraInfo)
            obj.writeDateToFile();
            obj.writeCameraInfoToFile(cameraInfo);
            if obj.sensingRegionsExists(sensingRegions)
                obj.writeSensingRegionsInfoToFile(sensingRegions);
            end
            obj.writeFrameFormatInfoToFile();
        end
        
        function writeFrameFormatInfoToFile(obj)
            fprintf(obj.fileId,'Time, Intensity:\n');
        end
        
        function writeDateToFile(obj)
            fprintf(obj.fileId,'Date & time:\t%s\n\n',datetime);
        end
        
        function exists = sensingRegionsExists(obj,sensingRegions)
            exists = length(sensingRegions.namesOfAllRegions) > 0.5;
        end
        
        function writeCameraInfoToFile(obj,cameraInfo)
            fprintf(obj.fileId,'Camera info:\n');
            fprintf(obj.fileId,cameraInfo);
            fprintf(obj.fileId,'\n\n');
        end
        
        function writeSensingRegionsInfoToFile(obj,sensingRegions)
            fprintf(obj.fileId,'Sensing regions:\n');
            fprintf(obj.fileId,'Names of all regions:\t');
            fprintf(obj.fileId,'%s;',sensingRegions.namesOfAllRegions{:});
            fprintf(obj.fileId,'\n');
            
            fprintf(obj.fileId,'Signal regions:\t');
            fprintf(obj.fileId,'%s;',sensingRegions.namesOfSignalRegions{:});
            fprintf(obj.fileId,'\n');
            
            fprintf(obj.fileId,'Reference regions:\t');
            fprintf(obj.fileId,'%s;',sensingRegions.namesOfReferenceRegions{:});
            fprintf(obj.fileId,'\n');
            
            fprintf(obj.fileId,'Background regions:\t');
            fprintf(obj.fileId,'%s;',sensingRegions.namesOfBackgroundRegions{:});
            fprintf(obj.fileId,'\n');
            
            fprintf(obj.fileId,'Associations:\n');
            for n=1:length(sensingRegions.namesOfSignalRegions)
                fprintf(obj.fileId,'%s:\t',sensingRegions.namesOfSignalRegions{n});
                refRegions = sensingRegions.getNamesOfAssociatedReferenceRegions(sensingRegions.namesOfSignalRegions{n});
                fprintf(obj.fileId,'%s;',refRegions{:});
                backgroundRegions = sensingRegions.getNamesOfAssociatedBackgroundRegions(sensingRegions.namesOfSignalRegions{n});
                fprintf(obj.fileId,'%s;',backgroundRegions{:});
                fprintf(obj.fileId,'\n');
            end
            fprintf(obj.fileId,'Cooridnates:\t[x1,y1],[x2,y2],[x3,y3],[x4,y4]\n');
            namesOfAllRegions = sensingRegions.namesOfAllRegions;
            for n=1:length(namesOfAllRegions)
                region = sensingRegions.getRegion(namesOfAllRegions{n});
                fprintf(obj.fileId,'%s:\t',namesOfAllRegions{n});
                fprintf(obj.fileId,'[%d,%d],',region.coordinates');
                fprintf(obj.fileId,'\n');
            end
            fprintf(obj.fileId,'\n');
        end
    end
    
end

