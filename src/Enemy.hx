import pony.Config;
import pony.geom.Point;
import pony.geom.Direction;
import pony.Random;
import pony.math.MathTools;
import pony.pixi.nape.NapeSpaceView;
import pony.pixi.nape.BodyCircleView;

final class Enemy {

	private static inline final ENEMY_RADIUS: Float = 40;

	private final body: BodyCircleView;
	private final space: NapeSpaceView;

	public function new(space: NapeSpaceView) {
		this.space = space;
		var size: Point<Float> = new Point<Float>(Config.width, Config.height);
		var pos: Point<Float> = size * switch Random.direction() {
			case Direction.Down: new Point<Float>(Math.random(), 0);
			case Direction.Up: new Point<Float>(Math.random(), 1);
			case Direction.Left: new Point<Float>(0, Math.random());
			case Direction.Right: new Point<Float>(1, Math.random());
			case _: throw 'Error';
		}
		body = space.enemys.createCircle(ENEMY_RADIUS);
		body.core.pos = pos;
		var target = size / 2;
		body.core.lookAt(target.x, target.y);
		body.core.setSpeed(200);
		body.core.groupCollision(space.bullets.core) << hit;
		body.core.groupCollision(space.player.core) << body.destroy.bind(null);
	}

	public function hit(): Void {
		body.alpha -= 0.1;
		if (body.alpha < 0.4) body.destroy();
	}

}