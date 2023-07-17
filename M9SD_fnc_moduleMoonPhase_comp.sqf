M9SD_fnc_zeusComp_changeDateMoonPhaseModule = {
	M9SD_fnc_zeusCompHelipadCleanup = {
		comment "Determine if execution context is composition and delete the helipad.";
		if ((!isNull (findDisplay 312)) && (!isNil 'this')) then {
			if (!isNull this) then {
				if (typeOf this == 'Land_HelipadEmpty_F') then {
					deleteVehicle this;
				};
			};
		};
	};
	M9SD_fnc_maxMoon = {
		comment "Set the date to the fullest Moon in Arma 3.";
		private ['_date', '_globalEffect', '_showTransition'];
		comment "https://community.bistudio.com/wiki/moonPhase";
		_date = [4804,7,12,23,0]; comment "Offset -1hr from midnight.";
		_globalEffect = true;
		_showTransition = false;
		[_date, _globalEffect, _showTransition] call BIS_fnc_setDate; 
		date;
	};
	M9SD_fnc_moonPhaseEditorMP = {
		comment "M9: This is an edited version of 'A3\Functions_F\Debug\Utilities\utility_moonPhases.sqf'";
		disableSerialization;  

		private _fnc_addControlGroup =  
		{ 
			params ["_display", "_class", "_position", "_bgcolor", "_fgcolor"]; 
			private _ctrl = _display ctrlCreate [_class, -1]; 
			_ctrl ctrlSetPosition _position; 
			_ctrl ctrlSetBackgroundColor _bgcolor; 
			_ctrl ctrlSetTextColor _fgcolor; 
			_ctrl ctrlCommit 0; 
			_ctrl 
		}; 
		
		private _fnc_addControl =  
		{ 
			params ["_display", "_class", "_text", "_position", "_bgcolor", "_fgcolor", "_tip", "_enable", ["_ctrlGroup", controlNull], ["_idc", -1]]; 
			_text params ["_text", "_font", "_size"]; 
			
			private _ctrl = call 
			{ 
			if (isNull _ctrlGroup) exitWith 
			{ 
			_display ctrlCreate [_class, _idc]; 
			}; 
			_display ctrlCreate [_class, _idc, _ctrlGroup]; 
			}; 
			_ctrl ctrlSetPosition _position; 
			_ctrl ctrlSetBackgroundColor _bgcolor; 
			_ctrl ctrlSetTextColor _fgcolor; 
			if !(_text isEqualTo "") then {_ctrl ctrlSetText _text}; 
			if !(_font isEqualTo "") then {_ctrl ctrlSetFont _font}; 
			if (_size > 0) then {_ctrl ctrlSetFontHeight _size}; 
			_ctrl ctrlCommit 0; 
			_ctrl ctrlSetTooltip _tip; 
			_ctrl ctrlEnable _enable; 
			_ctrl; 
		}; 
		
		private ["_frame", "_close"]; 
		
		private _missionDisplay = displayNull; 
		private _functionDisplay = displayNull; 
		
		isNil 
		{  
			if (is3DEN) then 
			{ 
			_missionDisplay = findDisplay 316000;  
			if (isNull _missionDisplay) then {_missionDisplay = findDisplay 313};  
			}; 
			
			if (isNull _missionDisplay) then {_missionDisplay = findDisplay 49};  
			if (isNull _missionDisplay) then {_missionDisplay = findDisplay 46};  
			
			comment "M9: Allow it to open on top of Zeus interface:";

			if (!isNull (findDisplay 312)) then {
				_missionDisplay = findDisplay 312;
			};

			if (isNull _missionDisplay) exitWith  
			{ 
			["Cannot find suitable display for a Utility. Available displays: %1", allDisplays] call BIS_fnc_error; 
			}; 
			
			
			{ 
			if (_x getVariable ["lib\header.sqf", false]) then 
			{ 
			_x closeDisplay 2; 
			}; 
			} 
			forEach allDisplays; 
			
			_functionDisplay = _missionDisplay createDisplay "RscDisplayEmpty"; 
			_functionDisplay setVariable ["lib\header.sqf", true]; 
			
			
			[_functionDisplay, "RscText", ["","",0], [safeZoneXAbs, safeZoneY, safeZoneWAbs, safeZoneH], [0,0,0,0.9], [0,0,0,0], "", false] call _fnc_addControl; 
			_frame = [_functionDisplay, "RscEditMulti", ["","",0], [-0.01, -0.01, 1.02, 1.02], [0.1,0.1,0.1,1], [1,1,1,0.5], "", false] call _fnc_addControl; 
			
			_close = [_functionDisplay, "RscButtonMenu", ["X","PuristaMedium",0.03], [0.965, 0, 0.035, 0.04], [0.15,0.15,0.15,1], [1,1,1,1], "Exit", true] call _fnc_addControl; 
			_close ctrlSetEventHandler ["ButtonClick", "ctrlParent (_this select 0) closeDisplay 2"]; 
		}; 
		
		[_functionDisplay, "RscText", ["Enter Year","EtelkaMonospacePro",0.03], [-0.01,0.01,0.25,0.04], [0,0,0,0], [0.3,0.3,0.3,1], "Enter year for moon phase calculation", false] call _fnc_addControl; 

		

		comment "M9: Add text to instruct user to select the day and the month";

		[_functionDisplay, "RscText", ["Select Day","EtelkaMonospacePro",0.03], [-0.01,0.15,0.25,0.04], [0,0,0,0], [0.3,0.3,0.3,1], "Select the day of any month of the entered year.\n(Scroll down for more months/days)", false] call _fnc_addControl; 
		
		comment "M9: Add text to instruct user to select the hour of the day";

		[_functionDisplay, "RscText", ["Choose Hour","EtelkaMonospacePro",0.03], [-0.01,0.96,0.25,0.04], [0,0,0,0], [0.3,0.3,0.3,1], "Choose the hour of the day from 0 to 24.", false] call _fnc_addControl; 


		private _input = [_functionDisplay, "RscEdit", ["","EtelkaMonospacePro",0.03], [0,0.06,1,0.04], [0.05,0.05,0.05,1], [0.9,0.9,0.9,1], "", true] call _fnc_addControl; 
		_input ctrlAddEventHandler ["KeyDown",  
		{ 
			if (_this select 1 == 28) then 
			{ 
			_disp = ctrlParent (_this select 0); 

			comment "
			ctrlText (_disp getVariable '_input') execVM 'A3\Functions_F\Debug\Utilities\utility_moonPhases.sqf'; 
			";

			ctrlText (_disp getVariable "_input") spawn M9SD_fnc_moonPhaseEditorMP;

			playSound ["SoundClick", true]; 
			}; 
			
			false 
		}]; 
		
		private _selected = []; 
		
		_functionDisplay setVariable ["_selected", _selected]; 
		_functionDisplay setVariable ["_input", _input]; 
		
		private _show = [_functionDisplay, "RscButtonMenu", ["SHOW","",0], [0.8,0.11,0.2,0.04], [0.15,0.15,0.15,1], [1,1,1,1], "", true] call _fnc_addControl; 
		_show ctrlAddEventHandler ["ButtonClick",  
		{ 
			params ["_ctrl"]; 
			_ctrl ctrlRemoveAllEventHandlers "ButtonClick"; 
			_disp = ctrlParent _ctrl;   
			comment "
			ctrlText (_disp getVariable '_input') execVM 'A3\Functions_F\Debug\Utilities\utility_moonPhases.sqf'; 
			";

			ctrlText (_disp getVariable "_input") spawn M9SD_fnc_moonPhaseEditorMP;

		}]; 
		
		ctrlSetFocus _input; 
		
		private _ctrlGroup = [_functionDisplay, "RscControlsGroupNoHScrollbars", [0,0.2,1,0.72], [0,0,0,0], [0,0,0,0]] call _fnc_addControlGroup; 
		private _year = abs parseNumber param [0, str (date select 0)] min 10000; 
		if (_year isEqualTo 0) then {_year = date select 0}; 
		
		_input ctrlSetText str _year; 
		

		if (false) then {
			private _set = [_functionDisplay, "RscButtonMenu", ["SET","",0], [0.7,0.96,0.09,0.04], [0.15,0.15,0.15,1], [1,1,1,1], "Set last selected date", false] call _fnc_addControl; 
			_set ctrlAddEventHandler ["ButtonClick",  
			{ 
				_disp = ctrlParent (_this select 0); 
				_selected = _disp getVariable "_selected"; 
				_date = _selected param [count _selected - 1, controlNull] getVariable "_date"; 
				if (isNil "_date") exitWith {}; 
				_disp closeDisplay 2; 
				
				findDisplay 49 closeDisplay 2; 
				titleText [format ["Date set to %1", _date], "PLAIN DOWN"]; 
				setDate _date; 





			
			}]; 

			private _copy = [_functionDisplay, "RscButtonMenu", ["COPY","",0], [0.8,0.96,0.2,0.04], [0.15,0.15,0.15,1], [1,1,1,1], "Copy selected date(s) to clipboard", false] call _fnc_addControl; 
			_copy ctrlAddEventHandler ["ButtonClick",  
			{ 
				_dates = ctrlParent (_this select 0) getVariable "_selected" apply {_x getVariable "_date"}; 
				if (count _dates isEqualTo 1) then {_dates = _dates select 0}; 
				copyToClipboard str _dates; 
				playSound ["Topic_Selection", true]; 
			}]; 

			if (isMultiplayer && !isServer) then  
			{ 
				_copy ctrlEnable false; 
				_copy ctrlSetToolTip "In MP copyToClipboard is only available for the host"; 
			}; 
			
			_functionDisplay setVariable ["_set", _set]; 
			_functionDisplay setVariable ["_copy", _copy]; 



			comment "M9: Hide the original SET button.";

			_set ctrlShow false;
			_set ctrlEnable false;

			comment "M9: Delete the original COPY button.";

			ctrlDelete _copy;

		};


		


		comment "M9: Replace the original COPY button with new SET MOON PHASE button.";

		private _setNew = [_functionDisplay, "RscButtonMenu", ["SET MOON PHASE","",0], [0.75,0.96,0.25,0.04], [0.15,0.15,0.15,1], [1,1,1,1], "Set mission to selected date (moon phase).", false] call _fnc_addControl;  
		_setNew ctrlAddEventHandler ["ButtonClick",  
		{ 
			_disp = ctrlParent (_this select 0); 
			_selected = _disp getVariable "_selected"; 
			_date = _selected param [count _selected - 1, controlNull] getVariable "_date"; 
			if (isNil "_date") exitWith {}; 
			_disp closeDisplay 2; 
			findDisplay 49 closeDisplay 2; 
			comment "
			titleText [format ['Date set to %1\n(only you can see this message)', _date], 'PLAIN DOWN']; 
			";
			comment "setDate _date; ";
			comment "TODO:
			add controls for parameters for BIS_fnc_setDate 
			";

			private _global = true;
			private _transition = profileNameSpace getVariable ['M9_cbState_checkbox_transition', false];
			private _hour = sliderPosition (_disp getVariable "_slider_timeofday");
			
			private _minute = 0;
			if (_hour >= 24) then {_hour = 23; _minute = 59;};
			_date set [3, _hour];
			_date set [4, _minute];

			[_date, _global, _transition] call BIS_fnc_setDate;

			private _title = "Moon Phase Module";
			private _type = typeOf _obj;

			getOrdinalIndicator = {
				private["_number", "_ordinalIndicator"];

				_number = _this;
				_ordinalIndicator = "th";

				if (_number > 0) then {
					_numberStr = str(_number);
					_lastChar = _numberStr select [count _numberStr - 1, count _numberStr];
					_secondLastChar = _numberStr select [count _numberStr - 2, count _numberStr - 1];

					if (_lastChar == "1" && {_secondLastChar != "1"}) then {
						_ordinalIndicator = "st";
					} else {
						if (_lastChar == "2" && {_secondLastChar != "1"}) then {
							_ordinalIndicator = "nd";
						} else {
							if (_lastChar == "3" && {_secondLastChar != "1"}) then {
								_ordinalIndicator = "rd";
							};
						};
					};
				};

				_ordinalIndicator;
			};
			
			comment "// Function to convert a date array to text format";
			convertDateToText = {
				private["_date", "_monthNames", "_month", "_day", "_year", "_hour", "_minute", "_textDate", "_textTime"];

				comment "// Define month names";
				_monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

				comment "// Extract date components";
				_date = _this;
				_year = _date select 0;
				_month = _date select 1;
				_day = _date select 2;
				_hour = _date select 3;
				_minute = _date select 4;

				_hourAndMinutes = _hour + (_minute / 60);
				

				comment "// Convert month, day, and year to text format";
				_textDate = format["%1 %2, %3", _monthNames select (_month - 1), str(_day) + (_day call getOrdinalIndicator), _year];

				comment "// Convert hour and minute to text format";
				_textTime = [_hourAndMinutes, 'HH:MM'] call BIS_fnc_timeToString;

				comment "// Return the combined text format";
				format["%1\n%2", _textDate, _textTime];
				[_textDate, _textTime];
			};

			comment "// Example usage
			_dateArray = [2035, 1, 9, 2, 30];
			_textFormat = _dateArray call convertDateToText;
			hint _textFormat;";

		
			private _dateStrArr = _date call convertDateToText;
			private _dateStr = _dateStrArr # 0;
			private _timeStr = _dateStrArr # 1;
			

			private _msg = format ["The date has been changed to %1.", _date];
			systemChat format ["[ %1 ] : %2", _title, _msg];
			[_title, _msg, 7] call BIS_fnc_curatorHint;
			[ 
				[ 
					[_dateStr, nil, 0.5],
					[_timeStr, nil, 35]
				], 
				0, 
				(safeZoneY + safeZoneH / 2) + (safeZoneY + safeZoneH * 0.44) 
			] spawn BIS_fnc_typeText;
		}]; 
		_setNew ctrlSetText 'LOADING...';
		_setNew ctrlShow true;
		_setNew ctrlEnable false;


		private _cnt = 0; 
		private _month = 0; 
		private _months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", " December"]; 
		private _chkX = 0.03/4*3; 
		
		private ["_date", "_phase", "_nextItemY", "_checkbox"]; 
		
		for "_i" from dateToNumber [_year, 1, 1, 0, 0] to dateToNumber [_year, 12, 31, 23, 59] step 1/365 do 
		{ 
			_date = numberToDate [_year, _i]; 
			_phase = moonPhase _date; 
			
			if (_date select 1 > _month) then 
			{ 
			[_functionDisplay, "RscTextMulti", [format [" %1 %2", _months select _month, _year], "PuristaMedium", 0.06], [0,_cnt * 0.04,0.98,0.07], [0.15,0.15,0.15,1], [1,1,1,1], "", false, _ctrlGroup]  call _fnc_addControl; 
			_month = _month + 1; 
			_cnt = _cnt + 2; 
			}; 
			
			_nextItemY = _cnt * 0.04; 
			
			[_functionDisplay, "RscText", [str (_date select 2), "PuristaMedium", 0.03], [0.2,_nextItemY,0.2,0.03], [0,0,0,0], [1,1,1,1], "", false, _ctrlGroup]  call _fnc_addControl; 
			
			isNil  
			{ 
				_checkbox = [_functionDisplay, "RscCheckBox", ["","",0], [0.27,_nextItemY,_chkX,0.03], [1,1,1,1], [1,1,1,1], str _date, true, _ctrlGroup] call _fnc_addControl; 
				comment "M9: Make sure they all load before allowing user to select.";
				_checkbox ctrlEnable false;
				_checkbox setVariable ["_date", _date]; 
				_checkbox ctrlSetEventHandler ["CheckedChanged", " 
				_ctrl = _this select 0; 
				_disp = ctrlParent _ctrl; 
				_selected = _disp getVariable ""_selected""; 
				_copy = _disp getVariable ""_copy""; 
				playSound [""SoundClick"", true]; 
					
				if (_this select 1 > 0) exitWith  
				{ 
					_selected pushBack _ctrl; 
					if !(_selected isEqualTo []) then  
					{ 
					_disp getVariable ""_set"" ctrlEnable true; 
					if (isServer) then {_copy ctrlEnable true}; 
					}; 
					_copy ctrlSetText format [""COPY %1"", count _selected]; 
				}; 
					
				_selected deleteAt (_selected find _ctrl); 
				
				if (_selected isEqualTo []) exitWith 
				{ 
					_disp getVariable ""_set"" ctrlEnable false; 
					_copy ctrlEnable false; 
					_copy ctrlSetText ""COPY""; 
				}; 
					
				_copy ctrlSetText format [""COPY %1"", count _selected]; 
				"]; 
			}; 
			
			[_functionDisplay, "RscProgress", ["","",0], [0.3,_nextItemY,0.5,0.03], [1,1,1,1], [1,1,1,1], "", false, _ctrlGroup] call _fnc_addControl 
			progressSetPosition _phase; 
			
			[_functionDisplay, "RscText", [_phase toFixed 3,"PuristaMedium",0.03], [0.3 + 0.5 * _phase,_nextItemY,0.1,0.03], [0,0,0,0], [1,1,1,1], "", false, _ctrlGroup] call _fnc_addControl; 
			
			_cnt = _cnt + 1; 
		}; 

		comment "debugging";

		if (false) then {
			_setNew ctrlSetTooltip format ["%1", count (_functionDisplay call {
				private _cbs = [];
				{
					if ((toLower (ctrlClassName _x)) == 'rsccheckbox') then {
						_cbs pushBack _x;
					};
				} forEach allControls _this;
				_cbs;
			})];
		};

		comment "M9: Make it so you can only select one date.";

		{
			if ((toLower (ctrlClassName _x)) == 'rsccheckbox') then {
				_x ctrlAddEventHandler ['CheckedChanged', {
					params ["_control", "_checked"];
					private _oppositeChecked = if (_checked == 0) then {_checked = false;true} else {_checked = true;false};
					{
						if (_x == _control) then {continue};
						if ((toLower (ctrlClassName _x)) == 'rsccheckbox') then {
							if !(_x getVariable ['isParamCb', false]) then {
								_x ctrlSetChecked _oppositeChecked;
								_x cbSetChecked _oppositeChecked;
							};
						};
					} forEach allControls (ctrlParent _control);
					_control ctrlSetChecked _checked;
					_control cbSetChecked _checked;
				}];
				_x ctrlEnable true;
			};
		} forEach allControls _functionDisplay;

		comment "Add custom checkboxes to control set date function";

		if (false) then {

		} else {

			private _global
		};

		private _globalTip = 'Globally execute setDate command.\n(Make change apply to all players)';

		_checkbox_global = [_functionDisplay, "RscCheckBox", ["Global","",0], [0.64,0.96,0.03,0.04], [1,1,1,1], [1,1,1,1], _globalTip, false] call _fnc_addControl; 
		_functionDisplay setVariable ["_checkbox_global", _checkbox_global];
		_checkbox_global setVariable ['isParamCb', true];
		_checkbox_global ctrlAddEventHandler ["CheckedChanged", { 
			params ["_control", "_checked"];
			comment "todo";
		}];
		_checkbox_global cbSetChecked true;

		_textbox_global = [_functionDisplay, "RscText", ["Global","",0], [0.67,0.96,0.08,0.04], [0.15,0.15,0.15,0], [0.4,0.4,0.4,0.7], _globalTip, false] call _fnc_addControl;  

		private _transitionTip = 'Show a transition effect instead of an immediate skip.\n(Black screen with white text)\n\nNOTE:\n* Does not show up for Zeuses.\n* Does not show if going backward in time.';

		_checkbox_transition = [_functionDisplay, "RscCheckBox", ["Transition","",0], [0.505,0.96,0.03,0.04], [1,1,1,1], [1,1,1,1], _transitionTip, true] call _fnc_addControl; 
		_functionDisplay setVariable ["_checkbox_transition", _checkbox_transition];
		_checkbox_transition setVariable ['isParamCb', true];
		_checkbox_transition ctrlAddEventHandler ["CheckedChanged", { 
			params ["_control", "_checked"];
			profileNameSpace setVariable ['M9_cbState_checkbox_transition', if (_checked == 0) then {false} else {true}];
			saveProfileNamespace;
		}];
		_checkbox_transition cbSetChecked (profileNameSpace getVariable ['M9_cbState_checkbox_transition', false]);

		_textbox_transition = [_functionDisplay, "RscText", ["Transition","",0], [0.535,0.96,0.1,0.04], [0.15,0.15,0.15,0], [1,1,1,1], _transitionTip, false] call _fnc_addControl;  

		comment "Add Time slider";

		private _timeTip = 'Select the time (hour) of day.\n(from 0 to 24)';

		comment "
		_textbox_time = [_functionDisplay, 'RscText', ['Time','',0], [0.44,0.96,0.06,0.04], [0.15,0.15,0.15,0], [1,1,1,1], _timeTip, false] call _fnc_addControl;
		";




		_slider_timeofday = [_functionDisplay, "RscXSliderH", ["","",0], [0.136,0.966,0.299,0.03], [0.15,0.15,0.15,0], [1,1,1,1], _timeTip, true] call _fnc_addControl;
		_functionDisplay setVariable ['_slider_timeofday', _slider_timeofday];
		
		_slider_timeofday ctrlSetActiveColor [1,1,1,1];

		_slider_timeofday sliderSetRange [0, 24];

		_slider_timeofday sliderSetSpeed [1, 1, 1];

		_slider_timeofday sliderSetPosition 0;


		if (False) then {
		_frame_timeDisplay = [_functionDisplay, "RscFrame", ["","",0], [0.393,0.96,0.065,0.04], [0.15,0.15,0.15,0], [1,1,1,1], _timeTip, false] call _fnc_addControl;
		_frame_timeDisplay ctrlShow false;
		};
		
		_textbox_timeDisplay = [_functionDisplay, "RscText", ["00:00","RobotoCondensedLight",0], [0.440,0.96,0.06,0.04], [0.15,0.15,0.15,0], [1,1,1,1], _timeTip, false] call _fnc_addControl;

		_slider_timeofday setVariable ['_textbox_timeDisplay', _textbox_timeDisplay];

		_slider_timeofday ctrlAddEventHandler ['sliderposchanged', {
			params ["_control", "_newValue"];
			private _textbox = _control getVariable '_textbox_timeDisplay';
			comment "
			private _zeroHour = if (_newValue < 10) then {
				'0' + str(_newValue)
			} else {
				str(_newValue)
			};
			_textbox ctrlSetText format ['%1:00', _zeroHour];
			";
			_textbox ctrlSetText format ['%1', [_newValue, 'HH:MM'] call BIS_fnc_timeToString];
		}];

		_textbox_timeDisplay ctrlSetFade 1;
		_slider_timeofday ctrlSetFade 1;
		_checkbox_global ctrlSetFade 1;
		_checkbox_transition ctrlSetFade 1;
		_textbox_global ctrlSetFade 1;
		_textbox_transition ctrlSetFade 1;

		_textbox_timeDisplay ctrlCommit 0;
		_slider_timeofday ctrlCommit 0;
		_checkbox_global ctrlCommit 0;
		_checkbox_transition ctrlCommit 0;
		_textbox_global ctrlCommit 0;
		_textbox_transition ctrlCommit 0;

		_textbox_timeDisplay ctrlSetFade 0;
		_slider_timeofday ctrlSetFade 0;
		_checkbox_global ctrlSetFade 0;
		_checkbox_transition ctrlSetFade 0;
		_textbox_global ctrlSetFade 0;
		_textbox_transition ctrlSetFade 0;
		
		_textbox_timeDisplay ctrlCommit 1;
		_slider_timeofday ctrlCommit 1;
		_checkbox_global ctrlCommit 1;
		_checkbox_transition ctrlCommit 1;
		_textbox_global ctrlCommit 1;
		_textbox_transition ctrlCommit 1;

		comment "M9: Enable button now loading is done.";

		_setNew ctrlShow false;
		_setNew ctrlEnable true;
		_setNew ctrlSetText 'SET MOON PHASE';
		_setNew ctrlSetBackgroundColor [0,0.5,0,0.7];
		_setNew ctrlSetFade 1;
		_setNew ctrlCommit 0;
		_setNew ctrlShow true;
		_setNew ctrlSetFade 0;
		_setNew ctrlCommit 2;

		playSound ['additemok', true];
		playSound ['additemok', false];
	};
	call M9SD_fnc_zeusCompHelipadCleanup;
	[] spawn M9SD_fnc_moonPhaseEditorMP;
}; call M9SD_fnc_zeusComp_changeDateMoonPhaseModule;