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
    private var seperationScale:Number = 1.5;
    private var cohesionScale:Number = 0.0;
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
    private var speed:Number = 2;
    private var personalSpace:Number = 10;

    public function Boid(x:Number, y:Number) {
      this.x = x;
      this.y = y;
    }

    private function calcAlignment(attractor:Point,
                                   flock:Vector.<Boid>,
                                   position:Point):Point {
      var temp:Point = attractor.subtract(position);
      return temp;
    }

    private function calcSeparation(attractor:Point,
                                    flock:Vector.<Boid>,
                                    position:Point):Point {
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
                                  position:Point):Point {
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
                                   position:Point):Point {
      var obstacle:Point = nearestObstacle(position)
      if (Point.distance(obstacle, position) < personalSpace) {
        var temp:Point = subtract(obstacle);
        return temp;
      }
      else return null;
    }

    private function calcRandom(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point):Point {
      random.offset(2*randomJitter*(Math.random()-0.5),
                    2*randomJitter*(Math.random()-0.5));
      return random;
    }

    private function calcMomentum(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point):Point {
      return velocity;
    }

    private function calcSwirly(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point):Point {
      swirlyTheta = (swirlyTheta + swirlyRadius) % (2 * Math.PI);
      var temp:Point = Point.polar(1, swirlyTheta);
      return temp;
    }

    public function updateBoid(attractor:Point, flock:Vector.<Boid>):void {
      var behaviors:Array = [
          { func: calcAlignment, scale: alignmentScale },
          { func: calcSeparation, scale: seperationScale },
          { func: calcCohesion, scale: cohesionScale },
          { func: calcAvoidance, scale: avoidanceScale },
          { func: calcRandom, scale: randomScale },
          { func: calcMomentum, scale: momentumScale * velocity.length },
          { func: calcSwirly, scale: swirlyScale }
        ];

      // Each behavior is scaled individually. scaleSum allows the final result
      // to receive a weighted average.
      // eg: scale 4, value 10 & scale 1, value 5 -> value 9
      var scaleSum:Number = 0;
      var influence:Point = new Point(0, 0);

      //calculate the influence of each behavior
      for each(var behavior:Object in behaviors) {
        if (!behavior.scale) {
          continue;
        }
        var result:Point = behavior.func(attractor, flock, this);
        if (result !== null) {
          scaleSum += behavior.scale;
          result.normalize(behavior.scale);
          influence.offset(result.x, result.y);
        }
      }

      // Perform a weighted average: totalValue / totalScale
      influence.normalize(influence.length / scaleSum);
      velocity = influence;

      //update position based on velocity
      offset(velocity.x * speed, velocity.y * speed);
    }

    //dummy function used by calcAvoidance
    //TODO: implement nearestObstacle
    private function nearestObstacle(position:Point):Point {
      return new Point(Math.round(position.x / 30) * 30,
                       Math.round(position.y / 30) * 30);
    }
  }
}
