using Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Time.Gregorian;

class UCWidgetBehaviourDelegate extends WatchUi.BehaviorDelegate {

	static var instance = null;
	var consumed = false;
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
			consume(false);
			return true;
		}
		return false;
	}
	
	function withinBounds(x, y, width, height, coords) {
		Sys.println("X0: " + x + ", Y0: " + y + ", X1: " + (x + width) + ", Y1: " + (y + height) + ", coords: " + coords);
		return coords[0] >= x and coords[0] <= x + width and coords[1] >= y and coords[1] <= y + height;
	}
	
	function onTap(click) {
		Sys.println("Tap: " + click.getCoordinates() + ", type: " + click.getType());
		var view = UCWidgetView.instance;
		if (consuming) {
			if (click.getCoordinates()[1] <= 48 and consuming) {
				view.up();
			} else if (click.getCoordinates()[1] >= view.getHeight() - 48 and consuming) {
				view.down();
			} else if (withinBounds(view.btn0X, view.upperBtnY, view.btnWidth, view.btnHeight, click.getCoordinates())) {
				view.weekDown();
			} else if (withinBounds(view.btn1X, view.upperBtnY, view.btnWidth, view.btnHeight, click.getCoordinates())) {
				view.weekUp();
			} else if (withinBounds(view.btn2X, view.lowerBtnY, view.btnWidth, view.btnHeight, click.getCoordinates())) {
				view.dayDown();
			} else if (withinBounds(view.btn3X, view.lowerBtnY, view.btnWidth, view.btnHeight, click.getCoordinates())) {
				view.dayUp();
			} else {
				consume(false);
			}
		} else {
			consume(false);
		}
	}
	
	function consume(fromView) {
		if (!fromView) {
			if (consuming) {
				WatchUi.popView(WatchUi.SLIDE_DOWN);
				consumed = true;
			} else {
				WatchUi.pushView(UCWidgetView.instance, self, WatchUi.SLIDE_UP);
			}
		}
		consuming = fromView ? false : !consuming;
		var view = UCWidgetView.instance;
		view.drawArrows = consuming;
		view.secondaryDaysOffset = 0;
		view.weekOffset = 0;
		view.dayNo = view.getWeekDay(Gregorian.info(Time.now(), Time.FORMAT_SHORT));
		view.momentOffset = 0;
		view.resetUC();
	}

}