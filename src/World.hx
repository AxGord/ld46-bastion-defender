@:assets_path('')
final class World implements HasAsset {

	private final canvas: Sprite;
	private final space: NapeSpaceView;
	private final player: Player;

	public function new(canvas: Sprite) {
		this.canvas = canvas;
		space = new NapeSpaceView(Config.width, Config.height, new Point<Float>(0, 0));
		space.debugLines = {size: 3, color: 0xFFFFFF};
		space.enemys.core.sensor = false;
		space.bullets.core.sensor = false;
		space.player.core.sensor = false;
		canvas.addChild(space);
		player = new Player(space);
		new Spawn(space);
		space.play();
	}

}