package editors;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import Controls.KeyboardScheme;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxState;

// copied from options menu lalalala
class EditorList extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var editors:Array<Dynamic> = [
		['Chart Editor', ()-> new editors.ChartingState()],
		['Character Editor', ()-> new editors.CharacterEditor()]
	];

	var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence('In the Editors');
		#end
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(MainMenuState.randomizeBG());

		menuBG.color = 0xff1c0e51;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...editors.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, editors[i][0], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.itemType = 'Vertical';
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
		}

		super.create();
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK) {
			FlxG.switchState(()->new MainMenuState());
		}
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
		if (controls.ACCEPT)
		{
			FlxG.switchState(editors[curSelected][1]);
		}
		Settings.save();
		Settings.load();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}