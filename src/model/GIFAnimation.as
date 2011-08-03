package model
{
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;

[RemoteClass]
/**
 * Represents one GIF animation.
 */
public class GIFAnimation extends EventDispatcher
{
	
	public function GIFAnimation(name:String = null)
	{
		super();
	}
	
	[Bindable]
	public var uid:String = UIDUtil.createUID();
	
	[Bindable]
	public var name:String;
	
	[Bindable]
	public var frames:ArrayCollection /* of Frame */;
	
}
}