classdef testSetupSensingRegionsUI < matlab.unittest.TestCase & matlab.uitest.TestCase
    
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
        function test_choosing_tab(testCase)
            % Choose Settings Tab
            tabs = testCase.App.SettingsTab;
            testCase.choose(tabs);
            
            % Verify Settings Tab is selected
            testCase.verifyEqual(testCase.App.TabGroup.SelectedTab.Title,'Settings');
        end
        
        function test_adding_and_removing_regions(testCase)
            % Choose Settings Tab
            tabs = testCase.App.SettingsTab;
            testCase.choose(tabs);
            
            % Test intital select region dropdown itmes
            expectedInitialDropDownItems = {'','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedInitialDropDownItems);
            
            % Add a region
            dropDown = testCase.App.SelectRegionDropDown;
            testCase.choose(dropDown,2)
            
            % Verify the items in the dropdown
            expectedDropDownItems = {'region_1','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);
            
            % Add two regions
            testCase.choose(dropDown,2)
            testCase.choose(dropDown,3)
            
            % Verify the items in the dropdown
            expectedDropDownItems = {'region_1','region_2','region_3','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);
            
            % Remove one region
            removeRegionButton = testCase.App.DeleteRegionButton;
            testCase.press(removeRegionButton);
            
            % Verify items in dropdown
            expectedDropDownItems = {'region_1','region_2','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);
            
            % Press remove region button several times
            removeRegionButton = testCase.App.DeleteRegionButton;
            testCase.press(removeRegionButton);
            testCase.press(removeRegionButton);
            testCase.press(removeRegionButton);
            testCase.press(removeRegionButton);
            testCase.press(removeRegionButton);
            testCase.press(removeRegionButton);
            
            % Verify items in dropdown
            expectedDropDownItems = {'','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);
            
            % Add 5 regions then 
            dropDown = testCase.App.SelectRegionDropDown;            
            testCase.choose(dropDown,2);
            testCase.choose(dropDown,2);
            testCase.choose(dropDown,3);
            testCase.choose(dropDown,4);
            testCase.choose(dropDown,5);
            
            % Remove region 1, 4 and 3
            removeRegionButton = testCase.App.DeleteRegionButton;
            testCase.choose(dropDown,1);
            testCase.press(removeRegionButton);
            testCase.choose(dropDown,3);
            testCase.press(removeRegionButton);
            testCase.choose(dropDown,2);
            testCase.press(removeRegionButton);
            
            % Verify items in dropdown
            expectedDropDownItems = {'region_2','region_5','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);    
        end
        
        function test_editing_region_size_and_position(testCase)
            % Choose Settings Tab
            tabs = testCase.App.SettingsTab;
            testCase.choose(tabs);
            
            % Add two regions
            dropDown = testCase.App.SelectRegionDropDown;
            testCase.choose(dropDown,2)
            testCase.choose(dropDown,2)
            
            % Change position and size of region_2
            widthSpinner = testCase.App.WidthSpinner;
            heightSpinner = testCase.App.HeightSpinner;
            xpositionSpinner = testCase.App.XpositionSpinner;
            ypositionSpinner = testCase.App.YpositionSpinner;
            testCase.type(widthSpinner,2);
            testCase.type(heightSpinner,3);
            testCase.type(xpositionSpinner,4);
            testCase.type(ypositionSpinner,5);
            
            % Verify size and position
            expectedWidth = 2;
            expectedHeight = 3;
            expectedxPosition = 4;
            expectedyPosition = 5;
            testCase.verifyEqual(testCase.App.WidthSpinner.Value,expectedWidth); 
            testCase.verifyEqual(testCase.App.HeightSpinner.Value,expectedHeight); 
            testCase.verifyEqual(testCase.App.XpositionSpinner.Value,expectedxPosition); 
            testCase.verifyEqual(testCase.App.YpositionSpinner.Value,expectedyPosition); 
            
            % Choose region_1
            testCase.choose(dropDown,'region_1');
            
            % Verify size and position
            expectedWidth = 1;
            expectedHeight = 1;
            expectedxPosition = 248;
            expectedyPosition = 347;
            testCase.verifyEqual(testCase.App.WidthSpinner.Value,expectedWidth); 
            testCase.verifyEqual(testCase.App.HeightSpinner.Value,expectedHeight); 
            testCase.verifyEqual(testCase.App.XpositionSpinner.Value,expectedxPosition); 
            testCase.verifyEqual(testCase.App.YpositionSpinner.Value,expectedyPosition); 
            
            % Choose region_2
            testCase.choose(dropDown,'region_2');
            
            % Verify size and position
            expectedWidth = 2;
            expectedHeight = 3;
            expectedxPosition = 4;
            expectedyPosition = 5;
            testCase.verifyEqual(testCase.App.WidthSpinner.Value,expectedWidth); 
            testCase.verifyEqual(testCase.App.HeightSpinner.Value,expectedHeight); 
            testCase.verifyEqual(testCase.App.XpositionSpinner.Value,expectedxPosition); 
            testCase.verifyEqual(testCase.App.YpositionSpinner.Value,expectedyPosition);
        end
        
        function test_choosing_reference_and_background_regions(testCase)
            % Choose Settings Tab
            tabs = testCase.App.SettingsTab;
            testCase.choose(tabs);
            
            % Add 5 regions
            dropDown = testCase.App.SelectRegionDropDown;
            testCase.choose(dropDown,'Add region')
            testCase.choose(dropDown,'Add region')
            testCase.choose(dropDown,'Add region')
            testCase.choose(dropDown,'Add region')
            testCase.choose(dropDown,'Add region')
            
            % Choose region_2 and rename it to ref_1
            testCase.choose(dropDown,'region_2')
            testCase.type(dropDown,'ref_1');
            
            % Make it rererence
            isReferenceCheckBox = testCase.App.IsReferenceRegionCheckBox;
            testCase.press(isReferenceCheckBox);
            
            % Verify that the reference and background listboxes becomes
            % disabled
            referenceListBox = testCase.App.ReferenceRegionsListBox;
            backgroundListBox = testCase.App.BackgroundRegionsListBox;
            testCase.verifyEqual(referenceListBox.Enable,'off');
            testCase.verifyEqual(backgroundListBox.Enable,'off');
            
            % Verify the items in the dropdown
            expectedDropDownItems = {'region_1','region_3','region_4','region_5','ref_1','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);
            
            % Choose region_3 and rename it to ref_2
            testCase.choose(dropDown,'region_3')
            testCase.type(dropDown,'ref_2');
            
            % Make it rererence
            isReferenceCheckBox = testCase.App.IsReferenceRegionCheckBox;
            testCase.press(isReferenceCheckBox);
            
            % Choose region_4 and rename it to bkg_1
            testCase.choose(dropDown,'region_4')
            testCase.type(dropDown,'bkg_1');
            
            % Verify that reference and background listboxes are enabled 
            referenceListBox = testCase.App.ReferenceRegionsListBox;
            backgroundListBox = testCase.App.BackgroundRegionsListBox;
            testCase.verifyEqual(referenceListBox.Enable,'on');
            testCase.verifyEqual(backgroundListBox.Enable,'on');
            
            % Verify the items in the dropdown
            expectedDropDownItems = {'region_1','region_5','ref_1','ref_2','bkg_1','Add region'};
            testCase.verifyEqual(testCase.App.SelectRegionDropDown.Items,expectedDropDownItems);
            
            % Make it reference
            isReferenceCheckBox = testCase.App.IsReferenceRegionCheckBox;
            testCase.press(isReferenceCheckBox);
            
            % Make it background
            isBackgroundCheckBox = testCase.App.IsBackgroundRegionCheckBox;
            testCase.press(isBackgroundCheckBox);
            
            % Verify that the reference box is unchecked
            isReferenceCheckBox = testCase.App.IsReferenceRegionCheckBox;
            testCase.verifyFalse(isReferenceCheckBox.Value);
            
            % Verify that the reference and background listboxes becomes
            % disabled
            referenceListBox = testCase.App.ReferenceRegionsListBox;
            backgroundListBox = testCase.App.BackgroundRegionsListBox;
            testCase.verifyEqual(referenceListBox.Enable,'off');
            testCase.verifyEqual(backgroundListBox.Enable,'off');
            
            % Choose region_5 and rename it to bkg_2
            testCase.choose(dropDown,'region_5');
            testCase.type(dropDown,'bkg_2');
            
            % Make it background
            isBackgroundCheckBox = testCase.App.IsBackgroundRegionCheckBox;
            testCase.press(isBackgroundCheckBox);
            
            % Choose region_1
            testCase.choose(dropDown,'region_1');
            
            % Verify that reference and background listboxes are enabled 
            referenceListBox = testCase.App.ReferenceRegionsListBox;
            backgroundListBox = testCase.App.BackgroundRegionsListBox;
            testCase.verifyEqual(referenceListBox.Enable,'on');
            testCase.verifyEqual(backgroundListBox.Enable,'on');
            
            % Verify the items in the reference and background listboxes 
            referenceListBox = testCase.App.ReferenceRegionsListBox;
            backgroundListBox = testCase.App.BackgroundRegionsListBox;
            testCase.verifyEqual(referenceListBox.Items,{'ref_1','ref_2'});
            testCase.verifyEqual(backgroundListBox.Items,{'bkg_1','bkg_2'});
            
            % Associate ref_1, bkg_1 and bkg_2 with the region_1
            testCase.choose(referenceListBox,'ref_1');
            testCase.choose(backgroundListBox,{'bkg_1','bkg_2'});
            
            % Verify the choosen values in the listboxes
            testCase.verifyEqual(referenceListBox.Value,{'ref_1'});
            testCase.verifyEqual(backgroundListBox.Value,{'bkg_1','bkg_2'});
            
            % Verify values in the drop down
            disp(dropDown.Items);
            testCase.verifyEqual(dropDown.Items,{'region_1','ref_1','ref_2','bkg_1','bkg_2','Add region'});
            
            % Choose 'bkg_2' and rename it to dark_background
            dropDown = testCase.App.SelectRegionDropDown;
            testCase.choose(dropDown,'bkg_2');
            testCase.type(dropDown,'dark_background');
            
            % Choose region_1
            testCase.choose(dropDown,'region_1');
            
            % Verify the choosen values in the listboxes
            testCase.verifyEqual(referenceListBox.Value,{'ref_1'});
            disp(backgroundListBox.Value);
            testCase.verifyEqual(backgroundListBox.Value,{'bkg_1','dark_background'});
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
% results = runtests('./tests/UItests/testSetupSensingRegionsUI.m')
