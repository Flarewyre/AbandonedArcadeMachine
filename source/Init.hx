import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import gameFolder.meta.CoolUtil;
import gameFolder.meta.InfoHud;
import gameFolder.meta.data.Highscore;
import gameFolder.meta.data.dependency.Discord;
import gameFolder.meta.state.*;
import gameFolder.meta.state.charting.*;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

using StringTools;

/**
	This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
	A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
	most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends FlxState
{
	/*
		Okay so here we'll set custom settings. As opposed to the previous options menu, everything will be handled in here with no hassle.
		This will read what the second value of the key's array is, and then it will categorise it, telling the game which option to set it to.

		0 - boolean, true or false checkmark
		1 - choose string
		2 - choose number (for fps so its low capped at 30)
		3 - offsets, this is unused but it'd bug me if it were set to 0
		might redo offset code since I didnt make it and it bugs me that it's hardcoded the the last part of the controls menu
	 */
	public static var gameSettings:Map<String, Dynamic> = [
		'Downscroll' => [false, 0, 'Whether to have the strumline vertically flipped in gameplay.'],
		'Centered Notefield' => [false, 0, 'Whether to center the strumline in gameplay.'],
		'Auto Pause' => [true, 0, ''],
		'FPS Counter' => [true, 0, 'Whether to display the FPS counter.'],
		'Memory Counter' => [true, 0, 'Whether to display approximately how much memory is being used.'],
		'Debug Info' => [false, 0, 'Whether to display information like your game state.'],
		'Reduced Movements' => [
			false,
			0,
			'Whether to reduce movements, like icons bouncing or beat zooms in gameplay.'
		],
		'Display Accuracy' => [true, 0, 'Whether to display your accuracy on screen.'],
		'Disable Antialiasing' => [false, 0, 'Whether to disable Anti-aliasing. Helps improve performance in FPS.'],
		'No Camera Note Movement' => [false, 0, 'When enabled, left and right notes no longer move the camera.'],
		'Use Forever Chart Editor' => [true, 0, 'When enabled, uses the custom Forever Engine chart editor!'],
		'Disable Note Splashes' => [
			false,
			0,
			'Whether to disable note splashes in gameplay. Useful if you find them distracting.'
		],
		// custom ones lol
		'Offset' => [0, 3],
		'Filter' => [
			'none',
			1,
			'Choose a filter for colorblindness.',
			['none', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		"UI Skin" => ['default', 1, 'Choose a UI Skin for ratings, combo, etc.', ''],
		"Note Skin" => ['default', 1, 'Choose a note skin.', ''],
		"Framerate Cap" => [120, 1, 'Define your maximum FPS.', ['']],
		"Opaque Arrows" => [false, 0, "Makes the arrows at the top of the screen opaque again."],
		"Opaque Holds" => [false, 0, "Huh, why isnt the trail cut off?"],
	];

	public static var trueSettings:Map<String, Dynamic> = [];
	public static var settingsDescriptions:Map<String, String> = [];

	public static var gameControls:Map<String, Dynamic> = [
		'UP' => [[FlxKey.UP, W], 2],
		'DOWN' => [[FlxKey.DOWN, S], 1],
		'LEFT' => [[FlxKey.LEFT, A], 0],
		'RIGHT' => [[FlxKey.RIGHT, D], 3],
		'ACCEPT' => [[FlxKey.SPACE, Z, FlxKey.ENTER], 4],
		'BACK' => [[FlxKey.BACKSPACE, X, FlxKey.ESCAPE], 5],
		'PAUSE' => [[FlxKey.ENTER, P], 6],
		'RESET' => [[R, null], 7]
	];

	public static var filters:Array<BitmapFilter> = []; // the filters the game has active
	/// initalise filters here
	public static var gameFilters:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Deuteranopia" => {
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Protanopia" => {
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Tritanopia" => {
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		}
	];

	override public function create():Void
	{
		FlxG.save.bind('forever', 'engine');
		Highscore.load();

		loadSettings();
		loadControls();

		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end

		// apply saved filters
		FlxG.game.setFilters(filters);

		Main.switchState(this, new TitleState());
	}

	public static function loadSettings():Void
	{
		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs

		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		// lemme fix that for you
		if (!Std.isOfType(trueSettings.get("Framerate Cap"), Int) || trueSettings.get("Framerate Cap") < 30)
			trueSettings.set("Framerate Cap", 30);

		// 'hardcoded' ui skins
		trueSettings.set("UI Skin", 'default');
		trueSettings.set("Note Skin", 'default');
		trueSettings.set("Filter", 'none');


		saveSettings();

		updateAll();
	}

	public static function loadControls():Void
	{
		if ((FlxG.save.data.gameControls != null) && (Lambda.count(FlxG.save.data.gameControls) == Lambda.count(gameControls)))
			gameControls = FlxG.save.data.gameControls;

		saveControls();
	}

	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		updateAll();
	}

	public static function saveControls():Void
	{
		FlxG.save.data.gameControls = gameControls;
		FlxG.save.flush();
	}

	public static function updateAll()
	{
		InfoHud.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('Debug Info'), trueSettings.get('Memory Counter'));

		#if !html5
		Main.updateFramerate(trueSettings.get("Framerate Cap"));
		#end

		///*
		filters = [];
		FlxG.game.setFilters(filters);

		var theFilter:String = trueSettings.get('Filter');
		if (gameFilters.get(theFilter) != null)
		{
			var realFilter = gameFilters.get(theFilter).filter;

			if (realFilter != null)
				filters.push(realFilter);
		}

		FlxG.game.setFilters(filters);
		// */
	}
}
