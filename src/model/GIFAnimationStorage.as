package model
{
import flash.net.SharedObject;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.collections.ISort;
import mx.collections.Sort;
import mx.collections.SortField;

public class GIFAnimationStorage
{
	
	private static const SHARED_OBJECT_NAME:String = "GIFs";
	
	private static const ANIMATION_NAME_PREFIX:String = "Animation";
	
	private static var _instance:GIFAnimationStorage;
	
	public static function get instance():GIFAnimationStorage
	{
		if (!_instance)
			_instance = new GIFAnimationStorage();
		
		return _instance;
	}
	
	public function GIFAnimationStorage()
	{
		if (_instance)
			throw new Error("singleton error");
		
		_instance = this;
		
		load();
	}
	
	private var sharedObject:SharedObject;
	
	private var _items:ArrayCollection;
	
	[Bindable("__NoChangeEvent__")]
	public function get items():ArrayCollection
	{
		return _items;
	}
	
	private function load():void
	{
		_items = new ArrayCollection();
		var sort:Sort = new Sort();
		sort.fields = [ new SortField("dateTime") ];
		_items.sort = sort;
		_items.refresh();
		
		sharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
		var storedItems:IList = sharedObject.data.items as IList;
		if (storedItems)
			_items.addAll(storedItems);
		
		sharedObject.data.items = _items;
	}
	
	public function save():void
	{
		sharedObject.flush();
	}
	
	public function add(gifAnimation:GIFAnimation):void
	{
		_items.addItem(gifAnimation);
		
		save();
	}
	
	public function remove(gifAnimation:GIFAnimation):void
	{
		for each (var item:GIFAnimation in items)
		{
			if (item.uid == gifAnimation.uid)
				items.removeItemAt(items.getItemIndex(item));
		}
		
		save();
	}
	
	public function getNewGIFAnimationName():String
	{
		var nameMap:Object = {};
		for each (var item:GIFAnimation in items)
		{
			nameMap[item.name] = item;
		}
		
		for (var i:int = 1; ; i++)
		{
			var name:String = ANIMATION_NAME_PREFIX + " " + i;
			if (!nameMap[name])
				return name;
		}
		
		return null;
	}
	
	public function getNewGIFAnimation():GIFAnimation
	{
		var gifAnimation:GIFAnimation = new GIFAnimation(getNewGIFAnimationName());
		gifAnimation.frames.addItem(new Frame());
		return gifAnimation;
	}
	
}
}