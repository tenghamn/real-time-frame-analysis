classdef testBinningAndAOI < matlab.unittest.TestCase & matlab.uitest.TestCase
    %TESTBINNINGANDAOI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        App
    end
    
    methods (TestMethodSetup)
        function launchApp(testCase)
            testCase.App = main;
            testCase.addTeardown(@delete,testCase.App);
        end
    end
    
    methods (Test)
        function test_changing_binning(testCase)
            
            % Choose Settings Tab
            tabs = testCase.App.SettingsTab;
            testCase.choose(tabs);
            
            % Reset AOI
            resetButton = testCase.App.ResetAOIButton;
            testCase.press(resetButton);
            
            
            
            
        end
        
        
        
    end
end

% To run the test run the following commands
% addpath('/source/')
% addpath('/source/Cameras')
% addpath('/source/SensingRegions')
% addpath('/source/LiveAnalyzer')
% addpath('/assets/')
% addpath('/source/UserCustomisation')
% addpath('/source/DefaultLiveAnalyzers')
% addpath('/source/FileWriter')
% results = runtests('./tests/UItests/testBinningAndAOI.m')

