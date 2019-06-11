# A camera software for real time frame analysis

Recording software for Andor cameras with the possibility of implementing analysis in real time.
Works with Zyla, iXon and Newton. You need to provide an Andor sdk for it to work.

![alt text](https://github.com/tenghamn/real-time-frame-analysis/raw/master/assets/example_screen.png)

# Usage

## Settings

To change camera settings, such as exposure time, number of accumulations and area of interest go to the camera settings tab.

## Implement your own analysis

In the software there is a possibility to plot whatever you want. This is done by writing "plotter" classes and store them in a folder called plotters in the matlab working directory. There two types of plotters, single axis plotter and triple axis plotter. The single axis plotters allows you to plot on the one axis in the Single Axis Plotter panel and the Triple axis plotter allows you to plot on the three axes in the Triple Axis Plotter shown in the figure below.
When you have provided a plotter class you can use it by choosing it in the plot function dropdown.

![alt text](https://github.com/tenghamn/real-time-frame-analysis/raw/master/assets/main_page.png)

The plotter classes needs to follow a certain pattern to work.
1. It needs to inherit the LiveAnalyzer class
    ```matlab
    classdef PlotterSingleAxis<LiveAnalyzer
    ``` 
2. You need to give it a name and specify if it is triple axis plotter or a single axis plotter by having the property TYPE to be either 'Single axis' or 'Triple axis'.
    ```matlab
    properties(Constant)
        NAME = 'Test Plotter Single';
        TYPE = 'Single axis';
    end
    ``` 
3. It can have a function called initializeSingleAxis or initalizeTripleAxis
    ```matlab
    function initializeSingleAxis(obj,axis)
        cla(axis);
        colorbar(axis);
        set(axis,'xlim', [1,size(obj.currentFrame,2)]);
        set(axis,'ylim', [1,size(obj.currentFrame,1)]);
    end
    ```
    This function is the first function called when the play button is pressed. Here you initialise your axis. In the code above, the axis is cleared, 
    a colorbar is added and then the xlim and ylim of the axis is set.
4. It needs to have a function called plotOnSingleAxis or plotOnTripleAxis
    ```matlab
    function plotOnSingleAxis(obj,axis)
        image(axis,obj.currentFrame,'CDataMapping','scaled');
    end
    ```
    This function is called every time a new frame is available. That frame exists in the class as obj.currentFrame. You can also access the timestamp of that frame, 
    the previous frame and the timestamp of the previous frame with `obj.currentTime`, `obj.previousFrame` and `obj.previousTime` respectively.
    
5. It can have a function called resetZoomSingleAxis or resetZoomTripelAxis
    ```matlab
    function resetZoomSingleAxis(obj,axis)
            set(axis,'xlim', [1,size(obj.currentFrame,2)]);
            set(axis,'ylim', [1,size(obj.currentFrame,1)]);
            set(axis,'zlimMode', 'auto');
    end
    ```
    This function is called when you press the house button above the figures. The intention of this function is to reset the zoom of the figure.
    
In the folder plotters there are some examples of how to manipulate the figures by adding buttons and extra functionality to the software. To start writing a plotter
you can use one of the templates below.
1. Single axis plotter
    ```matlab
    classdef TemplateOnSingleAxis<LiveAnalyzer
        properties(Constant)
            NAME = 'Template';
            TYPE = 'Single axis';
        end
    
        methods
            function obj = TemplateOnSingleAxis()
            
            end
        
            function initializeSingleAxis(obj,axis)
                cla(axis);
                colorbar(axis);
                set(axis,'xlim', [1,size(obj.currentFrame,2)]);
                set(axis,'ylim', [1,size(obj.currentFrame,1)]);
            end
        
            function plotOnSingleAxis(obj,axis)
                image(axis,obj.currentFrame,'CDataMapping','scaled');
            end
        
            function resetZoomSingleAxis(obj,axis)
                set(axis,'xlim', [1,size(obj.currentFrame,2)]);
                set(axis,'ylim', [1,size(obj.currentFrame,1)]);
                set(axis,'zlimMode', 'auto');
            end
        end
    end
    ```
2. Triple axis plotter
    ```matlab
    classdef TemplateTripleAxis<LiveAnalyzer
        properties(Constant)
            NAME = 'Template';
            TYPE = 'Triple axis';
        end
    
        methods
            function obj = TemplateTripleAxis()
            
            end
        
            function initializeTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
                cla(mainAxis);
                cla(miniAxisLeft);
                cla(miniAxisBottom);
            
                set(mainAxis,'xlim', [1,size(obj.currentFrame,2)]);
                set(mainAxis,'ylim', [1,size(obj.currentFrame,1)]);
                set(mainAxis,'zlimMode', 'auto');
            
                xlimits = get(mainAxis,'xlim');
                ylimits = get(mainAxis,'ylim');
            
                set(miniAxisLeft,'ylim',ylimits);
                set(miniAxisLeft,'Ydir','reverse');
                set(miniAxisBottom,'xlim',xlimits);
                colorbar(mainAxis);
            end
        
            function plotOnTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
                image(mainAxis,obj.currentFrame,'CDataMapping','scaled');
                averageInXDirection = obj.calculateAverageIntensityInXDirection(obj.currentFrame);
                averageInYDirection = obj.calculateAverageIntensityInYDirection(obj.currentFrame);
                plot(miniAxisBottom,averageInYDirection);
                plot(miniAxisLeft,averageInXDirection,1:size(averageInXDirection,1));
            
                set(mainAxis,'zlimMode', 'auto');
            
                xlimits = get(mainAxis,'xlim');
                ylimits = get(mainAxis,'ylim');
            
                set(miniAxisLeft,'ylim',ylimits);
                set(miniAxisLeft,'Ydir','reverse');
                set(miniAxisBottom,'xlim',xlimits);
            end
        
            function resetZoomTripleAxis(obj,mainAxis,miniAxisLeft,miniAxisBottom)
                set(mainAxis,'xlim', [1,size(obj.currentFrame,2)]);
                set(mainAxis,'ylim', [1,size(obj.currentFrame,1)]);
                set(mainAxis,'zlimMode', 'auto');
            
                xlimits = get(mainAxis,'xlim');
                ylimits = get(mainAxis,'ylim');
            
                set(miniAxisLeft,'ylim',ylimits);
                set(miniAxisLeft,'Ydir','reverse');
                set(miniAxisBottom,'xlim',xlimits);
                set(axis,'zlimMode', 'auto');
            end
        end
    end
    ```

## Sensing regions

There is a possibility to add define sensing regions of the camera view. This can be done under the settings tab of the software. To add a region go to the dropdown and choose 'add region'. Define the size of the region by changing the values in the spinner boxes below.

![alt text](https://github.com/tenghamn/real-time-frame-analysis/raw/master/assets/sensing_regions.png)

### Signal, background and reference regions

For convenience there is a possibility of defining the regions as a signal (default), background or reference region. 

This is done by checking the 'Is reference region' or 'Is background region' checkboxes. The regions will then be added in the listboxes in the bottom of the view. These regions can then be associated with the signal regions by clicking on them in the listboxes.

### Use the sensing regions in the plotters

In the plotter classes you can access the defined sensing regions by.
```matlab
obj.SensingRegions
```
To get the names of the regions use one of
```matlab
regionNames = obj.SensingRegions.namesOfAllRegions
signalNames = obj.SensingRegions.namesOfSignalRegions
referenceNames = obj.SensingRegions.namesOfReferenceRegions
backgroundNames = obj.SensingRegions.namesOfBackgroundRegions
```
To get the associations between regions one can use
```matlab
signalName = obj.SensingRegions.namesOfSignalRegions{1}
namesOfAssociatedReferenceRegions = obj.SensingRegions.getNamesOfAssociatedReferenceRegions(signalName)
namesOfAssociatedBackgroundRegions = obj.SensingRegions.getNamesOfAssociatedBackgroundRegions(signalName)
```
To plot a region one can use
```matlab
regionName = obj.SensingRegions.namesOfAllRegions{1};
region = obj.SensingRegions.getRegion(regionName);
data = region.getDataInRegion(obj.currentFrame)
image(axis,data,'CDataMapping','scaled');
```

# Code style

Please use MATLAB Programming Style Guidelines:

http://www.datatool.com/downloads/matlab_style_guidelines.pdf


## Colors
For figures:<br/>
BackgroundColor: [1.0,1.0,1.0] <br/>
ForegroundColor: [0.00,0.45,0.74]<br/>
<br/>
For settings:<br/>
BackgroundColor: [0.94,0.94,0.94]<br/>
ForegroundColor: [0.00,0.45,0.74]<br/>
<br/>
Buttons:<br/>
BackgroundColor: [0.00,0.45,0.74]<br/>
FontColor: [1.0,1.0,1.0]<br/>
<br/>
