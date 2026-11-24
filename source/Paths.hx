package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, ?type:AssetType, library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type))
				return levelPath;
		}

		var levelPath:String = getLibraryPathForce(file, 'shared');
		if (Assets.exists(levelPath, type))
			return levelPath;

		return 'assets/$file';
	}

	public static function getLibraryPath(file:String, library = 'preload'):String
	{
		return if (library == 'preload' || library == 'default') getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	static inline function getLibraryPathForce(file:String, library:String):String
	{
		return '$library:assets/$library/$file';
	}

	inline static public function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String, ?library:String)
	{
		return getPath('songs/${song.toLowerCase()}/Voices.$SOUND_EXT', MUSIC, library);
	}

	inline static public function inst(song:String, ?library:String)
	{
		return getPath('songs/${song.toLowerCase()}/Inst.$SOUND_EXT', MUSIC, library);
	}

	inline static public function songJson(song:String, ?library:String)
	{
		return getPath('songs/${song.toLowerCase()}.json', TEXT, library);
	}

	inline static public function songTxt(song:String, ?library:String)
	{
		return getPath('songs/${song.toLowerCase()}.txt', TEXT, library);
	}


	inline static public function externmusic(song:String, ?library:String)
	{
		return getPath('songs/extern/${song.toLowerCase()}.$SOUND_EXT', MUSIC, library);
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function jsonImg(key:String, ?library:String)
	{
		return getPath('images/$key.json', IMAGE, library);
	}

	inline static public function font(key:String, ?library:String)
	{
		return getPath('fonts/$key', FONT, library);
	}

	// i modified this from doida engine
	public static function getScriptArray(?song:String):Array<String>
	{
		var arr:Array<String> = [];
		for(folder in ["scripts", 'songs/ingame', 'songs/ingame/$song', 'songs/ingame/$song/scripts', "data/scripts"])
		{
			for(file in readDir(folder, [".hx", ".hxc"], false))
				arr.push('assets/$file');
		}
		#if debug trace('got script array: ', arr); #end
		return arr;
	}

	// aaaahhh
	public static function readDir(dir:String, ?typeArr:Array<String>, ?removeType:Bool = true, ?library:String):Array<String>
	{
		var assets:Array<String> = Assets.list();
		var swagList:Array<String> = [];
		var returnList:Array<String> = [];

		for (asset in assets) {
			trace(asset);
			if (asset.startsWith('mods')) {
				assets.remove(asset);
				continue;
			}
			if (asset.startsWith('assets/$dir')) {
				swagList.push(asset); 
			}
		}
		for(swag in swagList) {
			var rawAsset = getPath(swag.replace('assets/', ''), null, library);
			if(typeArr?.length > 0)
			{
				for(type in typeArr) {
					if(rawAsset.endsWith(type)) {
						if(removeType)
							rawAsset = rawAsset.replace(type, "");
						returnList.push(rawAsset);
					}
				}
			}
			else
				returnList.push(rawAsset);
		}

		#if debug
		trace(dir);
		trace(swagList);
		trace(returnList);
		#end
		return returnList;
	}
	

	static public function loadJSON(key:String, ?library:String):Dynamic
	{
		var rawJson = Assets.getText(Paths.json(key, library)).trim();

		// Perform cleanup on files that have bad data at the end.
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			// Attempt to parse and return the JSON data.
			return Json.parse(rawJson);
		}
		catch (e)
		{
			trace("AN ERROR OCCURRED parsing a JSON file. " + key);
			trace(e.message);

			// Return null.
			return null;
		}
	}

	static public function loadSongJSON(key:String, ?library:String):Dynamic
	{
		var rawJson = Assets.getText(Paths.songJson(key, library)).trim();

		// Perform cleanup on files that have bad data at the end.
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			// Attempt to parse and return the JSON data.
			return Json.parse(rawJson);
		}
		catch (e)
		{
			trace("AN ERROR OCCURRED parsing a JSON file. " + key);
			trace(e.message);

			// Return null.
			return null;
		}
	}

	static public function loadJSONImg(key:String, ?library:String):Dynamic
	{
		var rawJson = Assets.getText(Paths.jsonImg(key, library)).trim();

		// Perform cleanup on files that have bad data at the end.
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			// Attempt to parse and return the JSON data.
			return Json.parse(rawJson);
		}
		catch (e)
		{
			trace("AN ERROR OCCURRED parsing a JSON file. " + key);
			trace(e.message);

			// Return null.
			return null;
		}
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
