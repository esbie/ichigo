package ichigo {
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.geom.Point;

  import ichigo.Flock;
  import ichigo.Main;
  import ichigo.utils.Log;

  public class Boid extends MovieClip {
    /*
     * percent that each steering behavior affects the velocity
     * for posterity's sake, these should add to 1.00
     */
    private var separationPercent:Number = 0.4;
    private var alignmentPercent:Number = 0.25;
    private var cohesionPercent:Number = 0.35;
    private var avoidancePercent:Number = 0.2;

    private var momentumPercent:Number = 0.85;

    private var velocity:Point = new Point(0, 0);
    private var speed:Number = 6;
    private var personalSpace:Number = 100;
    public var position:Point = new Point(0, 0);

    /*
     * the four steering behaviors of Boids
     * TODO: avoidance not yet implemented--need obstacles
     */
    private var separation:Point = new Point(0, 0);
    private var alignment:Point = new Point(0, 0);
    private var cohesion:Point = new Point(0, 0);
    private var avoidance:Point = new Point(0, 0);

    public function Boid() {
      Log.out("initializing Boid!");
      graphics.beginFill(0x11);
      graphics.drawCircle(0, 0, 5);
      graphics.endFill();
      x = 0;
      y = 0;
      Log.out("initialization complete");
    }

    private function calcAlignment(attractor:Point, flock:Array, position:Point):Point {
      var temp:Point = attractor.subtract(position);
      temp.normalize(1);
      return temp;
    }

    private function calcSeparation(attractor:Point, flock:Array, position:Point):Point {
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
          if (Point.distance(neighbor.position, position) < personalSpace) {
            var difference:Point = neighbor.position.subtract(position);
            difference.normalize(1 / difference.length);
            temp.offset(difference.x, difference.y);
          }
      }
      temp.normalize(-1);
      return temp;
    }

    private function calcCohesion(attractor:Point, flock:Array, position:Point):Point {
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
        temp.offset(neighbor.position.x, neighbor.position.y);
      }
      temp.x = temp.x / flock.length - position.x;
      temp.y = temp.y / flock.length - position.y;
      temp.normalize(1);
      return temp;
    }

    public function updateBoid(attractor:Point):void {
      var behaviors:Array = [ { func: calcAlignment, perc: alignmentPercent },
          { func: calcSeparation, perc: separationPercent },
          { func: calcCohesion, perc: cohesionPercent } ];

      var percentUsed:Number = 0.0;

      //calculate the influence of each behavior
      for each(var behavior:Object in behaviors) {
        behavior.result = behavior.func(attractor, Flock.units, position);
        if (behavior.result.length > 0) {
          percentUsed += behavior.perc;
        }
      }

      //calculate a normalizer in case some behaviors are not in effect
      //watch our for divide by zero!
      var normalizer:Number = (percentUsed==0)? 1 : 1 / percentUsed;
      var temp:Point = new Point(0, 0);

      //add together weighted behaviors
      for each(var behav:Object in behaviors) {
        temp.x += behav.result.x * behav.perc * normalizer;
        temp.y += behav.result.y * behav.perc * normalizer;
      }

      //add behaviors to the Boid's current velocity's momentum
      velocity.x = velocity.x * momentumPercent + temp.x * (1 - momentumPercent);
      velocity.y = velocity.y * momentumPercent + temp.y * (1 - momentumPercent);

      //update position based on velocity
      position.offset(velocity.x * speed, velocity.y * speed);
      x = position.x
      y = position.y;
    }
  }
}
