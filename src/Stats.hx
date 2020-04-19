import pony.ui.keyboard.Key;
import pony.ui.keyboard.Keyboard;

final class Stats {

	private static inline final PRICE_SHIELD: Int = 24;
	private static inline final PRICE_REPAIR: Int = 35;
	private static inline final PRICE_MINE: Int = 8;

	private final root: Main;
	private var score(default, set): Int;
	private var money(default, set): Int;
	private var liveTimer: DTimer = DTimer.createTimer(4000, -1);

	public function new(root: Main) {
		this.root = root;
		liveTimer.complete << liveHandler;
		Enemy.onKill << killHandler;
	}

	public function startGame(): Void {
		root.stats.visible = true;
		root.store.visible = true;
		score = 0;
		money = 10;
		liveTimer.reset();
		liveTimer.start();
		Keyboard.click << keyHandler;
	}

	public function stopGame(): Void {
		root.stats.visible = false;
		root.store.visible = false;
		liveTimer.stop();
		Keyboard.click >> keyHandler;
	}

	private function keyHandler(key: Key): Void {
		switch key {
			case Number1 if (money >= PRICE_SHIELD):
				money -= PRICE_SHIELD;
				Player.instance.applyShield();
			case Number2 if (money >= PRICE_REPAIR):
				money -= PRICE_REPAIR;
				Player.instance.applyRepair();
			case Number3 if (money >= PRICE_MINE):
				money -= PRICE_MINE;
				Player.instance.applyMine();
			case _:
		}
	}

	private function liveHandler(): Void {
		score++;
		money++;
	}

	private function killHandler(cost: Int): Void {
		score += cost;
		money += cost;
	}

	private function set_score(v: Int): Int {
		score = v;
		root.stats_score.t = '$v';
		return v;
	}

	private function set_money(v: Int): Int {
		money = v;
		root.stats_money.t = '$ $v';
		return v;
	}

}