
package ichigo {
  import flash.display.*;
  import flash.events.*;
  import flash.geom.Point;
  import flash.utils.setInterval;

  import ichigo.utils.Log;

  [SWF(width=100, height=100, backgroundColor=0x0B025B, frameRate=40)]
  public class Main extends MovieClip {
    public static var mousePos:Point = new Point(0, 0);
    public static var flocks:Vector.<Flock> = new Vector.<Flock>();

    //variable for testing Flcok add and remove
    public var lastAdded:Flock;

    public function Main () {
      stage.align     = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

      var child:MovieClip = new MovieClip();
      child.graphics.beginFill(0xFF);
      child.graphics.drawRoundRect(0, 0, 50, 50, 10, 10);
      child.graphics.endFill();
      addChild(child);

      var school:Flock = new Flock(12, mousePos, new Point(300,300));
      addChild(school);
      var theirSchool:Flock = new Flock(3, new Point(100, 100),
                                        new Point(30, 30));
      addChild(theirSchool);
      var aSchool:Flock = new Flock(3, new Point(300, 100), new Point(30, 30));
      addChild(aSchool);

      flocks.push(school, theirSchool, aSchool);

      buttonMode = true;
      useHandCursor = true;
      addEventListener(MouseEvent.CLICK, onRelease);

      setInterval(update, 20);
    }

    public function update():void {
      for (var i:int = 0; i < flocks.length; i++ ) {
        flocks[i].updateFlock();
        // assumes (for the moment) that flocks[0] is the only flock
        // we want to test for collisions
        if (i != 0) {
          if (flocks[0].hitTestObject(flocks[i])) {
            flocks[0].add(flocks[i]);
            lastAdded = flocks[i];
            flocks.splice(i, 1);
          }
        }
      }
      if (flocks[0].hitTestPoint(250, 250, false) && flocks[0].includes(lastAdded)) {
        flocks[0].remove(lastAdded);
        flocks.push(lastAdded);
      }
    }

    public function onRelease (evt:MouseEvent):void {
      Log.out("Clicked!");
    }

    public function onMouseMove(evt:MouseEvent):void {
      mousePos.x = evt.stageX;
      mousePos.y = evt.stageY;
    }
  }
}
