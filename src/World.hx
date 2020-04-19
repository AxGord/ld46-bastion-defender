import pixi.extras.TilingSprite;

@:assets_path('')
final class World implements HasAsset {

	@:asset('grass.png') private static var GRASS = 'game.json';

	private final canvas: Sprite;
	private final space: NapeSpaceView;
	private final player: Player;

	public function new(canvas: Sprite) {
		this.canvas = canvas;
		space = new NapeSpaceView(Config.width, Config.height, new Point<Float>(0, 0));
		final grassTexture = getTexture(GRASS);
		final grassTile = new TilingSprite(grassTexture);
		grassTile.width = Config.width;
		grassTile.height = Config.height;
		canvas.addChild(grassTile);
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