import toxi.geom.*;
import toxi.processing.*;

class Diamond extends Mover {

	private static final int LENGTH = 150;
	private static final int WIDTH = 90;

	private static final float SEPARATION_FORCE_WEIGHT = 1.5;
	private static final float ALIGNING_FORCE_WEIGHT = 1.0;
	private static final float COHESION_FORCE_WEIGHT = 1.0;
	private static final float Z_BOUNDARY_REPULSION_WEIGHT = 0.003;

	private static final float DESIRED_SEPARATION = 90.0;
	private static final float NEIGHBOR_DISTANCE = 150;

	private static final float Z_SCALE_WEIGHT = 0.3;
	private static final float Z_SCALE_OFFSET = 4.0;
	private static final float MAX_Z = 1;

	private Polygon2D shape;
	private color fillColor;

	// Size of the world.
	private int worldWidth;
	private int worldHeight;

	// Properties shown while debugging
	private Vec3D separationForce;   // Force wanting to separate from all other diamonds
	private Vec3D aligningForce;   // Force wanting to align with the same direction of all nearby diamonds
	private Vec3D cohesionForce;   // Force wanting to stay between all nearby diamonds
	private Vec3D zRepulsionForce;   // Force pushing away from Z boundaries


	Diamond(Vec3D pos, int ww, int wh, color c) {
		position = pos;
		worldWidth = ww;
		worldHeight = wh;
		fillColor = c;
		maxSpeed = 9;
		velocity = new Vec3D(random(-maxSpeed, maxSpeed), random(-maxSpeed, maxSpeed), random(-0.1*maxSpeed, 0.1*maxSpeed));
		acceleration = new Vec3D();
		maxForce = 0.05;
	}


	public void run(ArrayList<Diamond> diamonds) {
		flock(diamonds);
		update();
		wrapAroundBorders();
	}

	/**
   * Draw our diamond at its current position.
   *
   * @param gfx  A ToxiclibsSupport object to use for drawing.
   * @param debug  Whether on not to draw debugging visuals.
   */
	public void draw(ToxiclibsSupport gfx, boolean debug) {
		// Draw a diamond rotated in the direction of velocity.
		float theta = velocity.headingXY() + PI*0.5;
		float zScale;

		// Determine the amount to scale the drawing based on the
		// z dimension of the position.
		zScale = (position.z()+Z_SCALE_OFFSET) * Z_SCALE_WEIGHT;

		noStroke();
		fill(fillColor);

		pushMatrix();
		translate(position.x, position.y);
		rotate(theta);

		// Define the shape.
		shape = new Polygon2D();
		shape.add(new Vec2D(0, +0.5*LENGTH*zScale));  // Top
		shape.add(new Vec2D(+0.5*WIDTH*zScale, 0));  // Right
		shape.add(new Vec2D(0, -0.5*LENGTH*zScale));  // Bottom
		shape.add(new Vec2D(-0.5*WIDTH*zScale, 0));  // Left

		gfx.polygon2D(shape);
		popMatrix();

		if (debug) drawDebugVisuals(gfx);
	}

	/**
   * Get the diamond's position.
   */
	public Vec3D getPosition() {
		return position;
	}

	/**
   * Get the diamond's velocity.
   */
	public Vec3D getVelocity() {
		return velocity;
	}


	/**
   * Figure out a new acceleration based on three rules.
   */
	private void flock(ArrayList<Diamond> diamonds) {
		separationForce = determineSeparationForce(diamonds);
		aligningForce = determineAligningForce(diamonds);
		cohesionForce = determineCohesionForce(diamonds);
		zRepulsionForce = determineZRepulsionForce();

		// Weight these forces.
		separationForce.scaleSelf(SEPARATION_FORCE_WEIGHT);
		aligningForce.scaleSelf(ALIGNING_FORCE_WEIGHT);
		cohesionForce.scaleSelf(COHESION_FORCE_WEIGHT);
		zRepulsionForce.scaleSelf(Z_BOUNDARY_REPULSION_WEIGHT);

		// Add the force vectors to our acceleration
		applyForce(separationForce);
		applyForce(aligningForce);
		applyForce(cohesionForce);
		applyForce(zRepulsionForce);
	}

	/**
   * Check for nearby diamonds and separate from them.
   */
	private Vec3D determineSeparationForce(ArrayList<Diamond> diamonds) {
		Vec3D sepForce = new Vec3D();

		// For every diamond in the flock, check if it's too close.
		for (Diamond other : diamonds) {
			Vec3D otherPosition = closestWrappedOtherPosition(other);
			float distance = position.distanceTo(otherPosition);
			if (distance > 0 && distance < DESIRED_SEPARATION) {
				// Calculate vector pointing away from the other.
				Vec3D diff = position.sub(otherPosition);
				diff.normalize();
				diff.scaleSelf(1/distance);   // Weight by distance.
				sepForce.addSelf(diff);
			}
		}

		if (sepForce.magnitude() > 0) {
			sepForce.normalize();
			sepForce.scaleSelf(maxSpeed);
			sepForce.subSelf(velocity);
			sepForce.limit(maxForce);
		}

		return sepForce;
	}

