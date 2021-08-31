package gameFolder.meta.subState;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameFolder.meta.MusicBeat.MusicBeatSubState;
import gameFolder.meta.data.font.Alphabet;
import gameFolder.meta.data.font.FlxTextControls;

using StringTools;

class OptionsSubstate extends MusicBeatSubState
{
	private var curSelection = 0;
	private var submenuGroup:FlxTypedGroup<FlxBasic>;
	private var submenuoffsetGroup:FlxTypedGroup<FlxBasic>;

	private var offsetTemp:Float;

	// the controls class thingy
	override public function create():Void
	{
		// call the options menu
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		super.create();

		keyOptions = generateOptions();
		updateSelection();

		submenuGroup = new FlxTypedGroup<FlxBasic>();
		submenuoffsetGroup = new FlxTypedGroup<FlxBasic>();

		submenu = new FlxSprite(0, 0).makeGraphic(FlxG.width - 200, FlxG.height - 200, FlxColor.BLUE);
		submenu.screenCenter();

		// submenu group
		var submenuText:FlxText = new FlxText(0, 0, 0, "Press any key to rebind");
		submenuText.setFormat(Paths.font("atari.ttf"), 32);
		submenuText.screenCenter();
		submenuText.y -= 32;
		submenuGroup.add(submenuText);

		var submenuText2:FlxText = new FlxText(0, 0, 0, "Escape to Cancel");
		submenuText2.setFormat(Paths.font("atari.ttf"), 32);
		submenuText2.screenCenter();
		submenuText2.y += 32;
		submenuGroup.add(submenuText2);

		// submenuoffset group
		// this code by codist
		var submenuOffsetText:FlxText = new FlxText(0, 0, 0, "Left or Right to edit.");
		submenuOffsetText.setFormat(Paths.font("atari.ttf"), 32);
		submenuOffsetText.screenCenter();
		submenuOffsetText.y -= 144;
		submenuoffsetGroup.add(submenuOffsetText);

		var submenuOffsetText2:FlxText = new FlxText(0, 0, 0, "Negative is Late");
		submenuOffsetText2.setFormat(Paths.font("atari.ttf"), 32);
		submenuOffsetText2.screenCenter();
		submenuOffsetText2.y -= 80;
		submenuoffsetGroup.add(submenuOffsetText2);

		var submenuOffsetText3:FlxText = new FlxText(0, 0, 0, "Escape to Cancel");
		submenuOffsetText3.setFormat(Paths.font("atari.ttf"), 32);
		submenuOffsetText3.screenCenter();
		submenuOffsetText3.y += 102;
		submenuoffsetGroup.add(submenuOffsetText3);

		var submenuOffsetText4:FlxText = new FlxText(0, 0, 0, "Enter to Save");
		submenuOffsetText4.setFormat(Paths.font("atari.ttf"), 32);
		submenuOffsetText4.screenCenter();
		submenuOffsetText4.y += 164;
		submenuoffsetGroup.add(submenuOffsetText4);

		var submenuOffsetValue:FlxTextControls = new FlxTextControls(0, 0, 0, "< 0ms >");
		submenuOffsetValue.setFormat(Paths.font("atari.ttf"), 32);
		submenuOffsetValue.screenCenter();
		submenuOffsetValue.borderColor = FlxColor.BLACK;
		submenuOffsetValue.borderSize = 5;
		submenuOffsetValue.borderStyle = FlxTextBorderStyle.OUTLINE;
		submenuoffsetGroup.add(submenuOffsetValue);

		// alright back to my code :ebic:

		add(submenu);
		add(submenuGroup);
		add(submenuoffsetGroup);
		submenu.visible = false;
		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
	}

	private var keyOptions:FlxTypedGroup<FlxText>;
	private var otherKeys:FlxTypedGroup<FlxTextControls>;

