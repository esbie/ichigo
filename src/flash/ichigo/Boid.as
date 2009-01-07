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
    private var alignmentWeight:Number = 1.0;
    private var seperationWeight:Number = 1.1;
    private var cohesionWeight:Number = 0.0;
    private var avoidanceWeight:Number = 3.0;
    private var randomWeight:Number = 0.0;
    private var momentumWeight:Number = 3.0;
    private var swirlyWeight:Number = 0.0;

    private var random:Point = new Point(Math.random() - 0.5, Math.random() - 0.5);
    //randomJitter controls the granularity of randomness
    //0.0: straight arrow
    //0.5: slightly drunk
    //1.0: caffiene high
    private var randomJitter:Number = 0.5;

    //swirlyRadius controls the size of swirly circle and direction of rotation
    private var swirlyRadius:Number = (Math.round(Math.random()) * 2 - 1) * 0.3 * Math.random();
    private var swirlyTheta:Number = 0.0;

    private var velocity:Point = new Point(0, 0);
    private var speed:Number = 2;
    private var personalSpace:Number = 7;
    private var position:Point = new Point(0, 0);

    public function Boid(x:Number, y:Number) {
      Log.out("initializing Boid!");
      graphics.beginFill(0x11);
      graphics.drawCircle(0, 0, 3);
      graphics.endFill();
      this.x = x;
      this.y = y;
      position = new Point(x, y);
      random.normalize(1);
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

    private function calcAvoidance(attractor:Point, flock:Array, position:Point):Point {
      var obstacle:Point = nearestObstacle(position)
      if (Point.distance(obstacle, position) < personalSpace) {
        var temp:Point = position.subtract(obstacle);
        temp.normalize(1);
        return temp;
      }
      else return new Point(0, 0);
    }

    private function calcRandom(attractor:Point, flock:Array, position:Point):Point {
      random.offset(2*randomJitter*(Math.random()-0.5), 2*randomJitter*(Math.random()-0.5));
      random.normalize(1);
      return random;
    }

    private function calcMomentum(attractor:Point, flock:Array, position:Point):Point {
      return velocity;
    }

    private function calcSwirly(attractor:Point, flock:Array, position:Point):Point {
      swirlyTheta = (swirlyTheta + swirlyRadius) % (2 * Math.PI);
      var temp:Point = Point.polar(1, swirlyTheta);
      return temp;
    }

    public function updateBoid(attractor:Point, flock:Array):void {
      var behaviors:Array = [ { func: calcAlignment, weight: alignmentWeight },
          { func: calcSeparation, weight: seperationWeight },
          { func: calcCohesion, weight: cohesionWeight },
          { func: calcAvoidance, weight: avoidanceWeight },
          { func: calcRandom, weight: randomWeight },
          { func: calcMomentum, weight: momentumWeight },
          { func: calcSwirly, weight: swirlyWeight } ];

      var totalWeight:Number = 0.0;
      var influence:Point = new Point(0, 0);

      //calculate the influence of each behavior
      for each(var behavior:Object in behaviors) {
        var result:Point = behavior.func(attractor, flock, position);
        if (result.length > 0) {
          totalWeight += behavior.weight;
          influence.offset(result.x * behavior.weight, result.y * behavior.weight);
        }
      }

      var normalizer:Number = (totalWeight)? 1 / totalWeight : 1;
      influence.normalize(influence.length * normalizer);
      velocity = influence;

      //update position based on velocity
      position.offset(velocity.x * speed, velocity.y * speed);
      x = position.x
      y = position.y;
    }

    //dummy function used by calcAvoidance
    //TODO: implement nearestObstacle
    private function nearestObstacle(position:Point):Point {
      if (Math.min(position.x, position.y) == position.x) {
        return new Point(0,position.y);
      }
      else return new Point(position.x, 0);
    }
  }
}
