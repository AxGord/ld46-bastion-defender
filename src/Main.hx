import pony.pixi.ui.BText;
import haxe.io.Bytes;
import js.Browser;
import pony.time.Tween;
import pony.ui.AssetManager;
import pony.Pair;

final class Main extends pony.pixi.SimpleXmlApp {

	private static final storageKey: String = 'BastionDefender';

	private var statsContoller: Stats;
	private var worldSpace: World;
	private var settings: Settings;

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
		menu_sound.core.onClick << switchSound;
		menu_music.core.onClick << switchMusic;
		menu_leader.core.onClick << openLeader;
		leaderBoard_back.core.onClick << backFromLeaderBoard;
		Player.onGameOver << gameOverHandler;
		Sound.init();
		Music.init();
		var storage = Browser.getLocalStorage().getItem(storageKey);
		if (storage != null) {
			try {
				settings = Settings.fromBytes(Bytes.ofHex(storage));
			} catch (_: Any) {
				settings = new Settings();
			}
		} else {
			settings = new Settings();
		}
		applySettings();
	}

	private function openLeader(): Void {
		Sound.enemyShot();
		menu.visible = false;
		leaderBoard.visible = true;
		while (leaderBoard_list.children.length > 0) leaderBoard_list.remove(cast leaderBoard_list.getChildAt(0));
		var data = [ for (time => score in settings.leaders) new Pair(time, score) ];
		data.sort(sortByScore);
		for (p in data) {
			final t = new BText(
				DateTools.format(Date.fromTime(p.a * 1000), '%Y-%m-%d %H:%M:%S') + ': ' + p.b,
				{font: 'dpcomic', tint: 0xFFFFFF}, true, app
			);
			t.scale = new pixi.core.math.Point(2, 2);
			leaderBoard_list.add(t);
		}
	}

	private function sortByScore(a: Pair<Int, Int>, b: Pair<Int, Int>): Int {
		return b.b - a.b;
	}

	private function backFromLeaderBoard(): Void {
		Sound.enemyShot();
		menu.visible = true;
		leaderBoard.visible = false;
	}

	private function applySettings(): Void {
		Sound.enabled = settings.sound;
		Music.enabled = settings.music;
		updateSoundState();
		updateMusicState();
	}

	private function saveSettings(): Void {
		Browser.getLocalStorage().setItem(storageKey, settings.toBytes().toHex());
	}

	private function switchSound(): Void {
		Sound.enabled = !Sound.enabled;
		updateSoundState();
		Sound.enemyShot();
		settings.sound = Sound.enabled;
		saveSettings();
	}

	private function switchMusic(): Void {
		Music.enabled = !Music.enabled;
		updateMusicState();
		Sound.enemyShot();
		settings.music = Music.enabled;
		saveSettings();
	}

	private function updateSoundState(): Void {
		menu_soundState.t = 'Sound: ' + (Sound.enabled ? 'On' : 'Off');
	}

	private function updateMusicState(): Void {
		menu_musicState.t = 'Music: ' + (Music.enabled ? 'On' : 'Off');
	}

	private function startHandler(): Void {
		Sound.enemyShot();
		Music.play();
		menu.visible = false;
		world.visible = true;
		final tween = new Tween(TweenType.BackSquare);
		tween.onProgress << v -> world.alpha = v;
		tween.play();
		worldSpace.startGame();
		statsContoller.startGame();
	}

	private function gameOverHandler(): Void {
		Music.stop();
		settings.leaders[Std.int(Date.now().getTime() / 1000)] = statsContoller.score;
		if (Lambda.count(settings.leaders) > 5) {
			var min: Int = MathTools.MAX_INT;
			var k: Null<Int> = null;
			for (t => score in settings.leaders) if (score < min) {
				min = score;
				k = t;
			}
			if (k != null) settings.leaders.remove(k);
		}
		saveSettings();
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