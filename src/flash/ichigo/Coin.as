package ichigo {
  import flash.display.MovieClip;
  import ichigo.utils.Log;

  public class Coin extends Collectable {

    public function Coin(x:int, y:int) {
      super(x,y);
      var icon:MovieClip = new MovieClip();
      icon.graphics.beginFill(0xEEEE00);
      icon.graphics.drawCircle(0, 0, 8);
      icon.graphics.endFill();
      addChild(icon);
    }

    public override function pickUp():void {
      Log.out("coin pickup");
      this.parent.removeChild(this);
    }

  }
}

