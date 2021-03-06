﻿namespace RemObjects.Elements.RTL;

type
  SimpleCommandLineParser = public class
  public

    constructor (aArgs: not nullable array of String);
    begin
      var lSwitches := new Dictionary<String,String>;
      var lSettings := new Dictionary<String,String>;
      var lOtherParameters := new List<String>;
      for each a in aArgs do begin
        if a.StartsWith("--") then
          AddSwitch(a.Substring(2), lSwitches, lSettings)
        else if (Environment.OS = OperatingSystem.Windows) and a.StartsWith("/") then
          AddSwitch(a.Substring(1), lSwitches, lSettings)
        else
          lOtherParameters.Add(a);
      end;
      Switches := lSwitches;
      Settings := lSettings;
      OtherParameters := lOtherParameters;
    end;

    property Switches: ImmutableDictionary<String,String>; readonly;
    property Settings: ImmutableDictionary<String,String>; readonly;
    property OtherParameters: ImmutableList<String>; readonly;

  private

    method AddSwitch(aString: String; aSwitches: Dictionary<String,String>; aSettings: Dictionary<String,String>);
    begin
      var lSplit := aString.SplitAtFirstOccurrenceOf(":");
      var aName := lSplit[0].ToLower;
      if lSplit.Count = 2 then begin
        if aName = "setting" then begin
          lSplit := lSplit[1].SplitAtFirstOccurrenceOf("=");
          if lSplit.Count = 2 then begin
            aSettings[lSplit[0]] := lSplit[1];
          end;
        end
        else begin
          aSwitches[aName] := lSplit[1]
        end
      end
      else begin
        aSwitches[aName] := "";
      end;
    end;

  end;

end.