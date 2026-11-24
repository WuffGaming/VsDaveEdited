package modding.scripting;

import flixel.group.FlxGroup;
import modding.scripting.HScript;

class HScriptPack extends FlxGroup {
    public var loadedScripts:Array<HScript> = [];

    public function new(paths:Array<String>, ?autoRun:Bool = true) {
        super();
        for(path in paths)
		{
			if (Assets.exists(path)) {
				var newScript:HScript = new HScript(Assets.getText(path), {name: path, autoRun: false, autoPreset: true});
				loadedScripts.push(newScript);
				trace('loaded $path');
			}
			#if debug 
			else
				 trace('$path was null'); 
			#end
		}
		if (autoRun)
			runScripts();
    }

    public function runScripts() {
        for (script in loadedScripts) {
            script.safeExecute();
        }
    }

	public function callScripts(fun:String, ?args:Array<Dynamic>)
	{
		for(script in loadedScripts) {
			@:privateAccess {
				var ny: Dynamic = script.interp.variables.get(fun);
				try {
					if(ny != null && Reflect.isFunction(ny))
						script.call(fun, args);
				} catch(e) {
					trace('error parsing script: ' + e);
				}
			}
		}
	}
	public function setScripts(name:String, value:Dynamic, allowOverride:Bool = true)
	{
		for(script in loadedScripts)
			script.set(name, value, allowOverride);
	}
}