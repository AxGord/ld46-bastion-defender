import pixi.core.sprites.Sprite;
import pixi.core.graphics.Graphics;
import pony.ui.gui.SmoothBarCore;

class GraphicsBar extends Sprite {

	public final core: SmoothBarCore;
	public final size: Point<Float> = new Point<Float>(60, 14);
	private final bg: Graphics = new Graphics();
	private final g: Graphics = new Graphics();
	private final padding: Float = 2;

	public function new() {
		super();
		bg.beginFill(0x505050);
		bg.drawRect(0, 0, size.x, size.y);
		addChild(bg);
		g.beginFill(0x008800);
		g.drawRect(padding, padding, size.x - padding * 2, size.y - padding * 2);
		addChild(g);
		core = new SmoothBarCore(size.x);
		core.smoothChangeX = changeXHandler;
		core.smooth = true;
		core.initValue(0, 1);
		core.endInit();
	}

	private function changeXHandler(v: Float): Void {
		g.width = v;
	}

}