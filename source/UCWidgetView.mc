using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Graphics;
using Toybox.Application;

class UCWidgetView extends WatchUi.View {

	static var instance = null;
	static const btnWidth = 30;
    static const btnHeight = 40;
	static const arrowButtonHeight = 36;
	hidden var hideCount = 0;
	hidden var width = -1;
	hidden var height = -1;
	var drawArrows = false;
	var secondaryDaysOffset = 0;
	var weekOffset = 0;
	var dayNo = -1;
	var btn0X = -1;
	var btn1X = -1;
	var btn2X = -1;
	var btn3X = -1;
	var upperBtnY = -1;
	var lowerBtnY = -1;
	var uc = "";
	var momentOffset = 0;
	hidden var arrowUp = null;
	hidden var arrowDown = null;
	hidden var app = Application.getApp();
	hidden var init = false;
	hidden var arcEnabled = true;
	hidden var backgroundColour = -1;
	hidden var textColour = -1;
	hidden var arcColour = -1;
	hidden var arcType = 0;
	hidden var buttonBackgroundColour = -1;

    function initialize() {
    	View.initialize();
        if (!init) {
        	instance = self;
        	init = true;
        }
        width = System.getDeviceSettings().screenWidth;
        height = System.getDeviceSettings().screenHeight;
        arcEnabled = app.getProperty("ArcToggle");
        backgroundColour = loadColourProperty("CustomBackgroundColour", "BackgroundColour");
        textColour = loadColourProperty("CustomTextColour", "TextColour");
        arcColour = loadColourProperty("CustomArcColour", "ArcColour");
        buttonBackgroundColour = loadColourProperty("CustomButtonBackgroundColour", "ButtonBackgroundColour");
        if (app.getProperty("Format").length() == 0) {
        	app.setProperty("Format", "{WEEK}-{DAY_LETTER}");
        }
        arcType = app.getProperty("ArcType");
        if (arcType == 0) {
        	arcType = System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE ? 3 : System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_SEMI_ROUND ? 2 : 1;
        }
        uc = format(app.getProperty("Format"));
        Sys.println("Done. " + app.getProperty("Format") + " => " + uc);
    }
    
    function getWidth() {
    	return width;
    }
    
