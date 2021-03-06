package views.frame
{
import flash.events.Event;

import model.Frame;
import model.Settings;

import mx.core.IDataRenderer;
import mx.core.UIComponent;

import spark.components.supportClasses.ItemRenderer;

/**
 * Renderer that shows and allows to edit frame.
 */
public class FrameItemRenderer extends ItemRenderer
{
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function FrameItemRenderer()
	{
		super();
		
		autoDrawBackground = false;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var frameRenderer:FrameRenderer;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  data
	//--------------------------------------
	
	override public function set data(value:Object):void
	{
		super.data = value;

		frame = value as Frame;
	}
	
	//--------------------------------------
	//  frame
	//--------------------------------------
	
	private var _frame:Frame;
	
	private function get frame():Frame 
	{
		return _frame;
	}
	
	private function set frame(value:Frame):void
	{
		if (_frame == value)
			return;
		
		_frame = value;
		
		if (_frameEditor)
			_frameEditor.frame = _frame;
		frameRenderer.frame = frame;
	}
	
	//--------------------------------------
	//  frameEditor
	//--------------------------------------
	
	private var _frameEditor:FrameEditor;
	
	/**
	 * Is set by parent list when editing is requested.
	 */
	public function get frameEditor():FrameEditor 
	{
		return _frameEditor;
	}
	
	public function set frameEditor(value:FrameEditor):void
	{
		if (_frameEditor == value)
			return;
		
		if (_frameEditor)
		{
			if (_frameEditor.parent == this)
				removeElement(_frameEditor);
			_frameEditor.frame = null;
		}
		
		_frameEditor = value;
		frameRenderer.visible = _frameEditor == null;
		invalidateDisplayList();
		
		if (_frameEditor)
		{
			_frameEditor.frame = _frame;
			_frameEditor.width = Settings.instance.frameWidth;
			_frameEditor.top = 0;
			_frameEditor.bottom = 0;
			addElement(_frameEditor);
		}
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		frameRenderer = new FrameRenderer();
		frameRenderer.verticalCenter = 0;
		frameRenderer.width = Settings.instance.frameWidth;
		addElement(frameRenderer);
	}
	
}
}