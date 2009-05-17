package ichigo{
  import flash.display.Sprite;
  import flash.events.*;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.SoundTransform;
  import flash.net.URLRequest;

  import ichigo.utils.Log;

  public class SoundBox extends Sprite {
    private var file:String;
    private var soundChannel:SoundChannel;
    private var sound:Sound;
    public var isPlaying:Boolean = false;

    public function SoundBox(file:String) {
      this.file = file;
      var request:URLRequest = new URLRequest(file);
      sound = new Sound();
      sound.load(request);
    }

    public function play(volume:Number, panning:Number):void {
      if (soundChannel && soundChannel.hasEventListener(Event.SOUND_COMPLETE)) {
        soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
      }
      soundChannel = sound.play();
      soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
      soundChannel.soundTransform = new SoundTransform(volume, panning);
      isPlaying = true;
    }

    private function soundCompleteHandler(event:Event):void {
      isPlaying = false;
    }

    public function setVol(volume:Number):void {
      var transform:SoundTransform = soundChannel.soundTransform;
      transform.volume = volume;
      soundChannel.soundTransform = transform;
    }

    public function setPan(panning:Number):void {
      var transform:SoundTransform = soundChannel.soundTransform;
      transform.pan = panning;
      soundChannel.soundTransform = transform;
    }
  }
}
