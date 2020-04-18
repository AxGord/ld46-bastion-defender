import pony.pixi.nape.NapeSpaceView;
import pony.time.DTimer;

final class Spawn {

	private final space: NapeSpaceView;
	private final timer: DTimer = DTimer.createFixedTimer(5000, -1);

	public function new(space: NapeSpaceView) {
		this.space = space;
		timer.complete << spawn;
		timer.start();
	}

	public function spawn(): Void {
		new Enemy(space);
	}

}