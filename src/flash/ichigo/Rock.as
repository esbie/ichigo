package ichigo {
  import flash.display.MovieClip;
  import ichigo.utils.Log;

  public class Rock extends MovieClip {

    public function Rock(x:int, y:int) {
      this.x = x;
      this.y = y;
      var icon:MovieClip = new MovieClip();
      icon.graphics.beginFill(0x000000);
      icon.graphics.drawCircle(0, 0, 20);
      icon.graphics.endFill();
      addChild(icon);
    }
  }
}

