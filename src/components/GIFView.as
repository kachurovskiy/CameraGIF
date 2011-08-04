package components
{
import model.GIFAnimation;

import spark.components.View;
import spark.events.ViewNavigatorEvent;

public class GIFView extends View
{
	public function GIFView()
	{
		super();
		
		addEventListener(ViewNavigatorEvent.VIEW_ACTIVATE, viewActivateHandler);
		addEventListener(ViewNavigatorEvent.VIEW_DEACTIVATE, viewDeactivateHandler);
	}
	
	[Bindable("dataChange")]
	public function get gifAnimation():GIFAnimation
	{
		return data as GIFAnimation;
	}
	
	public function set gifAnimation(value:GIFAnimation):void
	{
		data = value;
	}
	
	protected function viewActivateHandler(event:ViewNavigatorEvent):void
	{
	}
	
	protected function viewDeactivateHandler(event:ViewNavigatorEvent):void
	{
	}
	
}
}