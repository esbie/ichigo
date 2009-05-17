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
        private var url:String = "sounds/test.mp3";
        private var song:SoundChannel;
        private var soundFactory:Sound;
        private var isPlaying:Boolean = false;

        private var sb:SoundBox;

        public function SoundPlayer(flock:Flock) {
          flock.addEventListener(Event.CHANGE, directionAverage);
          sb = new SoundBox(url);
        }

        private function directionAverage(event:Event):void {
          var avg:Point = event.target.getDirectionAvg();
          if (avg.length >= 0.75 && !sb.isPlaying ) {
            sb.play(avg.length*avg.length*avg.length*0.1,0);
          }
        }
    }
}
