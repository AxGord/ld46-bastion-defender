final class Stats {

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
		score = 0;
		money = 10;
		liveTimer.reset();
		liveTimer.start();
	}

	public function stopGame(): Void {
		root.stats.visible = false;
		liveTimer.stop();
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