	private function generateOptions()
	{
		keyOptions = new FlxTypedGroup<FlxText>();

		var arrayTemp:Array<String> = [];
		// re-sort everything according to the list numbers
		for (controlString in Init.gameControls.keys())
			arrayTemp[Init.gameControls.get(controlString)[1]] = controlString;

		arrayTemp.push("EDIT OFFSET"); // append edit offset to the end of the array

		for (i in 0...arrayTemp.length)
		{
			// generate key options lol
			var optionsText:FlxText = new FlxText(0, 0, 0, arrayTemp[i]);
			optionsText.setFormat(Paths.font("atari.ttf"), 32);
			optionsText.screenCenter();
			optionsText.x -= 408;
			optionsText.y += (70 * (i - (arrayTemp.length / 2))) + 35;
			optionsText.alpha = 0.6;

			keyOptions.add(optionsText);
		}

		// stupid shubs you always forget this
		add(keyOptions);

		generateExtra(arrayTemp);

		return keyOptions;
	}

	private function generateExtra(arrayTemp:Array<String>)
	{
		otherKeys = new FlxTypedGroup<FlxTextControls>();
		for (i in 0...arrayTemp.length)
		{
			for (j in 0...2)
			{
				var keyString = "";

				if (arrayTemp[i] != "EDIT OFFSET")
					keyString = getStringKey(Init.gameControls.get(arrayTemp[i])[0][j]);

				var secondaryText:FlxTextControls = new FlxTextControls(0, 0, 0, keyString);
				secondaryText.setFormat(Paths.font("atari.ttf"), 32);
				secondaryText.screenCenter();
				secondaryText.y += (70 * (i - (arrayTemp.length / 2))) + 35;
				// secondaryText.targetY = i;
				// secondaryText.disableX = true;
				secondaryText.x += ((j + 1) * 420);
				secondaryText.x -= 408;
				// secondaryText.isMenuItem = true;
				secondaryText.alpha = 0.6;

				secondaryText.controlGroupID = i;
				secondaryText.extensionJ = j;
				otherKeys.add(secondaryText);
			}
		}
		add(otherKeys);
	}

	private function getStringKey(arrayThingy:Dynamic):String
	{
		var keyString:String = 'none';
		if (arrayThingy != null)
		{
			var keyDisplay:FlxKey = arrayThingy;
			keyString = keyDisplay.toString();
		}

		keyString = keyString.replace(" ", "");

		return keyString;
	}

