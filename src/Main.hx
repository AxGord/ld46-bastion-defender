import pony.ui.AssetManager;

class Main extends pony.pixi.SimpleXmlApp {

	override private function init():Void {
		onLoaded < loadedHandler;
		AssetManager.baseUrl = 'assets/';
		super.init();
	}

	private function loadedHandler():Void {
		createUI();
		new World(world);
	}

	private static function main():Void new Main();

}