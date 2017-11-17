﻿namespace RemObjects.Elements.RTL;

interface

{$IF ECHOES OR (TOFFEE AND MACOS)}
type
  {$IF JAVA}
  PlatformTask = {$ERROR Unsupported platform};
  {$ELSEIF ECHOES}
  PlatformTask = System.Diagnostics.Process;
  {$ELSEIF ISLAND}
  PlatformTask = {$ERROR Unsupported platform};
  {$ELSEIF TOFFEE}
  PlatformTask = Foundation.NSTask;
  {$ENDIF}

  Task = public class mapped to PlatformTask
  private
    class method QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;
    class method SetUpTask(aCommand: String; aArguments: array of String; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Task;
    {$IF TOFFEE}
    class method processStdOutData(rawString: String) lastIncompleteLogLine(out lastIncompleteLogLine: String) callback(callback: block(aLine: String));
    {$ENDIF}
  protected
  public

    class method JoinArgumentsCommandLine(aArguments: not nullable array of String): not nullable String;
    class method SplitQuotedArgumentString(aArgumentString: not nullable String): not nullable array of String;

    class method StringForCommand(aCommand: not nullable String) Parameters(aArguments: nullable array of String): not nullable String;

    method WaitFor; inline;
    method Start; inline;
    method Stop; inline;
    property ExitCode: Integer read {$IF ECHOES}mapped.ExitCode{$ELSEIF TOFFEE}mapped.terminationStatus{$ENDIF};

    class method Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer;
    class method Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer;
    class method Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer;
    class method Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
    class method RunAsync(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Task;
  end;
{$ENDIF}
implementation
{$IF ECHOES OR (TOFFEE AND MACOS)}

method Task.WaitFor;
begin
  {$IF ECHOES}
  mapped.WaitForExit();
  {$ELSEIF TOFFEE}
  mapped.waitUntilExit();
  {$ENDIF}
end;

method Task.Start;
begin
  {$IF ECHOES}
  mapped.Start();
  {$ELSEIF TOFFEE}
  mapped.launch();
  {$ENDIF}
end;

method Task.Stop;
begin
  {$IF ECHOES}
  mapped.Kill();
  {$ELSEIF TOFFEE}
  mapped.terminate();
  {$ENDIF}
end;

//
// Static Methods
//

class method Task.Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil): Integer;
begin
  using lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory) do begin
    lTask.Start();
    lTask.WaitFor();
    result := lTask.ExitCode;
  end;
end;

class method Task.Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String): Integer;
begin
  var lIgnoreStdErr: String;
  result := Run(aCommand, aArguments, aEnvironment, aWorkingDirectory, out aStdOut, out lIgnoreStdErr);
end;

class method Task.Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; out aStdOut: String; out aStdErr: String): Integer;
begin
  {$IF ECHOES}
  using lDone := new System.Threading.AutoResetEvent(false) do begin
    var lStdOut := new StringBuilder;
    var lStdErr := new StringBuilder;
    var lResult: Integer;
    Task.RunAsync(aCommand, aArguments, aEnvironment, aWorkingDirectory, method (aLine: String) begin
      lStdOut.Append(Environment.LineBreak+aLine);
    end, method (aLine: String) begin
      lStdErr.Append(Environment.LineBreak+aLine);
    end, method(aExitCode: Integer) begin
      lResult := aExitCode;
      lDone.Set();
    end);
    lDone.WaitOne();
    aStdOut := lStdOut.ToString();
    aStdErr := lStdErr.ToString();
    result := lResult;
  end;
  {$ELSE IF TOFFEE}
  using lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory) do begin
    (lTask as NSTask).standardOutput := NSPipe.pipe();
    (lTask as NSTask).standardError := NSPipe.pipe();
    var stdOut := (lTask as NSTask).standardOutput.fileHandleForReading;
    var stdErr := (lTask as NSTask).standardError.fileHandleForReading;
    lTask.Start();
    lTask.WaitFor();
    aStdOut := "";
    aStdErr := "";
    var d := stdOut.availableData();
    while (d ≠ nil) and (d.length() > 0) do begin
      aStdOut := aStdOut+new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding);
      d := stdOut.availableData();
    end;
    stdOut.closeFile();
    d := stdErr.availableData();
    while (d ≠ nil) and (d.length() > 0) do begin
      aStdErr := aStdErr+new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding);
      d := stdErr.availableData();
    end;
    stdErr.closeFile();
  end;
  {$ENDIF}
