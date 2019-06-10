# andor-camera

A matlab software for controlling andor cameras.

## Usage

### Creating your own specific plotter

In the software there is a possibility to plot whatever you want. This is done by creating "plotter" classes and putting them in a folder called plotters in the working 
directory. There two types of plotters, single axis plotter and triple axis plotter. The single axis plotters allows you to plot on the one axis
in the Single Axis Plotter panel and the triple axis plotter allows you to plot on the three axes in the Triple Axis Plotter panel.

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
2. Triplpe axis plotter
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

### Setting up sensing regions

To setup sensing regions go to the settings tab. 

In the settings tab one can define sensing regions. With these regions you will be able choose what data will be saved and you can perform some live analysis using these regions. 

There are three different types of regions, ''signal'', ''reference'' and ''background''. One can add a new region by choosing ''Add region'' in the select region dropdown. This will create a ''signal'' region in the center of the camera view. Using the spinners below you can choose the size and position of these. 

### Create your own live analysis

To create your own live analysis create a matlab class called CustomLiveAnalyzer and let it inherit from LiveAnalyzer. 

## Code style

Please use MATLAB Programming Style Guidelines:

http://www.datatool.com/downloads/matlab_style_guidelines.pdf


## Colors
For figures:
BackgroundColor: [1.0,1.0,1.0]
ForegroundColor: [0.00,0.45,0.74]

For settings:
BackgroundColor: [0.94,0.94,0.94]
ForegroundColor: [0.00,0.45,0.74]

Buttons: 
BackgroundColor: [0.00,0.45,0.74]
FontColor: [1.0,1.0,1.0]
