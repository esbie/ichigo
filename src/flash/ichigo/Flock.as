package ichigo {
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.utils.setInterval;

  import ichigo.utils.Log;

  public class Flock extends MovieClip {
    public var units:Vector.<Boid> = new Vector.<Boid>();
    public var icons:Vector.<MovieClip> = new Vector.<MovieClip>();

    public function Flock(fleetSize:int) {
      for (var i:int = 0; i < fleetSize; i++) {
        var fish:Boid = new Boid(i*3 + 10, 10);
        units[i] = fish;
        var icon:MovieClip = new MovieClip();
        icon.graphics.beginFill(0xFFFFFF);
        icon.graphics.drawCircle(0, 0, 3);
        icon.graphics.endFill();
        icons[i] = icon;
        addChild(icon);
      }

      // Update the flock every 20 milliseconds
      setInterval(updateFlock, 20, null);
    }

    public function updateFlock(ignore:*):void {
      var i:int = units.length;
      while (i--) {
        units[i].updateBoid(Main.mousePos, units);
        icons[i].x = units[i].x;
        icons[i].y = units[i].y;
      }
    }
  }
}
