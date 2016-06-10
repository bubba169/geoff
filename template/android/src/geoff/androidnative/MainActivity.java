package geoff.androidnative;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.view.Window;
import android.view.WindowManager;
import android.view.View;
import android.view.KeyEvent;
import android.view.inputmethod.InputMethodManager;
import android.view.inputmethod.EditorInfo;
import android.view.ViewGroup;
import android.content.Context;
import android.util.Log;
import android.widget.EditText;

import geoff.App;

public class MainActivity extends Activity
{

	public static Activity activity;

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
		
		activity = this;
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
		getWindow().getDecorView().setSystemUiVisibility( View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY );
		
		// Call the app entry point
		{{Main}}.main();
		
		App.current.platform.setActivity( this );
		
        GeoffGLView glView = new GeoffGLView(this);
        glView.init( App.current );
		
        setContentView( glView );

    }
}
