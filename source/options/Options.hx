package options;

import Controls.KeyboardScheme;
import flixel.FlxG;

class BaseOption extends MusicBeatSubstate
{
	public function new()
	{
		super();
		display = updateDisplay();
	}

	private var display:String;

	public final function getDisplay():String
	{
		return display;
	}

	// Returns whether the label is to be updated.
	public function pressEnter():Bool
	{
		return false;
	}

	public function pressLeft():Bool
	{
		return false;
	}

	public function pressRight():Bool
	{
		return false;
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}
}

class ControlOption extends BaseOption
{
	public function new(controls:Controls)
	{
		super();
	}

	public override function pressEnter():Bool
	{
		Settings.data.dfjk = !Settings.data.dfjk;

		controls.setKeyboardScheme(KeyboardScheme.Solo, true);

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return Settings.data.dfjk ? "DFJK" : "WASD";
	}
}

class OffsetOption extends BaseOption
{
	public override function pressLeft():Bool
	{
		Settings.data.offset--;
		display = updateDisplay();
		return true;
	}

	public override function pressRight():Bool
	{
		Settings.data.offset++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Offset: " + Settings.data.offset;
	}
}

class FramerateOption extends BaseOption
{
	public override function pressLeft():Bool
	{
		Settings.data.framerate--;
		if (Settings.data.framerate < 10) Settings.data.framerate = 10;
		display = updateDisplay();
		return true;
	}

	public override function pressRight():Bool
	{
		Settings.data.framerate++;
		if (Settings.data.framerate > 240) Settings.data.framerate = 240;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Framerate: " + Settings.data.framerate;
	}
}

class NewInputOption extends BaseOption
{
	public override function pressEnter():Bool
	{
		Settings.data.newInput = !Settings.data.newInput;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return Settings.data.newInput ? "Ghost Tapping" : "Base Tapping";
	}
}

class DownscrollOption extends BaseOption
{
	public override function pressEnter():Bool
	{
		Settings.data.downscroll = !Settings.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return Settings.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class AccuracyOption extends BaseOption
{
	public override function pressEnter():Bool
	{
		Settings.data.accuracyDisplay = !Settings.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy " + (!Settings.data.accuracyDisplay ? "off" : "on");
	}
}

class CutsceneOption extends BaseOption
{
	public override function pressEnter():Bool
	{
		Settings.data.freeplayCuts = !Settings.data.freeplayCuts;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Cutscenes " + (!Settings.data.freeplayCuts ? "off" : "on");
	}
}

class EyesoresOption extends BaseOption
{
	public override function pressEnter():Bool
	{
		Settings.data.eyesores = !Settings.data.eyesores;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Eyesores " + (!Settings.data.eyesores ? "false" : "true");
	}
}

class HitsoundOption extends BaseOption
{
	public override function pressEnter():Bool
	{
		Settings.data.donoteclick = !Settings.data.donoteclick;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Hitsounds " + (!Settings.data.donoteclick ? "off" : "on");
	}
}