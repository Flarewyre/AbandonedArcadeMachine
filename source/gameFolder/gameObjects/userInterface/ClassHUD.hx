package gameFolder.gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameFolder.meta.CoolUtil;
import gameFolder.meta.InfoHud;
import gameFolder.meta.data.Conductor;
import gameFolder.meta.data.Timings;
import gameFolder.meta.state.PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var pointsText:FlxText;
	var accuracyText:FlxText;
	var rankText:FlxText;
	var comboText:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	var comboInvisTimer:Float = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// small info bar, kinda like the KE watermark
		// based on scoretxt which I will set up as well
		var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty)
			+ " - Forever BETA v" + Main.gameVersion;

		infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
		infoBar.setFormat(Paths.font("atari.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoBar.scrollFactor.set();
		infoBar.visible = false;
		add(infoBar);

		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		var barY = FlxG.height * (0.875) + 20;
		if (Init.trueSettings.get('Downscroll'))
			barY = 16;

		var boxY = (FlxG.height * 0.875) + 10;
		if (Init.trueSettings.get('Downscroll'))
			boxY = 0;

		var UIBox:FlxShapeBox = new FlxShapeBox(0, boxY, 1280, 80, {thickness: 0, color: FlxColor.TRANSPARENT}, FlxColor.BLACK);
		add(UIBox);

		healthBarBG = new FlxSprite(0, barY).loadGraphic(Paths.image('UI/default/base/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = false;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = false;
		add(iconP2);

		pointsText = new FlxText(120, healthBarBG.y + 25, 0, scoreDisplay, 32);
		pointsText.setFormat(Paths.font("atari.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pointsText.scrollFactor.set();
		add(pointsText);

		accuracyText = new FlxText(536, healthBarBG.y + 25, 0, "", 32);
		accuracyText.setFormat(Paths.font("atari.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accuracyText.scrollFactor.set();
		add(accuracyText);

		rankText = new FlxText(988, healthBarBG.y + 25, 0, "", 32);
		rankText.setFormat(Paths.font("atari.ttf"), 32, FlxColor.WHITE, RIGHT);
		rankText.scrollFactor.set();
		add(rankText);

		comboText = new FlxText(0, 0, 0, "000", 32);
		comboText.setFormat(Paths.font("atari.ttf"), 32, FlxColor.WHITE, CENTER);
		comboText.scrollFactor.set();
		comboText.textField.background = true;
		comboText.textField.backgroundColor = FlxColor.BLACK;
		comboText.screenCenter();
		comboText.visible = false;

		comboText.y -= 260;
		if (Init.trueSettings.get('Downscroll'))
			comboText.y += 530;
		add(comboText);

		updateScoreText();
	}

	public function updateCombo(curCombo:Int, negative:Bool)
	{
		var txtString:String = Std.string(Math.abs(curCombo));

		// lol i'm lazy and don't want to use math for this
		switch (txtString.length)
		{
			case 1:
				txtString = "00" + txtString;
			case 2:
				txtString = "0" + txtString;
		}

		if (negative)
			txtString = "-" + txtString;

		comboText.text = txtString;
		comboText.visible = true;
		comboInvisTimer = 0.8;

		comboText.screenCenter(X);

		comboText.color = FlxColor.WHITE;
		if (negative)
			comboText.color = FlxColor.RED;
	}

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		updateScoreText();

		var iconLerp = 0.5;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, iconLerp)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (comboInvisTimer > 0)
		{
			comboInvisTimer -= elapsed;
			if (comboInvisTimer <= 0)
			{
				comboInvisTimer = 0;
				comboText.visible = false;
			}
		}
	}

	private function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		pointsText.text = 'PTS $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			accuracyText.text = 'ACC ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			rankText.text = 'RNK ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}
		accuracyText.x = ((FlxG.width / 2) - (accuracyText.width / 2)) + 56;
	}

	public function beatHit()
	{
		if (false) // !Init.trueSettings.get('Reduced Movements'))
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 45));
			iconP2.setGraphicSize(Std.int(iconP2.width + 45));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		//
	}
}
