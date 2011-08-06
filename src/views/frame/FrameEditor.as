package views.frame
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.media.Camera;
import flash.media.Video;
import flash.text.TextField;
import flash.text.TextFormat;

import model.Frame;
import model.Icons;
import model.Settings;

import mx.core.UIComponent;

import spark.components.BusyIndicator;
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
	
	private static const ERROR_TEXT_FORMAT:TextFormat = new TextFormat("Arial", 14, 0xCC0000);
	
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
	
	private var busyIndicator:Bitmap;
	
	private var videoContainer:Sprite;
	private var videoRotation:Sprite;
	private var video:Video;
	
	private var border:DisplayObject;
	
	private var rotateButton:SimpleButton;
	private var rotateBitmap:Bitmap;
	
	private var shotButton:SimpleButton;
	private var shotBitmap:Bitmap;
	
	private var errorTextField:TextField;
	
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
	
	//--------------------------------------
	//  errorText
	//--------------------------------------
	
	private var _errorText:String;
	
	public function get errorText():String
	{
		return _errorText;
	}
	
	public function set errorText(value:String):void
	{
		if (_errorText == value)
			return;
		
		_errorText = value;
		setErrorText();
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
			measuredWidth = videoContainer.width;
			measuredHeight = videoContainer.height;
		}
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if (unscaledWidth <= 0 || unscaledHeight <= 0)
			return;
		
		if (camera)
		{
			busyIndicator.x = unscaledWidth / 2 - busyIndicator.width / 2;
			busyIndicator.y = unscaledHeight / 2 - busyIndicator.height / 2;
			
			var suggestedScaleX:Number = unscaledWidth / (videoContainer.width / videoContainer.scaleX);
			var suggestedScaleY:Number = unscaledHeight / (videoContainer.height / videoContainer.scaleY);
			var scale:Number = Math.min(suggestedScaleX, suggestedScaleY);
			if (Math.abs(videoContainer.scaleX - scale) > 0.01)
			{
				videoContainer.scaleX = scale;
				videoContainer.scaleY = scale;
				
				// measured width should change
				invalidateSize();
				invalidateDisplayList();
			}
			
			videoContainer.x = unscaledWidth / 2;
			videoContainer.y = unscaledHeight / 2;
			
			border.x = videoContainer.x - videoContainer.width / 2 - 5;
			border.y = videoContainer.y - videoContainer.height / 2 - 4;
			border.width = videoContainer.width + 10;
			border.height = videoContainer.height + 12;
			
			rotateButton.x = videoContainer.x - rotateButton.width / 2;
			rotateButton.y = videoContainer.y - videoContainer.height / 2 - 10 - rotateButton.height;
			
			shotButton.x = videoContainer.x - shotButton.width / 2;
			shotButton.y = videoContainer.y + videoContainer.height / 2 + 10;
		}
		
		if (errorTextField)
		{
			errorTextField.x = 20;
			errorTextField.wordWrap = true;
			errorTextField.y = unscaledHeight / 2 - 10;
			errorTextField.width = unscaledWidth - 40;
			errorTextField.height = unscaledHeight / 3;
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function activate():void
	{
		invalidateSize();
		invalidateDisplayList();
		
		if (!errorTextField)
		{
			errorTextField = new TextField();
			errorTextField.multiline = true;
			errorTextField.mouseEnabled = false;
			setErrorText();
			addChild(errorTextField);
		}
		
		try
		{
			if (!camera)
				camera = Camera.getCamera();
		}
		catch (error:Error)
		{
			errorText = "Camera error: " + error.message;
		}
		if (!camera)
		{
			if (!errorText)
				errorText = "Camera is not available";
			return;
		}
		
		updateCamera();
		
		if (!busyIndicator)
		{
			var busyClass:Class = Icons.instance.picture;
			busyIndicator = new busyClass();
			addChild(busyIndicator);
		}
		
		if (!video)
		{
			videoContainer = new Sprite();
			videoRotation = new Sprite();
			video = new Video(camera.width, camera.height);
			videoRotation.addChild(video);
			videoContainer.addChild(videoRotation);
			videoContainer.addEventListener(TouchEvent.TOUCH_TAP, videoContainer_touchTapHandler);
			videoContainer.addEventListener(MouseEvent.CLICK, videoContainer_clickHandler);
			addChild(videoContainer);
		}
		updateVideoPosition();
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
		
		if (!shotButton)
		{
			shotButton = new SimpleButton();
			var shotClass:Class = Icons.instance.camera;
			shotBitmap = new shotClass();
			shotButton.hitTestState = shotBitmap;
			shotButton.upState = shotBitmap;
			shotButton.overState = shotBitmap;
			shotButton.downState = shotBitmap;
			shotButton.addEventListener(MouseEvent.CLICK, shotButton_clickHandler);
			addChild(shotButton);
		}
		
		if (!border)
		{
			var borderClass:Class = Icons.instance.pictureFrame;
			border = new borderClass();
			InteractiveObject(border).mouseEnabled = false;
			addChild(border);
		}
	}
	
	private function setErrorText():void
	{
		if (!errorTextField)
			return;
		
		errorTextField.text = _errorText ? _errorText : "";
		errorTextField.setTextFormat(ERROR_TEXT_FORMAT);
	}
	
	private function updateVideoPosition():void
	{
		video.width = camera.width;
		video.height = camera.height;
		video.x = - video.width / 2;
		video.y = - video.height / 2;
	}
	
	private function updateCamera():void
	{
		var swapWidthHeight:Boolean = videoRotation ? videoRotation.rotation % 180 != 0 : false;
		var cameraWidth:Number = Settings.instance.cameraWidth;
		var cameraHeight:Number = Settings.instance.cameraHeight;
		if (swapWidthHeight)
		{
			cameraWidth = Settings.instance.cameraHeight;
			cameraHeight = Settings.instance.cameraWidth;
		}
		camera.setMode(cameraWidth, cameraHeight, camera.fps);
		camera.setQuality(0, Settings.instance.cameraQuality);
	}
	
	private function deactivate():void
	{
		if (video)
			video.attachCamera(null);
	}
	
	private function shot():void
	{
		var bitmapData:BitmapData = new BitmapData(videoContainer.width / videoContainer.scaleX, 
			videoContainer.height / videoContainer.scaleY, false);
		var matrix:Matrix = new Matrix();
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
		videoRotation.rotation += 90;
		updateCamera();
		if (video)
			updateVideoPosition();
		callLater(invalidateDisplayList);
	}
	
	private function shotButton_clickHandler(event:MouseEvent):void
	{
		shot();
	}
	
}
}