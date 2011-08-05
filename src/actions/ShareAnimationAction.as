package actions
{
import com.facebook.graph.FacebookMobile;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import model.GIFAnimation;

[Event(name="complete", type="flash.events.Event")]
[Event(name="error", type="flash.events.ErrorEvent")]
public class ShareAnimationAction extends EventDispatcher
{
	
	private var gifAnimation:GIFAnimation;

	private var _url:String = "http://facebook.com";
	
	public function get url():String
	{
		return _url;
	}
	
	public function start(gifAnimation:GIFAnimation):void
	{
		this.gifAnimation = gifAnimation;
		
		var action:FacebookInitAction = new FacebookInitAction();
		action.start(upload);
	}
	
	private function upload(fail:Object = null):void
	{
		if (fail)
		{
			finish(fail);
			return;
		}
		
		var action:UploadImgurAction = new UploadImgurAction();
		action.addEventListener(Event.COMPLETE, uploadAction_completeHandler);
		action.addEventListener(ErrorEvent.ERROR, uploadAction_errorHandler);
		action.start(gifAnimation);
	}
	
	private function uploadAction_errorHandler(event:ErrorEvent):void
	{
		finish({ error: { message: event.text } });
	}
	
	private function uploadAction_completeHandler(event:Event):void
	{
		shareLink();
	}
	
	private function shareLink():void
	{
		var values:Object = 
			{
				link: String(gifAnimation.imgurXML.links.original),
				message: gifAnimation.name
			};
		FacebookMobile.api("/me/feed", linksCallback, values, "POST");
	}
	
	private function finish(fail:Object):void
	{
		if (fail)
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, fail.error.message));
		else
			dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function linksCallback(success:Object, fail:Object):void
	{
		finish(fail);
	}
	
}
}