import processing.video.*;
import toxi.processing.*;


private static final int WORLD_WIDTH = 640;
private static final int WORLD_HEIGHT = 480;

private static final color BACKGROUND_COLOR = #000000;
private static final int NUM_FLOCKS = 3;
private static final int FLOCK_SIZE = 50;

private static final color[] COLORS = {
	0xCCBF0426,
	0xCC730A1D,
	0xCCF23D7F,
	0xCCF25EB0,
	0xCCFF2C74,
	0xCCA12320,
	0xCC1A2944,
	0xCC2DA7C7,
	0xCC56ACBA,
	0xCC98C4C9,
	0xCCA7FFFA,
	0xCC8AAB8A,
	0xCCCBD5D2,
	0xCCF2F2F2,
	0xCC94B2B1,
	0xCC025159,
	0xCC03A6A6,
	0xCC181F24,
	0xCCBFB52A,
	0xCCB2D4CA,
	0xCCEFFFF0,
	0xCC485773,
	0xCC6685B0,
	0xCC80BAE0,
	0xCCBCD7F1,
	0xCCF2E6F2,
	0xCCC4E3E0,
	0xCCF4FFFF,
	0xCC30BBDB,
	0xCC2D243B,
	0xCC004EAB,
	0xCCE8CA59,
	0xCCED5E11,
	0xCC30F5D4,
	0xCCBF364F,
	0xCC730240,
	0xCC89A67C,
	0xCCBFA473,
	0xCCBF0426,
	0xCC730A1D,
	0xCCBF0426,
	0xCC730A1D,
	0xCCF23D7F,
	0xCCF25EB0,
	0xCC447316,
	0xCCAE2678
};

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
	    f.addDiamond( new Diamond3D(new Vec3D(random(0, WORLD_WIDTH), random(0, WORLD_HEIGHT), random(-1, 1)), WORLD_WIDTH, WORLD_HEIGHT, COLORS[floor(random(COLORS.length))]) );
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
