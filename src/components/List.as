package components
{
import mx.core.IDataRenderer;
import mx.core.IVisualElement;

import spark.components.IItemRenderer;
import spark.components.List;

public class List extends spark.components.List
{
	
	public function List()
	{
		super();
	}
	
	public function updateRenderers():void
	{
		var n:int = dataGroup ? dataGroup.numElements : 0;
		for (var i:int = 0; i < n; i++)
		{
			var renderer:IDataRenderer = dataGroup.getElementAt(i) as IDataRenderer;
			if (!renderer)
				continue;
			
			updateRenderer(IVisualElement(renderer), i, renderer.data);
		}
	}
	
}
}