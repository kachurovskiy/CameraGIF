package views.frame
{
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import model.Frame;

import spark.components.IItemRenderer;

public class FrameEvent extends Event
{
	
	public static const FRAME_REMOVE:String = "frameRemove";
	
	public static const FRAME_EDIT:String = "frameEdit";
	
	public static const FRAME_EDITED:String = "frameEdited";
	
	public function FrameEvent(type:String, bubbles:Boolean=false, 
		cancelable:Boolean=false, frame:Frame = null)
	{
		super(type, bubbles, cancelable);
		
		this.frame = frame;
	}
	
	public var frame:Frame;
	
	public function get itemRenderer():IItemRenderer
	{
		var parent:DisplayObjectContainer = target as DisplayObjectContainer;
		while (parent && !(parent is IItemRenderer))
		{
			parent = parent.parent;
		}
		return parent as IItemRenderer;
	}
	
}
}