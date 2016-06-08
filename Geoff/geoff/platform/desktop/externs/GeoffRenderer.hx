package geoff.platform.desktop.externs;
import geoff.renderer.RenderBatch;
import geoff.renderer.Shader;
import geoff.renderer.Texture;


/**
 * ...
 * @author Simon
 */
@:structAccess
@:unreflective
@:include("GeoffRenderer.h")
@:native("geoff::GeoffRenderer")

extern class GeoffRenderer
{
	public function clear( r : Float, g : Float, b : Float, a : Float ) : Void;
	
	public function compileShader( shader : Shader ) : Int;
	public function destroyShader( shader : Shader ) : Void;
	
	public function beginRender( width : Int, height : Int ) : Void;
	public function renderBatch( batch : RenderBatch ) : Void;
	public function endRender( ) : Void;
	
	public function pushRenderTarget( target : Texture ) : Void;
	public function popRenderTarget( ) : Void;
	
	public function getError() : Int;
	
	public function createTextureFromAsset( texture : Texture ) : Void;
	public function createTexture( texture : Texture ) : Void;
	public function uploadTexture( texture : Texture ) : Void;
	public function destroyTexture( texture : Texture ) : Void;
	
}