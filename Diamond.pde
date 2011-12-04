class Diamond extends Mover {
  
  import toxi.geom.*;
  import toxi.processing.*;
  
  private static final color STROKE_COLOR = #ffffff;
  private static final int STROKE_WEIGHT = 2;
  private static final int LENGTH = 50;
  private static final int WIDTH = 30;
  
  private static final float SEPARATION_FORCE_WEIGHT = 1.0;
  private static final float ALIGNING_FORCE_WEIGHT = 0.2;
  private static final float COHESION_FORCE_WEIGHT = 0.2;
  
  private static final float DESIRED_SEPARATION = 30.0;
  private static final float NEIGHBOR_DISTANCE = 50;
  
  private Polygon2D shape;
  private color fillColor;
  
  
  Diamond(Vec2D pos) {
    position = pos;
    fillColor = color(random(256), random(256), random(256), random(150, 256));
    velocity = new Vec2D(random(-1, 1), random(-1, 1));
    acceleration = new Vec2D(0, 0);
    maxSpeed = 3;
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
    float theta = velocity.heading() + PI*0.5;
    
    stroke(STROKE_COLOR);
    strokeWeight(STROKE_WEIGHT);
    fill(fillColor);
    
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    
    // Define the shape.
    shape = new Polygon2D();
    shape.add(new Vec2D(0, +0.5*LENGTH));  // Top
    shape.add(new Vec2D(+0.5*WIDTH, 0));  // Right
    shape.add(new Vec2D(0, -0.5*LENGTH));  // Bottom
    shape.add(new Vec2D(-0.5*WIDTH, 0));  // Left
    
    gfx.polygon2D(shape);
    popMatrix();
    
    if (debug) drawDebugVisuals(gfx);
  }
  
  /**
   * Get the diamond's position.
   */
  public Vec2D getPosition() {
    return position;
  }
  
  /**
   * Get the diamond's velocity.
   */
  public Vec2D getVelocity() {
    return velocity;
  }
  
  
  /**
   * Figure out a new acceleration based on three rules.
   */
  private void flock(ArrayList<Diamond> diamonds) {
    Vec2D separationForce = determineSeparationForce(diamonds);
    Vec2D aligningForce = determineAligningForce(diamonds);
    Vec2D cohesionForce = determineCohesionForce(diamonds);
    
    // Weight these forces.
    separationForce.scaleSelf(SEPARATION_FORCE_WEIGHT);
    println("separationForce=" + separationForce);
    aligningForce.scaleSelf(ALIGNING_FORCE_WEIGHT);
    println("aligningForce=" + aligningForce);
    cohesionForce.scaleSelf(COHESION_FORCE_WEIGHT);
    println("cohesionForce=" + cohesionForce);
    
    // Add the force vectors to our acceleration
    applyForce(separationForce);
    applyForce(aligningForce);
    applyForce(cohesionForce);
  }
  
  /**
   * Check for nearby diamonds and separate from them.
   */
  private Vec2D determineSeparationForce(ArrayList<Diamond> diamonds) {
    Vec2D sepForce = new Vec2D(0, 0);
    int count = 0;
    
    // For every diamond in the flock, check if it's too close.
    for (Diamond other : diamonds) {
      Vec2D otherPosition = other.getPosition();
      float distance = position.distanceTo(otherPosition);
      if (distance > 0 && distance < DESIRED_SEPARATION) {
        // Calculate vector pointing away from the other.
        Vec2D diff = position.sub(otherPosition);
        diff.normalize();
        diff.scaleSelf(1/distance);   // Weight by distance.
        sepForce.addSelf(diff);
        count++;   // Keep track of how many close neighbors.
      }
    }
    // Average -- divide by the number of close neighbors.
    if (count > 0) {
      sepForce.scaleSelf(1/count);
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
  private Vec2D determineAligningForce(ArrayList<Diamond> diamonds) {
    Vec2D algnForce = new Vec2D(0, 0);
    int count = 0;
    
    for (Diamond other : diamonds) {
      float distance = position.distanceTo(other.getPosition());
      if (distance > 0 && distance < NEIGHBOR_DISTANCE) {
        algnForce.addSelf(other.getVelocity());
        count++;
      }
    }
    
    if (count > 0) {
      algnForce.scaleSelf(1/count);
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
  private Vec2D determineCohesionForce(ArrayList<Diamond> diamonds) {
    Vec2D cohForce = new Vec2D(0, 0);
    int count = 0;
    
    for (Diamond other : diamonds) {
      Vec2D otherPosition = other.getPosition();
      float distance = position.distanceTo(otherPosition);
      if (distance > 0 && distance < NEIGHBOR_DISTANCE) {
        cohForce.addSelf(otherPosition);
        count++;
      }
    }
    
    if (count > 0) {
      cohForce.scaleSelf(1/count);
      cohForce.normalize();
      cohForce.scaleSelf(maxSpeed);
      cohForce.subSelf(velocity);
      cohForce.limit(maxForce);
    }
    
    return cohForce;
  }
  
  /**
   * Make all borders wrap-around so we return to the other side of the canvas.
   */
  private void wrapAroundBorders() {
    if (position.x < -LENGTH) position.x = width + LENGTH;
    if (position.y < -LENGTH) position.y = height + LENGTH;
    if (position.x > (width+LENGTH)) position.x = -LENGTH;
    if (position.y > (height+LENGTH)) position.y = -LENGTH;
  }
  
  /**
   * Draw extra visuals useful for debugging purposes.
   */
  private void drawDebugVisuals(ToxiclibsSupport gfx) {
    // Draw the diamond's position
    noStroke();
    fill(#ff0000);
    gfx.ellipse(new Ellipse(position, 5));
    
    // Draw the diamond's velocity
    stroke(#ff00ff);
    strokeWeight(1);
    fill(#ff00ff);
    Arrow.draw(gfx, position, position.add(velocity.scale(50)), 4);
  }
  
}
