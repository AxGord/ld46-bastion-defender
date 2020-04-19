import haxe.io.Bytes;

final class Settings implements hxbit.Serializable {

	@:s public var sound: Bool;
	@:s public var music: Bool;
	@:s public var leaders: Map<Int, Int>;

	public function new() {
		sound = true;
		music = true;
		leaders = [];
	}

	public function toBytes(): Bytes {
		var s = new hxbit.Serializer();
		return s.serialize(this);
	}

	public static function fromBytes(bytes: Bytes): Settings {
		var s = new hxbit.Serializer();
		return s.unserialize(bytes, Settings);
	}

}