final class Spawn {

	private final space: NapeSpaceView;
	private final timer: DTimer = DTimer.createFixedTimer(3000, -1);
	private final size: Point<Float> = new Point<Float>(Config.width, Config.height);

	public function new(space: NapeSpaceView) {
		this.space = space;
		timer.complete << spawn;
	}

	public function startGame(): Void {
		timer.reset();
		timer.start();
	}

	public function stopGame(): Void {
		timer.stop();
	}

	public function spawn(): Void {
		var pos: Point<Float> = size * switch Random.direction() {
			case Direction.Down: new Point<Float>(Math.random(), 0);
			case Direction.Up: new Point<Float>(Math.random(), 1);
			case Direction.Left: new Point<Float>(0, Math.random());
			case Direction.Right: new Point<Float>(1, Math.random());
			case _: throw 'Error';
		}
		new Enemy(space, pos, Random.uint(4));
	}

}