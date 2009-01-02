package ichigo {
	import flash.display.MovieClip;
	import flash.events.Event;

	import ichigo.utils.Log;

	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class Flock extends MovieClip {
		public static var units:Array = [];

		public function Flock() {
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			var fish:Boid = new Boid();
			addChild(fish);
			units[0] = fish;

			var fish2:Boid = new Boid();
			addChild(fish2);
			units[1] = fish2;

			var fish3:Boid = new Boid();
			addChild(fish3);
			units[2] = fish3;
		}

		public static function onEnterFrame(evt:Event):void {
			if(Main.mousePos.x > 0 || Main.mousePos.y > 0){
				for each (var value:Boid in units) {
					value.updateBoid(Main.mousePos);
				}
			}
		}
	}
}