    function getHeight() {
    	return height;
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
    
    function up() {
    	secondaryDaysOffset += 1;
    	resetAndUpdate();
    }
    
    function down() {
    	secondaryDaysOffset -= 1;
    	resetAndUpdate();
    }
    
    function weekUp() {
    	weekOffset += 1;
    	resetAndUpdate();
    }
    
    function weekDown() {
    	weekOffset -= 1;
    	resetAndUpdate();
    }
    
    function dayUp() {
    	dayNo += 1;
    	dayNo -= dayNo > 6 ? 7 : 0;
    	calcMomentOffset();
    	resetAndUpdate();
    }
    
    function dayDown() {
    	dayNo -= 1;
    	dayNo += dayNo < 0 ? 7 : 0;
    	calcMomentOffset();
    	resetAndUpdate();
    }
    
    function calcMomentOffset() {
    	momentOffset = dayNo == -1 ? 0 : (dayNo - getWeekDay(Gregorian.info(getMoment(false), Time.FORMAT_SHORT))) * 86400;
    }
        
    function resetUC() {
    	uc = format(Application.getApp().getProperty("Format"));
    }
    
    function resetAndUpdate() {
    	resetUC();
    	WatchUi.requestUpdate();
    }
    
    function getMoment(addMomentOffset) {
    	return Time.now().add(new Time.Duration(86400 * (app.getProperty("DayOffset") + secondaryDaysOffset) + 604800 * weekOffset + (addMomentOffset ? momentOffset : 0)));
    }
    
    function format(format) {
    	var moment = getMoment(true);
    	var info = Gregorian.info(moment, Time.FORMAT_SHORT);
    	var days = 0;
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
    	if (info.year % 4 == 0 and info.month > 2) {
    		days += 1;
    	}
    	days += info.day;
    	var week = getWeekNumber(moment);
    	var weekDay = getWeekDay(info);
    	var daysArray = new [7];
    	daysArray[0] = "A";
    	daysArray[1] = "B";
    	daysArray[2] = "C";
    	daysArray[3] = "D";
    	daysArray[4] = "E";
    	daysArray[5] = "F";
    	daysArray[6] = "G";
    	return replaceAllDict(format, {
    		"{WEEK}" => week,
    		"{DAY_LETTER}" => daysArray[weekDay],
    		"{DAY_NO}" => weekDay + 1,
    		"{DAY_MONTH}" => info.day,
    		"{YEAR}" => info.year,
    		"{YEAR_SHORT}" => info.year % 100,
    		"{MONTH_NO}" => info.month,
    		"{MONTH_SHORT}" => Gregorian.info(moment, Time.FORMAT_MEDIUM).month,
    		"{MONTH_LONG}" => Gregorian.info(moment, Time.FORMAT_LONG).month,
    		"{TIME_EPOCH}" => moment.value(),
    		"{TIME_24H}" => formatTime(Time.now(), false),
    		"{TIME_12H}" => formatTime(Time.now(), true)
    	}, true);
    }
    
    function getWeekDay(info) {
    	var weekDay = info.day_of_week - 1;
    	if (app.getProperty("FirstDay") == 1) {
    		weekDay -= 1;
    	}
    	return weekDay == -1 ? 6 : weekDay;
    }
    
    function yearToSeconds(year) {
    	year -= 1970;
    	var s = year * 365 * 86400;
    	s += Math.floor(year / 4) * 86400;
    	return s;
    }
    
    function getWeekNumber(moment) {
		var newYear = Gregorian.moment({
					:year => Gregorian.info(moment, Time.FORMAT_SHORT).year, 
					:month => 1, 
					:day => 1
				});
		var day = getWeekDay(Gregorian.info(newYear, Time.FORMAT_SHORT));
		var daynum = Math.floor((moment.value() - newYear.value())/86400) + 1;
		var weeknum = 0;
		if (day < 4) {
			weeknum = Math.floor((daynum+day-1)/7) + 1;
			if (weeknum > 52) {
				var nYear = Gregorian.info(Gregorian.moment({
					:year => Gregorian.info(moment, Time.FORMAT_SHORT).year, 
					:month => 1, 
					:day => 1
				}), Time.FORMAT_SHORT);
				var nday = nYear.day;
				nday = nday >= 0 ? nday : nday + 7;
				weeknum = nday < 4 ? 1 : 53;
			}
		} else {
			weeknum = Math.floor((daynum+day-1)/7);
		}
		return weeknum;
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
    
    function loadArrows(width, height) {
    	arrowUp = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.ArrowUp,
            :locX=>width/2-10,
            :locY=>arrowButtonHeight/2-5
        });
        arrowDown = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.ArrowDown,
            :locX=>width/2-10,
            :locY=>height+(arrowButtonHeight/2-41)
        });
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
        width = dc.getWidth();
        height = dc.getHeight();
        if (arrowUp == null or arrowDown == null) {
        	loadArrows(dc.getWidth(), dc.getHeight());
        }
        if (app.getProperty("UpperText").length() == 0) {
        	app.setProperty("UpperText", "UC of {DAY_MONTH} {MONTH_SHORT} is:");
        }
        dc.setColor(backgroundColour, backgroundColour);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        if (arcEnabled) {
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
        dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_SMALL) - 3, Graphics.FONT_SMALL, format(app.getProperty("UpperText")), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, uc, Graphics.TEXT_JUSTIFY_CENTER);
        if (app.getProperty("DayOffset") != 0) {
        	var s = app.getProperty("DayOffset").toString();
        	if (s.toNumber() > 0) {
        		s = "+" + s;
        	}
        	dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_SMALL) * 3 + 12, Graphics.FONT_SMALL, s, Graphics.TEXT_JUSTIFY_CENTER);
        }
        if (drawArrows) {
        	dc.setColor(buttonBackgroundColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillRectangle(0, 0, dc.getWidth(), arrowButtonHeight);
        	arrowUp.draw(dc);
        	dc.fillRectangle(0, dc.getHeight()-arrowButtonHeight, dc.getWidth(), arrowButtonHeight);
        	arrowDown.draw(dc);
        	
        	var fHeight  = dc.getFontHeight(Graphics.FONT_XTINY);
        	var fHeight1 = dc.getFontHeight(Graphics.FONT_MEDIUM);
        	var fHeight2 = dc.getFontHeight(Graphics.FONT_LARGE);
        	btn0X = width / 2 - dc.getTextDimensions("Week:", Graphics.FONT_XTINY)[0] / 2;
        	btn1X = width / 2 + dc.getTextDimensions("Week:", Graphics.FONT_XTINY)[0] / 2;
        	upperBtnY = fHeight * 2 + btnHeight / 2;
        	
        	dc.setColor(buttonBackgroundColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillEllipse(btn0X - btnWidth / 2 - 2, upperBtnY, btnWidth / 2, btnHeight / 2);
        	dc.fillEllipse(btn1X + btnWidth / 2 + 2, upperBtnY, btnWidth / 2, btnHeight / 2);
        	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        	dc.drawText(btn0X - btnWidth / 2 - 2, upperBtnY - fHeight1 / 2 - 2, Graphics.FONT_MEDIUM, "-", Graphics.TEXT_JUSTIFY_CENTER);
        	dc.drawText(btn1X + btnWidth / 2 + 2, upperBtnY - fHeight1 / 2 - 2, Graphics.FONT_MEDIUM, "+", Graphics.TEXT_JUSTIFY_CENTER);
        	
        	btn0X -= btnWidth - 2;
        	btn1X += 2;
        	upperBtnY -= btnHeight / 2;
        	btn2X = width / 2 - dc.getTextDimensions("Day:", Graphics.FONT_XTINY)[0] / 2;
        	btn3X = width / 2 + dc.getTextDimensions("Day:", Graphics.FONT_XTINY)[0] / 2;
        	var offset = height - arrowButtonHeight;
        	lowerBtnY = offset - fHeight * 2 + btnHeight / 2;
        	
        	dc.setColor(buttonBackgroundColour, Graphics.COLOR_TRANSPARENT);
        	dc.fillEllipse(btn2X - btnWidth / 2 - 2, lowerBtnY, btnWidth / 2, btnHeight / 2);
        	dc.fillEllipse(btn3X + btnWidth / 2 + 2, lowerBtnY, btnWidth / 2, btnHeight / 2);
        	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        	dc.drawText(btn2X - btnWidth / 2 - 2, offset - (fHeight * 2 + btnHeight / 2 - fHeight1 / 2 - 4), Graphics.FONT_MEDIUM, "-", Graphics.TEXT_JUSTIFY_CENTER);
        	dc.drawText(btn3X + btnWidth / 2 + 2, offset - (fHeight * 2 + btnHeight / 2 - fHeight1 / 2 - 4), Graphics.FONT_MEDIUM, "+", Graphics.TEXT_JUSTIFY_CENTER);
        	lowerBtnY -= btnHeight / 2;
        	
        	btn2X -= btnWidth - 2;
        	btn3X += 2;
        	
        	dc.setColor(textColour, Graphics.COLOR_TRANSPARENT);
        	dc.drawText(width / 2, fHeight * 2, Graphics.FONT_XTINY, "Week:", Graphics.TEXT_JUSTIFY_CENTER);
        	dc.drawText(width / 2, fHeight * 3, Graphics.FONT_XTINY, format("{WEEK}"), Graphics.TEXT_JUSTIFY_CENTER);
        	dc.drawText(width / 2, height - arrowButtonHeight - fHeight * 4 + fHeight2 + 4, Graphics.FONT_XTINY, "Day:", Graphics.TEXT_JUSTIFY_CENTER);
        	dc.drawText(width / 2, height - arrowButtonHeight - fHeight * 3 + fHeight2 + 4, Graphics.FONT_XTINY, format("{DAY_LETTER}"), Graphics.TEXT_JUSTIFY_CENTER);
        }
        System.println("Screen updated");
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	hideCount += 1;
    	Sys.println("Hide count: " + hideCount);
    	if (!UCWidgetBehaviourDelegate.instance.consumed && hideCount % 2 == 0) {
    		UCWidgetBehaviourDelegate.instance.consume(true);
    	}
    	UCWidgetBehaviourDelegate.instance.consumed = false;
    }

}
