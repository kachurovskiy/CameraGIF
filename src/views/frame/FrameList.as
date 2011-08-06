package views.frame
{
import components.List;

import flash.geom.Point;

import model.Frame;

import mx.core.IVisualElement;

import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
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
	
	override public function ensureIndexIsVisible(index:int):void
	{
		var spDelta:Point = dataGroup.layout.getScrollPositionDeltaToElement(index);
		if (!spDelta || spDelta.x == 0)
			return;
		
		var animation:Animate = new Animate(dataGroup);
		animation.motionPaths = new Vector.<MotionPath>();
		var motionPath:SimpleMotionPath = new SimpleMotionPath("horizontalScrollPosition");
		motionPath.valueBy = spDelta.x + (spDelta.x > 0 ? 10 : -10);
		animation.motionPaths.push(motionPath);
		callLater(animation.play);
	}
	
}
}