	/**
   * Align velocity with the average of the nearby diamonds.
   */
	private Vec3D determineAligningForce(ArrayList<Diamond> diamonds) {
		Vec3D algnForce = new Vec3D();

		for (Diamond other : diamonds) {
			if (isCloseTo(other)) {
				algnForce.addSelf(other.getVelocity());
			}
		}

		if (algnForce.magnitude() > 0) {
			algnForce.normalize();
			algnForce.scaleSelf(maxSpeed);
			algnForce.subSelf(velocity);
			algnForce.limit(maxForce);
		}

		return algnForce;
	}

  /**
   * Steer towards the average position of all nearby diamonds.
   */
  private Vec3D determineCohesionForce(ArrayList<Diamond> diamonds) {
    Vec3D cohForce = new Vec3D();

    for (Diamond other : diamonds) {
      if (isCloseTo(other)) {
        cohForce.addSelf(closestWrappedOtherPosition(other));
      }
    }

    if (cohForce.magnitude() > 0) {
      cohForce.normalize();
      cohForce.scaleSelf(maxSpeed);
      cohForce.subSelf(velocity);
      cohForce.limit(maxForce);
    }

    return cohForce;
  }

	/**
   * Be repulsed from the Z boundaries
   */
  private Vec3D determineZRepulsionForce() {
		return new Vec3D(0, 0, -(position.z()/MAX_Z));
	}

  /**
   * Check whether the distance between us and another Diamond,
   * including wrap-around-borders, is closer than NEIGHBOR_DISTANCE.
   *
   * @param other  The other Diamond to compare ourselves with.
   */
  private boolean isCloseTo(Diamond other) {
    Vec3D otherPosition = other.getPosition().copy();
    float distance = position.distanceTo(otherPosition);

    // If the distance is 0, it's most likely us and we should bail.
    if (distance == 0) {
      return false;
    }

    // Nearby without wrapping borders is the easy case.
    if (distance < NEIGHBOR_DISTANCE) {
      return true;
    }

    // Compare the distance again.
    distance = position.distanceTo(closestWrappedOtherPosition(other));

    if (distance < NEIGHBOR_DISTANCE) {
      return true;
    } else {
      return false;
    }
  }

	private Vec3D closestWrappedOtherPosition(Diamond other) {
		Vec3D otherPosition = other.getPosition().copy();
		float distance = position.distanceTo(otherPosition);

		if (position.distanceTo(otherPosition.add(new Vec3D(worldWidth, 0, 0))) < distance) {
			// Move the other over to the right
			otherPosition.addSelf(new Vec3D(worldWidth, 0, 0));
			distance = position.distanceTo(otherPosition);
		} else if (position.distanceTo(otherPosition.sub(new Vec3D(worldWidth, 0, 0))) < distance) {
			// Move the other over to the left
			otherPosition.subSelf(new Vec3D(worldWidth, 0, 0));
			distance = position.distanceTo(otherPosition);
		}
		if (position.distanceTo(otherPosition.add(new Vec3D(0, worldHeight, 0))) < distance) {
			// Move the other down
			otherPosition.addSelf(new Vec3D(0, worldHeight, 0));
			distance = position.distanceTo(otherPosition);
		} else if (position.distanceTo(otherPosition.sub(new Vec3D(0, worldHeight, 0))) < distance) {
			// Move the other up
			otherPosition.subSelf(new Vec3D(0, worldHeight, 0));
			distance = position.distanceTo(otherPosition);
		}

		return otherPosition;
	}

  /**
   * Make all borders wrap-around so we return to the other side of the canvas.
   */
  private void wrapAroundBorders() {
    if (position.x < 0) position.x = worldWidth;
    if (position.y < 0) position.y = worldHeight;
    if (position.x > (worldWidth)) position.x = 0;
    if (position.y > (worldHeight)) position.y = 0;
  }

  /**
   * Draw extra visuals useful for debugging purposes.
   */
  private void drawDebugVisuals(ToxiclibsSupport gfx) {
    // Draw the diamond's velocity
    stroke(#ff00ff);
    strokeWeight(1);
    fill(#ff00ff);
    Arrow.draw(gfx, position.to2DXY(), position.to2DXY().add(velocity.to2DXY().scale(10)), 4);

    // Draw the separation force in green
    stroke(#97FF14);
    noFill();
    Arrow.draw(gfx, position.to2DXY(), position.to2DXY().add(separationForce.to2DXY().scale(500)), 4);

    // Draw the aligning force in blue
    stroke(#52C7FF);
    noFill();
    Arrow.draw(gfx, position.to2DXY(), position.to2DXY().add(aligningForce.to2DXY().scale(1000)), 4);

    // Draw the cohesion force in pink
    stroke(#FF5EDE);
    noFill();
    Arrow.draw(gfx, position.to2DXY(), position.to2DXY().add(cohesionForce.to2DXY().scale(1000)), 4);
  }

}
