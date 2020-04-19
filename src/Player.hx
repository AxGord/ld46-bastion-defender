import pony.pixi.nape.BodyRectView;
import pony.TypedFPool;

@:assets_parent(World)
final class Player implements HasAsset implements HasSignal {

	@:asset('player_bg.png') private static var BG = 'game.json';
	@:asset('player_head.png') private static var HEAD = 'game.json';
	@:asset('player_shot.png') private static var BULLET = 'game.json';
	@:asset('bang.png') private static var BANG = 'game.json';
	@:asset('shield.png') private static var SHIELD = 'game.json';

	@:auto public static final onGameOver: Signal0;

	private static inline final PLAYER_RADIUS: Float = 60;
	private static inline final PLAYER_LOOK_SPEED: Float = 6;
	private static inline final PLAYER_SHOOT_SPEED: Int = 200;
	private static inline final PLAYER_BULLET_SPEED: Int = 800;

	public static var instance(default, null): Player;

	private final bar: GraphicsBar = new GraphicsBar();
	private final shieldBar: GraphicsBar = new GraphicsBar(0x000088);
	private final shieldBall: Sprite;
	private var body: BodyCircleView;
	private final space: NapeSpaceView;
	private final shootsTimer: DTimer = DTimer.createTimer(PLAYER_SHOOT_SPEED, -1);
	private final pos: Point<Float>;
	private var bulletPool: TypedFPool<BodyRectView>;
	private final bg: Sprite;

	public function new(space: NapeSpaceView) {
		instance = this;
		this.space = space;
		shootsTimer.complete << shoot;
		bg = image(BG);
		space.addChildAt(bg, 0);
		space.addChild(bar);
		space.addChild(shieldBar);

		pos = new Point<Float>(Config.width, Config.height) / 2;
		final bgPos = pos - new Point(bg.width, bg.height) / 2;
		bg.x = bgPos.x;
		bg.y = bgPos.y;
		final barPos = pos - bar.size / 2;
		bar.x = barPos.x;
		bar.y = barPos.y - bg.height / 2;
		shieldBar.x = barPos.x;
		shieldBar.y = barPos.y + bg.height / 2;
		shieldBar.core.changeSmoothPercent << shielChangeHandler;
		shieldBall = image(SHIELD);
		shieldBar.visible = false;
		shieldBall.visible = false;
	}

	private function shielChangeHandler(v: Float): Void {
		shieldBall.visible = shieldBar.visible = v > 0;
	}

	public function startGame(): Void {
		bar.visible = true;
		bg.visible = true;
		bulletPool = new TypedFPool<BodyRectView>(createBullet);
		shieldBar.core.percent = 0;
		bar.core.percent = 1;
		bar.core.changeSmoothPercent << hpPercentHandler;
		body = space.player.createCircle(PLAYER_RADIUS);
		body.debugLines = null;
		final head = image(HEAD);
		body.addChild(head);
		space.addChild(shieldBall);
		shieldBall.x = pos.x - shieldBall.width / 2;
		shieldBall.y = pos.y - shieldBall.height / 2;
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
		body.core.groupCollision(space.enemys.core) << hit;
	}

	private function stopGame(): Void {
		body.destroy();
		bulletPool.destroy();
		bulletPool = null;
		bar.core.changeSmoothPercent >> hpPercentHandler;
		bar.core.percent = 0;
		Mouse.onMove >> moveHandler;
		Mouse.onLeftDown >> shootsTimer.start0;
		Mouse.onLeftDown >> shoot;
		Mouse.onLeftUp >> shootsTimer.stop;
		Mouse.onLeftUp >> shootsTimer.reset;
		Mouse.onLeave >> shootsTimer.stop;
		Mouse.onLeave >> shootsTimer.reset;
		shootsTimer.stop();
		shootsTimer.reset();
	}

	public function applyShield(): Void {
		shieldBar.core.percent = 1;
	}

	public function applyRepair(): Void {
		bar.core.percent = 1;
	}

	private function hpPercentHandler(v: Float): Void {
		if (v > 0) return;
		final bang = image(BANG);
		final scale = 2;
		bang.scale = new pixi.core.math.Point(scale, scale);
		final bPos = new Point(body.x, body.y);
		bang.x = bPos.x - bang.width / 2;
		bang.y = bPos.y - bang.height / 2;
		space.addChild(bang);
		stopGame();
		eGameOver.dispatch();
		DTimer.delay(1000, () -> {
			bang.destroy();
			bar.visible = false;
			body.visible = false;
			bg.visible = false;
		}).progress << v -> {
			bang.alpha = v;
			bang.scale = new pixi.core.math.Point(scale + v * scale / 2, scale + v * scale / 2);
			bang.x = bPos.x - bang.width / 2;
			bang.y = bPos.y - bang.height / 2;
		}
	}

	private function hit(): Void {
		final dmg: Float = 0.1;
		if (shieldBar.core.percent > 0) {
			shieldBar.core.percent -= dmg;
			if (shieldBar.core.percent < 0) {
				bar.core.percent += shieldBar.core.percent;
				shieldBar.core.percent = 0;
			}
		} else {
			bar.core.percent -= dmg;
		}
	}

	private function createBullet(): BodyRectView {
		var b = image(BULLET);
		var s = new Point(b.width, b.height);
		var bullet = space.bullets.createRect(new Rect<Float>(0, -s.y / 2, s.x, s.y / 2), false);
		function hide() {
			bullet.visible = false;
			bullet.core.sleep();
			if (bulletPool != null)
				bulletPool.ret(bullet);
			else
				bullet.destroy();
		}
		bullet.core.onOut << hide;
		bullet.debugLines = null;
		bullet.visible = false;
		bullet.addChild(b);
		bullet.core.body.allowRotation = false;
		bullet.core.groupCollision(space.enemys.core) << () -> {
			final bang = image(BANG);
			bang.scale = new pixi.core.math.Point(0.2, 0.2);
			final bPos = new Point(bullet.x + Math.cos(bullet.core.rotation) * s.y, bullet.y + Math.sin(bullet.core.rotation) * s.y);
			hide();
			bang.x = bPos.x - bang.width / 2;
			bang.y = bPos.y - bang.height / 2;
			bang.rotation = Math.random() * 2 * Math.PI;
			space.addChild(bang);
			DTimer.delay(300, bang.destroy.bind(null)).progress << v -> {
				bang.alpha = v;
				bang.scale = new pixi.core.math.Point(0.2 + v * 0.2, 0.2 + v * 0.2);
				bang.x = bPos.x - bang.width / 2;
				bang.y = bPos.y - bang.height / 2;
			}
		}
		return bullet;
	}

	private function shoot(): Void {
		var bullet = bulletPool.get();
		bullet.core.wake();
		bullet.core.body.space = space.core.space;
		var b: Sprite = cast bullet.getChildAt(0);
		var s = new Point(b.width, b.height);
		DeltaTime.update < () -> bullet.visible = true;
		b.y = -s.y / 2;
		var d = new Point(Math.cos(body.core.rotation), Math.sin(body.core.rotation));
		bullet.core.pos = body.core.pos + d;
		bullet.core.rotation = body.core.rotation;
		bullet.core.setSpeed(PLAYER_BULLET_SPEED);
	}

	private function moveHandler(x: Float, y: Float): Void {
		body.core.lookAtVelLin(x, y, PLAYER_LOOK_SPEED);
	}

}