package geoff;
import haxe.Timer;

/**
 * ...
 * @author Simon
 */
class App
{

	public static var current : App;
	
	public var platform : Platform;
	public var delegate : AppDelegate;
	public var fps : Int = 60;
	
	var _timeOfLastUpdate : Float = 0;
	var _timeSinceLastTick : Float = 0;
	var _updateTime : Float = 0;
	
	public static function main()
	{
		trace("Main");
	}
	
	public static function create( delegate : AppDelegate ) : App
	{
		var app : App = new App( );
		app.platform = new Platform();
		app.delegate = delegate;
		return app;
	}
		
	/**
	 * 
	 */
	
	public function new( ) 
	{
		current = this;
	}
	
	public function init()
	{
		platform.renderer.init();
		delegate.init( platform.renderer );
		
		_timeOfLastUpdate = Timer.stamp();
		_timeSinceLastTick = 0;
	}
	
	public function update()
	{
		_updateTime = Timer.stamp();
		_timeSinceLastTick = _updateTime - _timeOfLastUpdate;
		_timeOfLastUpdate = _updateTime;
		
		platform.eventManager.handleEvents( delegate );
		delegate.update( platform.renderer, _timeSinceLastTick );
	}
	
	public function destroy()
	{
		delegate.destroy( );
		platform.renderer.destroy();
	}
	
	
}