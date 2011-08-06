package model
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.utils.Base64Encoder;
import mx.utils.UIDUtil;

import org.bytearray.gif.encoder.GIFEncoder;

[RemoteClass]
/**
 * Represents one GIF animation.
 */
public class GIFAnimation extends EventDispatcher
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function GIFAnimation(name:String = null)
	{
		super();
		
		this.name = name;
		
		frames = new ArrayCollection();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	[Bindable]
	public var uid:String = UIDUtil.createUID();
	
	[Bindable]
	public var name:String;
	
	[Bindable]
	public var date:Date = new Date();
	
	[Bindable]
	public var generation:int = 0;
	
	[Bindable]
	/**
	 * XML with info about Imgur image storage.
	 */
	public var imgurXML:XML;
	
	[Bindable]
	/**
	 * Value of <code>generation</code> when <code>imgurXML</code> was received.
	 */
	public var imgurXMLGeneration:int = -1;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  dateTime
	//----------------------------------
	
	[Transient]
	[Bindable("__NoChangeEvent__")]
	public function get dateTime():Number
	{
		return date.time;
	}
	
	//--------------------------------------
	//  frames
	//--------------------------------------
	
	private var _frames:ArrayCollection /* of Frame */;
	
	[Bindable("framesChange")]
	public function get frames():ArrayCollection /* of Frame */ 
	{
		return _frames;
	}
	
	public function set frames(value:ArrayCollection /* of Frame */):void
	{
		if (_frames == value)
			return;
		
		if (_frames)
			_frames.removeEventListener(CollectionEvent.COLLECTION_CHANGE, frames_collectionChangeHandler);
		
		_frames = value;
		checkEmpty();
		
		if (_frames)
			_frames.addEventListener(CollectionEvent.COLLECTION_CHANGE, frames_collectionChangeHandler);
		
		dispatchEvent(new Event("framesChange"));
	}
	
	//----------------------------------
	//  empty
	//----------------------------------
	
	private var _empty:Boolean = true;
	
	[Transient]
	[Bindable("change")]
	public function get empty():Boolean
	{
		return _empty;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function checkEmpty():void
	{
		var newEmpty:Boolean = true;
		for each (var frame:Frame in frames)
		{
			if (!frame.empty)
			{
				newEmpty = false;
				break;
			}
		}
		
		if (_empty != newEmpty)
		{
			_empty = newEmpty;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
	public function removeEmptyFrames():void
	{
		var n:int = _frames.length;
		for (var i:int = n - 1; i >= 0; i--)
		{
			if (Frame(_frames[i]).empty)
				_frames.removeItemAt(i);
		}
	}
	
	public function generateGIF():ByteArray
	{
		if (empty)
			return null;
		
		var encoder:GIFEncoder = new GIFEncoder();
		encoder.start();
		// we call the setRepeat method with 0 as parameter so that it loops
		encoder.setRepeat(Settings.instance.gifRepeat);
		encoder.setDelay(Settings.instance.frameDuration * 1000);
		var size:Point = getSize();
		var cacheBitmapData:BitmapData = new BitmapData(size.x, size.y);
		for each (var frame:Frame in frames)
		{
			encoder.addFrame(sizeBitmap(frame.bitmapData, cacheBitmapData, size));
		}
		encoder.finish();
		return encoder.stream;
	}
	
	private function sizeBitmap(bitmapData:BitmapData, cacheBitmapData:BitmapData, size:Point):BitmapData
	{
		if (bitmapData.width == size.x && bitmapData.height == size.y)
			return bitmapData;
		
		// clear bitmap with black
		cacheBitmapData.floodFill(0, 0, 0xFF000000);
		
		// scale bitmap to GIF size
		var scale:Number = Math.min(size.x / bitmapData.width, size.y / bitmapData.height);
		var destPoint:Point = new Point((size.x - bitmapData.width * scale) / 2, 
			(size.y - bitmapData.height * scale) / 2);
		var matrix:Matrix = new Matrix();
		matrix.scale(scale, scale);
		matrix.translate(destPoint.x, destPoint.y);
		cacheBitmapData.draw(bitmapData, matrix, null, null, null, true);
		
		return cacheBitmapData;
	}
	
	public function generateGIFBase64():String
	{
		var byteArray:ByteArray = generateGIF();
		if (!byteArray)
			return null;
		
		var encoder:Base64Encoder = new Base64Encoder();
		encoder.encodeBytes(byteArray);
		return encoder.drain();
	}
	
	public function getSize():Point
	{
		var point:Point = new Point();
		for each (var frame:Frame in frames)
		{
			if (frame.empty)
				continue;
			
			if (frame.bitmapData.width > point.x)
				point.x = frame.bitmapData.width;
			
			if (frame.bitmapData.height > point.y)
				point.y = frame.bitmapData.height;
		}
		return point;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function frames_collectionChangeHandler(event:CollectionEvent):void
	{
		checkEmpty();
	}
	
}
}