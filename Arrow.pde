/**
 * Utility class for drawing arrows.
 */
static class Arrow {

  import toxi.geom.*;
  import toxi.processing.*;

  
  /**
   * Draw an arrow from point "from" to point "to".
   *
   * @param gfx  The Toxiclibs drawing object.
   * @param from  The base of the arrow.
   * @param to  The tip of the arrow.
   * @param headSize  The size of the head of the arrow.
   */
  public static void draw(ToxiclibsSupport gfx, Vec2D from, Vec2D to, float headSize) {
    Vec2D arrowEdge = from.sub(to).normalizeTo(headSize);
    // Main shaft of the arrow.
    gfx.line(from, to);
    // Two edges of the arrow, rotated 30 degrees.
    gfx.line(to, to.add(arrowEdge.copy().rotate(0.5235988)));
    gfx.line(to, to.add(arrowEdge.copy().rotate(-0.5235988)));
  }
  
}
