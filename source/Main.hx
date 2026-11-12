	package;

	import flixel.FlxGame;
	import flixel.FlxState;
	import openfl.Assets;
	import openfl.Lib;
	import openfl.display.FPS;
	import openfl.display.Sprite;
	import openfl.events.Event;

	class Main extends Sprite
	{
		public static final game = {
			width: 1280, // WINDOW width
			height: 720, // WINDOW height
			initialState: TitleState, // initial game state
			framerate: 60, // default framerate
			skipSplash: true, // if the default flixel splash screen should be skipped
			startFullscreen: false // if the game should start at fullscreen mode
		};

		// You can pretty much ignore everything from here on - your code should go in your states.

		public static function main():Void
		{
			Lib.current.addChild(new Main());
		}

		public function new()
		{
			super();

			if (stage != null)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		private function init(?E:Event):Void
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
			{
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			setupGame();
		}

		private function setupGame():Void
		{
			addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

			#if !mobile
			addChild(new FPS(10, 3, 0xFFFFFF));
			#end
		}
	}
