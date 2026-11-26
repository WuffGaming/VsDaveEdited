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
				var newScript:HScript = new HScript(Assets.getText(path), path);
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
            script.run();
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
				} catch(e:haxe.Exception) {
					trace('error parsing ' + script.name + ': ' + e);
					trace('\n' + e.details());
					loadedScripts.remove(script);
				}
			}
		}
	}
	public function setScripts(name:String, value:Dynamic)
	{
		for(script in loadedScripts)
			script.set(name, value);
	}
}