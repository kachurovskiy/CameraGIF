package model
{
import flash.events.EventDispatcher;
import flash.net.SharedObject;

[RemoteClass]
public class Settings extends EventDispatcher
{
	
	public static const CAMERA_SIZE_MIN:Number = 50;
	public static const CAMERA_SIZE_MAX:Number = 500;
	
	public static const FRAME_DURATION_MIN:Number = 0.5;
	public static const FRAME_DURATION_MAX:Number = 5;
	
	private static const SHARED_OBJECT_NAME:String = "Settings";
	
	private static var sharedObject:SharedObject;
	
	private static var _instance:Settings;
	
	[Bindable("__NoChangeEvent__")]
	public static function get instance():Settings
	{
		if (!_instance)
			_instance = loadSettings();
		if (!_instance)
			_instance = new Settings();
		
		return _instance;
	}
	
	private static function loadSettings():Settings
	{
		if (!sharedObject)
			sharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
		return sharedObject.data.settings as Settings;
	}
	
	public function Settings()
	{
		super();
		
		if (sharedObject)
			sharedObject.data.settings = this;
	}

	[Bindable]
	public var cameraWidth:Number = 300;
	
	[Bindable]
	public var cameraHeight:Number = 400;
	
	[Bindable]
	public var frameDuration:Number = 2;
	
	[Bindable]
	public var jpegQuality:Number = 80;
	
	[Bindable]
	public var cameraQuality:Number = 100;
	
	[Bindable]
	public var gifRepeat:int = 0;
	
	[Bindable]
	public var frameWidth:Number = 150;
	
	public function save():void
	{
		sharedObject.flush();
	}
	
}
}