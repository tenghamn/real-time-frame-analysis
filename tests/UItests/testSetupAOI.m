classdef testSetupAOI < matlab.unittest.TestCase & matlab.uitest.TestCase
    %TESTSETUPAOI Summary of this class goes here
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
        function test_changing_AOI(testCase)
            
            % Choose Settings Tab
            tabs = testCase.App.SettingsTab;
            testCase.choose(tabs);
            
            % Reset AOI
            resetButton = testCase.App.ResetAOIButton;
            testCase.press(resetButton);
            
            % Check limits of axes
            axes = testCase.App.UIAxesSensingRegionsSettings;
            widthSpinnerAOI = testCase.App.AOIWidthSpinner;
            heightSpinnerAOI = testCase.App.AOIHeightSpinner;
            xPositionSpinner = testCase.App.AOIXpositionSpinner;
            yPositionSpinner = testCase.App.AOIYpositionSpinner;
            halfWidthLeft = round(widthSpinnerAOI.Value/2+0.1);
            halfWidthRight = round(widthSpinnerAOI.Value/2-0.1);
            halfHeightTop = round(heightSpinnerAOI.Value/2+0.1);
            halfHeightBottom = round(heightSpinnerAOI.Value/2-0.1);
            expectedXlim = [xPositionSpinner.Value - halfWidthLeft,xPositionSpinner.Value + halfWidthRight];
            expectedYlim = [yPositionSpinner.Value - halfHeightTop,yPositionSpinner.Value + halfHeightBottom];
            xlim = get(axes,'xlim');
            ylim = get(axes,'ylim');
            testCase.verifyEqual(xlim,expectedXlim);
            testCase.verifyEqual(ylim,expectedYlim);
            
            % Change AOI width
            widthSpinnerAOI = testCase.App.AOIWidthSpinner;
            testCase.type(widthSpinnerAOI,200);
            applyButton = testCase.App.ApplyAOIButton;
            testCase.press(applyButton);
            
            % Check limits of axes
            axes = testCase.App.UIAxesSensingRegionsSettings;
            widthSpinnerAOI = testCase.App.AOIWidthSpinner;
            heightSpinnerAOI = testCase.App.AOIHeightSpinner;
            xPositionSpinner = testCase.App.AOIXpositionSpinner;
            yPositionSpinner = testCase.App.AOIYpositionSpinner;
            halfWidthLeft = round(widthSpinnerAOI.Value/2+0.1);
            halfWidthRight = round(widthSpinnerAOI.Value/2-0.1);
            halfHeightTop = round(heightSpinnerAOI.Value/2+0.1);
            halfHeightBottom = round(heightSpinnerAOI.Value/2-0.1);
            expectedXlim = [xPositionSpinner.Value - halfWidthLeft,xPositionSpinner.Value + halfWidthRight];
            expectedYlim = [yPositionSpinner.Value - halfHeightTop,yPositionSpinner.Value + halfHeightBottom];
            xlim = get(axes,'xlim');
            ylim = get(axes,'ylim');
            testCase.verifyEqual(xlim,expectedXlim);
            testCase.verifyEqual(ylim,expectedYlim);
            
            % Reset AOI
            resetButton = testCase.App.ResetAOIButton;
            testCase.press(resetButton);
            
            % Check AOI values
            widthSpinner = testCase.App.AOIWidthSpinner;
            heightSpinner = testCase.App.AOIHeightSpinner;
            assert(widthSpinner.Value == 2160);
            assert(heightSpinner.Value == 2560);
            
            % Check limits of axes
            axes = testCase.App.UIAxesSensingRegionsSettings;
            widthSpinnerAOI = testCase.App.AOIWidthSpinner;
            heightSpinnerAOI = testCase.App.AOIHeightSpinner;
            expectedXlim = [1,widthSpinnerAOI.Value+1];
            expectedYlim = [1,heightSpinnerAOI.Value+1];
            xlim = get(axes,'xlim');
            ylim = get(axes,'ylim');
            testCase.verifyEqual(xlim,expectedXlim);
            testCase.verifyEqual(ylim,expectedYlim);
            
            % Change width, height and position of AOI
            widthSpinner = testCase.App.AOIWidthSpinner;
            heightSpinnerAOI = testCase.App.AOIHeightSpinner;
            yPositionSpinner = testCase.App.AOIYpositionSpinner;
            xPositionSpinner = testCase.App.AOIXpositionSpinner;
            applyButton = testCase.App.ApplyAOIButton;
            testCase.type(widthSpinner,200);
            testCase.type(heightSpinner,300);
            testCase.type(yPositionSpinner,300);
            testCase.type(xPositionSpinner,250);
            testCase.press(applyButton);
            
            % Check limits of axes
            axes = testCase.App.UIAxesSensingRegionsSettings;
            widthSpinnerAOI = testCase.App.AOIWidthSpinner;
            heightSpinnerAOI = testCase.App.AOIHeightSpinner;
            xPositionSpinner = testCase.App.AOIXpositionSpinner;
            yPositionSpinner = testCase.App.AOIYpositionSpinner;
            halfWidthLeft = round(widthSpinnerAOI.Value/2+0.1);
            halfWidthRight = round(widthSpinnerAOI.Value/2-0.1);
            halfHeightTop = round(heightSpinnerAOI.Value/2+0.1);
            halfHeightBottom = round(heightSpinnerAOI.Value/2-0.1);
            expectedXlim = [xPositionSpinner.Value - halfWidthLeft,xPositionSpinner.Value + halfWidthRight];
            expectedYlim = [yPositionSpinner.Value - halfHeightTop,yPositionSpinner.Value + halfHeightBottom];
            xlim = get(axes,'xlim');
            ylim = get(axes,'ylim');
            testCase.verifyEqual(xlim,expectedXlim);
            testCase.verifyEqual(ylim,expectedYlim);

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
% results = runtests('./tests/UItests/testSetupAOI.m')

