clc, clear, close;
addpath('../source/FileWriter');
addpath('../source/Cameras');
addpath('../source/SensingRegions');

camera = CameraSimulator();
sr = SensingRegions();

%% Setup sensing regions
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
name_3 = 'region_3';
name_4 = 'region_4';
name_5 = 'region_5';
name_6 = 'region_6';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.addNewRegion(name_3);
sr.addNewRegion(name_4);
sr.addNewRegion(name_5);
sr.addNewRegion(name_6);
sr.setRegionType(name_2,'reference');
sr.setRegionType(name_3,'reference');
sr.setRegionType(name_4,'background');
sr.setRegionType(name_5,'background');
sr.associateRegionWithSignal(name_2,name_1);
sr.associateRegionWithSignal(name_3,name_1);
sr.associateRegionWithSignal(name_4,name_1);
sr.associateRegionWithSignal(name_5,name_1);
sr.associateRegionWithSignal(name_5,name_6);
sr.associateRegionWithSignal(name_4,name_6);
sr.associateRegionWithSignal(name_3,name_6);
sr.associateRegionWithSignal(name_2,name_6);
%%
outputPath = './output/';
[frame,time] = camera.getNextFrame();
fw = FileWriter(outputPath,sr,camera.cameraInfo,frame);
%%
tic 
for n=1:100
    [frame,time] = camera.getNextFrame();
    fw.writeFrameToFiles(frame,time);
end
toc
camera.close();
fw.closeAllFiles();

%%

a = {}

a.('test_1') = fopen('test_1.txt','w');
a.('test_2') = fopen('test_2.txt','w');

disp(a)