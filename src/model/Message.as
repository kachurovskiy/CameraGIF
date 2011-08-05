package model
{
import flash.utils.getTimer;

public class Message
{
	public function Message(text:String, isError:Boolean = false, 
		lifetime:Number = 7000, url:String = null)
	{
		super();
		
		this.text = text;
		this.isError = isError;
		this.lifetime = lifetime;
		this.url = url;
	}
	
	public var creationTime:int = getTimer();
	
	public var text:String;
	
	public var lifetime:Number;
	
	public var isError:Boolean;
	
	public var url:String;
	
}
}