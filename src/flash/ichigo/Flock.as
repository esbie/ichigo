package ichigo {
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.geom.Point;

  import ichigo.utils.Log;

  public class Flock extends MovieClip {
    public var units:Vector.<Boid> = new Vector.<Boid>();
    public var icons:Vector.<MovieClip> = new Vector.<MovieClip>();
    public var attractor:Point = new Point();

    public function Flock(fleetSize:int, attractor:Point, spawnPoint:Point) {
      for (var i:int = 0; i < fleetSize; i++) {
        var fish:Boid = new Boid(i*3 + spawnPoint.x, spawnPoint.y);
        units[i] = fish;
        var icon:MovieClip = new MovieClip();
        icon.graphics.beginFill(0xFFFFFF);
        icon.graphics.drawCircle(0, 0, 3);
        icon.graphics.endFill();
        icons[i] = icon;
        addChild(icon);
      }

      this.attractor = attractor;
    }

    public function updateFlock():void {
      var i:int = units.length;
      while (i--) {
        units[i].updateBoid(attractor, units);
        icons[i].x = units[i].x;
        icons[i].y = units[i].y;
      }
    }

    public function add(acquired:Flock):void {
      var length:int = acquired.units.length;
      for (var i:int = 0; i < length; i++) {
        units.push(acquired.units[i]);
        icons.push(acquired.icons[i]);
      }
    }
  }
}
