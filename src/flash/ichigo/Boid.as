package ichigo {
	import flash.display.MovieClip;
	import flash.events.Event;

	import ichigo.Main;
	import ichigo.utils.Log;
	import ichigo.Flock;

	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class Boid extends MovieClip {
		/*
		 * percent that each steering behavior affects the velocity
		 * for posterity's sake, these should add to 1.00
		 */
		private var sepPercent:Number = 0.35;
		private var aliPercent:Number = 0.35;
		private var cohPercent:Number = 0.3;
		private var avoPercent:Number = 0.2;

		private var vel:Object = {x:0, y:0};
		private var speed:Number = 2;
		private var normAlt:Number = 1;
		private var personalSpace:Number = 20;

		/*
		 * the four steering behaviors of Boids
		 * avoidance not yet implemented: need obstacles
		 */
		private var separation:Object = {x:0, y:0};
		private var alignment:Object = {x:0, y:0};
		private var cohesion:Object = {x:0, y:0};
		private var avoidance:Object = {x:0, y:0};

		public function Boid() {
			Log.out("initializing Boid!");
			this.graphics.beginFill(0x11);
			this.graphics.drawCircle(0, 0, 5);
			this.graphics.endFill();
			this.x = 0;
			this.y = 0;
			Log.out("initialization complete");
		}

		public function updateBoid(mousePos:Object):void {
			//calculate the unit vector for alignment
			alignment.x = mousePos.x - this.x;
			alignment.y = mousePos.y - this.y;
			var norm:Number = (alignment.x == 0 && alignment.y == 0 )?
				normAlt: Math.sqrt(alignment.x * alignment.x + alignment.y * alignment.y);
			alignment.x = alignment.x / norm;
			alignment.y = alignment.y / norm;

			//no flocking if only one fish
			if(Flock.units.length == 1){
				vel.x = alignment.x;
				vel.y = alignment.y;
			}
			else {
				//calculate the unit vector for separation
				for each (var neighbor:Boid in Flock.units) {
					if(Math.abs(neighbor.x - this.x)+Math.abs(neighbor.y-this.y) < personalSpace){
						separation.x += neighbor.x - this.x;
						separation.y += neighbor.y - this.y;
					}
					cohesion.x += neighbor.x;
					cohesion.y += neighbor.y;
				}
				norm = (separation.x == 0 && separation.y == 0 )?
					normAlt: Math.sqrt(separation.x * separation.x + separation.y * separation.y);
				separation.x = - separation.x / norm;
				separation.y = - separation.y / norm;

				//calculate the unit vector for cohesion
				cohesion.x = cohesion.x / Flock.units.length - this.x;
				cohesion.y = cohesion.y / Flock.units.length - this.y;
				norm = (cohesion.x == 0 && cohesion.y == 0 )?
					normAlt: Math.sqrt(cohesion.x * cohesion.x + cohesion.y * cohesion.y);
				cohesion.x = cohesion.x / norm;
				cohesion.y = cohesion.y / norm;

				//calculate velocity based on alignment, separation, and cohesion vectors
				vel.x = alignment.x * aliPercent + separation.x * sepPercent + cohesion.x * cohPercent;
				vel.y = alignment.y * aliPercent + separation.y * sepPercent + cohesion.y * cohPercent;
			}

			//update position based on velocity
			this.x += vel.x*speed;
			this.y += vel.y*speed;
		}
	}
}