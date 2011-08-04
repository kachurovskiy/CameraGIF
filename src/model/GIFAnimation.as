package model
{
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.utils.UIDUtil;

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