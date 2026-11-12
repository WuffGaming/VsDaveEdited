package options;

import flixel.math.FlxMath;
import flixel.FlxG;

/**
i stole some shitt from psych 0.7.3 i hope you dont mind
sorry 
**/

// this is all settings junk
@:structInit class SaveVariables {
    public var downscroll:Null<Bool> = false;

    public var dfjk:Null<Bool> = false;

    public var newInput:Null<Bool> = true;

    public var offset:Null<Int> = 0;

    public var eyesores:Null<Bool> = true;

    public var begin_thing:Null<Bool> = false;

    public var accuracyDisplay:Null<Bool> = true;

    public var donoteclick:Null<Bool> = true;

    public var freeplayCuts:Null<Bool> = true;

    public var framerate:Null<Int> = 60;
}

class Settings {
    public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

    public static function save() {
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		FlxG.save.flush();
	}

    public static function load() {

		for (key in Reflect.fields(data))
			if (Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));


		if(FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
		}

		if(data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}

}