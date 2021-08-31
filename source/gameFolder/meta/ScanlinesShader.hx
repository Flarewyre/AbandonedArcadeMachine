package gameFolder.meta;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.FlxAssets.FlxShader;
import lime.math.Vector2;

class ScanlinesShader extends FlxShader
{
	@:glFragmentSource('
        #pragma header
		
		void main()
		{
			float scale = 3.0;
			vec2 uResolution = vec2(1280.0, 720.0);
			vec2 uv = openfl_TextureCoordv.xy;
			if (mod(floor(uv.y * uResolution.y / scale), 3.0) == 0.0)
				gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
			else
				gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		}
	')
	public function new()
	{
		super();
	}
}
