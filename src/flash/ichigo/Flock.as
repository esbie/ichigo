package ichigo {
  import flash.display.MovieClip;
  import flash.events.Event;

  import ichigo.utils.Log;

  public class Flock extends MovieClip {
    public var units:Array = [];

    public function Flock(fleetSize:int) {
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
      for (var i:int = 0; i < fleetSize; i++) {
        var fish:Boid = new Boid(i*3, 10);
        addChild(fish);
        units[i] = fish;
      }
    }

    public function onEnterFrame(evt:Event):void {
      for each (var unit:Boid in units) {
        unit.updateBoid(Main.mousePos, units);
      }
    }
  }
}
