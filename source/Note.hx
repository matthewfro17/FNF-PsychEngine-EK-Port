package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;
	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;

<<<<<<< HEAD

	/////ek shit i copied
	public static var mania:Int = 0; 
	public static var noteScale:Float;
	public static var pixelnoteScale:Float;
	public static var tooMuch:Float = 30;

	public static var p1NoteScale:Float;
	public static var p2NoteScale:Float;
	public var defaultWidth:Float;

	public static var noteScales:Array<Float> = [0.7, 0.6, 0.5, 0.65, 0.58, 0.55, 0.7, 0.7, 0.7];
	public static var pixelNoteScales:Array<Float> = [1, 0.83, 0.7, 0.9, 0.8, 0.74, 1, 1, 1];
	public static var noteWidths:Array<Float> = [112, 84, 66.5, 91, 77, 70, 140, 126, 119];
	public static var sustainXOffsets:Array<Float> = [97, 84, 70, 91, 77, 78, 97, 97, 97];
	public static var posRest:Array<Int> = [0, 35, 70, 0, 50, 60, 0, 0, 0];

	public static var frameN:Array<Dynamic> = [
		['purple', 'blue', 'green', 'red'],
		['purple', 'green', 'red', 'yellow', 'blue', 'dark'],
		['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'],
		['purple', 'blue', 'white', 'green', 'red'],
		['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'],
		['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'],
		['white'],
		['purple', 'red'],
		['purple', 'white', 'red']
	];
	public static var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	public static var ammoToMania:Array<Int> = [0, 6, 7, 8, 0, 3, 1, 4, 5, 2];
	public var curMania:Int = 0;
	public var scaleToUse:Float = 1;

	public static var P1MSwitchMap:Array<Dynamic> = [];
	public static var P2MSwitchMap:Array<Dynamic> = [];

=======
>>>>>>> parent of b8ca628 (first commit for ek port)
	private function set_texture(value:String):String {
		if(texture != value) {
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String {
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

		if(noteData > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					if(isSustainNote) {
						missHealth = 0.1;
					} else {
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'No Animation':
					noAnimation = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?_mustPress:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.noteOffset;

		if (!_mustPress)
		{
			/*if (strumTime >= PlayState.lastP2mChange)
				curMania = PlayState.curP2NoteMania;
			else
				curMania = PlayState.prevP2NoteMania;*/

			var highestStrumIdx:Int = 0;
			for (i in 0...P2MSwitchMap.length)
			{
				if (P2MSwitchMap[i][1] < this.strumTime)
					highestStrumIdx = i;
			}
			curMania = P2MSwitchMap[highestStrumIdx][0];
		}
		else
		{
			/*if (strumTime >= PlayState.lastP1mChange)
				curMania = PlayState.curP1NoteMania;
			else
				curMania = PlayState.prevP1NoteMania;*/

			var highestStrumIdx:Int = 0;
			for (i in 0...P1MSwitchMap.length)
			{
				if (P1MSwitchMap[i][1] < this.strumTime)
					highestStrumIdx = i;
			}
			curMania = P1MSwitchMap[highestStrumIdx][0];
		}

		scaleToUse = noteScales[curMania];
		if (PlayState.isPixelStage)
			scaleToUse = pixelNoteScales[curMania];

		this.noteData = noteData;

		if(noteData > -1) {
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % 4);
			if(!isSustainNote) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			if(ClientPrefs.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

<<<<<<< HEAD
				prevNote.animation.play(frameN[mania][prevNote.noteData % keyAmmo[mania]] + "hold");

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05 * PlayState.SONG.speed * (0.7 / scaleToUse);
=======
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05 * PlayState.SONG.speed;
>>>>>>> parent of b8ca628 (first commit for ek port)
				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage) {
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		} else if(!isSustainNote) {
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '') {
		if(prefix == null) prefix = '';
		if(texture == null) texture = '';
		if(suffix == null) suffix = '';
		
		var skin:String = texture;
		if(texture.length < 1) {
			skin = PlayState.SONG.arrowSkin;
			if(skin == null || skin.length < 1) {
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length-1] = prefix + arraySkin[arraySkin.length-1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			} else {
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
<<<<<<< HEAD
			p1NoteScale = Note.pixelnoteScale;
			p2NoteScale = Note.pixelnoteScale;
			defaultWidth = width;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * scaleToUse));
=======
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
>>>>>>> parent of b8ca628 (first commit for ek port)
			loadPixelNoteAnims();
			antialiasing = false;
		} else {
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);

		if(inEditor) {
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims() {
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}
<<<<<<< HEAD
		defaultWidth = width;
		setGraphicSize(Std.int(width * scaleToUse));
=======

		setGraphicSize(Std.int(width * 0.7));
>>>>>>> parent of b8ca628 (first commit for ek port)
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote) {
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		} else {
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
<<<<<<< HEAD


		//get rid of this shitty system
		/*if (!isSustainNote && !inEditor) ///fix note scales
		{
			var noteTypeShit:Float = 1;
			if (noteType == "Hurt Note")
				noteTypeShit = ((9.2 / 1.7) / 1.7); //i literally have no idea what any of these numbers mean, i just tried to compare the width and height of the pngs and this ended up working lol
			if (mustPress)
			{
				
				if (PlayState.isPixelStage)
					setGraphicSize(Std.int(defaultWidth * PlayState.daPixelZoom * Note.p1NoteScale));
				else
					setGraphicSize(Std.int(defaultWidth * Note.p1NoteScale * noteTypeShit));
			}
			else
			{
				if (PlayState.isPixelStage)
					setGraphicSize(Std.int(defaultWidth * PlayState.daPixelZoom * Note.p2NoteScale));
				else
					setGraphicSize(Std.int(defaultWidth * Note.p2NoteScale * noteTypeShit));
			}

		}*/
=======
>>>>>>> parent of b8ca628 (first commit for ek port)
	}
}
