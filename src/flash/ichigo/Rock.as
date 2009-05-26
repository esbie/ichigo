package ichigo {
  import flash.display.Sprite;

  public class Rock extends Sprite {

    public function Rock(x:int, y:int) {
      this.x = x;
      this.y = y;
      graphics.beginFill(0x000000);
      graphics.drawCircle(0, 0, 20);
      graphics.endFill();
    }
  }
}

