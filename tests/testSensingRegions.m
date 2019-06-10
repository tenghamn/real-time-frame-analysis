clc, clear, close;
addpath('../source/SensingRegions');


% Test initialisation of regions
sr =  SensingRegions();
assert(sr.nRegions()==0);

% Test adding regions
sr = SensingRegions();
name_1 = sr.addNewRegion();
assert(sr.nRegions==1);
assert(isequal(name_1,'region_1'));
name_2 = sr.addNewRegion('second_region');
assert(sr.nRegions==2);
assert(isequal(name_2,'second_region'));
assert(isequal(sr.namesOfAllRegions,{'region_1','second_region'}));
assert(isequal(sr.namesOfSignalRegions,{'region_1','second_region'}));


% Test removing regions
sr.removeRegion('second_region');
assert(sr.nRegions==1);
assert(isequal(sr.namesOfAllRegions,{'region_1'}));

% Test getting the regions fill coordinates by name
name = 'region_1';
[x,y] = sr.getRegionFillCoordinates(name);
expected_x = [-1; 1; 1; -1; -1];
expected_y = [-1; -1; 1; 1; -1];
assert(isequal(x,expected_x));
assert(isequal(y,expected_y));

% Test the function that checks if region name exists
sr = SensingRegions();
sr.addNewRegion();
result = sr.regionNameExists('region_1');
assert(result)
result = sr.regionNameExists('channel');
assert(result==false);

% Test adding a region with a name
sr = SensingRegions();
name = 'regionName';
sr.addNewRegion(name);
result = sr.regionNameExists(name);
assert(result)

% Test editing a region name
sr = SensingRegions();
name = 'regionName';
sr.addNewRegion(name);
newName = 'newName';
sr.editRegionName(name,newName);
result = sr.regionNameExists(name);
assert(~result)
result = sr.regionNameExists(newName);
assert(result);

% Test setting position, width and height of region
sr = SensingRegions();
name = 'regionName';
sr.addNewRegion(name);
width = 10;
height = 20;
xPosition = 5;
yPosition = -5;
sr.setWidthOfRegion(name,width);
sr.setHeightOfRegion(name,height);
sr.setxPositionOfRegion(name,xPosition);
sr.setyPositionOfRegion(name,yPosition);
assert(sr.getWidthOfRegion(name)==width);
assert(sr.getHeightOfRegion(name)==height);
assert(sr.getxPositionOfRegion(name)==xPosition);
assert(sr.getyPositionOfRegion(name)==yPosition);

% Test setting a region as reference
sr = SensingRegions();
name = 'regionName';
sr.addNewRegion(name);
sr.setRegionType(name,'reference');
assert(isequal(sr.getRegionType(name),'reference'));

% Test getting names of all reference regions
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'ref_1';
name_3 = 'ref_2';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.addNewRegion(name_3);
sr.setRegionType(name_1,'signal');
sr.setRegionType(name_2,'reference');
sr.setRegionType(name_3,'reference');
expectedNames = {name_2,name_3};
assert(isequal(sr.namesOfReferenceRegions,expectedNames));

% Test setting associated reference regions
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'ref_1';
name_3 = 'ref_2';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.addNewRegion(name_3);
sr.setRegionType(name_1,'signal');
sr.setRegionType(name_2,'reference');
sr.setRegionType(name_3,'background');
sr.associateRegionWithSignal(name_2,name_1);
sr.associateRegionWithSignal(name_3,name_1);
assert(isequal(sr.associationsOfRegion(name_1),{name_2,name_3}));

% Test editing the name of a reference region
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.setRegionType(name_2,'reference');
sr.associateRegionWithSignal(name_2,name_1);
newName_2 = 'ref_region_1';
sr.editRegionName(name_2,newName_2);
expectedRegionNames = {name_1,newName_2};
assert(isequal(expectedRegionNames,sr.namesOfAllRegions));
expectedAssociation = {newName_2};
assert(isequal(expectedAssociation,sr.associationsOfRegion(name_1)));

% Test removing a reference region
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.setRegionType(name_2,'reference');
sr.associateRegionWithSignal(name_1,name_2);
sr.removeRegion(name_2);
expectedAssociation = {};
assert(isequal(expectedAssociation,sr.associationsOfRegion(name_1)));

% Test getting the names of associated reference and background regions
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
name_3 = 'region_3';
name_4 = 'region_4';
name_5 = 'region_5';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.addNewRegion(name_3);
sr.addNewRegion(name_4);
sr.addNewRegion(name_5);
sr.setRegionType(name_2,'reference');
sr.setRegionType(name_3,'reference');
sr.setRegionType(name_4,'background');
sr.setRegionType(name_5,'background');
sr.associateRegionWithSignal(name_2,name_1);
sr.associateRegionWithSignal(name_3,name_1);
sr.associateRegionWithSignal(name_4,name_1);
sr.associateRegionWithSignal(name_5,name_1);
expectedReferenceAssociation = {name_2,name_3};
expectedBackgroundAssociation = {name_4,name_5};
assert(isequal(expectedReferenceAssociation,sr.getNamesOfAssociatedReferenceRegions(name_1)));
assert(isequal(expectedBackgroundAssociation,sr.getNamesOfAssociatedBackgroundRegions(name_1)));

% Test editing the name of a reference region
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
name_3 = 'region_3';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.addNewRegion(name_3);
sr.setRegionType(name_2,'reference');
sr.setRegionType(name_3,'reference');
sr.associateRegionWithSignal(name_2,name_1);
newName_3 = 'ref_region_1';
sr.editRegionName(name_3,newName_3);
expectedAssociation = {name_2};
assert(isequal(expectedAssociation,sr.associationsOfRegion(name_1)));

% Test toggling between signal and reference
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.setRegionType(name_2,'reference');
sr.setRegionType(name_2,'signal');
expectedAssociation = {};
assert(isequal(expectedAssociation,sr.associationsOfRegion(name_2)));


% Edit name of background region
sr = SensingRegions();
name_1 = 'region_1';
name_2 = 'region_2';
name_3 = 'region_3';
sr.addNewRegion(name_1);
sr.addNewRegion(name_2);
sr.addNewRegion(name_3);
sr.setRegionType(name_2,'background');
sr.setRegionType(name_3,'background');
sr.associateRegionWithSignal(name_2,name_1);
sr.associateRegionWithSignal(name_3,name_1);
sr.editRegionName(name_3,'background_region');
expectedAssociation = {'region_2','background_region'};
assert(isequal(expectedAssociation,sr.associationsOfRegion(name_1)));











