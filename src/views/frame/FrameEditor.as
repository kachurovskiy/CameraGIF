package views.frame
{
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.media.Camera;
import flash.media.Video;

import model.Frame;

import mx.core.UIComponent;

import spark.components.Group;

/**
 * Dispatched when edit is completed.
 */
[Event(name="frameEdited", type="views.frame.FrameEvent")]

/**
 * Is added to frame item renderer when frame editing starts. Shows camera video
 * or some other edit content.
 */
public class FrameEditor extends UIComponent
{
	
	//--------------------------------------------------------------------------
	//
	//  Static constants
	//
	//--------------------------------------------------------------------------
	
	private static const CAMERA_WIDTH:Number = 300;
	
	private static const CAMERA_HEIGHT:Number = 400;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function FrameEditor()
	{
		super();
		
		addEventListener(TouchEvent.TOUCH_TAP, touchTapHandler);
		addEventListener(MouseEvent.CLICK, clickHandler);
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var camera:Camera;
	
	private var video:Video;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  frame
	//--------------------------------------
	
	private var _frame:Frame;
	
	public function get frame():Frame 
	{
		return _frame;
	}
	
	public function set frame(value:Frame):void
	{
		if (_frame == value)
			return;
		
		_frame = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override protected function measure():void
	{
		super.measure();
		
		measuredMinWidth = 0;
		measuredMinHeight = 0;
		if (camera)
		{
			measuredWidth = camera.width;
			measuredHeight = camera.height;
		}
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if (unscaledWidth <= 0 || unscaledHeight <= 0)
			return;
		
		var scale:Number = Math.min(unscaledWidth / (video.width / video.scaleX),
			unscaledHeight / (video.height / video.scaleY), 0.5);
		if (Math.abs(video.scaleX - scale) > 0.01)
		{
			video.scaleX = scale;
			video.scaleY = scale;
			
			// measured width should change
			invalidateSize();
			invalidateDisplayList();
		}
		
		video.x = (unscaledWidth - video.width) / 2;
		video.y = (unscaledHeight - video.height) / 2;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function activate():void
	{
		if (!camera)
		{
			camera = Camera.getCamera();
			camera.setMode(CAMERA_WIDTH, CAMERA_HEIGHT, camera.fps);
			camera.setQuality(0, 75);
		}
		
		if (!video)
		{
			video = new Video(camera.width, camera.height);
			addChild(video);
		}
		video.attachCamera(camera);
		invalidateSize();
		invalidateDisplayList();
	}
	
	private function deactivate():void
	{
		video.attachCamera(null);
	}
	
	private function shot():void
	{
		var bitmapData:BitmapData = new BitmapData(camera.width, camera.height, false, 0xFFFFCC00);
		bitmapData.draw(video);
		_frame.bitmapData = bitmapData;
		
		dispatchEvent(new FrameEvent(FrameEvent.FRAME_EDITED, true, true, _frame));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function addedToStageHandler(event:Event):void
	{
		activate();
	}
	
	private function removedFromStageHandler(event:Event):void
	{
		deactivate();
	}
	
	private function touchTapHandler(event:TouchEvent):void
	{
		shot();
	}
	
	private function clickHandler(event:MouseEvent):void
	{
		shot();
	}
	
}
}