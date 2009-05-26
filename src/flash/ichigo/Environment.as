package ichigo {
  import flash.display.DisplayObject;
  import flash.geom.Point;
  import ichigo.utils.Log;

  public class Environment {
    public static var obstacles:Vector.<DisplayObject> = new Vector.<DisplayObject>();

    public static function addObstacle(ob:DisplayObject):void {
      Environment.obstacles.push(ob);
    }

    public static function nearestObstacle(p:Point):Point {
      var min:Number = Number.MAX_VALUE
      var minPoint:Point = new Point(0,0);
      for (var i:int = 0; i < obstacles.length; i++) {
        var obPoint:Point = new Point(obstacles[i].x, obstacles[i].y);
        if (Point.distance(obPoint, p) < min) {
          min = Point.distance(obPoint, p);
          minPoint = obPoint;
        }
      }
      return minPoint;
    }
  }
}

