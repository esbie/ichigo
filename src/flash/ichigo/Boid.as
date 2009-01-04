package ichigo {
	import flash.display.MovieClip;
	import flash.events.Event;
  import flash.geom.Point;

	import ichigo.utils.Log;
	import ichigo.Flock;
	import ichigo.Main;

	public class Boid extends MovieClip {
		/*
		 * percent that each steering behavior affects the velocityocity
		 * for posterity's sake, these should add to 1.00
		 */
		private const separationPercent:Number = 0.4;
		private const alignmentPercent:Number = 0.25;
		private const cohesionPercent:Number = 0.35;
		private const avoidancePercent:Number = 0.2;

		private var velocity:Point = new Point(0, 0);
		private var speed:Number = 4;
		private var personalSpace:Number = 5;
    private var position:Point = new Point(0, 0);

		/*
		 * the four steering behaviors of Boids
		 * avoidance not yet implemented: need obstacles
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

		public function updateBoid(attractor:Point):void {
			//calculate the unit vector for alignment
      alignment = attractor.subtract(position);
      alignment.normalize(1);

			//no flocking if only one fish
			if (Flock.units.length == 1) {
        velocity.x = alignment.x * 0.2 + velocity.x * 0.8;
        velocity.y = alignment.y * 0.2 + velocity.y * 0.8;
			}
			else {
				//calculate the unit vector for separation
				for each (var neighbor:Boid in Flock.units) {
					if (Point.distance(neighbor.position, position) < personalSpace) {
            var difference:Point = neighbor.position.subtract(position);
            difference.normalize(1 / difference.length);
            separation.offset(difference.x, difference.y);
					}
          cohesion.offset(neighbor.position.x, neighbor.position.y);
				}
        separation.normalize(1);

				//calculate the unit vector for cohesion
				cohesion.x = cohesion.x / Flock.units.length - position.x;
				cohesion.y = cohesion.y / Flock.units.length - position.y;
        cohesion.normalize(1);

				//calculate velocity based on alignment, separation, and cohesion vectors
				velocity.x = velocity.x*0.95 + (alignment.x * alignmentPercent - separation.x * separationPercent + cohesion.x * cohesionPercent)*0.1;
				velocity.y = velocity.y*0.95 + (alignment.y * alignmentPercent - separation.y * separationPercent + cohesion.y * cohesionPercent)*0.1;
			}

			//update position based on velocity
      position.offset(velocity.x * speed, velocity.y * speed);
			x = position.x
			y = position.y;
		}
	}
}