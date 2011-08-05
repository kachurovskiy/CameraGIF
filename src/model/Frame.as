package model
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.ByteArray;

import mx.graphics.codec.JPEGEncoder;

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
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var encoder:JPEGEncoder = new JPEGEncoder(75);
	
	public var duration:Number = 2000;
	
	[Bindable]
	public var generation:int = 0;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  bitmapData
	//--------------------------------------
	
	private var _bitmapData:BitmapData;
	
	/**
	 * BitmapData can not be restored from AMF.
	 */
	[Transient]
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
		generation++;
		dispatchEvent(new Event("bitmapDataChange"));
	}
	
	//----------------------------------
	//  empty
	//----------------------------------
	
	[Transient]
	[Bindable("bitmapDataChange")]
	public function get empty():Boolean
	{
		return !_bitmapData;
	}
	
	//--------------------------------------
	//  bitmapBytes
	//--------------------------------------
	
	public function get bitmapBytes():ByteArray 
	{
		if (!_bitmapData)
			return null;
		
		var byteArray:ByteArray = new ByteArray();
		return encoder.encode(_bitmapData);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	public function set bitmapBytes(value:ByteArray):void
	{
		if (!value)
		{
			_bitmapData = null;
			return;
		}
		
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.INIT, loader_initHandler);
		loader.loadBytes(value);
	}
	
	public function ensureBitmapDataCreated(size:Point):void
	{
		// for photo frames bitmap data is always accessible
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function loader_initHandler(event:Event):void
	{
		bitmapData = Bitmap(LoaderInfo(event.target).content).bitmapData;
	}
	
}
}