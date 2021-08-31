package gameFolder.meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameFolder.meta.MusicBeat.MusicBeatSubState;
import gameFolder.meta.data.font.Alphabet;
import gameFolder.meta.state.*;
import gameFolder.meta.state.menus.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = ['Resume', 'Restart song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();
		#if debug
		// trace('pause call');
		#end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		#if debug
		// trace('pause background');
		#end

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 1;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text = CoolUtil.dashToSpace(PlayState.SONG.song);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("atari.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		#if debug
		// trace('pause info');
		#end

		var pausedText:FlxText = new FlxText(20, 208, 0, "", 32);
		pausedText.text = "-PAUSED-";
		pausedText.scrollFactor.set();
		pausedText.setFormat(Paths.font('atari.ttf'), 32);
		pausedText.updateHitbox();
		add(pausedText);

		pausedText.alpha = 1;
		levelInfo.alpha = 1;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		pausedText.x = (FlxG.width / 2) - (pausedText.width / 2);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(0, (70 * i) + 332, 0, menuItems[i], 32);
			songText.setFormat(Paths.font("atari.ttf"), 32);
			songText.x = (FlxG.width / 2) - (songText.width / 2);
			grpMenuShit.add(songText);
		}

		#if debug
		// trace('change selection');
		#end

		changeSelection();

		#if debug
		// trace('cameras');
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if debug
		// trace('cameras done');
		#end
	}

	override function update(elapsed:Float)
	{
		#if debug
		// trace('call event');
		#end

		super.update(elapsed);
		Main.vhsShader.update(elapsed);

		#if debug
		// trace('updated event');
		#end

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart song":
					FlxG.resetState();
				case "Exit to menu":
					PlayState.resetMusic();

					if (PlayState.isStoryMode)
						Main.switchState(this, new MainMenuState());
					else
						Main.switchState(this, new FreeplayState());
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		#if debug
		// trace('mid selection');
		#end

		for (item in grpMenuShit.members)
		{
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (bullShit - 1 == curSelected)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		#if debug
		// trace('finished selection');
		#end
		//
	}
}