end;

class method Task.Run(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil): Integer;
begin
  using lTask := RunAsync(aCommand, aArguments, aEnvironment, aWorkingDirectory, aStdOutCallback, aStdErrCallback) do begin
    lTask.WaitFor();
    result := lTask.ExitCode;
  end;
end;

class method Task.RunAsync(aCommand: not nullable String; aArguments: array of String := nil; aEnvironment: nullable ImmutableStringDictionary := nil; aWorkingDirectory: nullable String := nil; aStdOutCallback: block(aLine: String); aStdErrCallback: block(aLine: String) := nil; aFinishedCallback: block(aExitCode: Integer) := nil): Task;
begin
  var lTask := SetUpTask(aCommand, aArguments, aEnvironment, aWorkingDirectory);
  result := lTask;

  {$IF ECHOES}
  var lOutputWaitHandle := if assigned(aFinishedCallback) then new System.Threading.AutoResetEvent(false);
  var lErrorWaitHandle := if assigned(aFinishedCallback) then new System.Threading.AutoResetEvent(false);
  if assigned(aStdOutCallback) then begin
    (lTask as PlatformTask).StartInfo.RedirectStandardOutput := true;
    (lTask as PlatformTask).OutputDataReceived += method (sender: Object; e: System.Diagnostics.DataReceivedEventArgs) begin
      if assigned(e.Data) then
        aStdOutCallback(e.Data)
      else
        lOutputWaitHandle:&Set();
    end;
    //(lTask as PlatformTask).BeginOutputReadLine();
  end;
  if assigned(aStdErrCallback) then begin
    (lTask as PlatformTask).StartInfo.RedirectStandardError := true;
    (lTask as PlatformTask).ErrorDataReceived += method (sender: Object; e: System.Diagnostics.DataReceivedEventArgs) begin
      if assigned(e.Data) then
        aStdErrCallback(e.Data)
      else
        lErrorWaitHandle:&Set();
    end;
    //(lTask as PlatformTask).BeginErrorReadLine();
  end;
  if assigned(aFinishedCallback) then begin
    (lTask as PlatformTask).Exited += method (sender: Object; e: System.EventArgs) begin
      lOutputWaitHandle.WaitOne();
      lOutputWaitHandle:Dispose();
      lErrorWaitHandle.WaitOne();
      lErrorWaitHandle:Dispose();
      aFinishedCallback(lTask.ExitCode);
    end;
  end;
  lTask.Start();

  if assigned(aStdOutCallback) then
    (lTask as PlatformTask).BeginOutputReadLine();
  if assigned(aStdErrCallback) then
    (lTask as PlatformTask).BeginErrorReadLine();

  {$ELSEIF TOFFEE}
  if assigned(aStdOutCallback) then
    (lTask as PlatformTask).standardOutput := NSPipe.pipe();
  if assigned(aStdErrCallback) then
    (lTask as PlatformTask).standardError := NSPipe.pipe();

  if assigned(aStdOutCallback) then
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> begin
      var stdOut := (lTask as NSTask).standardOutput.fileHandleForReading;
      var lastIncompleteLogLine: String;
      while (lTask as PlatformTask).isRunning do begin
        using autoreleasepool do begin
          var d := stdOut.availableData;
          if (d ≠ nil) and (d.length > 0) then
            processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdOutCallback);
          NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
        end;
      end;
      lTask.WaitFor();
      var d := stdOut.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdOutCallback);
        d := stdOut.availableData;
      end;
      stdOut.closeFile();
    end);

  if assigned(aStdErrCallback) then
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), () -> begin
      var stdErr := (lTask as NSTask).standardError.fileHandleForReading;
      var lastIncompleteLogLine: String;
      while (lTask as PlatformTask).isRunning do begin
        using autoreleasepool do begin
          var d := stdErr.availableData;
          if (d ≠ nil) and (d.length > 0) then
            processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdErrCallback);
          NSRunLoop.currentRunLoop().runUntilDate(NSDate.date);
        end;
      end;
      lTask.WaitFor();
      var d := stdErr.availableData;
      while (d ≠ nil) and (d.length > 0) do begin
        processStdOutData(new NSString withData(d) encoding(NSStringEncoding.NSUTF8StringEncoding)) lastIncompleteLogLine(out lastIncompleteLogLine) callback(aStdErrCallback);
        d := stdErr.availableData;
      end;
      stdErr.closeFile();
    end);

  lTask.Start();

  if assigned(aFinishedCallback) then async begin
    lTask.WaitFor();
    aFinishedCallback(lTask.ExitCode);
  end;
  {$ENDIF}
