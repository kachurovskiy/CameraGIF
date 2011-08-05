package actions
{
import com.facebook.graph.FacebookMobile;

import flash.display.DisplayObject;

import model.FacebookAppData;

import mx.core.FlexGlobals;

public class FacebookInitAction
{
	
	private var callback:Function;
	
	public function start(callback:Function):void
	{
		this.callback = callback;
		
		init();
	}
	
	private function init():void
	{
		FacebookMobile.init(FacebookAppData.APP_ID, initCallback);
	}
	
	private function initCallback(success:Object, fail:Object):void
	{
		if (fail)
			login();
		else
			callback();
	}
	
	private function login():void
	{
		FacebookMobile.login(loginCallback, 
			DisplayObject(FlexGlobals.topLevelApplication).stage, [ "publish_stream" ]);
	}
	
	private function loginCallback(success:Object, fail:Object):void
	{
		callback(fail);
	}
	
}
}