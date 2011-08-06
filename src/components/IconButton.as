package components
{
import spark.components.Button;

/**
 * Button without background in UP state and with icon only.
 */
public class IconButton extends Button
{
	public function IconButton()
	{
		super();
		
		setStyle("skinClass", IconButtonSkin);
	}
}
}