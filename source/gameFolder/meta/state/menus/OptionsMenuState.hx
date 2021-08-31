package gameFolder.meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameFolder.gameObjects.userInterface.menu.Checkmark;
import gameFolder.gameObjects.userInterface.menu.Selector;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.dependency.FNFSprite;
import gameFolder.meta.data.font.Alphabet;
import gameFolder.meta.subState.OptionsSubstate;

/**
	Options menu rewrite because I'm unhappy with how it was done previously
**/
class OptionsMenuState extends MusicBeatState
{
	private var categoryMap:Map<String, Dynamic>;
	private var activeSubgroup:FlxTypedGroup<FlxText>;
	private var attachments:FlxTypedGroup<FlxBasic>;

	var curSelection = 0;
	var curSelectedScript:Void->Void;
	var curCategory:String;

	var lockedMovement:Bool = false;

	override public function create():Void
	{
		// define the categories
		/* 
			To explain how these will work, each main category is just any group of options, the options in the category are defined
			by the first array. The second array value defines what that option does.
			These arrays are within other arrays for information storing purposes, don't worry about that too much.
			If you plug in a value, the script will run when the option is hovered over.
		 */
		categoryMap = [
			'main' => [
				[['Preferences', callNewGroup], ['Controls', openControlmenu], ['Exit', exitMenu]]
			],
			'Preferences' => [
				[
					// ['-Game Settings-', null],
					['', null],
					['Downscroll', getFromOption],
					// ['Auto Pause', getFromOption],
					['Display Accuracy', getFromOption],
					//
					['', null],
					// ['-Meta Settings-', null],
					// ['', null],
					["Framerate Cap", getFromOption],
					['FPS Counter', getFromOption],
					['Memory Counter', getFromOption],
					['Debug Info', getFromOption],
					['', null],
					// ['-Forever Settings-', null],
					// ['', null],
					['Use Forever Chart Editor', getFromOption]
				]
			],
			'Appearance' => [
				[
					['Common Settings', null],
					['', null],
					['Disable Antialiasing', getFromOption],
					['No Camera Note Movement', getFromOption],
					['', null],
					['Accessibility Settings', null],
					['', null],
					['Filter', getFromOption],
					['Reduced Movements', getFromOption],
					// this shouldn't be get from option, just testing
					['', null],
					['User Interface', null],
					['', null],
					["UI Skin", getFromOption],
					["Note Skin", getFromOption],
					['Disable Note Splashes', getFromOption],
					['Opaque Arrows', getFromOption],
					['Opaque Holds', getFromOption],
				]
			]
		];

		for (category in categoryMap.keys())
		{
			categoryMap.get(category)[1] = returnSubgroup(category);
			categoryMap.get(category)[2] = returnExtrasMap(categoryMap.get(category)[1]);
		}

		// call the options menu
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		infoText = new FlxText(5, FlxG.height - 24, 0, "", 32);
		infoText.setFormat("atari.ttf", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		add(infoText);

		FlxG.camera.setFilters([Main.scanlinesFilter]);

		super.create();

		loadSubgroup('main');
	}

	private var currentAttachmentMap:Map<FlxText, Dynamic>;

	function loadSubgroup(subgroupName:String)
	{
		// unlock the movement
		lockedMovement = false;

		// lol we wanna kill infotext so it goes over checkmarks later
		if (infoText != null)
			remove(infoText);

		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);

		// load subgroup lmfao
		activeSubgroup = categoryMap.get(subgroupName)[1];
		add(activeSubgroup);

		// set the category
		curCategory = subgroupName;

		// add all group attachments afterwards
		currentAttachmentMap = categoryMap.get(subgroupName)[2];
		attachments = new FlxTypedGroup<FlxBasic>();
		for (setting in activeSubgroup)
			if (currentAttachmentMap.get(setting) != null)
				attachments.add(currentAttachmentMap.get(setting));
		add(attachments);

		// re-add
		add(infoText);
		regenInfoText();

		// reset the selection
		curSelection = 0;
		selectOption(curSelection);
	}

