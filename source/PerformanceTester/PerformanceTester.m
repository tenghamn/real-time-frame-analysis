classdef PerformanceTester
    %PERFORMANCETESTER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = PerformanceTester()

        end
        
        
    end
    
    methods(Static)
        
        function time = timeWriteOneFrameToDisk(frame)
            fileId = fopen('testFileWritingOneFrameToDisk.txt','W');
            tic
            for n=1:20
                fprintf(fileId,'%d;',frame(:));
            end
            time = toc/20;
            fclose(fileId);
            delete('testFileWritingOneFrameToDisk.txt');
        end
        
    end
end

