package views.frame
{
import components.List;

import model.Frame;

import mx.core.IVisualElement;

import spark.layouts.HorizontalLayout;

public class FrameList extends List
{
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var frameEditor:FrameEditor = new FrameEditor();
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  editingFrame
	//--------------------------------------
	
	private var _editingFrame:Frame;
	
	public function get editingFrame():Frame 
	{
		return _editingFrame;
	}
	
	public function set editingFrame(value:Frame):void
	{
		if (_editingFrame == value)
			return;
		
		_editingFrame = value;
		if (_editingFrame)
			ensureIndexIsVisible(dataProvider.getItemIndex(_editingFrame));
		updateRenderers();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
	{
		super.updateRenderer(renderer, itemIndex, data);
		
		FrameItemRenderer(renderer).frameEditor = (data && data == _editingFrame) ? frameEditor : null;
	}
	
}
}