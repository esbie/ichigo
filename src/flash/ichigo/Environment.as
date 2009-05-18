package ichigo {
  import flash.display.MovieClip;
  import flash.geom.Point;
  import ichigo.utils.Log;

  public class Environment extends MovieClip {
    public static var obstacles:Vector.<MovieClip> = new Vector.<MovieClip>();

    public static function addObstacle(ob:MovieClip, parent:MovieClip):void {
      parent.addChild(ob);
      Environment.obstacles.push(ob);
    }

    public static function nearestObstacle(p:Point):Point {
      return new Point(Environment.obstacles[0].x, Environment.obstacles[0].y);
    }
  }
}

