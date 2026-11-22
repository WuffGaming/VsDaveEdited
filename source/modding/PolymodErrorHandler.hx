package modding;

import polymod.Polymod;

class PolymodErrorHandler
{
	/**
	 * Show a popup with the given text.
	 * This displays a system popup, it WILL interrupt the game.
	 * Make sure to only use this when it's important, like when there's a script error.
	 * 
	 * This is practically all stolen from FunkinCrew https://github.com/FunkinCrew/Funkin/blob/main/source/funkin/modding/PolymodHandler.hx with minor changes.
	 *
	 * @param name The name at the top of the popup.
	 * @param desc The body text of the popup.
	 */
	public static function showAlert(name:String, desc:String):Void
	{
		lime.app.Application.current.window.alert(desc, name);
	}

	public static function onPolymodError(error:PolymodError):Void
	{
		trace(error.message);
	}

	static function logInfo(message:String):Void
	{
		trace('[INFO-] ${message}');
	}

	static function logError(message:String):Void
	{
		trace('[ERROR] ${message}');
	}

	static function logWarn(message:String):Void
	{
		trace('[WARN-] ${message}');
	}
}