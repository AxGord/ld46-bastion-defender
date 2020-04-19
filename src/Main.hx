import pony.ui.AssetManager;

class Main extends pony.pixi.SimpleXmlApp {

	private var stats: Stats;

	override private function init():Void {
		onLoaded < loadedHandler;
		AssetManager.baseUrl = 'assets/';
		super.init();
	}

	private function loadedHandler():Void {
		createUI();
		stats = new Stats(this);
		new World(world);
		stats.startGame();
	}

	private static function main():Void new Main();

}