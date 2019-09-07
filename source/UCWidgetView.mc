using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Graphics;
using Toybox.Application;

class UCWidgetView extends WatchUi.View {

	static var instance = null;
	hidden var s = "";
	hidden var app = Application.getApp();
	hidden var init = false;
	hidden var arcEnabled = true;
	hidden var backgroundColour = -1;
	hidden var textColour = -1;
	hidden var arcColour = -1;
	hidden var arcType = 0;

    function initialize() {
    	instance = self;
        if (!init) {
        	View.initialize();
        	init = true;
        }
        arcEnabled = app.getProperty("ArcToggle");
        backgroundColour = loadColourProperty("CustomBackgroundColour", "BackgroundColour");
        textColour = loadColourProperty("CustomTextColour", "TextColour");
        arcColour = loadColourProperty("CustomArcColour", "ArcColour");
        if (app.getProperty("Format").length() == 0) {
        	app.setProperty("Format", "{WEEK}-{DAY_LETTER}");
        }
        arcType = app.getProperty("ArcType");
        if (arcType == 0) {
        	arcType = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE ? 3 : System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_SEMI_ROUND ? 2 : 1;
        }
        s = format(app.getProperty("Format"));
        Sys.println("Done. " + app.getProperty("Format") + " => " + s);
    }
    
    function loadColourProperty(name, fallback) {
    	var colour = -1;
    	if (app.getProperty(name).length() != 0) {
        	colour = stringToHexadecimalNumber(app.getProperty(name));
        }
        if (colour == -1 or colour == null) {
        	colour = app.getProperty(fallback);
        }
        return colour;
    }
    
    function stringToHexadecimalNumber(s) {
    	if (s.substring(0, 1).equals("#")) {
    		s = s.substring(1, s.length());
    	} else if (s.substring(0, 2).equals("0x") or s.substring(0, 2).equals("0X")) {
    		s = s.substring(2, s.length());
    	}
    	return ("0x" + s.substring(0, 6)).toNumberWithBase(16);
    }
    
