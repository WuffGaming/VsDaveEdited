package modding.scripting;

import flixel.FlxG;
import flixel.util.FlxColor;

import insanity.Script;
import insanity.Config;
import insanity.Environment;
import insanity.backend.Interp;

class HScript extends Script {
    public function new(string:String, name:String = 'hscript', ?environment:Environment) {
		Config.interpClass = DaveInterp;
        super(string, name, environment);
    }

	public function run() {
		try {
			start();
		}
		catch(e:haxe.Exception) {
			throw e.details();
		}
	}

	public function set(name:String, whatItIs:Dynamic) {
		variables.set(name, whatItIs);
	}

    override function setDefaults() {
		super.setDefaults();
        set('Type', Type);

		#if sys
		set('File', File);
		set('FileSystem', FileSystem);
		#end

		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxCamera', flixel.FlxCamera);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('PlayState', PlayState);
		set('CoolUtil', CoolUtil);
		set('Paths', Paths);
		set('Conductor', Conductor);
		set('Character', Character);
		set('HealthIcon', HealthIcon);
		set('Alphabet', Alphabet);
		set('Note', Note);
        set('StrumNote', StrumNote);
		set('Settings', options.Flags.Settings);

		set('Assets', modding.HAssets);

		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);

		set('game', FlxG.state);
    }

	public static function init() {
		Config.typeProxy.set('lime.utils.Assets', HAssets);
		Config.typeProxy.set('openfl.utils.Assets', HAssets);
	}
}

class DaveInterp extends Interp {
	public function new(?environment:Environment, ?parent:Dynamic) {
		super(environment, parent);

		argumentOverflow = false;
		safeFunctions = true;
	}
}

class CustomFlxColor {
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int 
		return cast FlxColor.fromInt(Value);

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);

	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);

	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);

	public static function fromString(str:String):Int
		return cast FlxColor.fromString(str);

	public static function add(lhs:FlxColor, rhs:FlxColor):Int
		return cast FlxColor.add(lhs, rhs);

	public static function subtract(lhs:FlxColor, rhs:FlxColor):Int
		return cast FlxColor.subtract(lhs, rhs);

	public static function multiply(lhs:FlxColor, rhs:FlxColor):Int
		return cast FlxColor.multiply(lhs, rhs);

	public static function gradient(color1:FlxColor, color2:FlxColor, steps:Int, ?ease:Float->Float):Array<Int> 
		return cast FlxColor.gradient(color1, color2, steps, ease);

	public static function interpolate(color1:FlxColor, color2:FlxColor, factor:Float = 0.5):Int
		return cast FlxColor.interpolate(color1, color2, factor);
}