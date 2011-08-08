package actions
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.setTimeout;

import mx.core.FlexGlobals;

/**
 * Writes content to file without freezing the UI.
 */
public class WriteToFileAction
{
	
	private static const CHUNK_SIZE:uint = 10 * 1024;
	
	private var fileStream:FileStream;
	
	private var byteArray:ByteArray;
	
	private var timer:Timer;
	
	private var position:uint = 0;
	
	public function start(file:File, byteArray:ByteArray):void
	{
		this.byteArray = byteArray;
		
		fileStream = new FileStream();
		fileStream.openAsync(file, FileMode.WRITE);
		
		timer = new Timer(30);
		timer.addEventListener(TimerEvent.TIMER, timer_timerHandler);
		timer.start();
	}
	
	private function timer_timerHandler(event:TimerEvent):void
	{
		var lengthLeft:uint = byteArray.length - position;
		if (lengthLeft == 0)
		{
			fileStream.close();
			timer.removeEventListener(TimerEvent.TIMER, timer_timerHandler);
			timer.stop();
		}
		else
		{
			var length:uint = Math.min(lengthLeft, CHUNK_SIZE);
			fileStream.writeBytes(byteArray, position, length);
			position += length;
		}
	}
}
}