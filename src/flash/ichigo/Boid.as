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
    private var seperationWeight:Number = 1.10;
    private var alignmentWeight:Number = 1.0;
    private var cohesionWeight:Number = -0.10;
    private var avoidanceWeight:Number = 1.0;

    private var momentum:Number = 0.85;

    private var velocity:Point = new Point(0, 0);
    private var speed:Number = 2;
    private var personalSpace:Number = 7;
    public var position:Point = new Point(0, 0);

    /*
     * the four steering behaviors of Boids
     * TODO: avoidance not yet implemented--need obstacles
     */
    private var separation:Point = new Point(0, 0);
    private var alignment:Point = new Point(0, 0);
    private var cohesion:Point = new Point(0, 0);
    private var avoidance:Point = new Point(0, 0);

    public function Boid(x:Number, y:Number) {
      Log.out("initializing Boid!");
      graphics.beginFill(0x11);
      graphics.drawCircle(0, 0, 3);
      graphics.endFill();
      this.x = x;
      this.y = y;
      position = new Point(x, y);
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
      var behaviors:Array = [ { func: calcAlignment, weight: alignmentWeight },
          { func: calcSeparation, weight: seperationWeight },
          { func: calcCohesion, weight: cohesionWeight } ];

      var totalWeight:Number = 0.0;

      //calculate the influence of each behavior
      for each(var behavior:Object in behaviors) {
        behavior.result = behavior.func(attractor, Flock.units, position);
        if (behavior.result.length > 0) {
          totalWeight += behavior.weight;
        }
      }

      //calculate a normalizer in case some behaviors are not in effect
      //watch our for divide by zero!
      var normalizer:Number = (totalWeight==0)? 1 : 1 / totalWeight;
      var attraction:Point = new Point(0, 0);

      //add together weighted behaviors
      for each(behavior in behaviors) {
        attraction.x += behavior.result.x * behavior.weight * normalizer;
        attraction.y += behavior.result.y * behavior.weight * normalizer;
      }

      //add behaviors to the Boid's velocity
      velocity.x = velocity.x * momentum + attraction.x * (1 - momentum);
      velocity.y = velocity.y * momentum + attraction.y * (1 - momentum);

      //update position based on velocity
      position.offset(velocity.x * speed, velocity.y * speed);
      x = position.x
      y = position.y;
    }
  }
}
