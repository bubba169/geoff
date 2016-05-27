package geoff.platform.android;
import geoff.platform.android.AndroidRenderer;

/**
 * This is a static class that will give access to all of the platform dependant features
 * @author Simon
 */
class AndroidPlatform
{
	public var name : String = "Android";
	
	public var gl : AndroidRenderer;
	public var eventManager : AndroidEventManager;
	
	public function new()
	{
		gl = new AndroidRenderer();
		eventManager = new AndroidEventManager();
	}
}