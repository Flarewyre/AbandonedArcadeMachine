package gameFolder.meta.subState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameFolder.gameObjects.Boyfriend;
import gameFolder.meta.MusicBeat.MusicBeatSubState;
import gameFolder.meta.data.Conductor.BPMChangeEvent;
import gameFolder.meta.data.Conductor;
import gameFolder.meta.state.*;
import gameFolder.meta.state.menus.*;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var stageSuffix:String = "";
	var countdown:Float = 15;
	var countdownText:FlxText;
	var retryText:FlxText;
	var daBoyfriendType:String;

	public function new(x:Float, y:Float)
	{
		daBoyfriendType = PlayState.boyfriend.curCharacter;
		var daBf:String = '';
		switch (daBoyfriendType)
		{
			case 'bf-og':
				daBf = daBoyfriendType;
			case 'bf-pixel':
				daBf = 'bf-pixel-dead';
				stageSuffix = '-pixel';
			case 'bf-ghost':
				daBf = 'bf-ghost-dead';
				stageSuffix = '-ghost';
			default:
				daBf = 'bf-dead';
		}

		PlayState.boyfriend.destroy();

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		countdownText = new FlxText(bf.x, bf.y - 160, 0, "10", 32);
		countdownText.setFormat(Paths.font("atari.ttf"), 32, FlxColor.WHITE, CENTER);
		add(countdownText);

		retryText = new FlxText(bf.x, bf.y + 184, 0, "INSERT COIN TO CONTINUE", 32);
		retryText.setFormat(Paths.font("atari.ttf"), 32, FlxColor.WHITE, CENTER);
		retryText.x -= retryText.width / 2;
		retryText.x += 16;
		add(retryText);

		FlxFlicker.flicker(retryText, 16, 0.5);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('fade');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Main.vhsShader.update(elapsed);

		if (countdown > 0 && !isEnding)
		{
			countdown -= elapsed;

			var txtString:String = Std.string(Math.ceil(countdown));
			if (txtString.length == 1)
				txtString = "0" + txtString;
			countdownText.text = txtString;

			if (countdown <= 0)
			{
				countdown = 0;
			}
		}

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK || countdown == 0)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
			{
				Main.switchState(this, new MainMenuState());
			}
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'fade' && bf.animation.curAnim.curFrame == 1)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			countdownText.visible = false;
			FlxFlicker.stopFlickering(retryText);
			retryText.visible = false;
			isEnding = true;

			bf.destroy();
			bf = new Boyfriend(bf.x, bf.y, daBoyfriendType);
			add(bf);

			bf.animation.addByPrefix('idleLoop', 'BF IDLE instance 1', 24);
			bf.playAnim("idleLoop");

			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('revive'));
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 0, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
