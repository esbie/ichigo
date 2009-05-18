package ichigo {
  import flash.events.*;
  import flash.geom.Point;
  import ichigo.Main;

  import ichigo.utils.Log;

  public class Boid extends Point {
    /*
     * These values will scale their respective vector calculations.
     * Most often, the result of the vector calculation will normalize to 0 or
     * `Scale` length.
     */
    private var alignmentScale:Number = 1.3;
    private var seperationScale:Number = 0.70;
    private var cohesionScale:Number = 0.50;
    private var avoidanceScale:Number = 1.5;
    private var randomScale:Number = 0.80;
    private var momentumScale:Number = 1.0;
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

    public var velocity:Point = new Point(0, 0);
    private var speed:Number = 12;
    public var direction:Point = new Point(1, 0);
    // At steerResistance = 1 the boid cannot turn. At 0, boid turns instantly.
    private var steerResistance:Number = 0.95;
    private var personalSpace:Number = 15;

    public function Boid(x:Number, y:Number) {
      super(x, y);
    }

    private function calcAlignment(attractor:Point,
                                   flock:Vector.<Boid>,
                                   position:Point,
                                   influence:Point):Point {
      var temp:Point = attractor.subtract(position);
      //causes Boid to slow down when it's within
      //20px of the attractor, otherwise the vector
      //has length = 1
      temp.normalize(Math.min(temp.length/20, 1));
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
      temp.normalize(1);
      return temp.length? temp : null;
    }

    private function calcCohesion(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  influence:Point):Point {
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
        temp.offset(neighbor.x, neighbor.y);
      }
      temp.x = temp.x / flock.length - position.x;
      temp.y = temp.y / flock.length - position.y;
      //causes Boid to slow down when it's within
      //100px of the flock, otherwise the vector
      //has length = 1 (i.e. tries to catch up with flock)
      temp.normalize(Math.min(temp.length / 100, 1));
      return temp.length? temp : null;
    }

    private function calcAvoidance(attractor:Point,
                                   flock:Vector.<Boid>,
                                   position:Point,
                                   influence:Point):Point {
      var temp:Point = new Point();
      var theta:Number;
      var obstacle:Point = Environment.nearestObstacle(position);
      var hitVector:Point = position.subtract(obstacle);
      //100 = how far they can see obstacles ahead
      if(hitVector.length < 100){
        var radianDelta:Number = Math.atan2(hitVector.y, hitVector.x) -
                                 Math.atan2(velocity.y, velocity.x);
        //Move to the right
        if (radianDelta > 0 && radianDelta < (Math.PI / 6)) {
          theta = Math.atan2(velocity.y, velocity.x) + (Math.PI / 6 - radianDelta);
          hitVector = Point.polar(hitVector.length, theta);
        }
        //Move to the left
      else if (radianDelta < 0 && radianDelta > ( - Math.PI / 6)) {
        theta = Math.atan2(velocity.y, velocity.x) - (Math.PI / 6 - radianDelta);
        hitVector = Point.polar(hitVector.length, theta);
      }
      hitVector.normalize(1);
      return hitVector;
      } else {
        return new Point(0, 0);
      }
    }

    private function calcRandom(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point,
                                influence:Point):Point {
      random.offset(2*randomJitter*(Math.random()-0.5),
                    2*randomJitter*(Math.random()-0.5));
      return random;
    }

    //TODO: doesn't work as expected,
    //momentumScale seems to have no effect
    private function calcMomentum(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  influence:Point):Point {
      var temp:Point = velocity.clone();
      temp.normalize(1);
      return temp;
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

    public function applyInfluence(a:*, b:*, c:*, influence:Point):Point {
      return influence;
    }

    /**
     * TODO: It will probably look more realistic if there is also a minimum
     * distance a fish must travel before it can turn again. This function could
     * save the direction each time it picks "influence" over velocity and
     * return ignore "influence" until the boid has moved away.
     */
    //TODO: this function no longer picks just direction
    public function pickDirection(influence:Point):void {
      var radianDelta:Number = Math.abs(Math.atan2(direction.y, direction.x) -
                                        Math.atan2(influence.y, influence.x));
      influence = scale(influence, speed);
      influence = Point.interpolate(direction, influence, steerResistance);
      // If direction sufficiently diverges pick the new velocity
      if (radianDelta > (Math.PI / 6)) {
        direction = influence.clone();
      }
      else {
        direction.normalize(influence.length);
      }
    }

    public function calcVelocity(attractor:Point,
                                 flock:Vector.<Boid>,
                                 position:Point,
                                 influence:Point):Point {
      // Velocity is defined as speed * direction.
      pickDirection(influence);
      var velocity:Point = direction.clone();
      return velocity;
    }

    public function updateBoid(attractor:Point, flock:Vector.<Boid>):void {
      var start:Point = clone();
      var behaviors:Array = [
          { func: calcAlignment, scale: alignmentScale },
          { func: calcSeparation, scale: seperationScale },
          { func: calcCohesion, scale: cohesionScale },
          { func: calcAvoidance, scale: avoidanceScale },
          { func: calcRandom, scale: randomScale },
          { func: calcSwirly, scale: swirlyScale },
          { func: calcVelocity },
          { func: calcMomentum, scale: momentumScale },
          { func: applyInfluence }
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
          influence = scale(influence, 1/scaleSum);
          // And call non-scaling behavior function
          influence = behavior.func(attractor, flock, this, influence);
          // Which we apply to ourselves
          offset(influence.x, influence.y);
          // Then reset
          influence = new Point(0, 0);
          scaleSum = 0;
        } else if (behavior.scale != 0) {
          var result:Point = behavior.func(attractor, flock, this, influence);
          if (result !== null) {
            scaleSum += behavior.scale;
            result = scale(result, behavior.scale);
            influence.offset(result.x, result.y);
          }
        }
      }
      // Velocity = how much we have moved in this update.
      velocity = subtract(start);
    }

    /**
     * TODO: If we used new Boid() instead of new Point() we could call this
     * function as myBoid.scale(scale). We'd also want to move the behavior
     * functions out of this class.
     */
    private function scale(pt:Point, scale:Number):Point {
      if (scale != 0) {
        pt.normalize(pt.length * scale);
      }
      return pt;
    }
  }
}
