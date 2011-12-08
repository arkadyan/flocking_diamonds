import processing.video.*;
import toxi.processing.*;


private static final int WORLD_WIDTH = 720;
private static final int WORLD_HEIGHT = 480;

private static final color BACKGROUND_COLOR = #000000;
private static final int FLOCK_SIZE = 200;

// Whether or not to display extra visuals for debugging.
private boolean debug = false;

ToxiclibsSupport gfx;

// Whether or not to record a movie with this run.
// NOTE: Be sure to quit the running sketch by pressing ESC.
private boolean makingMovie = false;
// MovieMake object to write a movie file.
private MovieMaker mm;

// A flock of Diamonds.
Flock flock;


void setup() {
  size(720, 480);
/*  size(1920, 1355);*/
  smooth();
  noCursor();
  
  gfx = new ToxiclibsSupport(this);
  
  // Create MovieMaker object with size, filename,
  // compression codec and quality, framerate
  if (makingMovie) {
    mm = new MovieMaker(this, width, height, "flocking_diamonds.mov", 30, MovieMaker.H263, MovieMaker.HIGH);
  }

  flock = new Flock();
  
  // Add an initial set of diamonds into the flock.
  for (int i=0; i < FLOCK_SIZE; i++) {
    flock.addDiamond( new Diamond(new Vec2D(width*0.5+random(-50, 50), height*0.5+random(-50, 50)), WORLD_WIDTH, WORLD_HEIGHT) );
  }
}

void draw() {
  background(BACKGROUND_COLOR);
  
  flock.run();
  flock.draw(gfx, debug);

  if (makingMovie) {
    mm.addFrame();
  }
}


/**
 * Toggle the debug display by hitting the spacebar.
 */
void keyPressed() {
  if (key == ' ') debug = ! debug;
  
  // Finish the movie if the Escape key is pressed.
  if (key == ESC) {
    if (makingMovie) {
      mm.finish();
    }
    exit();
  }
}