	function selectOption(newSelection:Int, playSound:Bool = true)
	{
		// direction increment finder
		var directionIncrement = ((newSelection < curSelection) ? -1 : 1);

		// updates to that new selection
		curSelection = newSelection;

		// wrap the current selection
		if (curSelection < 0)
			curSelection = activeSubgroup.length - 1;
		else if (curSelection >= activeSubgroup.length)
			curSelection = 0;

		// set the correct group stuffs lol
		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].alpha = 0.6;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);

			// check for null members and hardcode the dividers
			if (categoryMap.get(curCategory)[0][i][1] == null)
			{
				activeSubgroup.members[i].alpha = 1;
			}
		}

		activeSubgroup.members[curSelection].alpha = 1;
		if (currentAttachmentMap != null)
			setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[curSelection]), 1);

		// what's the script of the current selection?
		for (i in 0...categoryMap.get(curCategory)[0].length)
			if (categoryMap.get(curCategory)[0][i][0] == activeSubgroup.members[curSelection].text)
				curSelectedScript = categoryMap.get(curCategory)[0][i][1];
		// wow thats a dumb check lmao

		// skip line if the selected script is null (indicates line break)
		if (curSelectedScript == null)
			selectOption(curSelection + directionIncrement, false);
	}

	function setAttachmentAlpha(attachment:FlxSprite, newAlpha:Float)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.alpha = newAlpha;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	var infoText:FlxText;
	var finalText:String;
	var textValue:String = '';
	var infoTimer:FlxTimer;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Main.vhsShader.update(elapsed);

		// just uses my outdated code for the main menu state where I wanted to implement
		// hold scrolling but I couldnt because I'm dumb and lazy
		if (!lockedMovement)
		{
			// check for the current selection
			if (curSelectedScript != null)
				curSelectedScript();

			updateSelections();
		}

		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			// lol had to set this or else itd tell me expected }
			var currentSetting = Init.gameSettings.get(activeSubgroup.members[curSelection].text);
			var textValue = currentSetting[2];
			if (textValue == null)
				textValue = "";

			if (finalText != textValue)
			{
				// trace('call??');
				// trace(textValue);
				regenInfoText();

				var textSplit = [];
				finalText = textValue;
				textSplit = finalText.split("");

				var loopTimes = 0;
				infoTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
				{
					//
					infoText.text += textSplit[loopTimes];
					infoText.screenCenter(X);

					loopTimes++;
				}, textSplit.length);
			}
		}

		// move the attachments if there are any
		for (setting in currentAttachmentMap.keys())
		{
			if ((setting != null) && (currentAttachmentMap.get(setting) != null))
			{
				var thisAttachment = currentAttachmentMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}

		if (controls.BACK)
		{
			if (curCategory != 'main')
				loadSubgroup('main');
			else
				Main.switchState(this, new MainMenuState());
		}
	}

	private function regenInfoText()
	{
		if (infoTimer != null)
			infoTimer.cancel();
		if (infoText != null)
			infoText.text = "";
	}

	function updateSelections()
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
							selectOption(curSelection - 1);
						else if (i == 3)
							selectOption(curSelection + 1);
					}
				}
				//
			}
		}
	}

	private function returnSubgroup(groupName:String):FlxTypedGroup<FlxText>
	{
		//
		var newGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

		for (i in 0...categoryMap.get(groupName)[0].length)
		{
			var thisOption:FlxText = new FlxText(0, 0, 0, categoryMap.get(groupName)[0][i][0]);
			thisOption.setFormat(Paths.font("atari.ttf"), 32);
			thisOption.screenCenter();
			thisOption.y = (70 * i) + 284;
			if (groupName == "Preferences")
			{
				thisOption.y = (50 * i) + 96;
			}
			thisOption.alpha = 0.6;
			newGroup.add(thisOption);
		}

		return newGroup;
	}

	private function returnExtrasMap(alphabetGroup:FlxTypedGroup<FlxText>):Map<FlxText, Dynamic>
	{
		var extrasMap:Map<FlxText, Dynamic> = new Map<FlxText, Dynamic>();
		for (letter in alphabetGroup)
		{
			if (Init.gameSettings.get(letter.text) != null)
			{
				switch (Init.gameSettings.get(letter.text)[1])
				{
					case 0:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, letter.y, 'checkboxThingie', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(letter.text)) + ' finished');

						extrasMap.set(letter, checkmark);
					case 1:
						// selector
						var selector:Selector = new Selector(10, letter.y, letter.text, Init.gameSettings.get(letter.text)[3],
							(letter.text == 'Framerate Cap') ? true : false);

						extrasMap.set(letter, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return extrasMap;
	}

	/*
		This is the base option return
	 */
	public function getFromOption()
	{
		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			switch (Init.gameSettings.get(activeSubgroup.members[curSelection].text)[1])
			{
				case 0:
					// checkmark basics lol
					if (controls.ACCEPT)
					{
						lockedMovement = true;
						FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							// LMAO THIS IS HUGE
							Init.trueSettings.set(activeSubgroup.members[curSelection].text,
								!Init.trueSettings.get(activeSubgroup.members[curSelection].text));
							updateCheckmark(currentAttachmentMap.get(activeSubgroup.members[curSelection]),
								Init.trueSettings.get(activeSubgroup.members[curSelection].text));

							// save the setting
							Init.saveSettings();
							lockedMovement = false;
						});
					}
				case 1:
					#if !html5
					var selector:Selector = currentAttachmentMap.get(activeSubgroup.members[curSelection]);

					if (!controls.LEFT)
						selector.selectorPlay('left');
					if (!controls.RIGHT)
						selector.selectorPlay('right');

					if (controls.RIGHT_P)
						updateSelector(selector, 1);
					else if (controls.LEFT_P)
						updateSelector(selector, -1);
					#end
				default:
					// none
			}
		}
	}

	function updateCheckmark(checkmark:FNFSprite, animation:Bool)
		checkmark.playAnim(Std.string(animation));

	function updateSelector(selector:Selector, updateBy:Int)
	{
		var fps = selector.fpsCap;
		if (!fps)
		{
			// get the current option as a number
			var storedNumber:Int = 0;
			for (curOption in 0...selector.options.length)
			{
				if (selector.options[curOption] == selector.optionChosen.text)
					storedNumber = curOption;
			}

			var newSelection = storedNumber + updateBy;
			if (newSelection < 0)
				newSelection = selector.options.length - 1;
			else if (newSelection >= selector.options.length)
				newSelection = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			selector.chosenOptionString = selector.options[newSelection];
			selector.optionChosen.text = selector.chosenOptionString;

			Init.trueSettings.set(activeSubgroup.members[curSelection].text, selector.chosenOptionString);
			Init.saveSettings();
		}
		else
		{ // bro I dont even know if the engine works in html5 why am I even doing this
			// lazily hardcoded fps cap
			var originalFPS = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 15 * updateBy;
			if (originalFPS + increase < 30)
				increase = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			originalFPS += increase;
			selector.chosenOptionString = Std.string(originalFPS);
			selector.optionChosen.text = Std.string(originalFPS);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, originalFPS);
			Init.saveSettings();
		}
	}

	public function callNewGroup()
	{
		if (controls.ACCEPT)
		{
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				loadSubgroup(activeSubgroup.members[curSelection].text);
			});
		}
	}

	public function openControlmenu()
	{
		if (controls.ACCEPT)
		{
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				openSubState(new OptionsSubstate());
				lockedMovement = false;
			});
		}
	}

	public function exitMenu()
	{
		//
		if (controls.ACCEPT)
		{
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				Main.switchState(this, new MainMenuState());
				lockedMovement = false;
			});
		}
	}
}
