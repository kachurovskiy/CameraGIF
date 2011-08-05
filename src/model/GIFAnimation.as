package model
{
import flash.events.Event;
import flash.events.EventDispatcher;
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
		
		var size:Point = getSize();
		var encoder:GIFEncoder = new GIFEncoder();
		encoder.start();
		// we call the setRepeat method with 0 as parameter so that it loops
		encoder.setRepeat(0);
		for each (var frame:Frame in frames)
		{
			if (frame.empty)
				continue;
			
			frame.ensureBitmapDataCreated(size);
			encoder.setDelay(frame.duration);
			encoder.addFrame(frame.bitmapData);
		}
		encoder.finish();
		return encoder.stream;
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
		var frame:Frame = frames[0];
		return new Point(frame.bitmapData.width, frame.bitmapData.height);
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