classdef testLiveAnalyzer < matlab.unittest.TestCase & matlab.uitest.TestCase
    %TESTLIVEANALYZER Summary of this class goes here
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
        
        function test_all_different_live_plots(testCase)
            startButton = testCase.App.StartButton;
            testCase.press(startButton);
            
            
        end
            
        
        
        
%         function test_analysing_one_signal_region(testCase)
%             % Choose Settings Tab
%             tabs = testCase.App.SettingsTab;
%             testCase.choose(tabs);
%             
%             % Verify Settings Tab is selected
%             testCase.verifyEqual(testCase.App.TabGroup.SelectedTab.Title,'Settings');
%             
%             % Add a region
%             dropDown = testCase.App.SelectRegionDropDown;
%             testCase.choose(dropDown,'Add region');
%             
%             % Change position and size of region
%             testCase.type(testCase.App.WidthSpinner,10);
%             testCase.type(testCase.App.HeightSpinner,500);
%             testCase.type(testCase.App.XpositionSpinner,25);
%             testCase.type(testCase.App.YpositionSpinner,347);
%             
%             % Choose Main Tab
%             tabs = testCase.App.Main;
%             testCase.choose(tabs);
%             
%             % Verify the items in the dropdown
%             dropDown = testCase.App.SelectRegionToAnalyzeDropDown;
%             expectedDropDownItems = {'','region_1'};
%             disp(dropDown.Items)
%             testCase.verifyEqual(expectedDropDownItems,dropDown.Items);
%             
%             % Choose region_1 to analyse
%             testCase.choose(dropDown,'region_1');
%             
%             
%         end 
    end
end

% To run the test run the following commands
% addpath('../..');
% addpath('../../source/')
% addpath('../../source/Camera')
% addpath('../../source/SensingRegions')
% addpath('../../source/CameraSimulator')
% addpath('../../source/LiveAnalyzer')
% addpath('../../assets/')
% results = runtests('testLiveAnalyzer')