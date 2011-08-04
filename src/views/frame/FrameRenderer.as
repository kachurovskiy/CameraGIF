package views.frame
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;

import model.Frame;
import model.Icons;

import mx.core.UIComponent;
import mx.graphics.BitmapScaleMode;

import spark.components.Button;
import spark.components.Group;
import spark.primitives.BitmapImage;

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
		
		editButton = new Button();
		editButton.setStyle("icon", Icons.instance.edit);
		editButton.addEventListener(MouseEvent.CLICK, editButton_clickHandler);
		editButton.left = 20;
		editButton.verticalCenter = -50;
		addElement(editButton);
		
		removeButton = new Button();
		removeButton.setStyle("icon", Icons.instance.remove);
		removeButton.addEventListener(MouseEvent.CLICK, removeButton_clickHandler);
		removeButton.right = 20;
		removeButton.verticalCenter = -50;
		addElement(removeButton);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
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
	
}
}