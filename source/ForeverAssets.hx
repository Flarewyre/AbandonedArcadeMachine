package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameFolder.gameObjects.Note;
import gameFolder.gameObjects.userInterface.*;
import gameFolder.gameObjects.userInterface.menu.*;
import gameFolder.meta.data.Conductor;
import gameFolder.meta.data.Section.SwagSection;
import gameFolder.meta.state.PlayState;

using StringTools;

/**
	Forever Assets is a class that manages the different asset types, basically a compilation of switch statements that are
	easy to edit for your own needs. Most of these are just static functions that return information
**/
class ForeverAssets
{
	//
	public static function generateCombo(asset:String, assetModifier:String = 'base', changeableSkin:String = 'default', baseLibrary:String, negative:Bool,
			createdColor:FlxColor, scoreInt:Int, recycleGroup:FlxTypedGroup<FlxText>):FlxText
	{
		var newSprite:FlxText = recycleGroup.recycle(FlxText, null);
		switch (assetModifier)
		{
			default:
				newSprite.text = '';
				newSprite.setFormat(Paths.font("atari.ttf"), 32);
				newSprite.textField.background = true;
				newSprite.textField.backgroundColor = FlxColor.BLACK;

				newSprite.alpha = 1;
				newSprite.screenCenter();
				newSprite.y -= 70;

				newSprite.color = FlxColor.WHITE;
				if (negative)
					newSprite.color = createdColor;
		}

		return newSprite;
	}

	public static function generateRating(asset:String, assetModifier:String = 'base', changeableSkin:String = 'default', baseLibrary:String,
			recycleGroup:FlxTypedGroup<FlxSprite>):FlxSprite
	{
		var rating:FlxSprite = recycleGroup.recycle(FlxSprite)
			.loadGraphic(Paths.image(ForeverTools.returnSkinAsset(asset, assetModifier, changeableSkin, baseLibrary)));
		switch (assetModifier)
		{
			default:
				rating.alpha = 1;
				rating.screenCenter();
				rating.x = (FlxG.width * 0.55) - 40;
				rating.y -= 60;
				rating.acceleration.y = 0;
				rating.velocity.y = -175;
				rating.velocity.x = 0;
		}

		return rating;
	}

	public static function generateNoteSplashes(asset:String, assetModifier:String = 'base', baseLibrary:String, noteData:Int):NoteSplash
	{
		//
		var tempSplash:NoteSplash = new NoteSplash(noteData);
		switch (assetModifier)
		{
			case 'pixel':
				tempSplash.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('splash-pixel', assetModifier, Init.trueSettings.get("Note Skin"),
					'noteskins/notes')), true, 34,
					34);
				tempSplash.animation.add('anim1', [noteData, 4 + noteData, 8 + noteData, 12 + noteData], 24, false);
				tempSplash.animation.add('anim2', [16 + noteData, 20 + noteData, 24 + noteData, 28 + noteData], 24, false);
				tempSplash.animation.play('anim1');
				tempSplash.addOffset('anim1', -120, -120);
				tempSplash.addOffset('anim2', -120, -120);
				tempSplash.setGraphicSize(Std.int(tempSplash.width * PlayState.daPixelZoom));

