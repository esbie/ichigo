package ichigo {
  import flash.display.DisplayObject;
  import flash.display.MovieClip;
  import ichigo.utils.Log;

  public class Collectable extends MovieClip {

    public var icon:MovieClip;

    public function Collectable(x:int, y:int) {
      this.x = x;
      this.y = y;
    }

    public function pickUp():void {}

  }
}

