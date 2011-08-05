package views.frame
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.media.Camera;
import flash.media.Video;

import model.Frame;
import model.Icons;
import model.Settings;

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
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function FrameEditor()
	{
		super();
		
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var camera:Camera;
	
	private var videoContainer:Sprite;
	private var video:Video;
	
	private var rotateButton:SimpleButton;
	private var rotateBitmap:Bitmap;
	
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
		
		video.x = - video.width / 2;
		video.y = - video.height / 2;
		
		var scale:Number = Math.min(unscaledWidth / videoContainer.width / videoContainer.scaleX,
			unscaledHeight / videoContainer.height / videoContainer.scaleY, 0.5);
		if (Math.abs(videoContainer.scaleX - scale) > 0.01)
		{
			videoContainer.scaleX = scale;
			videoContainer.scaleY = scale;
			videoContainer.x = unscaledWidth / 2;
			videoContainer.y = unscaledHeight / 2;
			
			// measured width should change
			invalidateSize();
			invalidateDisplayList();
		}
		
		rotateButton.x = videoContainer.x - rotateButton.width / 2;
		rotateButton.y = videoContainer.y - videoContainer.height / 2 - 10 - rotateButton.height;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function activate():void
	{
		if (!camera)
			camera = Camera.getCamera();
		
		camera.setMode(Settings.instance.cameraWidth, 
			Settings.instance.cameraHeight, camera.fps);
		camera.setQuality(0, Settings.instance.cameraQuality);
		
		if (!video)
		{
			videoContainer = new Sprite();
			video = new Video(camera.width, camera.height);
			videoContainer.addChild(video);
			videoContainer.addEventListener(TouchEvent.TOUCH_TAP, videoContainer_touchTapHandler);
			videoContainer.addEventListener(MouseEvent.CLICK, videoContainer_clickHandler);
			addChild(videoContainer);
		}
		video.attachCamera(camera);
		
		if (!rotateButton)
		{
			rotateButton = new SimpleButton();
			var rotateClass:Class = Icons.instance.rotate;
			rotateBitmap = new rotateClass();
			rotateButton.hitTestState = rotateBitmap;
			rotateButton.upState = rotateBitmap;
			rotateButton.overState = rotateBitmap;
			rotateButton.downState = rotateBitmap;
			rotateButton.addEventListener(MouseEvent.CLICK, rotateButton_clickHandler);
			addChild(rotateButton);
		}
		
		invalidateSize();
		invalidateDisplayList();
	}
	
	private function deactivate():void
	{
		video.attachCamera(null);
	}
	
	private function shot():void
	{
		var bitmapData:BitmapData = new BitmapData(videoContainer.width / videoContainer.scaleX, 
			videoContainer.height / videoContainer.scaleY, false);
		var matrix:Matrix = new Matrix();
		matrix.rotate(videoContainer.rotation / 180 * Math.PI);
		matrix.translate(bitmapData.width / 2, bitmapData.height / 2);
		bitmapData.draw(videoContainer, matrix);
		_frame.bitmapData = bitmapData;
		
		invalidateDisplayList();
		
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
	
	private function videoContainer_touchTapHandler(event:TouchEvent):void
	{
		shot();
	}
	
	private function videoContainer_clickHandler(event:MouseEvent):void
	{
		shot();
	}
	
	private function rotateButton_clickHandler(event:MouseEvent):void
	{
		videoContainer.rotation += 90;
		invalidateDisplayList();
	}
	
}
}