	private function updateSelection(equal:Int = 0)
	{
		curSelection = equal;
		// wrap the current selection
		if (curSelection < 0)
			curSelection = keyOptions.length - 1;
		else if (curSelection >= keyOptions.length)
			curSelection = 0;

		//
		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].alpha = 0.6;
		}
		keyOptions.members[curSelection].alpha = 1;

		///*
		for (i in 0...otherKeys.length)
		{
			otherKeys.members[i].alpha = 0.6;
			otherKeys.members[i].screenCenter(X);
			otherKeys.members[i].x += ((otherKeys.members[i].extensionJ + 1) * 420);
			otherKeys.members[i].x -= 408;
			// otherKeys.members[i].targetY = (((Math.floor(i / 2)) - curSelection) / 2) - 0.25;
		}
		otherKeys.members[(curSelection * 2) + curHorizontalSelection].alpha = 1;
		// */
	}

	private var curHorizontalSelection = 0;

	private function updateHorizontalSelection()
	{
		var left = controls.LEFT_P;
		var right = controls.RIGHT_P;
		var horizontalControl:Array<Bool> = [left, false, right];

		if (horizontalControl.contains(true))
		{
			for (i in 0...horizontalControl.length)
			{
				if (horizontalControl[i] == true)
				{
					curHorizontalSelection += (i - 1);

					if (curHorizontalSelection < 0)
						curHorizontalSelection = 1;
					else if (curHorizontalSelection > 1)
						curHorizontalSelection = 0;
				}
			}

			updateSelection(curSelection);
			//
		}
	}

	private var submenuOpen:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Main.vhsShader.update(elapsed);

		if (!submenuOpen)
		{
			var up = controls.UP;
			var down = controls.DOWN;
			var up_p = controls.UP_P;
			var down_p = controls.DOWN_P;
			var controlArray:Array<Bool> = [up, down, up_p, down_p];

			if (controlArray.contains(true))
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
								updateSelection(curSelection - 1);
							else if (i == 3)
								updateSelection(curSelection + 1);
						}
					}
					//
				}
			}

			//
			updateHorizontalSelection();

			if (controls.ACCEPT)
			{
				submenuOpen = true;

				FlxFlicker.flicker(otherKeys.members[(curSelection * 2) + curHorizontalSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
				{
					if (submenuOpen)
						openSubmenu();
				});
			}
			else if (controls.BACK)
				close();
		}
		else
			subMenuControl();
	}

	override public function close()
	{
		//
		Init.saveControls(); // for controls
		Init.saveSettings(); // for offset
		super.close();
	}

	/// options submenu stuffs
	/// right here lol
	//
	// I think
	//
	// just a little further
	//
	// almost there
	//
	// got it!
	private var submenu:FlxSprite;

	private function openSubmenu()
	{
		offsetTemp = Init.trueSettings['Offset'];

		submenu.visible = true;
		if (curSelection != keyOptions.length - 1)
			submenuGroup.visible = true;
		else
			submenuoffsetGroup.visible = true;
	}

	private function closeSubmenu()
	{
		submenuOpen = false;

		submenu.visible = false;

		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
	}

	private function subMenuControl()
	{
		// I dont really like hardcoded shit so I'm probably gonna change this lmao
		if (curSelection != keyOptions.length - 1)
		{
			// be able to close the submenu
			if (FlxG.keys.justPressed.ESCAPE)
				closeSubmenu();
			else if (FlxG.keys.justPressed.ANY)
			{
				// loop through existing keys and see if there are any alike
				var checkKey = FlxG.keys.getIsDown()[0].ID;

				// check if any keys use the same key lol
				for (i in 0...otherKeys.members.length)
				{
					///*
					if (otherKeys.members[i].text == checkKey.toString())
					{
						// switch them I guess???
						var oldKey = Init.gameControls.get(keyOptions.members[curSelection].text)[0][curHorizontalSelection];
						Init.gameControls.get(keyOptions.members[otherKeys.members[i].controlGroupID].text)[0][otherKeys.members[i].extensionJ] = oldKey;
						otherKeys.members[i].text = getStringKey(oldKey);
					}
					//*/
				}

				// now check if its the key we want to change
				Init.gameControls.get(keyOptions.members[curSelection].text)[0][curHorizontalSelection] = checkKey;
				otherKeys.members[(curSelection * 2) + curHorizontalSelection].text = getStringKey(checkKey);

				// refresh keys
				controls.setKeyboardScheme(None, false);

				// update all keys on screen to have the right values
				// inefficient so I rewrote it lolllll
				/*for (i in 0...otherKeys.members.length)
					{
						var stringKey = getStringKey(Init.gameControls.get(keyOptions.members[otherKeys.members[i].controlGroupID].text)[0][otherKeys.members[i].extensionJ]);
						trace('running $i times, options menu');
				}*/

				// close the submenu
				closeSubmenu();
			}
			//
		}
		else
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				Init.trueSettings['Offset'] = offsetTemp;
				closeSubmenu();
			}
			else if (FlxG.keys.justPressed.ESCAPE)
				closeSubmenu();

			var move = 0;
			if (FlxG.keys.pressed.LEFT)
				move = -1;
			else if (FlxG.keys.pressed.RIGHT)
				move = 1;

			offsetTemp += move * 0.1;

			submenuoffsetGroup.forEachOfType(FlxTextControls, str ->
			{
				str.text = "< " + Std.string(Math.floor(offsetTemp * 10) / 10) + " >";
				str.screenCenter(X);
			});
		}
	}
}
