package actions
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.ByteArray;

import model.GIFAnimation;
import model.ImgurAppData;

[Event(name="complete", type="flash.events.Event")]
[Event(name="error", type="flash.events.ErrorEvent")]
public class UploadImgurAction extends EventDispatcher
{
	
	private var gifAnimation:GIFAnimation;
	
	private var urlLoader:URLLoader;
	
	public function start(gifAnimation:GIFAnimation):void
	{
		this.gifAnimation = gifAnimation;
		
		var base64:String = gifAnimation.generateGIFBase64();
		if (!base64)
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Failed to generate image"));
			return;
		}
			
		urlLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler);
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_errorHandler);
		urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_errorHandler);
		var request:URLRequest = new URLRequest(ImgurAppData.UPLOAD_URL);
		request.method = URLRequestMethod.POST;
		var urlVariables:URLVariables = new URLVariables();
		urlVariables.key = ImgurAppData.API_KEY;
		urlVariables.image = base64;
		urlVariables.name = gifAnimation.name + ".gif";
		urlVariables.title = gifAnimation.name;
		request.data = urlVariables;
		urlLoader.load(request);
	}
	
	private function urlLoader_errorHandler(event:ErrorEvent):void
	{
		var errorText:String = event.text;
		if (urlLoader.data)
		{
			try
			{
				errorText = (new XML(urlLoader.data)).message;
			}
			catch (error:*) {}
		}
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorText));
	}
	
	private function urlLoader_completeHandler(event:Event):void
	{
		var xml:XML = new XML(urlLoader.data);
		trace(xml);
		gifAnimation.imgurXML = xml;
		gifAnimation.imgurXMLGeneration = gifAnimation.generation;
		dispatchEvent(new Event(Event.COMPLETE));
	}
}
}