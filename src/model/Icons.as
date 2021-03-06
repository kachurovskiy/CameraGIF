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
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/cog.png")]
	public var cog:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/cross.png")]
	public var cross:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/rotate.png")]
	public var rotate:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/camera.png")]
	public var camera:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed("icons/picture.png")]
	public var picture:Class;
	
	[Bindable("__NoChangeEvent__")]
	[Embed(source="icons/pictureFrame.png", scaleGridTop="5", scaleGridLeft="6",
		scaleGridBottom="22", scaleGridRight="25")]
	public var pictureFrame:Class;
	
}
}