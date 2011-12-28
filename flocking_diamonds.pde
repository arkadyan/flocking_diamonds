import processing.video.*;
import toxi.processing.*;


private static final int WORLD_WIDTH = 640;
private static final int WORLD_HEIGHT = 480;

private static final color BACKGROUND_COLOR = #000000;
private static final int NUM_FLOCKS = 3;
private static final int FLOCK_SIZE = 50;

private static final color[][] COLORS = {
	{   // Blues
		0xCC1A2944,
		0xCC2DA7C7,
		0xCC56ACBA,
		0xCC98C4C9,
		0xCCA7FFFA,
		0xCCCBD5D2,
		0xCCB2D4CA,
		0xCCEFFFF0,
		0xCC485773,
		0xCC6685B0,
		0xCC80BAE0,
		0xCCBCD7F1,
		0xCCF2E6F2,
		0xCC30F5D4,
		0xCC30BBDB,
		0xCC2D243B,
		0xCC004EAB
	},
	{   // Reds
		0xCCED5E11,
		0xCCBF364F,
		0xCC730240,
		0xCCBF0426,
		0xCC730A1D,
		0xCCF23D7F,
		0xCCF25EB0,
		0xCCAE2678,
		0xCCCC3366,
		0xCC990033,
		0xCCCC9999,
		0xCCCC3399,
		0xCCCC3333,
		0xCCCC33CC
	},
	{   // Oranges
		0xCCE89509,
		0xCCFFBD0A,
		0xCCFF8103,
		0xCCFF3D0A,
		0xCCE85809,
		0xCCBF2E07,
		0xCCB34114,
		0xCCFFC936,
		0xCCBF4828,
		0xCCF1BF6B,
		0xCCFF9A35,
		0xCC804102,
		0xCCEDAA3A,
		0xCCFF643B
	}
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
	    f.addDiamond( new Diamond3D(new Vec3D(random(0, WORLD_WIDTH), random(0, WORLD_HEIGHT), random(-1, 1)), WORLD_WIDTH, WORLD_HEIGHT, COLORS[i][floor(random(COLORS[i].length))]) );
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
