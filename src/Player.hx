@:assets_parent(World)
final class Player implements HasAsset {

	@:asset('player_bg.png') private static var BG = 'game.json';
	@:asset('player_head.png') private static var HEAD = 'game.json';
	@:asset('player_shot.png') private static var BULLET = 'game.json';

	private static inline final PLAYER_RADIUS: Float = 60;
	private static inline final PLAYER_LOOK_SPEED: Float = 6;
	private static inline final PLAYER_SHOOT_SPEED: Int = 200;

	private final bar: GraphicsBar = new GraphicsBar();
	private final body: BodyCircleView;
	private final space: NapeSpaceView;
	private final shootsTimer: DTimer = DTimer.createTimer(PLAYER_SHOOT_SPEED, -1);

	public function new(space: NapeSpaceView) {
		this.space = space;
		final bg = image(BG);
		space.addChildAt(bg, 0);
		space.addChild(bar);
		final pos: Point<Float> = new Point<Float>(Config.width, Config.height) / 2;
		final bgPos = pos - new Point(bg.width, bg.height) / 2;
		bg.x = bgPos.x;
		bg.y = bgPos.y;
		final barPos = pos - bar.size / 2;
		bar.x = barPos.x;
		bar.y = barPos.y - bg.height / 2;
		bar.core.percent = 1;

		body = space.player.createCircle(PLAYER_RADIUS);
		body.debugLines = null;
		final head = image(HEAD);
		body.addChild(head);
		final headPos = new Point(head.width, head.height) / 2;
		head.x = -headPos.x;
		head.y = -headPos.y;
		body.core.body.allowMovement = false;
		body.core.pos = pos;
		Mouse.onMove << moveHandler;
		Mouse.onLeftDown << shootsTimer.start0;
		Mouse.onLeftDown << shoot;
		Mouse.onLeftUp << shootsTimer.stop;
		Mouse.onLeftUp << shootsTimer.reset;
		Mouse.onLeave << shootsTimer.stop;
		Mouse.onLeave << shootsTimer.reset;
		shootsTimer.complete << shoot;

		body.core.groupCollision(space.enemys.core) << hit;
	}

	private function hit(): Void {
		bar.core.percent -= 0.1;
	}

	private function shoot(): Void {
		var b = image(BULLET);
		var s = new Point(b.width, b.height);
		var bullet = space.bullets.createRect(new Rect<Float>(0, -s.y / 2, s.x, s.y / 2), false);
		bullet.debugLines = null;
		bullet.visible = false;
		DeltaTime.update < () -> bullet.visible = true;
		bullet.addChild(b);
		b.y = -s.y / 2;
		var d = new Point(Math.cos(body.core.rotation), Math.sin(body.core.rotation));
		bullet.core.pos = body.core.pos + d;
		bullet.core.rotation = body.core.rotation;
		bullet.core.setSpeed(300);
		bullet.core.groupCollision(space.enemys.core) << () -> bullet.destroy();
	}

	private function moveHandler(x: Float, y: Float): Void {
		body.core.lookAtVelLin(x, y, PLAYER_LOOK_SPEED);
	}

}