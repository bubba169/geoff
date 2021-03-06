package geoff.platform.assets;

import geoff.assets.IAssetLoader;
import geoff.audio.AudioSource;
import geoff.platform.assets.audio.CPPOggLoader;
import geoff.platform.assets.images.STBImageLoader;
import geoff.renderer.Texture;
import haxe.Json;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Simon
 */
class WindowsAssetLoader implements IAssetLoader
{

	public function new() 
	{
		
	}

	public function loadTexture( texture : Texture ) : Void 
	{
		STBImageLoader.loadTexture( texture );
		
		if ( assetExists( texture.asset + ".map" ) )
		{
			texture.map = Json.parse( getText( texture.asset + ".map" ) );
		}
	}
		
	public function loadAudio( source : AudioSource ) : Void 
	{
		if ( source.originalFormat == AudioSourceFormat.Ogg ) 
		{
			CPPOggLoader.loadOgg( source );
		}
	}
		
	public function getText( asset : String ) : String 
	{
		return File.getContent( asset );
	}
	
	public function getBytes( asset : String ) : Bytes 
	{
		return File.getBytes( asset );
	}
	
	public function assetExists( asset : String ) : Bool
	{
		return FileSystem.exists( asset );
	}
	
}