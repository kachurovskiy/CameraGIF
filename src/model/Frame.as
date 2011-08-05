package model
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import mx.graphics.codec.JPEGEncoder;
import mx.utils.UIDUtil;

[RemoteClass]
/**
 * Describes one frame in the animation.
 */
public class Frame extends EventDispatcher
{
	
	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------
	
	public static function getFileURL(uid:String):String
	{
		return "app-storage://" + getFileAppStorageRelativePath(uid);
	}
	
	public static function getFileAppStorageRelativePath(uid:String):String
	{
		return "photos/" + uid + ".jpg";
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Frame()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var encoder:JPEGEncoder = new JPEGEncoder(75);
	
	[Bindable]
	public var generation:int = 0;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  uid
	//--------------------------------------
	
	private var _uid:String;
	
	public function get uid():String 
	{
		return _uid;
	}
	
	public function set uid(value:String):void
	{
		if (_uid == value)
			return;
		
		_uid = value;
		readFromFile();
	}
	
	//--------------------------------------
	//  bitmapData
	//--------------------------------------
	
	private var _bitmapData:BitmapData;
	
	[Transient]
	[Bindable("bitmapDataChange")]
	public function get bitmapData():BitmapData
	{
		return _bitmapData;
	}
	
	public function set bitmapData(value:BitmapData):void
	{
		if (_bitmapData == value)
			return;
		
		setBitmapDataWithoutWritingFile(value);
		generation++;
		writeToFile();
	}
	
	//----------------------------------
	//  empty
	//----------------------------------
	
	[Transient]
	[Bindable("bitmapDataChange")]
	public function get empty():Boolean
	{
		return !_bitmapData;
	}
	
	//--------------------------------------
	//  bitmapBytes
	//--------------------------------------
	
	[Transient]
	public function get bitmapBytes():ByteArray 
	{
		if (!_bitmapData)
			return null;
		
		var byteArray:ByteArray = new ByteArray();
		return encoder.encode(_bitmapData);
	}
	
	//----------------------------------
	//  file
	//----------------------------------
	
	private var _file:File;
	
	[Bindable("__NoChangeEvent__")]
	public function get file():File
	{
		var file:File = File.applicationStorageDirectory.resolvePath(
			getFileAppStorageRelativePath(_uid));
		return file;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function setUIDWithoutFileLoading(value:String):void
	{
		_uid = value;
	}
	
	private function setBitmapDataWithoutWritingFile(value:BitmapData):void
	{
		_bitmapData = value;
		dispatchEvent(new Event("bitmapDataChange"));
	}
	
	private function readFromFile():void
	{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.INIT, loader_initHandler);
		loader.load(new URLRequest(file.url));
	}
	
	private function writeToFile():void
	{
		if (!_uid)
			_uid = UIDUtil.createUID();
		
		var fileStream:FileStream = new FileStream();
		fileStream.openAsync(file, FileMode.WRITE);
		fileStream.writeBytes(bitmapBytes);
		fileStream.close();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function loader_initHandler(event:Event):void
	{
		setBitmapDataWithoutWritingFile(Bitmap(LoaderInfo(event.target).content).bitmapData);
	}
	
}
}