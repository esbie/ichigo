
package ichigo {
  import flash.display.*;
  import flash.events.*;

  import ichigo.utils.Log;

  [SWF(width=100, height=100, backgroundColor=0x0B025B, frameRate=40)]
  public class Main extends MovieClip {

    public function Main () {
      stage.align     = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

      var child:MovieClip = new MovieClip();
      child.graphics.beginFill(0xFF);
      child.graphics.drawRoundRect(0, 0, 50, 50, 10, 10);
      child.graphics.endFill();
      addChild(child);

	  var school:Flock = new Flock();
	  addChild(school);

      buttonMode = true;
      useHandCursor = true;
      addEventListener(MouseEvent.CLICK, onRelease);
    }

    public function onRelease (evt:MouseEvent):void {
      Log.out("Clicked!");
    }

    public static var mousePos:Object = {x: -1, y: -1};

    public function onMouseMove(evt:MouseEvent):void {
      mousePos.x = evt.stageX;
      mousePos.y = evt.stageY;
    }
  }
}
