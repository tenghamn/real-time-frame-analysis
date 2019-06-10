classdef UserCustomisation
    %CUSTOMISATIONTOOL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        namesOfSingleAxisLiveAnalyzers
        namesOfTripleAxisLiveAnalyzers
        singleAxisLiveAnalyzers
        tripleAxisLiveAnalyzers
        defaultSingleAxisLiveAnalyzers
        defaultTripleAxisLiveAnalyzers
        usersSingleAxisLiveAnalyzers
        usersTripleAxisLiveAnalyzers
        preSets
        namesOfPreSets
    end
    
    methods
        
        function obj = UserCustomisation()
        end
        
        function names = get.namesOfPreSets(obj)
            names = {};
            if ~isstruct(obj.preSets)
                return;
            end
            fields = fieldnames(obj.preSets);
            for n=1:length(fields)
                names{end+1} = obj.preSets.(fields{n});
            end
        end
        
        
        function preSets = get.preSets(obj)
            preSets = {};
            txtFiles = obj.findTxtFilesInPreSetsFolder();
            for n=1:length(txtFiles)
                [preset, name] = obj.readPreSetsFromFile(txtFiles{n});
                preSets.(strrep(txtFiles{n},'.txt','')) = name;
            end
        end
        
        function preset = getPreSetByName(obj,name)
            txtFiles = obj.findTxtFilesInPreSetsFolder();
            for n=1:length(txtFiles)
                [preset, presetName] = obj.readPreSetsFromFile(txtFiles{n});
                if isequal(name,presetName)
                    return
                end
            end
        end
        
        function names = get.namesOfSingleAxisLiveAnalyzers(obj)
            names = {};
            if ~isstruct(obj.singleAxisLiveAnalyzers)
                return;
            end
            fieldNames = fieldnames(obj.singleAxisLiveAnalyzers);
           for n=1:length(fieldNames)
                names{end+1} = obj.singleAxisLiveAnalyzers.(fieldNames{n});
           end
        end
        
        function names = get.namesOfTripleAxisLiveAnalyzers(obj)
            names = {};
            fieldNames = fieldnames(obj.tripleAxisLiveAnalyzers);
            for n=1:length(fieldNames)
                names{end+1} = obj.tripleAxisLiveAnalyzers.(fieldNames{n});
            end
        end
        
        function liveAnalyzers = get.usersSingleAxisLiveAnalyzers(obj)
            classNames = obj.findClassesInPlotterFolder();
            plotterNames = obj.checkPlotterNames(classNames);
            liveAnalyzers = struct;
            for n=1:length(classNames)
                if obj.isSingleAxisPlotter(classNames{n})
                    liveAnalyzers.(classNames{n}) = plotterNames{n};
                end
            end
        end
        
        function liveAnalyzers = get.usersTripleAxisLiveAnalyzers(obj)
            classNames = obj.findClassesInPlotterFolder();
            plotterNames = obj.checkPlotterNames(classNames);
            liveAnalyzers = struct;
            for n=1:length(classNames)
                if obj.isTripleAxisPlotter(classNames{n})
                    liveAnalyzers.(classNames{n}) = plotterNames{n};
                end
            end
        end
        
        function liveAnalyzers = get.singleAxisLiveAnalyzers(obj)
           liveAnalyzers = struct;
           fieldNames = fieldnames(obj.defaultSingleAxisLiveAnalyzers);
           for n=1:length(fieldNames)
                liveAnalyzers.(fieldNames{n}) = obj.defaultSingleAxisLiveAnalyzers.(fieldNames{n});
           end
           
           fieldNames = fieldnames(obj.usersSingleAxisLiveAnalyzers);
           for n=1:length(fieldNames)
                liveAnalyzers.(fieldNames{n}) = obj.usersSingleAxisLiveAnalyzers.(fieldNames{n});
           end
        end
        
        function liveAnalyzers = get.tripleAxisLiveAnalyzers(obj)
           liveAnalyzers = struct;
           fieldNames = fieldnames(obj.defaultTripleAxisLiveAnalyzers);
           for n=1:length(fieldNames)
                liveAnalyzers.(fieldNames{n}) = obj.defaultTripleAxisLiveAnalyzers.(fieldNames{n});
           end
           
           fieldNames = fieldnames(obj.usersTripleAxisLiveAnalyzers);
           for n=1:length(fieldNames)
                liveAnalyzers.(fieldNames{n}) = obj.usersTripleAxisLiveAnalyzers.(fieldNames{n});
           end
        end
        
        function liveAnalyzers = get.defaultSingleAxisLiveAnalyzers(~)
            liveAnalyzers = struct;
            liveAnalyzers.('EmptySingleAxis') = '';
            liveAnalyzers.('CameraViewOnSingleAxis') = 'Camera View';
            liveAnalyzers.('TraceXMassOnSingleAxis') = 'Trace Mass (x-value)';
            liveAnalyzers.('TraceYMassOnSingleAxis') = 'Trace Mass (y-value)';
        end
        
        function liveAnalyzers = get.defaultTripleAxisLiveAnalyzers(~)
            liveAnalyzers = struct;
            liveAnalyzers.('EmptyTripleAxis') = '';
            liveAnalyzers.('CameraViewOnTripleAxis') = 'Camera View';
            liveAnalyzers.('PercentualChangeOnTripleAxis') = 'Percentual change';
        end
        
        function LiveAnalyzer = getSingleAxisLiveAnalyzerByName(obj,name)
            fieldNames = fieldnames(obj.singleAxisLiveAnalyzers);
            for n=1:length(fieldNames)
                if isequal(obj.singleAxisLiveAnalyzers.(fieldNames{n}),name)
                    LiveAnalyzer = eval(strcat(fieldNames{n},'()'));
                    break;
                end
            end
        end
        
        function LiveAnalyzer = getTripleAxisLiveAnalyzerByName(obj,name)
            fieldNames = fieldnames(obj.tripleAxisLiveAnalyzers);
            for n=1:length(fieldNames)
                if isequal(obj.tripleAxisLiveAnalyzers.(fieldNames{n}),name)
                    LiveAnalyzer = eval(strcat(fieldNames{n},'()'));
                    break;
                end
            end
        end
        
        function plotterNames = checkPlotterNames(obj,classNames)
            plotterNames = {};
            for n=1:length(classNames)
                Plotter = eval(strcat(classNames{n},'()'));
                plotterNames{end+1} = Plotter.NAME;
            end
        end
        
        function result = isSingleAxisPlotter(obj,className)
            Plotter = eval(strcat(className,'()'));
            result = isequal(Plotter.TYPE,'Single axis');
        end
        
        function result = isTripleAxisPlotter(obj,className)
            Plotter = eval(strcat(className,'()'));
            result = isequal(Plotter.TYPE,'Triple axis');
        end
        
    end
    
    methods(Static)
        
        function classNames = findClassesInPlotterFolder()
            classNames = {};
            try
                addpath('./plotters');
                listing = dir('./plotters');
                for n=1:length(listing)
                    name = listing(n).name;
                    if exist(listing(n).name)==2
                        nameSplitted = strsplit(name,'.');
                        nameWithoutExtension = nameSplitted{1};
                        if exist(nameWithoutExtension,'class') == 8
                            classNames{end+1} = nameWithoutExtension;
                        end
                    end
                end
            catch
        
            end
        end
        
        function txtFileNames = findTxtFilesInPreSetsFolder()
            txtFileNames = {};
            try
                addpath('./presets');
                listing = dir('./presets');
                for n=1:length(listing)
                    matchStr = regexp(listing(n).name,'.txt$');
                    if ~isequal(matchStr,[])
                        txtFileNames{end+1} = listing(n).name;
                    end
                end
            catch
        
            end
        end
        
        function [preSets, name] = readPreSetsFromFile(filename)
            path = ['./presets/', filename];
            preSets = fileread(path);
            match = regexp(preSets,'(?<=name:\t)[^\f\n\r\t\v]+','match');
            name = match{1};
        end
    end
    
    
end

