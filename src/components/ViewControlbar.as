package components
{
import spark.components.SkinnableContainer;

public class ViewControlbar extends SkinnableContainer
{
	public function ViewControlbar()
	{
		super();
		
		setStyle("skinClass", ViewControlbarSkin);
	}
}
}