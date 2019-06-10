clc, clear, close;
addpath('../source/UserCustomisation');
addpath('../source/LiveAnalyzer');
addpath('../source/DefaultLiveAnalyzers');

uc = UserCustomisation();

% Test default LiveAnalyzers
expectedDefaultSingleAxisLiveAnalyzers = {};
expectedDefaultSingleAxisLiveAnalyzers.('EmptySingleAxis') = '';
expectedDefaultSingleAxisLiveAnalyzers.('CameraViewOnSingleAxis') = 'Camera View';
expectedDefaultSingleAxisLiveAnalyzers.('TraceXMassOnSingleAxis') = 'Trace Mass (x-value)';
expectedDefaultSingleAxisLiveAnalyzers.('TraceYMassOnSingleAxis') = 'Trace Mass (y-value)';
assert(isequal(expectedDefaultSingleAxisLiveAnalyzers,uc.defaultSingleAxisLiveAnalyzers));

expectedDefaultTripleAxisLiveAnalyzers = {};
expectedDefaultTripleAxisLiveAnalyzers.('EmptyTripleAxis') = '';
expectedDefaultTripleAxisLiveAnalyzers.('CameraViewOnTripleAxis') = 'Camera View';
expectedDefaultTripleAxisLiveAnalyzers.('PercentualChangeOnTripleAxis') = 'Percentual change';
assert(isequal(expectedDefaultTripleAxisLiveAnalyzers,uc.defaultTripleAxisLiveAnalyzers));

% Test finding users LiveAnalyzers
expectedUsersTripleAxisLiveAnalyzers = {};
expectedUsersTripleAxisLiveAnalyzers.('TestPlotterTripleAxis') = 'Test Plotter Triple';
assert(isequal(expectedUsersTripleAxisLiveAnalyzers,uc.usersTripleAxisLiveAnalyzers));

% Test finding users LiveAnalyzers
expectedUsersSingleAxisLiveAnalyzers = {};
expectedUsersSingleAxisLiveAnalyzers.('PlotOnExternalAxis') = 'Plot on external axis';
expectedUsersSingleAxisLiveAnalyzers.('RegionPlotterSingleAxis') = 'Region Plotter';
expectedUsersSingleAxisLiveAnalyzers.('TestPlotterSingleAxis') = 'Test Plotter Single';
assert(isequal(expectedUsersSingleAxisLiveAnalyzers,uc.usersSingleAxisLiveAnalyzers));


% Test finding all single LiveAnalyzers
expectedSingleAxisLiveAnalyzers = {};
expectedSingleAxisLiveAnalyzers.('EmptySingleAxis') = '';
expectedSingleAxisLiveAnalyzers.('CameraViewOnSingleAxis') = 'Camera View';
expectedSingleAxisLiveAnalyzers.('TraceXMassOnSingleAxis') = 'Trace Mass (x-value)';
expectedSingleAxisLiveAnalyzers.('TraceYMassOnSingleAxis') = 'Trace Mass (y-value)';
expectedSingleAxisLiveAnalyzers.('PlotOnExternalAxis') = 'Plot on external axis';
expectedSingleAxisLiveAnalyzers.('RegionPlotterSingleAxis') = 'Region Plotter';
expectedSingleAxisLiveAnalyzers.('TestPlotterSingleAxis') = 'Test Plotter Single';
assert(isequal(expectedSingleAxisLiveAnalyzers,uc.singleAxisLiveAnalyzers));

% Test finding all triple LiveAnalyzers
expectedTripleAxisLiveAnalyzers = {};
expectedTripleAxisLiveAnalyzers.('EmptyTripleAxis') = '';
expectedTripleAxisLiveAnalyzers.('CameraViewOnTripleAxis') = 'Camera View';
expectedTripleAxisLiveAnalyzers.('PercentualChangeOnTripleAxis') = 'Percentual change';
expectedTripleAxisLiveAnalyzers.('TestPlotterTripleAxis') = 'Test Plotter Triple';
assert(isequal(expectedTripleAxisLiveAnalyzers,uc.tripleAxisLiveAnalyzers));

% Test getting the names of LiveAnalyzers
expectedSingleAxisNames = {'', 'Camera View', 'Trace Mass (x-value)', 'Trace Mass (y-value)', 'Plot on external axis', 'Region Plotter', 'Test Plotter Single'};
assert(isequal(expectedSingleAxisNames,uc.namesOfSingleAxisLiveAnalyzers));

% Test getting the names of LiveAnalyzers
expectedTripleAxisNames = {'', 'Camera View','Percentual change', 'Test Plotter Triple'};
assert(isequal(expectedTripleAxisNames,uc.namesOfTripleAxisLiveAnalyzers));

% Test getting a LiveAnalyzer by name
name = 'Camera View';
liveAnalyzer = uc.getSingleAxisLiveAnalyzerByName(name);
assert(isequal(liveAnalyzer.NAME,name));

% Test getting a LiveAnalyzer by name
name = 'Test Plotter Triple';
liveAnalyzer = uc.getTripleAxisLiveAnalyzerByName(name);
assert(isequal(liveAnalyzer.NAME,name));

% Test getting the names of presets
expectedPresetNames = {'Short exposure', 'Superduper'};
uc.namesOfPreSets
assert(isequal(expectedPresetNames,uc.namesOfPreSets))


% Test getting the presets by name
expectedPreset = ['name:	Superduper', newline, ...
    'imageHeight:	20', newline, ...
    'imageWidth:	8', newline, ...
    'imageLeftPosition:	1277', newline, ...
    'imageTopPosition:	1071', newline, ...
    'verticalBinning:	1', newline, ...
    'horisontalBinning:	1', newline, ...
    'exposureTime:	0.001035', newline, ...
    'numberOfAccumulations:	1', newline, ...
    'pixelReadoutRate:	280 MHz', newline, ...
    'overlapReadout:	1', newline, ...
    'spuriousNoiseFilter:	1', newline, ...
    'cycleMode:	Continuous', newline, ...
    'triggerMode:	Internal', newline, ...
    'simplePreAmpGainControl:	16-bit (low noise & high well capacity)', newline, ...
    'pixelEncoding:	Mono32', newline, ...
    'fanSpeed:	Off', newline, ...
    'electronicShutteringMode:	Rolling', newline, ...
    'fastAOIFrameRateEnable:	1'];
assert(isequal(expectedPreset,uc.getPreSetByName('Superduper')))


% expectedPresets = {};
% expectedPresets.('name') = 'Superduper';
% expectedPresets.('imageHeight') = 20;
% expectedPresets.('imageWidth') = 8;
% expectedPresets.('imageLeftPosition') = 1277;
% expectedPresets.('imageTopPosition') = 1071;
% expectedPresets.('verticalBinning') = 1;
% expectedPresets.('horisontalBinning') = 1;
% expectedPresets.('exposureTime') = 0.001035;
% expectedPresets.('numberOfAccumulations') = 1;
% expectedPresets.('pixelReadoutRate') = '280 MHz';
% expectedPresets.('overlapReadout') = 1;
% expectedPresets.('spuriousNoiseFilter') = 1;
% expectedPresets.('cycleMode') = 'Continuous';
% expectedPresets.('triggerMode') = 'Internal';
% expectedPresets.('simplePreAmpGainControl') = '16-bit (low noise & high well capacity)';
% expectedPresets.('pixelEncoding') = 'Mono32';
% expectedPresets.('fanSpeed') = 'Off';
% expectedPresets.('electronicShutteringMode') = 'Rolling';
% expectedPresets.('fastAOIFrameRateEnable') = 1;
% assert(uc.preSets.('Superduper'),expectedPresets)





