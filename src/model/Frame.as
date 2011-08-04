package model
{
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;

[RemoteClass]
/**
 * Describes one frame in the animation.
 */
public class Frame extends EventDispatcher
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Frame()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  bitmapData
	//--------------------------------------
	
	private var _bitmapData:BitmapData;
	
	[Bindable("bitmapDataChange")]
	public function get bitmapData():BitmapData
	{
		return _bitmapData;
	}
	
	public function set bitmapData(value:BitmapData):void
	{
		if (_bitmapData == value)
			return;
		
		_bitmapData = value;
		dispatchEvent(new Event("bitmapDataChange"));
	}
	
	[Transient]
	[Bindable("bitmapDataChange")]
	public function get empty():Boolean
	{
		return !_bitmapData;
	}
	
}
}