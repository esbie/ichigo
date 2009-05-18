package ichigo{
  import flash.display.Sprite;
  import flash.events.*;
  import flash.geom.Point;

  import ichigo.utils.Log;

  public class SoundPlayer extends Sprite {
    private var sb:SoundBox = new SoundBox("sounds/test.mp3");

    public function SoundPlayer(flock:Flock) {
      flock.addEventListener(Event.CHANGE, directionAverage);
    }

    private function directionAverage(event:Event):void {
      var avg:Point = event.target.getDirectionAvg();
      if (sb.isPlaying) {
        sb.setVol(avg.length * avg.length * avg.length * 0.1);
      } else if(avg.length >= 0.75 && !sb.isPlaying ) {
        //basing volume on an exponential function of direction average
        sb.play(avg.length*avg.length*avg.length*0.1,0);
      }
    }
  }
}
