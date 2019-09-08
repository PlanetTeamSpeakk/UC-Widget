using Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application;

class UCWidgetBehaviourDelegate extends WatchUi.BehaviorDelegate {

	static var instance = null;
	hidden var consuming = false;

	function initialize() {
		BehaviorDelegate.initialize();
		instance = self;
	}
	
	function onNextPage() {
		if (consuming) {
			UCWidgetView.instance.down();
		}
		return consuming;
	}
	
	function onPreviousPage() {
		if (consuming) {
			UCWidgetView.instance.up();
		}
		return consuming;
	}
	
	function onKey(key) {
		if (key.getKey() == WatchUi.KEY_ENTER) {
			consume();
			return true;
		}
		return false;
	}
	
	function onTap(click) {
		Sys.println("Tap: " + click.getCoordinates() + ", type: " + click.getType());
		if (click.getCoordinates()[1] <= 24 and consuming) {
			UCWidgetView.instance.up();
		} else if (click.getCoordinates()[1] >= UCWidgetView.instance.getHeight() - 24 and consuming) {
			UCWidgetView.instance.down();
		} else {
			consume();
		}
	}
	
	function consume() {
		Sys.println("Consuming: " + !consuming);
		if (consuming) {
			WatchUi.popView(WatchUi.SLIDE_DOWN);
		} else {
			WatchUi.pushView(UCWidgetView.instance, self, WatchUi.SLIDE_UP);
		}
		consuming = !consuming;
		UCWidgetView.instance.drawArrows = consuming;
		UCWidgetView.instance.secondaryDaysOffset = 0;
		UCWidgetView.instance.resetUC();
	}

}