package ichigo{
  import flash.display.Sprite;
  import flash.events.*;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.SoundTransform;
  import flash.net.URLRequest;
  import flash.geom.Point;

  import ichigo.utils.Log;

  public class SoundPlayer extends Sprite {
    private const url:String = "sounds/test.mp3";
    private var sb:SoundBox = new SoundBox(url);

    public function SoundPlayer(flock:Flock) {
      flock.addEventListener(Event.CHANGE, directionAverage);
    }

    private function directionAverage(event:Event):void {
      var avg:Point = event.target.getDirectionAvg();
      if (avg.length >= 0.75 && !sb.isPlaying ) {
        //basing volume on an exponential function of direction average
        sb.play(avg.length*avg.length*avg.length*0.1,0);
      }
    }
  }
}
