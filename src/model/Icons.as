package model
{
import flash.events.EventDispatcher;

public class Icons extends EventDispatcher
{
	
	private static var _instance:Icons;
	
	public static function get instance():Icons
	{
		if (!_instance)
			_instance = new Icons();
		
		return _instance;
	}
	
	public function Icons()
	{
		if (_instance)
			throw new Error("singleton error");
		
		_instance = this;
	}
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/remove.png")]
	public var remove:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/edit.png")]
	public var edit:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/message.png")]
	public var message:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/error.png")]
	public var error:Class;
	
}
}