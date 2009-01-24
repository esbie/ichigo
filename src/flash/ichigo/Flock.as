package ichigo {
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.filters.DropShadowFilter;
  import flash.geom.Point;

  import ichigo.utils.Log;

  public class Flock extends MovieClip {
    private static var DROPSHADOW:Array =
        [new DropShadowFilter(3, 45, 0x000011, .75)];

    public var units:Vector.<Boid> = new Vector.<Boid>();
    public var icons:Vector.<MovieClip> = new Vector.<MovieClip>();
    public var attractor:Point = new Point();

    public function Flock(fleetSize:int, attractor:Point, spawnPoint:Point) {
      for (var i:int = 0; i < fleetSize; i++) {
        var fish:Boid = new Boid(i*3 + spawnPoint.x, spawnPoint.y);
        units[i] = fish;
        var icon:MovieClip = new MovieClip();
        icon.graphics.beginFill(0x669999);
        icon.graphics.drawCircle(0, 0, 8);
        icon.graphics.beginFill(0xFFFFFF);
        icon.graphics.drawCircle(6, -3, 2.5);
        icon.graphics.drawCircle(6, 3, 2.5);
        icon.graphics.beginFill(0x000000);
        icon.graphics.drawCircle(7, -3, 1.5);
        icon.graphics.drawCircle(7, 3, 1.5);
        icon.graphics.endFill();
        icon.filters = DROPSHADOW;
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
        // Direction is a unit vector pointing in the direction of movement.
        var direction:Point = units[i].direction;
        // Convert vector to radians then degrees.
        icons[i].rotation = Math.atan2(direction.y, direction.x)/Math.PI * 180;
      }
    }

    public function add(acquired:Flock):void {
      var length:int = acquired.units.length;
      for (var i:int = 0; i < length; i++) {
        units.push(acquired.units[i]);
        icons.push(acquired.icons[i]);
      }
    }

    public function remove(child:Flock):void {
      var length:int = child.units.length;
      for (var i:int = 0; i < length; i++) {
        var index:int = units.indexOf(child.units[i]);
        units.splice(index, 1);
        icons.splice(index, 1);
      }
    }

    public function includes(child:Flock):Boolean {
      var length:int = child.units.length;
      for (var i:int = 0; i < length; i++) {
        var index:int = units.indexOf(child.units[i]);
        if (index == -1)
          return false;
      }
      return true;
    }

  }
}
