var workingStages:Array<String> = ['daveHouse', 'daveHouseNight', 'farm-night', 'farm', 'farm-sunset', 'polygonizedVoid', 'unfairVoid'];
var dadHitQueue:Bool = false;
var enabledScript:Bool = false;

function postCreate() {
    if (workingStages.contains(PlayState.curStage)) {
        enabledScript = true;
        PlayState.instance.autoZoomCam = false;
    } 
}

function onDadHit() {
	if (enabledScript)
		dadHitQueue = true;
}

function onPlayerHit() {
	if (enabledScript)
		dadHitQueue = false;
}

function beatHit() {
	if (enabledScript)
        PlayState.instance.focusOnDadGlobal = dadHitQueue;
		PlayState.instance.ZoomCam(dadHitQueue);
}