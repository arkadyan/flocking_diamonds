class Diamond extends Mover {
  
  import toxi.geom.*;
  import toxi.processing.*;
  
  private static final color STROKE_COLOR = #ffffff;
  private static final int STROKE_WEIGHT = 2;
  private static final int LENGTH = 50;
  private static final int WIDTH = 30;
  
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
/*    flock(diamonds);*/
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
