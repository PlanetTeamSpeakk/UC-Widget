using Toybox.Application;
using Toybox.System as Sys;
using Toybox.WatchUi;

class UCWidgetApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [new UCWidgetView(), new UCWidgetBehaviourDelegate()];
    }
    
    function onSettingsChanged() {
    	Sys.println("Settings changed, updating!");
		UCWidgetView.instance.initialize();
    	WatchUi.requestUpdate();
    }

}