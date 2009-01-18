package ichigo {
  import flash.geom.Point;

  import ichigo.utils.Log;

  public class Boid extends Point {
    /*
     * These values will scale their respective vector calculations.
     * Most often, the result of the vector calculation will normalize to 0 or
     * `Scale` length.
     */
    private var alignmentScale:Number = 1.0;
    private var seperationScale:Number = 2.5;
    private var cohesionScale:Number = 0.5;
    private var avoidanceScale:Number = 0.0;
    private var randomScale:Number = 0.0;
    // Momentum uses velocity directly which can have length [0, 1].
    // This value will scale that length
    private var momentumScale:Number = 3.1;
    private var swirlyScale:Number = 0.0;

    private var random:Point = new Point(0, 0);
    //randomJitter controls the granularity of randomness
    //0.0: straight arrow
    //0.5: slightly drunk
    //1.0: caffiene high
    private var randomJitter:Number = 0.5;

    //swirlyRadius controls the size of swirly circle and direction of rotation
    //in the range of (-.3, .3).
    private var swirlyRadius:Number = Math.random()*.6 - .3;
    private var swirlyTheta:Number = 0.0;

    private var velocity:Point = new Point(0, 0);
    private var maxSpeed:Number = 2;
    private var personalSpace:Number = 10;

    public function Boid(x:Number, y:Number) {
      super(x, y);
    }

    private function calcAlignment(attractor:Point,
                                   flock:Vector.<Boid>,
                                   position:Point,
                                   influence:Point):Point {
      var temp:Point = attractor.subtract(position);
      return temp;
    }

    private function calcSeparation(attractor:Point,
                                    flock:Vector.<Boid>,
                                    position:Point,
                                    influence:Point):Point {
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
          if (Point.distance(neighbor, position) < personalSpace) {
            var difference:Point = neighbor.subtract(position);
            difference.normalize(1 / difference.length);
            temp.offset(-difference.x, -difference.y);
          }
      }
      return temp.length? temp : null;
    }

    private function calcCohesion(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  influence:Point):Point {
      if (!flock.length) {
        return null;
      }
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
        temp.offset(neighbor.x, neighbor.y);
      }
      temp.x = temp.x / flock.length - position.x;
      temp.y = temp.y / flock.length - position.y;
      return temp;
    }

    private function calcAvoidance(attractor:Point,
                                   flock:Vector.<Boid>,
                                   position:Point,
                                  influence:Point):Point {
      var obstacle:Point = nearestObstacle(position)
      if (Point.distance(obstacle, position) < personalSpace) {
        var temp:Point = subtract(obstacle);
        return temp;
      }
      else return null;
    }

    private function calcRandom(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point,
                                influence:Point):Point {
      random.offset(2*randomJitter*(Math.random()-0.5),
                    2*randomJitter*(Math.random()-0.5));
      return random;
    }

    private function calcMomentum(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  influence:Point):Point {
      return velocity;
    }

    private function calcSwirly(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point,
                                influence:Point):Point {
      swirlyTheta = (swirlyTheta + swirlyRadius) % (2 * Math.PI);
      var temp:Point = Point.polar(1, swirlyTheta);
      return temp;
    }

    public function reset(a:*, b:*, c:*, d:*):Point {
      return new Point(0, 0);
    }

    /**
     * TODO: It will probably look more realistic if there is also a minimum
     * distance a fish must travel before it can turn again. This function could
     * save the direction each time it picks "influence" over velocity and
     * return ignore "influence" until the boid has moved away.
     */
    public function lockDirection(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  influence:Point):Point {
      var radianDelta:Number = Math.abs(Math.atan2(velocity.y, velocity.x) -
                                        Math.atan2(influence.y, influence.x));
      return radianDelta < (Math.PI / 6) ? velocity.clone() : influence;
    }

    public function updateBoid(attractor:Point, flock:Vector.<Boid>):void {
      var behaviors:Array = [
          { func: calcAlignment, scale: alignmentScale },
          { func: calcSeparation, scale: seperationScale },
          { func: calcCohesion, scale: cohesionScale },
          { func: calcAvoidance, scale: avoidanceScale },
          { func: calcRandom, scale: randomScale },
          { func: calcSwirly, scale: swirlyScale },
          { func: lockDirection },
          { func: calcMomentum, scale: momentumScale * velocity.length }
        ];

      // Each behavior is scaled individually. scaleSum allows the final result
      // to receive a weighted average.
      // eg: scale 4, value 10 & scale 1, value 5 -> value 9
      var scaleSum:Number = 0;
      var influence:Point = new Point(0, 0);

      //calculate the influence of each behavior
      for each(var behavior:Object in behaviors) {
        if (behavior.scale == undefined) {
          // Scale and save whatever has been summed so far (weighted average)
          influence = scale(influence, scaleSum);
          // Then reset sum
          scaleSum = 0;
          // And call non-scaling behavior function
          influence = behavior.func(attractor, flock, this, influence);
        } else if (behavior.scale != 0) {
          var result:Point = behavior.func(attractor, flock, this, influence);
          if (result !== null) {
            scaleSum += behavior.scale;
            result.normalize(behavior.scale);
            influence.offset(result.x, result.y);
          }
        }
      }

      // Save new velocity using weighted average of influence and scale.
      //Log.out("Next step: ", velocity, scaleSum, this);
      velocity = scale(influence, scaleSum);
      var speed:Number = getSpeed(attractor, maxSpeed);
      offset(velocity.x * speed, velocity.y * speed);
    }

    //dummy function used by calcAvoidance
    //TODO: implement nearestObstacle
    private function nearestObstacle(position:Point):Point {
      return new Point(Math.round(position.x / 30) * 30,
                       Math.round(position.y / 30) * 30);
    }

    /**
     * TODO: If we used new Boid() instead of new Point() we could call this
     * function as myBoid.scale(scale). We'd also want to move the behavior
     * functions out of this class.
     */
    private function scale(pt:Point, scale:Number):Point {
      if (scale != 0) {
        pt.normalize(pt.length / scale);
      }
      return pt;
    }

    /**
     * TODO: Redesign how "speed" is determined. Velocity and maxSpeed should
     * be enough.
     */
    private function getSpeed(attractor:Point, maxSpeed:Number):Number {
      var distance:Number = Point.distance(this, attractor);
      return Math.min(maxSpeed, distance / (maxSpeed * maxSpeed));
    }
  }
}
