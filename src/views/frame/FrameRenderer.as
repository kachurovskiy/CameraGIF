package views.frame
{
import components.IconButton;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;

import model.Frame;
import model.Icons;

import mx.core.UIComponent;
import mx.events.ResizeEvent;
import mx.graphics.BitmapScaleMode;
import mx.graphics.SolidColor;

import spark.components.Button;
import spark.components.Group;
import spark.primitives.BitmapImage;
import spark.primitives.Rect;

/**
 * Dispatched when "Remove" button is clicked.
 */
[Event(name="frameRemove", type="views.frame.FrameEvent")]

/**
 * Dispatched when "Edit" button is clicked.
 */
[Event(name="frameEdit", type="views.frame.FrameEvent")]

/**
 * Renders frame that is not being edited right now.
 */
public class FrameRenderer extends Group
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function FrameRenderer()
	{
		super();
		
		bitmapImage = new BitmapImage();
		bitmapImage.scaleMode = BitmapScaleMode.LETTERBOX;
		bitmapImage.smooth = true;
		bitmapImage.right = 10;
		bitmapImage.left = 10;
		bitmapImage.verticalCenter = 0;
		addElement(bitmapImage);
		
		bitmapBorder = new BitmapImage();
		bitmapBorder.right = 5;
		bitmapBorder.left = 5;
		bitmapBorder.verticalCenter = 2;
		bitmapBorder.source = Icons.instance.pictureFrame;
		bitmapBorder.smooth = true;
		addElement(bitmapBorder);
		
		editButton = new IconButton();
		editButton.setStyle("icon", Icons.instance.edit);
		editButton.addEventListener(MouseEvent.CLICK, editButton_clickHandler);
		editButton.left = 20;
		editButton.verticalCenter = -50;
		addElement(editButton);
		
		removeButton = new IconButton();
		removeButton.setStyle("icon", Icons.instance.remove);
		removeButton.addEventListener(MouseEvent.CLICK, removeButton_clickHandler);
		removeButton.right = 20;
		removeButton.verticalCenter = -50;
		addElement(removeButton);
		
		addEventListener(ResizeEvent.RESIZE, resizeHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var bitmapBorder:BitmapImage;
	
	private var bitmapImage:BitmapImage;
	
	private var removeButton:Button;
	
	private var editButton:Button;
	
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
		
		if (_frame)
			_frame.removeEventListener("bitmapDataChange", frame_bitmapDataChangeHandler);
		
		_frame = value;
		updateBitmapData();
		
		if (_frame)
			_frame.addEventListener("bitmapDataChange", frame_bitmapDataChangeHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function updateBitmapData():void
	{
		var bitmapData:BitmapData = _frame ? _frame.bitmapData : null;
		visible = bitmapData != null;
		bitmapImage.source = bitmapData;
		sizeBorder();
	}
	
	private function sizeBorder():void
	{
		var bitmapData:BitmapData = _frame ? _frame.bitmapData : null;
		if (!bitmapData || width <= 0)
			return;
		
		var scaledBitmapHeight:Number = (bitmapData.height / bitmapData.width) * (width - 20);
		bitmapBorder.height = scaledBitmapHeight + 12;
		editButton.verticalCenter = - scaledBitmapHeight / 2 - 24;
		removeButton.verticalCenter = - scaledBitmapHeight / 2 - 24;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function frame_bitmapDataChangeHandler(event:Event):void
	{
		updateBitmapData();
	}
	
	private function editButton_clickHandler(event:MouseEvent):void
	{
		dispatchEvent(new FrameEvent(FrameEvent.FRAME_EDIT, true, true, _frame));
	}
	
	private function removeButton_clickHandler(event:MouseEvent):void
	{
		dispatchEvent(new FrameEvent(FrameEvent.FRAME_REMOVE, true, true, _frame));
	}
	
	private function resizeHandler(event:ResizeEvent):void
	{
		sizeBorder();
	}
	
}
}