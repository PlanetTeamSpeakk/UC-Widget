using Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application;

class UCWidgetBehaviourDelegate extends WatchUi.BehaviorDelegate {

	static var instance = null;
	var consumed = false;
	var noPop = false;
	var consuming = false;

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
		if (click.getCoordinates()[1] <= 48 and consuming) {
			UCWidgetView.instance.up();
		} else if (click.getCoordinates()[1] >= UCWidgetView.instance.getHeight() - 48 and consuming) {
			UCWidgetView.instance.down();
		} else {
			consume();
		}
	}
	
	function consume() {
		Sys.println("Consuming: " + consuming + " nopop: " + noPop);
		if (consuming) {
			if (!noPop) {
				WatchUi.popView(WatchUi.SLIDE_DOWN);
			}
			consumed = true;
			noPop = false;
		} else {
			WatchUi.pushView(UCWidgetView.instance, self, WatchUi.SLIDE_UP);
		}
		consuming = !consuming;
		UCWidgetView.instance.drawArrows = consuming;
		UCWidgetView.instance.secondaryDaysOffset = 0;
		UCWidgetView.instance.resetUC();
	}

}