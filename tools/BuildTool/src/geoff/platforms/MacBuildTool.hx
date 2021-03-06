package geoff.platforms;
import geoff.helpers.TemplateHelper;
import sys.FileSystem;
import sys.io.File;
import geoff.helpers.DirectoryHelper;
import sys.io.Process;

/**
 * ...
 * @author Simon
 */
class MacBuildTool
{
	var projectDirectory : String;
	var binDirectory : String;
	var flags : Array<String>;
	var config : Dynamic;


	public function new( dir : String, flags : Array<String>, config : Dynamic )
	{
		this.projectDirectory = dir;
		this.flags = flags;
		this.config = config;
		this.binDirectory = projectDirectory + "bin/mac/";
	}


	public function clean() : Int
	{
		if ( FileSystem.exists( projectDirectory + "build.hxml" ) ) FileSystem.deleteFile( projectDirectory + "build.hxml" );

		// clean any old builds
		if ( FileSystem.exists( binDirectory ) )
		{
			trace("Cleaning " + binDirectory );
			DirectoryHelper.removeDirectory( binDirectory );
		}

		return 0;
	}


	public function update( ) : Int
	{

		var buildHXML = "";
		var srcArray : Array<String> = config.project.src;
		for ( dir in srcArray ) {
			buildHXML += "-cp " + dir + "\n";
		}

		var libArray : Array<String> = config.project.haxelib;
		for ( lib in libArray ) {
			buildHXML += "-lib " + lib + "\n";
		}

		buildHXML += "-cpp bin/mac/build\n";
		buildHXML += "-main " + config.project.main + "\n";
		buildHXML += "-resource project.geoff@project\n";

		if ( isDebugBuild() ) {
			buildHXML += "-debug\n";
			buildHXML += "-D HXCPP_DEBUG_LINK\n";
			buildHXML += "-D HXCPP_STACK_TRACE\n";
			buildHXML += "-D HXCPP_STACK_LINE\n";
			buildHXML += "-D HXCPP_CHECK_POINTER\n";
		}

		buildHXML += "-D mac\n";
		buildHXML += "-D desktop\n";
		buildHXML += "-D static_link\n";
		buildHXML += "-D HX_MACOS\n";
		buildHXML += "-D HXCPP_M64\n";
		buildHXML += "-D geoff_cpp\n";

		var defineArray : Array<String> = config.project.defines;
		for ( define in defineArray )
		{
			buildHXML += "-D " + define + "\n";
		}

		if ( !isDebugBuild() ) buildHXML += "-D no_console\n";
		File.saveContent(  projectDirectory + "build.hxml", buildHXML );

		return 0;
	}


	public function build( ) : Int
	{
		var templateConstants =
		[
			"Main" => config.project.main,
			"Version" => config.project.version,
			"ProjectName" => config.project.name,
			"WindowWidth" => config.project.window.width,
			"WindowHeight" => config.project.window.height,
			"ConsoleSetting" => ""
		];

		if ( !isDebugBuild() )
		{
			var debugDefines = "<set name='no_console' value='true'/>";
			debugDefines += "\n<set name='HXCPP_DEBUG_LINK' value='true'/>";
			debugDefines += "\n<set name='HXCPP_STACK_TRACE' value='true'/>";
			debugDefines += "\n<set name='HXCPP_STACK_LINE' value='true'/>";
			debugDefines += "\n<set name='HXCPP_CHECK_POINTER' value='true'/>";

			templateConstants.set( "ConsoleSetting", debugDefines);
		}

		if ( flags.indexOf( "clean" ) > -1 ) {
			clean();
			update();
		}

		// Make the directory
		FileSystem.createDirectory( binDirectory + "project" );

		//Copy template files
		DirectoryHelper.copyDirectory( config.geoffpath + "template/mac/", binDirectory + "project/" );
		DirectoryHelper.copyDirectory( config.geoffpath + "template/common/cpp/glfw_base/", binDirectory + "project/" );
		DirectoryHelper.copyDirectory( config.geoffpath + "template/common/cpp/al_audio/", binDirectory + "project/" );
		DirectoryHelper.copyDirectory( config.geoffpath + "template/common/cpp/gl_renderer/", binDirectory + "project/" );
		DirectoryHelper.copyDirectory( config.geoffpath + "template/common/cpp/stb_image/", binDirectory + "project/" );
		DirectoryHelper.copyDirectory( config.geoffpath + "template/common/cpp/ogg_decoder/", binDirectory + "project/" );

		trace("Processing templates");

		//Fill in values
		TemplateHelper.processTemplates( binDirectory + "project/", templateConstants );

		//Compile project to java
		if ( compileHaxe( ) != 0 )
		{
			trace("Haxe Compilation could not be completed!");
			return -1;
		}

		copyLibs( );
		copyAssets( );

		if ( compileCPP( ) != 0 ) {
			trace("CPP Compilation could not be completed!");
			return -1;
		};

		return 0;

	}


	function compileHaxe( ) : Int
	{
		Sys.setCwd( projectDirectory );
		return Sys.command( "haxe", [ "build.hxml"] );
	}

	function copyAssets( )
	{
		trace("Looking for assets in " + config.project.haxelib );

		var libArray : Array<String> = config.project.haxelib;
		for ( lib in libArray ) {
			var libdir_assets = DirectoryHelper.getHaxelibDir(lib) + "assets";

			trace("Looking for assets in " + libdir_assets );

			if ( FileSystem.exists( libdir_assets ) && FileSystem.isDirectory( libdir_assets ) )
			{
				DirectoryHelper.copyDirectory( libdir_assets + "/", binDirectory + "/project/assets/" );
			}
		}

		if ( FileSystem.exists( projectDirectory + "assets" ) )
		{
			DirectoryHelper.copyDirectory( projectDirectory + "assets/", binDirectory + "/project/assets/" );
		}
	}

	function copyLibs( ) : Void
	{
		var filename : String = "lib";
		var libName : String = config.project.main;
		if ( libName.indexOf(".") > -1 )
		{
			libName = libName.substr( libName.lastIndexOf(".") + 1 );
		}
		filename += libName;
		if ( isDebugBuild() ) filename += "-debug";
		filename += ".a";

		File.copy( binDirectory + "build/" + filename, binDirectory + "/project/lib/libApp.a" );

		var hxcppDir : String = new Process( "haxelib", ["path", "hxcpp"] ).stdout.readLine().toString();
		File.copy( hxcppDir + "lib/Mac64/libstd.a", binDirectory + "project/lib/libstd.a" );
		File.copy( hxcppDir + "lib/Mac64/libmysql5.a", binDirectory + "project/lib/libmysql5.a" );
		File.copy( hxcppDir + "lib/Mac64/libregexp.a", binDirectory + "project/lib/libregexp.a" );
		File.copy( hxcppDir + "lib/Mac64/libsqlite.a", binDirectory + "project/lib/libsqlite.a" );
		File.copy( hxcppDir + "lib/Mac64/libzlib.a", binDirectory + "project/lib/libzlib.a" );

		DirectoryHelper.copyDirectory( binDirectory + "build/include/", binDirectory + "project/include/" );
	}

	function compileCPP( ) : Int
	{
		Sys.setCwd( binDirectory + "project" );
		var params = ["run", "hxcpp", "build.xml"];
		if ( isDebugBuild() ) params.push( "-debug" );
		return Sys.command( "haxelib", params );
	}


	function isDebugBuild() : Bool
	{
		return flags.indexOf("debug") > -1;
	}




	public function run( )
	{
		Sys.command( binDirectory + "project/" + config.project.name, [] );
	}

}
