import pony.time.Tween;
import pony.ui.AssetManager;

final class Main extends pony.pixi.SimpleXmlApp {

	private var statsContoller: Stats;
	private var worldSpace: World;

	override private function init():Void {
		onLoaded < loadedHandler;
		AssetManager.baseUrl = 'assets/';
		super.init();
	}

	private function loadedHandler():Void {
		createUI();
		statsContoller = new Stats(this);
		worldSpace = new World(world);
		menu_start.core.onClick << startHandler;
		Player.onGameOver << gameOverHandler;
		Sound.init();
		Sound.enabled = true;
	}

	private function startHandler(): Void {
		menu.visible = false;
		world.visible = true;
		final tween = new Tween(TweenType.BackSquare);
		tween.onProgress << v -> world.alpha = v;
		tween.play();
		worldSpace.startGame();
		statsContoller.startGame();
	}

	private function gameOverHandler(): Void {
		statsContoller.stopGame();
		worldSpace.stopGame();
		gameOver.visible = true;

		gameOver_score.t = stats_score.t;
		final menuTimer: DTimer = DTimer.createFixedTimer(1000);
		final tween = new Tween(Config.height...0, TweenType.BackSquare);
		tween.onUpdate << v -> gameOver.y = v;
		tween.onProgress << v -> gameOver.alpha = v;
		tween.onComplete << menuTimer.start;
		menuTimer.complete << () -> {
			final tween = new Tween(-Config.height...0, TweenType.BackSquare, true);
			tween.onUpdate << v -> gameOver.y = v;
			tween.onProgress << v -> {
				gameOver.alpha = v;
				world.alpha = v;
			}
			tween.onComplete << () -> {
				worldSpace.stopGame();
				world.visible = false;
				gameOver.visible = false;
				menu.visible = true;
			}
			tween.play();
		}
		tween.play();

	}

	private static function main(): Void new Main();

}