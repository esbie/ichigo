package ichigo {
	import flash.events.Event;
  import flash.geom.Point;
  public class VelocityEvent extends Event {
    public static const UPDATE:String = "updated";
			public var velocity:Point;
			public function VelocityEvent(type:String, vel:Point, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles,cancelable);
			velocity = vel;
		}
	}
	
}
