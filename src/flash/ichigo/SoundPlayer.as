package ichigo{
    import flash.display.Sprite;
    import flash.events.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;

    import ichigo.utils.Log;

    public class SoundPlayer extends Sprite {
        private var url:String = "sounds/test.mp3";
        private var song:SoundChannel;

        public function SoundPlayer(flock:Flock) {
          flock.addEventListener(Event.CHANGE, velocityHandler);
        }

        public function play(volume:Number):void {
            var request:URLRequest = new URLRequest(url);
            var soundFactory:Sound = new Sound();
            soundFactory.addEventListener(Event.COMPLETE, completeHandler);
            soundFactory.addEventListener(Event.ID3, id3Handler);
            soundFactory.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            soundFactory.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            soundFactory.load(request);
            song = soundFactory.play();
            song.soundTransform = new SoundTransform(volume, 0);
        }
        private function completeHandler(event:Event):void {

        }
        private function id3Handler(event:Event):void {

        }
        private function ioErrorHandler(event:Event):void {

        }
        private function progressHandler(event:ProgressEvent):void {

        }

        private function velocityHandler(event:Event):void {
          var velocity:Point = event.target.units[0].velocity;
          if (velocity.x >= 5) {
            play(Math.abs(velocity.x)*0.01);
          }
        }
    }
}
