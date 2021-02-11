% sample script to assemble a pbrt test scene for object and camera motion.
%
% Feb, 2021
%
% We load the "bare" Cornell box, and then (in theory) add the Stanford
% bunny and the MCC chart (and AF target?) so that we have a full test
% scene.
%

%{
% recipe test, since on some systems there are errant 0 depth pixels
thisR = piRecipeDefault('scene name', 'CornellBoxReference');
thisR.set('spatial resolution',[640 640]);
piWrite(thisR);
ourScene = piRender(thisR);
min(min(ourScene.depthMap))
ieNewGraphWin; mesh(ourScene.depthMap);
ieNewGraphWin; imagesc(ourScene.depthMap);
%}

%%
ieInit();
filmResolution = 256;
numRays = 64;
sceneLuminance = 100;
ourCamera = cpBurstCamera();
sensor = sensorFromFile('ar0132atSensorRGB');
ourCamera.cmodules(1) = cpCModule('sensor', sensor);

%% scene with no lens file (yet)
simpleScene = cpScene('pbrt', 'scenePath', 'CornellBoxReference', ...
    'sceneName', 'CornellBoxReference', ...
    'resolution', [filmResolution filmResolution], ...
    'numRays', numRays, ...
    'sceneLuminance', sceneLuminance);

ourCamera.cmodules(1).sensor = ...
    sensorSet(ourCamera.cmodules(1).sensor, ...
    'size', [filmResolution, filmResolution]);

% Look at the original scene by showing our camera and then clicking
% "Preview" to get a rendering.
% cpCameraWindow(ourCamera, simpleScene);

% for focus stacking let's make our lens wide-open and
% longer focal length so we get optical blur
ourCamera.cmodules(1).oi = oiSet(ourCamera.cmodules(1).oi,'optics focallength', .120);
ourCamera.cmodules(1).oi = oiSet(ourCamera.cmodules(1).oi,'optics fnumber',1.2);

% Add the Stanford bunny to the scene
bunny = load('bunny.mat');
simpleScene.thisR.set('asset',1, 'add', bunny.assetTree.Node{1});
%thisR.assets.show;
simpleScene.thisR.set('material', 'add', bunny.matList{1});
piWrite(simpleScene.thisR);

% Optionally add some motion to the bunny
% simpleScene.objectMotion = {{'Bunny_O', [1 0 0], [0 0 0]}};

% Take a look if we want
%{
scene = piRender(thisR);
sceneWindow(scene);
%}

cpCameraWindow(ourCamera, simpleScene);

% TODO Next:
% Add MCC
% Add AF chart if there is an asset for it
% Give the resulting scene to our camera & try again.

%%
