final class Enemy {

	private final bar: GraphicsBar = new GraphicsBar();
	private final body: BodyCircleView;
	private final space: NapeSpaceView;
	private final impulseTimer: DTimer = DTimer.createTimer(1000, -1);
	private final pretargetSize: Point<Float> = 500;
	private final correctionTimer: DTimer = DTimer.createTimer(2400, -1);
	private final target: Point<Float>;
	private final subEnemys: Int;
	private final radius: Float;

	public function new(space: NapeSpaceView, pos: Point<Float>, subEnemys: Int, radius: Float) {
		this.space = space;
		this.subEnemys = subEnemys;
		this.radius = radius;
		var size: Point<Float> = new Point<Float>(Config.width, Config.height);
		body = space.enemys.createCircle(radius);
		space.addChild(bar);
		DeltaTime.update << syncBar;
		bar.core.percent = 1;
		body.core.body.mass = radius;
		body.core.body.allowRotation = false;
		body.core.pos = pos;
		syncBar();
		target = size / 2;
		var pretarget = target + Point.random() * pretargetSize;
		body.core.lookAt(pretarget.x, pretarget.y);
		body.core.groupCollision(space.bullets.core) << hit;
		body.core.groupCollision(space.player.core) << destroy;
		impulseTimer.complete << impulse;
		impulseTimer.start();
		impulse();
		correctionTimer.complete << correction;
		correctionTimer.start();
	}

	private function syncBar(): Void {
		bar.x = body.x - bar.size.x / 2;
		bar.y = body.y - bar.size.y / 2 - radius;
	}

	public function hit(): Void {
		bar.core.percent -= 0.1;
		if (bar.core.percent <= 0) killed();
	}

	private function correction(): Void {
		body.core.lookAtVelLin(target.x, target.y, 2);
		DeltaTime.update << speedUpdate;
		speedUpdate();
	}

	private function speedUpdate(): Void {
		body.core.setSpeed(100);

	}

	private function impulse(): Void {
		body.core.addSpeed(100);
	}

	private function killed(): Void {
		var pos = body.core.pos;
		destroy();
		for (_ in 0...subEnemys) {
			new Enemy(space, pos + Point.random() * radius, 0, radius / 2);
		}
	}

	private function destroy(): Void {
		DeltaTime.update >> syncBar;
		space.removeChild(bar);
		DeltaTime.update >> speedUpdate;
		correctionTimer.destroy();
		impulseTimer.destroy();
		body.destroy();
	}

}