    function format(format) {
		Sys.println("Getting time info.");
		var moment = Time.now().add(new Time.Duration(86400 * app.getProperty("DayOffset")));
    	var info = Gregorian.info(moment, Time.FORMAT_SHORT);
    	Sys.println(moment.value());
    	var days = 0;
    	Sys.println("Calculating days.");
    	switch (info.month - 1) {
    	case 11:
    		days += 30;
    	case 10:
    		days += 31;
    	case 9:
    		days += 30;
    	case 8:
    		days += 31;
    	case 7:
    		days += 31;
    	case 6:
    		days += 30;
    	case 5:
    		days += 31;
    	case 4:
    		days += 30;
    	case 3:
    		days += 31;
    	case 2:
    		days += 28;
    	case 1:
    		days += 31;
    	}
    	Sys.println("Checking leap year.");
    	if (info.year % 4 == 0 and info.month > 2) {
    		days += 1;
    	}
    	days += info.day;
    	Sys.println(days);
    	var week = Math.floor(days / 7) + 1;
    	var weekDay = info.day_of_week - 1;
    	if (app.getProperty("FirstDay") == 1) {
    		weekDay -= 1;
	    	if (weekDay == -1) {
	    		weekDay = 6;
	    	}
    	}
    	var daysArray = new [7];
    	daysArray[0] = "A";
    	daysArray[1] = "B";
    	daysArray[2] = "C";
    	daysArray[3] = "D";
    	daysArray[4] = "E";
    	daysArray[5] = "F";
    	daysArray[6] = "G";
    	Sys.println("Formatting.");
    	return replaceAllDict(format, {
    		"{WEEK}" => week,
    		"{DAY_LETTER}" => daysArray[weekDay],
    		"{DAY_NO}" => weekDay + 1,
    		"{DAY_MONTH}" => info.day,
    		"{YEAR}" => info.year,
    		"{YEAR_SHORT}" => info.year % 100,
    		"{MONTH_NO}" => info.month,
    		"{MONTH_SHORT}" => Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).month,
    		"{MONTH_LONG}" => Gregorian.info(Time.now(), Time.FORMAT_LONG).month,
    		"{TIME_EPOCH}" => Time.now().value(),
    		"{TIME_24H}" => formatTime(Time.now(), false),
    		"{TIME_12H}" => formatTime(Time.now(), true)
    	}, true);
    }
    
    function formatTime(moment, meridiem) {
    	if (moment instanceof Time.Moment) {
    		moment = Gregorian.info(moment, Time.FORMAT_SHORT);
    	}
    	if (moment instanceof Gregorian.Info) {
    		var s = "";
    		if (moment.hour < 10) {
    			s += "0";
    		}
    		if (meridiem) {
    			var hour = moment.hour;
    			if (hour > 12) {
    				hour -= 12;
    			}
    			s += hour;
    		} else {
    			s += moment.hour;
    		}
    		s += ":";
    		if (moment.min < 10) {
    			s += "0";
    		}
    		s += moment.min;
    		if (meridiem) {
    			if (moment.hour < 12) {
    				s += " AM";
    			} else {
    				s += " PM";
    			}
    		}
    		return s;
    	} else {
    		return null;
    	}
    }
    
    // Replace a certain target string in string s with the given replacement.
    function replace(s, target, replacement) {
    	if (s == null or target == null or s.find(target.toString()) == null) {
    		return s;
    	} else {
    		if (replacement == null) {
    			replacement = "";
    		}
    		target = target.toString();
    		replacement = replacement.toString();
    		var s1 = s.substring(0, s.find(target));
    		var s2 = s.substring(s.find(target) + target.length(), s.length());
    		return s1 + replacement + s2;
    	}
    }
    
    function replaceAll(s, target, replacement) {
    	if (s == null or target == null or s.find(target.toString()) == null) {
    		return s;
    	} else {
    		if (replacement == null) {
    			replacement = "";
    		}
    		target = target.toString();
    		replacement = replacement.toString();
    		var strings = new [0];
    		while (s.find(target) != null) {
    			strings.add(s.substring(0, s.find(target)));
    			s = s.substring(s.find(target) + target.length(), s.length());
    		}
    		var suffix = s;
    		s = "";
    		for (var i = 0; i < strings.size(); i += 1) {
    			s += strings[i] + replacement;
    		}
    		return s + suffix;
    	}
    }
    
    function replaceAllDict(s, dict, all) {
    	if (s == null or dict == null) {
    		return s;
    	} else {
    		for (var i = 0; i < dict.keys().size(); i += 1) {
    			if (all) {
    				s = replaceAll(s, dict.keys()[i], dict.get(dict.keys()[i]));
    			} else {
    				s = replace(s, dict.keys()[i], dict.get(dict.keys()[i]));
    			}
    		}
    		return s;
    	}
    }
    
    function min(a, b) {
    	return a > b ? b : a;
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        if (app.getProperty("UpperText").length() == 0) {
        	app.setProperty("UpperText", "UC of {DAY_MONTH} {MONTH_SHORT} is:");
        }
        dc.setColor(backgroundColour, backgroundColour);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        if (arcEnabled) {
        	System.println("Drawing arc");
        	var arcWidth = app.getProperty("ArcWidth");
        	dc.setColor(arcColour, Graphics.COLOR_TRANSPARENT);
        	dc.setPenWidth(arcWidth);
        	var i = min(arcWidth / 4, 3);
        	if (arcType != 3) {
        		dc.drawArc(dc.getWidth() / 2, dc.getHeight() / 2, dc.getWidth() / 2 - arcWidth / 2 + i, Graphics.ARC_CLOCKWISE, 0, 0);
        	} // A combination of these two creates the semi-round one.
        	if (arcType != 1) {
        		dc.drawRectangle(i, i, dc.getWidth() - i * 2, dc.getHeight() - i * 2); // Pfft, 'arc'.
        	}
        }
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_SMALL) - 3, Graphics.FONT_SMALL, format(app.getProperty("UpperText")), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, s, Graphics.TEXT_JUSTIFY_CENTER);
        if (app.getProperty("DayOffset") != 0) {
        	var s = app.getProperty("DayOffset").toString();
        	if (s.toNumber() > 0) {
        		s = "+" + s;
        	}
        	dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_SMALL) * 3 - 6, Graphics.FONT_SMALL, s, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
