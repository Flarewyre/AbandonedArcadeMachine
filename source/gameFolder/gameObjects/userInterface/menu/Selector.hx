package gameFolder.gameObjects.userInterface.menu;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import gameFolder.meta.data.dependency.FNFSprite;
import gameFolder.meta.data.font.Alphabet;

class Selector extends FlxTypedSpriteGroup<FlxSprite>
{
	//
	var leftSelector:FNFSprite;
	var rightSelector:FNFSprite;

	public var optionChosen:FlxText;
	public var chosenOptionString:String = '';
	public var options:Array<String>;

	public var fpsCap:Bool = false;

	public function new(x:Float = 0, y:Float = 0, word:String, options:Array<String>, fpsCap:Bool = false)
	{
		// call back the function
		super(x, y);

		this.options = options;

		// oops magic numbers
		var shiftX = 75;
		var shiftY = 61;
		// generate multiple pieces

		this.fpsCap = fpsCap;

		leftSelector = createSelector(shiftX, shiftY, word, 'left');
		rightSelector = createSelector(shiftX + ((word.length) * 32) + (shiftX / 4) + ((fpsCap) ? 20 : 0), shiftY, word, 'right');

		add(leftSelector);
		add(rightSelector);

		chosenOptionString = Init.trueSettings.get(word);
		if (fpsCap)
			chosenOptionString = Std.string(Init.trueSettings.get(word));
		optionChosen = new FlxText(shiftX + ((word.length) * 32) + 80, shiftY - 12, 0, chosenOptionString);
		optionChosen.setFormat(Paths.font("atari.ttf"), 32);
		add(optionChosen);
	}

	public function createSelector(objectX:Float = 0, objectY:Float = 0, word:String, dir:String):FNFSprite
	{
		var returnSelector = new FNFSprite(objectX, objectY);
		returnSelector.frames = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');

		returnSelector.animation.addByPrefix('idle', 'arrow left', 24, false);
		returnSelector.animation.addByPrefix('press', 'arrow push left', 24, false);
		returnSelector.addOffset('press', 0, -10);
		returnSelector.playAnim('idle');
		returnSelector.setGraphicSize(Std.int(returnSelector.width * 3), Std.int(returnSelector.height * 3));

		returnSelector.flipX = (dir == "left" ? false : true);

		return returnSelector;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		for (object in 0...objectArray.length)
			objectArray[object].setPosition(x + positionLog[object][0], y + positionLog[object][1]);
	}

	public function selectorPlay(whichSelector:String, animPlayed:String = 'idle')
	{
		switch (whichSelector)
		{
			case 'left':
				leftSelector.playAnim(animPlayed);
			case 'right':
				rightSelector.playAnim(animPlayed);
		}
	}

	var objectArray:Array<FlxSprite> = [];
	var positionLog:Array<Array<Float>> = [];

	override public function add(object:FlxSprite):FlxSprite
	{
		objectArray.push(object);
		positionLog.push([object.x, object.y]);
		return super.add(object);
	}
}
