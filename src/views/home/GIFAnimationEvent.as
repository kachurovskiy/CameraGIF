package views.home
{
import flash.events.Event;

import model.GIFAnimation;

public class GIFAnimationEvent extends Event
{
	
	public static const GIFA_VIEW:String = "gifaView";
	
	public static const GIFA_EDIT:String = "gifaEdit";
	
	public static const GIFA_REMOVE:String = "gifaRemove";
	
	public static const GIFA_SHARE:String = "gifaShare";
	
	public function GIFAnimationEvent(type:String, bubbles:Boolean=false, 
		cancelable:Boolean=false, gifAnimation:GIFAnimation = null)
	{
		super(type, bubbles, cancelable);
		
		this.gifAnimation = gifAnimation;
	}
	
	public var gifAnimation:GIFAnimation;
	
}
}