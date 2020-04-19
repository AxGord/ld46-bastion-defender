import howler.Howler;
import pony.ui.AssetManager;
import howler.Howl;

final class Sound {

	public static var enabled: Bool = false;

	private static var howl: Howl;

	public static function init(): Void {
		Howler.volume(0.04);
		howl = new Howl({
			src: [AssetManager.baseUrl + 'sound.mp3'],
			sprite: {
				bullet: [SoundList.Bullet.min, SoundList.Bullet.length],
				enemyShot: [SoundList.EnemyShot.min, SoundList.EnemyShot.length],
				explosion: [SoundList.Explosion.min, SoundList.Explosion.length],
				mine: [SoundList.Mine.min, SoundList.Mine.length],
				newEnemy: [SoundList.NewEnemy.min, SoundList.NewEnemy.length],
				playerShot: [SoundList.PlayerShot.min, SoundList.PlayerShot.length],
				repair: [SoundList.Repair.min, SoundList.Repair.length],
				shield: [SoundList.Shield.min, SoundList.Shield.length],
				shieldOff: [SoundList.ShieldOff.min, SoundList.LENGTH - SoundList.ShieldOff.min]
			}
		});
	}

	private static inline function play(name: String): Void if (enabled) howl.play(name);

	public static inline function bullet(): Void play('bullet');
	public static inline function enemyShot(): Void play('enemyShot');
	public static inline function explosion(): Void play('explosion');
	public static inline function mine(): Void play('mine');
	public static inline function newEnemy(): Void play('newEnemy');
	public static inline function playerShot(): Void play('playerShot');
	public static inline function repair(): Void play('repair');
	public static inline function shield(): Void play('shield');
	public static inline function shieldOff(): Void play('shieldOff');


}