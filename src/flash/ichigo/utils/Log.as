/**
 * Allows logging to both trace() and firebug console.
 */

package ichigo.utils {
  import flash.external.ExternalInterface;
  import flash.utils.getQualifiedClassName;

  public class Log {

    public static var level:Number = 0;
    public static var types:Object = {
      "debug": 0,
      "info": 1,
      "warn": 2,
      "error": 3
    }

    /**
     * Use getter/setter.
     * TODO: Verify performance is comparable.
     */
    public static function setLevel(newLevel:String):void {
      level = types[newLevel];
    }

    public static function out(...args:*):void {
      var type:String = args[0];
      // out expects "warn", "info", etc as first argument.
      if (types[type] == undefined) {
        // Set if needed.
        type = "debug";
        args.unshift(type);
      }
      // Only trace messages above a certain level.
      if (types[type] < level) {
        return;
      }
      if (ExternalInterface.available) {
        ExternalInterface.call("trace", objectify(args));
      } else {
        // Remove output type from args.
        args.shift();
        trace(type + ": " + args.join(', '));
      }
    }

    public static function debug(...args:*):void {
      args.unshift("debug");
      Log.out.apply(Log, args);
    }

    // Does it's best to convert all sorts of data types into something JS can
    // handle. Almost a JSON serialize function in that it's output is JSON-like
    // but still an object (and not a string).
    public static function objectify(args:*):Object {
      // Handles all primitive values which can be "false". (or undefined!)
      if (!args) {
        return args;
      }
      var result:Object;
      var type:String = getQualifiedClassName(args);
      switch (type) {
        case 'Object':
          // Check for cycles: objects which point to visited objects.
          if ("__visited" in args) {
            return "CYCLE DETECTED";
          }
          args.__visited = true;
          args.setPropertyIsEnumerable("__visited", false);

          result = {};
        break;

        case 'Array':
          result = [];
        break;

        case 'String':
        case 'Number':
        case 'int':
          // These primitives already work
          return args;
        break;

        case 'XML':
          return args.toXMLString();
        break;

        default:
          if ("toString" in args) {
            return args.toString();
          }
          trace("Unknown qualification: " + type);
          return "[object " + type + "]";
        break;
      }

      // Arrays and Objects come here: though they can be printed there may be
      //  entries which cannot be printed.
      for (var key:String in args) {
        result[key] = objectify(args[key]);
      }

      // Unpollute the input.
      if ("__visited" in args) {
        delete args.__visited;
      }
      return result;
    }

  }
}
