package model
{
import actions.WriteToFileAction;

import by.blooddy.crypto.image.JPEGEncoder;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequest;
import flash.utils.ByteArray;

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
	
	[Transient]
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
	
	[Bindable("bitmapDataChange")]
	public function get empty():Boolean
	{
		return !uid;
	}
	
	//--------------------------------------
	//  bitmapBytes
	//--------------------------------------
	
	public function get bitmapBytes():ByteArray 
	{
		if (!_bitmapData)
			return null;
		
		var byteArray:ByteArray = new ByteArray();
		return JPEGEncoder.encode(_bitmapData, Settings.instance.jpegQuality);
	}
	
	//----------------------------------
	//  file
	//----------------------------------
	
	private var _file:File;
	
	[Bindable("__NoChangeEvent__")]
	public function get file():File
	{
		if (!_uid)
			return null;
		
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
		
		var action:WriteToFileAction = new WriteToFileAction();
		action.start(file, bitmapBytes);
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