end;

{$IF TOFFEE}
class method Task.processStdOutData(rawString: String) lastIncompleteLogLine(out lastIncompleteLogLine: String) callback(callback: block(aLine: string));
begin
  if length(rawString) > 0 then begin
    if length(rawString) > 0 then begin
      rawString := lastIncompleteLogLine+rawString;
      lastIncompleteLogLine := nil;
    end;
    var lines := rawString.Split(Environment.LineBreak);
    for i: Int32 := 0 to lines.Count-1 do begin
      var s := lines[i];
      if (i = lines.Count-1) and not s.EndsWith(Environment.LineBreak) then begin
        if length(s) > 0 then
          lastIncompleteLogLine := s;
        break;
      end;
      callback(s);
    end;
  end;
end;
{$ENDIF}

class method Task.SetUpTask(aCommand: String; aArguments: array of String; aEnvironment: ImmutableStringDictionary; aWorkingDirectory: String): Task;
begin
  {$IF ECHOES}
  var lResult := new System.Diagnostics.Process();
  lResult.StartInfo := new System.Diagnostics.ProcessStartInfo();
  lResult.StartInfo.FileName := aCommand;
  lResult.StartInfo.CreateNoWindow := true;
  if (length(aWorkingDirectory) > 0) and aWorkingDirectory.FolderExists then
    lResult.StartInfo.WorkingDirectory := aWorkingDirectory;
  if length(aArguments) > 0 then
    lResult.StartInfo.Arguments := JoinArgumentsCommandLine(aArguments);
  for each k in aEnvironment:Keys do
    lResult.StartInfo.EnvironmentVariables[k] := aEnvironment[k];
  lResult.StartInfo.UseShellExecute := false;
  lResult.EnableRaisingEvents := true;
  {$ELSEIF TOFFEE}
  var lResult := new NSTask();
  lResult.launchPath := aCommand;
  if assigned(aArguments) then
    lResult.arguments := aArguments.ToList();
  if assigned(aEnvironment) then
    lResult.environment := aEnvironment;
  if (length(aWorkingDirectory) > 0) and aWorkingDirectory.FolderExists then
    lResult.currentDirectoryPath := aWorkingDirectory;
  {$ENDIF}
  result := lResult;
end;

class method Task.QuoteArgumentIfNeeded(aArgument: not nullable String): not nullable String;
begin
  result := aArgument;
  if result.Contains(" ") then
    result := '"'+result.Replace('"', '\"')+'"'
end;

class method Task.SplitQuotedArgumentString(aArgumentString: not nullable String): not nullable array of String;
begin
  var lResult := new List<String>;
  var lCurrent: String := ""; // why is this needed for lCurrent to not become an NSString?
  var lInQuotes := false;
  for i: Integer := 0 to length(aArgumentString) do begin
    var ch := aArgumentString[i];
    case ch of
      ' ': begin
          if lInQuotes then begin
            lCurrent := lCurrent+ch;
          end
          else begin
            lCurrent := lCurrent.Trim();
            if length(lCurrent) > 0 then
              lResult.Add(lCurrent);
            lCurrent := "";
          end;
        end;
      '"': lInQuotes := not lInQuotes;
      else begin
          lCurrent := lCurrent+ch;
        end;
    end;
  end;

  lCurrent := lCurrent.Trim();
  if length(lCurrent) > 0 then
    lResult.Add(lCurrent);

  result := lResult.ToArray;
end;

class method Task.JoinArgumentsCommandLine(aArguments: not nullable array of String): not nullable String;
begin
  result := "";
  for each a in aArguments do begin
    if length(result) > 0 then
      result := result+" ";
    result := result+QuoteArgumentIfNeeded(a);
  end;
end;

class method Task.StringForCommand(aCommand: not nullable String) Parameters(aArguments: nullable array of String): not nullable String;
begin
  if aCommand.Contains(" ") then
    aCommand := String.Format('"{0}"', aCommand);
  if length(aArguments) > 0 then
    aCommand := aCommand+" "+JoinArgumentsCommandLine(aArguments);
  result := aCommand;
end;

{$ENDIF}

end.