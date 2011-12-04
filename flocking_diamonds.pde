import toxi.processing.*;

private static final int WORLD_WIDTH = 680;
private static final int WORLD_HEIGHT = 480;

private static final color BACKGROUND_COLOR = #000000;
private static final int FLOCK_SIZE = 200;

// Whether or not to display extra visuals for debugging.
private boolean debug = false;

ToxiclibsSupport gfx;

// A flock of Diamonds.
Flock flock;


void setup() {
  size(680, 480);
/*  size(1920, 1355);*/
  smooth();
  noCursor();
  
  gfx = new ToxiclibsSupport(this);
  
  flock = new Flock();
  
  // Add an initial set of diamonds into the flock.
  for (int i=0; i < FLOCK_SIZE; i++) {
    flock.addDiamond( new Diamond(new Vec2D(width*0.5+random(-50, 50), height*0.5+random(-50, 50))) );
  }
}

void draw() {
  background(BACKGROUND_COLOR);
  
  flock.run();
  flock.draw(gfx, debug);
}


/**
 * Toggle the debug display by hitting the spacebar.
 */
void keyPressed() {
  if (key == ' ') debug = ! debug;
}
