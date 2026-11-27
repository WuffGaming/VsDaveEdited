package modding;

import openfl.utils.Assets;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetType;
import openfl.utils.Future;
import openfl.utils.ByteArray;
import openfl.utils.IAssetCache;
import polymod.fs.PolymodFileSystem;
import polymod.backends.PolymodAssets;
import polymod.backends.PolymodAssetLibrary;

/**
 * Controlled Assets Class for HScript
**/
class HAssets {

    public static var cache:IAssetCache = Assets.cache;

    public static function getPath(path:String):String
        return Assets.getPath(path);

    public static function getBytes(path:String):haxe.io.Bytes
        return Assets.getBytes(path);

    public static function loadBytes(path:String):Future<ByteArray>
        return Assets.loadBytes(path);

    public static function getText(path:String):String
        return Assets.getText(path);

    public static function loadText(path:String):Future<String>
        return Assets.loadText(path);

    public static function exists(id:String, ?type:AssetType):Bool
        return Assets.exists(id, type);

    public static function list(?type:AssetType):Array<String>
        return Assets.list(type);

    public static function hasLibrary(name:String):Bool
        return Assets.hasLibrary(name);

    public static function getLibrary(name:String):lime.utils.AssetLibrary
        return Assets.getLibrary(name);

    public static function loadLibrary(name:String):Future<AssetLibrary>
        return Assets.loadLibrary(name);

	//sys.FileSystem.readDirectory() except it takes mods into account.
    public static function readDirectory(dir:String, ?typeArr:Array<String>, ?removeType:Bool = true, ?recursive:Bool = true, ?library:String):Array<String>
	{
		var returnList:Array<String> = [];
		var swagList:Array<String> = [];
		if (sys.FileSystem.isDirectory(dir))
			swagList = sys.FileSystem.readDirectory(dir);
		for (mod in sys.FileSystem.readDirectory('mods')){
			trace(mod);
			if (sys.FileSystem.isDirectory(dir.replace('assets/', 'mods/' + mod + '/'))) {
				var modFiles:Array<String> = sys.FileSystem.readDirectory(dir.replace('assets/', 'mods/' + mod + '/'));
				for (file in modFiles) swagList.push(file.replace('mods/' + mod + '/', 'assets/')); //i'm going to hell for this programming bro
			}
		}
		for(swag in swagList) {
			var rawAsset = Paths.file(dir.replace('assets/', '') + swag, null, library);
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
		return returnList;
	}
}