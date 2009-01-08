package ichigo {
  import flash.geom.Point;

  import ichigo.utils.Log;

  public class Boid extends Point {
    /*
     * These values will scale their respective vector calculations.
     */
    private var alignmentScale:Number = 1.0;
    private var seperationScale:Number = 1.5;
    private var cohesionScale:Number = 0.0;
    private var avoidanceScale:Number = 4.0;
    private var randomScale:Number = 0.0;
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
                                   position:Point,
                                   weight:Number):Point {
      var temp:Point = attractor.subtract(position);
      temp.normalize(weight);
      return temp;
    }

    private function calcSeparation(attractor:Point,
                                    flock:Vector.<Boid>,
                                    position:Point,
                                    weight:Number):Point {
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
          if (Point.distance(neighbor, position) < personalSpace) {
            var difference:Point = neighbor.subtract(position);
            difference.normalize(1 / difference.length);
            temp.offset(difference.x, difference.y);
          }
      }
      // Negative weights have a repulsive/separating affect.
      temp.normalize(-weight);
      return temp;
    }

    private function calcCohesion(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  weight:Number):Point {
      var temp:Point = new Point(0, 0);
      for each(var neighbor:Boid in flock) {
        temp.offset(neighbor.x, neighbor.y);
      }
      temp.x = temp.x / flock.length - position.x;
      temp.y = temp.y / flock.length - position.y;
      temp.normalize(weight);
      return temp;
    }

    private function calcAvoidance(attractor:Point,
                                   flock:Vector.<Boid>,
                                   position:Point,
                                   weight:Number):Point {
      var obstacle:Point = nearestObstacle(position)
      if (Point.distance(obstacle, position) < personalSpace) {
        var temp:Point = subtract(obstacle);
        temp.normalize(weight);
        return temp;
      }
      else return new Point(0, 0);
    }

    private function calcRandom(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point,
                                weight:Number):Point {
      random.offset(2*randomJitter*(Math.random()-0.5),
                    2*randomJitter*(Math.random()-0.5));
      random.normalize(weight);
      return random;
    }

    private function calcMomentum(attractor:Point,
                                  flock:Vector.<Boid>,
                                  position:Point,
                                  weight:Number):Point {
      var temp:Point = velocity.clone();
      temp.normalize(weight);
      return temp;
    }

    private function calcSwirly(attractor:Point,
                                flock:Vector.<Boid>,
                                position:Point,
                                weight:Number):Point {
      swirlyTheta = (swirlyTheta + swirlyRadius) % (2 * Math.PI);
      var temp:Point = Point.polar(1, swirlyTheta);
      temp.normalize(weight);
      return temp;
    }

    public function updateBoid(attractor:Point, flock:Vector.<Boid>):void {
      var behaviors:Array = [
          { func: calcAlignment, weight: alignmentScale },
          { func: calcSeparation, weight: seperationScale },
          { func: calcCohesion, weight: cohesionScale },
          { func: calcAvoidance, weight: avoidanceScale },
          { func: calcRandom, weight: randomScale },
          { func: calcMomentum, weight: momentumScale },
          { func: calcSwirly, weight: swirlyScale }
        ];

      var totalWeight:Number = 0;
      var influence:Point = new Point(0, 0);

      //calculate the influence of each behavior
      for each(var behavior:Object in behaviors) {
        var result:Point = behavior.func(attractor,
                                         flock,
                                         this,
                                         behavior.weight);
        if (result.length && behavior.weight) {
          totalWeight += behavior.weight;
          influence.offset(result.x, result.y);
        }
      }

      influence.normalize(influence.length / totalWeight);
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
