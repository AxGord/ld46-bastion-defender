import pony.ui.AssetManager;
import howler.Howl;

final class Music {

	public static var enabled: Bool = false;

	private static var howl: Howl;

	public static function init(): Void {
		howl = new Howl({
			src: [AssetManager.baseUrl + 'music.mp3']
		});
		howl.loop(true);
	}

	public static inline function play(): Void if (enabled) howl.play();
	public static inline function stop(): Void howl.stop();

}