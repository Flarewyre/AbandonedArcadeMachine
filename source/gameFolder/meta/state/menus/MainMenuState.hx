package gameFolder.meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameFolder.meta.MusicBeat.MusicBeatState;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxText>;
	var curSelected:Float = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var camFollow:FlxObject;

	var optionShit:Array<String> = ['1P game', 'Freeplay', 'Options'];
	var canSnap:Array<Float> = [];

	// the create 'state'
	override function create()
	{
		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		// uh
		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		// create the menu items themselves
		var tex = Paths.getSparrowAtlas('menus/base/title/FNF_main_menu_assets');

		// loop through the menu options
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxText = new FlxText(0, 504 + (i * 48), 0, optionShit[i], 32);
			menuItem.setFormat(Paths.font("atari.ttf"), 32);
			canSnap[i] = -1;
			// set the id
			menuItem.ID = i;
			// menuItem.alpha = 0;

			// placements
			menuItem.screenCenter(X);
			// if the id is divisible by 2
			if (menuItem.ID % 2 == 0)
				menuItem.x += 1000;
			else
				menuItem.x -= 1000;

			// actually add the item
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(1, 1);

			/*
				FlxTween.tween(menuItem, {alpha: 1, x: ((FlxG.width / 2) - (menuItem.width / 2))}, 0.35, {
					ease: FlxEase.smootherStepInOut,
					onComplete: function(tween:FlxTween)
					{
						canSnap[i] = 0;
					}
			});*/
		}

		FlxG.camera.setFilters([Main.scanlinesFilter]);

		updateSelection();

		// from the base game lol

		var versionShit:FlxText = new FlxText(8, FlxG.height - 45, 0, "Forever Engine v" + Main.gameVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("atari.ttf", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var logo:FlxSprite = new FlxSprite(0, 0);
		logo.frames = Paths.getSparrowAtlas('menus/base/title/logoBumpin');
		logo.setGraphicSize(Std.int(logo.width * 4), Std.int(logo.height * 4));
		logo.animation.addByPrefix('idle', 'Idle1', 24);
		logo.animation.play('idle');
		logo.screenCenter();
		logo.y -= 120;
		add(logo);

		//

		super.create();
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

		var up = controls.UP;
		var down = controls.DOWN;
		var up_p = controls.UP_P;
		var down_p = controls.DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if ((controlArray.contains(true)) && (!selectedSomethin))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;
					}
					/* idk something about it isn't working yet I'll rewrite it later
						else
						{
							// paaaaaaaiiiiiiiinnnn
							var curDir:Int = 0;
							if (i == 0)
								curDir = -1;
							else if (i == 1)
								curDir = 1;

							if (counterControl < 2)
								counterControl += 0.05;

							if (counterControl >= 1)
							{
								curSelected += (curDir * (counterControl / 24));
								if (curSelected % 1 == 0)
									FlxG.sound.play(Paths.sound('scrollMenu'));
							}
					}*/

					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;
				}
				//
			}
		}
		else
		{
			// reset variables
			counterControl = 0;
		}

		if ((controls.ACCEPT) && (!selectedSomethin))
		{
			//
			selectedSomethin = true;

			menuItems.forEach(function(spr:FlxText)
			{
				var daChoice:String = optionShit[Math.floor(curSelected)];
				if (daChoice == spr.text)
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (daChoice)
						{
							case '1P game':
								var storyMenuState:StoryMenuState = new StoryMenuState();
								storyMenuState.selectWeek();
							case 'Freeplay':
								Main.switchState(this, new FreeplayState());
							case 'Options':
								transIn = FlxTransitionableState.defaultTransIn;
								transOut = FlxTransitionableState.defaultTransOut;
								Main.switchState(this, new OptionsMenuState());
						}
					});
				}
			});
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);
		Main.vhsShader.update(elapsed);

		menuItems.forEach(function(menuItem:FlxText)
		{
			menuItem.screenCenter(X);
		});
	}

	var lastCurSelected:Int = 0;

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxText)
		{
			spr.alpha = 0.5;
		});

		// set the sprites and all of the current selection
		// camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
		// 	menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y);

		if (menuItems.members[Math.floor(curSelected)].alpha == 0.5)
			menuItems.members[Math.floor(curSelected)].alpha = 1;

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
	}
}
