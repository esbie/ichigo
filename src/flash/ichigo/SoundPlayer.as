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

        public function SoundPlayer(flock:Flock) {
          flock.addEventListener(Event.CHANGE, velocityHandler);
            var request:URLRequest = new URLRequest(url);
            soundFactory = new Sound();
            soundFactory.load(request);
        }

        public function play(volume:Number):void {
            song = soundFactory.play();
            song.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
            song.soundTransform = new SoundTransform(volume, 0);
            isPlaying = true;
        }
        private function soundCompleteHandler(event:Event):void {
          isPlaying = false;
        }

        private function velocityHandler(event:Event):void {
          var avg:Point = event.target.getDirectionAvg();
          if (avg.length >= 0.75 && !isPlaying ) {
            play(avg.length*avg.length*avg.length*0.05);
          }
        }
    }
}
