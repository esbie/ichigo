package ichigo {
  import flash.display.DisplayObject;
  import flash.geom.Point;

  public class Environment {
    public static var obstacles:Vector.<DisplayObject> = new Vector.<DisplayObject>();

    public static function addObstacle(ob:DisplayObject):void {
      Environment.obstacles.push(ob);
    }

    public static function nearestObstacle(p:Point):Point {
      return new Point(Environment.obstacles[0].x, Environment.obstacles[0].y);
    }
  }
}

