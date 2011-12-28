import processing.video.*;
import toxi.processing.*;


private static final int WORLD_WIDTH = 640;
private static final int WORLD_HEIGHT = 480;

private static final color BACKGROUND_COLOR = #000000;
private static final int NUM_FLOCKS = 3;
private static final int FLOCK_SIZE = 50;

// Whether or not to display extra visuals for debugging.
private boolean debug = false;

ToxiclibsSupport gfx;

// Whether or not to record a movie with this run.
// NOTE: Be sure to quit the running sketch by pressing ESC.
private boolean makingMovie = false;
// MovieMake object to write a movie file.
private MovieMaker mm;

// A collection of flocks of Diamonds.
ArrayList<Flock3D> flocks;


void setup() {
  size(640, 480);
  smooth();
  noCursor();
  
  gfx = new ToxiclibsSupport(this);
  
  // Create MovieMaker object with size, filename,
  // compression codec and quality, framerate
  if (makingMovie) {
    mm = new MovieMaker(this, width, height, "flocking_diamonds.mov", 30, MovieMaker.H263, MovieMaker.HIGH);
  }

	flocks = new ArrayList<Flock3D>();
	for (int i=0; i < NUM_FLOCKS; i++) {
		Flock3D f = new Flock3D();
		// Add an initial set of diamonds into the flock.
		for (int j=0; j < FLOCK_SIZE; j++) {
	    f.addDiamond( new Diamond3D(new Vec3D(random(0, WORLD_WIDTH), random(0, WORLD_HEIGHT), 0), WORLD_WIDTH, WORLD_HEIGHT) );
	  }
		flocks.add(f);
	}
}

void draw() {
  background(BACKGROUND_COLOR);
  
	for (Flock3D flock : flocks) {
	  flock.run();
	  flock.draw(gfx, debug);
	}

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
