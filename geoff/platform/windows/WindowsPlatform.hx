package geoff.platform.windows;

/**
 * ...
 * @author Simon
 */
class WindowsPlatform
{

	public var name : String = "Windows";
	
	public var gl : WindowsGLContext;
	public var eventManager : WindowsEventManager;
	
	public function new()
	{
		gl = new WindowsGLContext();
		eventManager = new WindowsEventManager();
	}
	
}