/**
 * Allows logging to both trace() and firebug console
 */

package ichigo.utils {
  import flash.external.ExternalInterface;

	public class Log {

  	public static var level:Number = 0;
  	public static var types:Object = {
  	  "debug": 0,
  	  "info": 1,
  	  "warn": 2,
  	  "error": 3
  	}
  	
  	public static function setLevel(newLevel:String):void {
  	  level = types[newLevel];
  	}
  	
  	public static function out(...args:*):void {
  	  //ExternalInterface.call("console.log", args);
  	  //ExternalInterface.call("foo", "asdf");
  	  var type:String = args[0];
  	  // trace expects "warn", "info", etc as first argument
  	  if (types[type] == undefined) {
  	    // Set if needed
  	    type = "debug";
  		  args.unshift(type);
  	  }
  	  // Only trace messages above a certain level
  	  if (types[type] < level) {
  	    return;
  	  }
  		if (ExternalInterface.available) {
  			ExternalInterface.call("trace", args);
  		} else {
  		  // Remove type from args
  		  args.shift();
    		trace(type + ": " + args.join(', '));
  		}
		}
		
		public static function debug(...args:*):void {
		  args.unshift("debug");
		  Log.out.apply(Log, args);
		}

	}
}