			default:
				// 'UI/$assetModifier/notes/noteSplashes'
				tempSplash.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('noteSplashes', assetModifier, Init.trueSettings.get("Note Skin"),
					'noteskins/notes')), true,
					210, 210);
				tempSplash.animation.add('anim1', [
					(noteData * 2 + 1),
					8 + (noteData * 2 + 1),
					16 + (noteData * 2 + 1),
					24 + (noteData * 2 + 1),
					32 + (noteData * 2 + 1)
				], 24, false);
				tempSplash.animation.add('anim2', [
					(noteData * 2),
					8 + (noteData * 2),
					16 + (noteData * 2),
					24 + (noteData * 2),
					32 + (noteData * 2)
				], 24, false);
				tempSplash.animation.play('anim1');
				tempSplash.addOffset('anim1', -20, -10);
				tempSplash.addOffset('anim2', -20, -10);

				/*
					tempSplash.frames = Paths.getSparrowAtlas('UI/$assetModifier/notes/noteSplashes');
					// get a random value for the note splash type
					tempSplash.animation.addByPrefix('anim1', 'note impact 1 ' + UIStaticArrow.getColorFromNumber(noteData), 24, false);
					tempSplash.animation.addByPrefix('anim2', 'note impact 2 ' + UIStaticArrow.getColorFromNumber(noteData), 24, false);
					tempSplash.animation.play('anim1');

					tempSplash.addOffset('anim1', 16, 16);
					tempSplash.addOffset('anim2', 16, 16);
				 */
		}

		return tempSplash;
	}

	public static function generateUIArrows(x:Float, y:Float, ?staticArrowType:Int = 0, assetModifier:String):UIStaticArrow
	{
		var newStaticArrow:UIStaticArrow = new UIStaticArrow(x, y, staticArrowType);
		switch (assetModifier)
		{
			case 'chart editor':
				newStaticArrow.loadGraphic(Paths.image('UI/forever/base/chart editor/note_array'), true, 157, 156);
				newStaticArrow.animation.add('static', [staticArrowType]);
				newStaticArrow.animation.add('pressed', [16 + staticArrowType], 12, false);
				newStaticArrow.animation.add('confirm', [4 + staticArrowType, 8 + staticArrowType, 16 + staticArrowType], 24, false);

				newStaticArrow.addOffset('static');
				newStaticArrow.addOffset('pressed');
				newStaticArrow.addOffset('confirm');

			default:
				// look man you know me I fucking hate repeating code
				// not even just a cleanliness thing it's just so annoying to tweak if something goes wrong like
				// genuinely more programmers should make their code more modular
				var framesArgument:String = "arrows-pixels";
				newStaticArrow.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('$framesArgument', assetModifier, Init.trueSettings.get("Note Skin"),
					'noteskins/notes')), true,
					17, 17);
				newStaticArrow.animation.add('static', [staticArrowType]);
				newStaticArrow.animation.add('pressed', [4 + staticArrowType, 8 + staticArrowType], 12, false);
				newStaticArrow.animation.add('confirm', [12 + staticArrowType, 16 + staticArrowType], 24, false);

				newStaticArrow.setGraphicSize(Std.int(newStaticArrow.width * PlayState.daPixelZoom));
				newStaticArrow.updateHitbox();
				newStaticArrow.antialiasing = false;

				newStaticArrow.addOffset('static', -67, -75);
				newStaticArrow.addOffset('pressed', -67, -75);
				newStaticArrow.addOffset('confirm', -67, -75);
		}

		return newStaticArrow;
	}

	/**
		Notes!
	**/
	public static function generateArrow(assetModifier, strumTime, noteData, noteType, noteAlt, ?isSustainNote:Bool = false, ?prevNote:Note = null):Note
	{
		var newNote:Note;
		var changeableSkin:String = Init.trueSettings.get("Note Skin");
		// gonna improve the system eventually
		if (changeableSkin.startsWith('quant'))
			newNote = Note.returnQuantNote(assetModifier, strumTime, noteData, noteType, noteAlt, isSustainNote, prevNote);
		else
			newNote = Note.returnDefaultNote(assetModifier, strumTime, noteData, noteType, noteAlt, isSustainNote, prevNote);

		// hold note offset
		if (isSustainNote && prevNote != null)
		{
			if (prevNote.isSustainNote)
				newNote.noteVisualOffset = prevNote.noteVisualOffset;
			else // calculate a new visual offset based on that note's width and newnote's width
				newNote.noteVisualOffset = ((prevNote.width / 2) - (newNote.width / 2));
		}

		return newNote;
	}

	/**
		Checkmarks!
	**/
	public static function generateCheckmark(x:Float, y:Float, asset:String, assetModifier:String = 'base', changeableSkin:String = 'default',
			baseLibrary:String)
	{
		var newCheckmark:Checkmark = new Checkmark(x, y);
		switch (assetModifier)
		{
			default:
				newCheckmark.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset(asset, assetModifier, changeableSkin, baseLibrary));
				newCheckmark.antialiasing = false;

				newCheckmark.animation.addByPrefix('false finished', 'uncheckFinished');
				newCheckmark.animation.addByPrefix('false', 'uncheck', 12, false);
				newCheckmark.animation.addByPrefix('true finished', 'checkFinished');
				newCheckmark.animation.addByPrefix('true', 'check', 12, false);

				// for week 7 assets when they decide to exist
				// animation.addByPrefix('false', 'Check Box unselected', 24, true);
				// animation.addByPrefix('false finished', 'Check Box unselected', 24, true);
				// animation.addByPrefix('true finished', 'Check Box Selected Static', 24, true);
				// animation.addByPrefix('true', 'Check Box selecting animation', 24, false);
				newCheckmark.setGraphicSize(Std.int(newCheckmark.width * 3), Std.int(newCheckmark.height * 3));
				newCheckmark.updateHitbox();

				///*
				var offsetByX = -60;
				var offsetByY = -60;
				newCheckmark.addOffset('false', offsetByX, offsetByY);
				newCheckmark.addOffset('true', offsetByX, offsetByY);
				newCheckmark.addOffset('true finished', offsetByX, offsetByY);
				newCheckmark.addOffset('false finished', offsetByX, offsetByY);
				// */

				// addOffset('true finished', 17, 37);
				// addOffset('true', 25, 57);
				// addOffset('false', 2, -30);
		}
		return newCheckmark;
	}
}
