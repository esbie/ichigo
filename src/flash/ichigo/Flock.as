package ichigo {
  import flash.display.MovieClip;
  import flash.events.Event;

  import ichigo.utils.Log;

  public class Flock extends MovieClip {
    public static var units:Array = [];

    public function Flock(fleetSize:int) {
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      for (var i:int = 0; i < fleetSize; i++) {
        var fish:Boid = new Boid(i*3, 0);
        addChild(fish);
        units[i] = fish;
      }
    }

    public static function onEnterFrame(evt:Event):void {
      for each (var value:Boid in units) {
        value.updateBoid(Main.mousePos);
      }
    }
  }
}
