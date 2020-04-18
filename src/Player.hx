import pony.time.Time;
import pony.time.DTimer;
import pony.time.DeltaTime;
import pony.ui.touch.Mouse;
import pony.Config;
import pony.pixi.nape.BodyCircleView;
import pony.geom.Point;
import pony.pixi.nape.NapeSpaceView;

final class Player {

	private static inline final PLAYER_RADIUS: Float = 60;
	private static inline final PLAYER_LOOK_SPEED: Float = 4;
	private static inline final PLAYER_SHOOT_SPEED: Int = 500;
	private static inline final PLAYER_BULLET_RADIUS: Float = 10;

	private final body: BodyCircleView;
	private final space: NapeSpaceView;
	private final shootsTimer: DTimer = DTimer.createTimer(PLAYER_SHOOT_SPEED, -1);

	public function new(space: NapeSpaceView) {
		this.space = space;
		var pos: Point<Float> = new Point<Float>(Config.width, Config.height);
		pos = pos / 2;
		body = space.player.createCircle(PLAYER_RADIUS);
		body.core.body.allowMovement = false;
		body.core.pos = pos;
		Mouse.onMove << moveHandler;
		Mouse.onLeftDown << shootsTimer.start0;
		Mouse.onLeftDown << shoot;
		Mouse.onLeftUp << shootsTimer.stop;
		Mouse.onLeftUp << shootsTimer.reset;
		shootsTimer.complete << shoot;
		// space.bullets.core.collision(space.enemys.core) << () -> trace(123);

		// body.core.groupCollision(space.enemys.core) << () -> trace(456);
	}

	private function shoot(): Void {
		var bullet = space.bullets.createCircle(PLAYER_BULLET_RADIUS, true);
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