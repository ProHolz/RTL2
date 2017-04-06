﻿namespace RemObjects.Elements.RTL;

interface

type
  XmlParser = public class
  private
    Tokenizer: XmlTokenizer;
    method Expected(params Values: array of XmlTokenKind);
    method ReadAttribute(aParent: XmlElement; aWS: String := ""; aIndent: String := ""): XmlNode;
    method ReadElement(aParent: XmlElement; aIndent: String := nil): XmlElement;
    method GetNamespaceForPrefix(aPrefix:not nullable String; aParent: XmlElement): XmlNamespace;
    method ReadProcessingInstruction(aParent: XmlElement): XmlProcessingInstruction;
    method ReadDocumentType: XmlDocumentType;
    method ParseEntities(S: String): nullable String;
    method ResolveEntity(S: not nullable String): nullable String;
  assembly
    fLineBreak: String;
  public
    constructor (XmlString: String);
    constructor (XmlString: String; aOptions: XmlFormattingOptions);
    method Parse: not nullable XmlDocument;
    FormatOptions: XmlFormattingOptions;
  end;

  XmlConsts = assembly static class
  public
    const TAG_DECL_OPEN: String =  "<?xml";
    const TAG_DECL_CLOSE: String = "?>";
  end;

  XmlTokenKind = public enum(
    BOF,
    EOF,
    Whitespace,
    DeclarationStart,
    DeclarationEnd,
    ProcessingInstruction,
    DocumentType,
    TagOpen,
    TagClose,
    EmptyElementEnd,
    TagElementEnd,
    ElementName,
    AttributeValue,
    SymbolData,
    Comment,
    CData,
    SlashSymbol,
    AttributeSeparator,
    OpenSquareBracket,
    CloseSquareBracket,
    SyntaxError);

  XmlWhitespaceStyle = public enum(
   PreserveAllWhitespace,  // even inside element tags, such as between attributes
   PreserveWhitespaceOutsideElements, // only outside of element tags
   PreserveWhitespaceAroundText); // only for text non-empty nodes

  XmlTagStyle = public enum(
    Preserve,
    PreferOpenAndCloseTag,
    PreferSingleTag);

  XmlNewLineSymbol = public enum(
    Preserve,
    PlatformDefault,
    LF,
    CRLF);

  XmlFormattingOptions = public class
  public
    WhitespaceStyle: XmlWhitespaceStyle := XmlWhitespaceStyle.PreserveAllWhitespace;
    EmptyTagSyle: XmlTagStyle := XmlTagStyle.Preserve;
    SpaceBeforeSlashInEmptyTags: Boolean := false;
    Indentation: String := #9;
    NewLineForElements: Boolean := true;
    NewLineForAttributes: Boolean := false;
    NewLineSymbol: XmlNewLineSymbol  := XmlNewLineSymbol.PlatformDefault;
    PreserveExactStringsForUnchnagedValues: Boolean := false;
    WriteNewLineAtEnd: Boolean := false;
    WriteBOM: Boolean := false;

    method UniqueCopy: XmlFormattingOptions;
    begin
      result := new XmlFormattingOptions;
      result.WhitespaceStyle := WhitespaceStyle;
      result.EmptyTagSyle := EmptyTagSyle;
      result.SpaceBeforeSlashInEmptyTags := SpaceBeforeSlashInEmptyTags;
      result.Indentation := Indentation;
      result.NewLineForElements := NewLineForElements;
      result.NewLineForAttributes := NewLineForAttributes;
      result.NewLineSymbol := NewLineSymbol;
      result.PreserveExactStringsForUnchnagedValues := PreserveExactStringsForUnchnagedValues;
      result.WriteNewLineAtEnd := WriteNewLineAtEnd;
      result.WriteBOM := WriteBOM;
    end;

  assembly

    method NewLineString: String;
    begin
      case NewLineSymbol of
        XmlNewLineSymbol.PlatformDefault: result := Environment.LineBreak;
        XmlNewLineSymbol.LF: result := #10;
        XmlNewLineSymbol.CRLF: result := #13#10;
        XmlNewLineSymbol.Preserve: result := nil;
      end;
    end;

  end;

implementation

constructor XmlParser( XmlString: String);
begin
  Tokenizer := new XmlTokenizer(XmlString);
  FormatOptions := new XmlFormattingOptions;
  fLineBreak := FormatOptions.NewLineString;
  if fLineBreak = nil then
    if XmlString.IndexOf(#13#10) > -1 then fLineBreak := #13#10
    else if XmlString.IndexOf(#10) > -1 then fLineBreak := #10
      else fLineBreak := Environment.LineBreak;
end;

constructor XmlParser(XmlString: String; aOptions: XmlFormattingOptions);
begin
  Tokenizer := new XmlTokenizer(XmlString);
  FormatOptions := aOptions;
  fLineBreak := FormatOptions.NewLineString;
  if fLineBreak = nil then
    if XmlString.IndexOf(#13#10) > -1 then fLineBreak := #13#10
    else if XmlString.IndexOf(#10) > -1 then fLineBreak := #10
      else fLineBreak := Environment.LineBreak;
end;

method XmlParser.Parse: not nullable XmlDocument;
begin
  var WS: String :="";
  Tokenizer.Next;
  result := new XmlDocument();
  result.fXmlParser := self;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
      result.AddNode(new XmlText(Value := Tokenizer.Value));
    Tokenizer.Next;
  end;
  Expected(XmlTokenKind.DeclarationStart, XmlTokenKind.ProcessingInstruction, XmlTokenKind.DocumentType, XmlTokenKind.TagOpen);

  {result.Version := "1.0";
  result.Encoding := "utf-8";
  result.Standalone := "no";}
  if Tokenizer.Token = XmlTokenKind.DeclarationStart then begin
    Tokenizer.Next;
    Expected(XmlTokenKind.Whitespace);
    if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
    Tokenizer.Next;
    Expected(XmlTokenKind.ElementName);
    var lXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
    if lXmlAttr.LocalName = "version" then begin
      //check version
      if (lXmlAttr.Value.IndexOf("1.") <> 0) or (lXmlAttr.Value.Length <> 3) or
        ((lXmlAttr.Value.Chars[2] < '0') or (lXmlAttr.Value.Chars[2] > '9')) then
        raise new XmlException(String.Format("Unknown XML version '{0}'", lXmlAttr.Value), lXmlAttr.EndLine, lXmlAttr.EndColumn);
      result.Version := lXmlAttr.Value;
      Expected(XmlTokenKind.DeclarationEnd, XmlTokenKind.ElementName);
      if Tokenizer.Token = XmlTokenKind.ElementName then begin
        if ((Tokenizer.Value <> "encoding") and (Tokenizer.Value <> "standalone")) then
          raise new XmlException("Unknown declaration attribute", Tokenizer.Row, Tokenizer.Column);
        lXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
      end;
    end;
    if lXmlAttr.LocalName = "encoding" then begin
      //check encoding
      var lEncoding := Encoding.GetEncoding(lXmlAttr.Value);
      if not assigned(lEncoding) then
        raise new XmlException(String.Format("Unknown encoding '{0}'", lXmlAttr.Value), lXmlAttr.EndLine, lXmlAttr.EndColumn);
      result.Encoding := lXmlAttr.Value;
      Expected(XmlTokenKind.DeclarationEnd, XmlTokenKind.ElementName);
      if Tokenizer.Token = XmlTokenKind.ElementName then begin
        if (Tokenizer.Value <> "standalone") then raise new XmlException("Unknown declaration attribute", Tokenizer.Row, Tokenizer.Column);
        lXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
      end;
    end;
    if lXmlAttr.LocalName = "standalone" then begin
      //check yes/no
      if (lXmlAttr.Value.Trim <> "yes") and (lXmlAttr.Value.Trim <>"no") then
        raise new XmlException("Unknown 'standalone' value", lXmlAttr.EndLine, lXmlAttr.EndColumn);
      result.Standalone := lXmlAttr.Value;
    end;
    Expected(XmlTokenKind.DeclarationEnd);
    Tokenizer.Next;

  end;
  Expected(XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction, XmlTokenKind.DocumentType);
  var lFormat := false;
  var WasDocType := false;
  if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
    lFormat := true;
  if lFormat and (result.Nodes.Count = 0) and (result.Version <> nil) then
    result.AddNode(new XmlText(Value := fLineBreak));
  while Tokenizer.Token <> XmlTokenKind.TagOpen do begin
    if WasDocType then
      Expected(XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction)
    else
      Expected(XmlTokenKind.TagOpen, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction, XmlTokenKind.DocumentType);
    {if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) and
      (Tokenizer.Token <> XmlTokenKind.Whitespace) then begin //or ((result.Nodes.count=0) and (result.Version <> nil)) then begin
      result.AddNode(new XmlText(Value := fLineBreak));
    end;}
    case Tokenizer.Token of
      XmlTokenKind.Whitespace: begin
        if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
          result.AddNode(new XmlText(Value := Tokenizer.Value));
        Tokenizer.Next;
      end;
      XmlTokenKind.Comment: begin
        result.AddNode(new XmlComment(Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column));
        Tokenizer.Next;
        var lCount := result.Nodes.Count-1;
        result.Nodes[lCount].EndLine := Tokenizer.Row;
        result.Nodes[lCount].EndColumn := Tokenizer.Column-1;
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;//add node
      XmlTokenKind.ProcessingInstruction : begin
        result.AddNode(ReadProcessingInstruction(nil));
        Tokenizer.Next;//add node
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;
      XmlTokenKind.DocumentType: begin
        WasDocType := true;
        result.AddNode(ReadDocumentType());
        Tokenizer.Next;
        if lFormat then result.AddNode(new XmlText(Value := fLineBreak));
      end;
    end;
  end;
  Expected(XmlTokenKind.TagOpen);
  var lIndent: String;
  if (FormatOptions.NewLineForElements) and (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
    lIndent := "";
    //result.AddNode(new XmlText(Value := fLineBreak));
  end;

  result.Root := ReadElement(nil,lIndent);
  while Tokenizer.Token <> XmlTokenKind.EOF do begin
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd);
    Tokenizer.Next;
    if (Tokenizer.Token = XmlTokenKind.Whitespace) then Tokenizer.Next;
    Expected(XmlTokenKind.EOF, XmlTokenKind.Comment, XmlTokenKind.ProcessingInstruction);
    case Tokenizer.Token of
      XmlTokenKind.Comment: result.AddNode(new XmlComment(Value := Tokenizer.Value));
      XmlTokenKind.ProcessingInstruction: result.AddNode(ReadProcessingInstruction(nil));
    end;
    Tokenizer.Next;
  end;
end;

method XmlParser.Expected(params Values: array of XmlTokenKind);
begin
  for Item in Values do
    if Tokenizer.Token = Item then
      exit;
  case Tokenizer.Token of
    XmlTokenKind.SyntaxError: raise new XmlException (Tokenizer.Value, Tokenizer.Row, Tokenizer.Column);
    XmlTokenKind.EOF: raise new XmlException ("Unexpected end of file", Tokenizer.Row,Tokenizer.Column);
    else raise new XmlException('Unexpected token. '+ Values[0].ToString + ' is expected but '+Tokenizer.Token.ToString+" found", Tokenizer.Row, Tokenizer.Column);
  end;
end;

method XmlParser.ReadAttribute(aParent: XmlElement; aWS: String; aIndent:String): XmlNode;
begin
  var lLocalName, lValue: String;
  var lStartRow, lStartCol, lEndRow, lEndCol: Integer;
  var lWSleft, lWSright, linnerWSleft, linnerWSright: String;

  lWSleft := aWS;
  Expected(XmlTokenKind.ElementName);
  lStartRow := Tokenizer.Row;
  lStartCol := Tokenizer.Column;
  lLocalName := Tokenizer.Value;
  if (FormatOptions.NewLineForAttributes) then begin
    if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace)  and (aIndent = nil) then
      lWSleft := fLineBreak+aParent.StartColumn+FormatOptions.Indentation
    else
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then
        lWSleft := fLineBreak+aIndent;
  end;
  Tokenizer.Next;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then linnerWSleft := Tokenizer.Value;
    Tokenizer.Next;
  end;
  Expected(XmlTokenKind.AttributeSeparator);
  Tokenizer.Next;
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then linnerWSright := Tokenizer.Value;
    Tokenizer.Next;
  end;
  Expected(XmlTokenKind.AttributeValue);
  lValue := Tokenizer.Value;
  var lQuoteChar := lValue[0];
  lValue  := lValue.Substring(1, length(lValue)-2); {$WARNING HACK FOR NOW}
  lEndRow := Tokenizer.Row;
  lEndCol := Tokenizer.Column;
  /************/
  Tokenizer.Next;
  Expected(XmlTokenKind.TagClose, XmlTokenKind.Whitespace, XmlTokenKind.EmptyElementEnd, XmlTokenKind.DeclarationEnd);
  if Tokenizer.Token = XmlTokenKind.Whitespace then begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then lWSright := Tokenizer.Value;
    Tokenizer.Next;
  end;
  /***********/
  if ((lLocalName.StartsWith("xmlns:")) or (lLocalName = "xmlns")) then begin
      if lLocalName.StartsWith("xmlns:") then
        lLocalName:=lLocalName.Substring("xmlns:".Length, lLocalName.Length- "xmlns:".Length)
      else if lLocalName = "xmlns" then lLocalName:="";
    result := new XmlNamespace withParent(aParent);
    (result as XmlNamespace).Prefix := lLocalName;
    (result as XmlNamespace).Url := Url.UrlWithString(lValue);
    result.StartLine := lStartRow;
    result.StartColumn := lStartCol;
    result.EndLine := lEndRow;
    result.EndColumn := lEndCol;
    (result as XmlNamespace).WSleft := lWSleft;
    (result as XmlNamespace).innerWSleft := linnerWSleft;
    (result as XmlNamespace).innerWSright := linnerWSright;
    (result as XmlNamespace).WSright := lWSright;
    (result as XmlNamespace).QuoteChar := lQuoteChar
  end
  else begin
    result := new XmlAttribute withParent(aParent);
    result.StartLine := lStartRow;
    result.StartColumn := lStartCol;
    result.EndLine := lEndRow;
    result.EndColumn := lEndCol;
    XmlAttribute(result).LocalName := lLocalName;
    var lparsedValue := ParseEntities(lValue);
    XmlAttribute(result).Value := lparsedValue;

    XmlAttribute(result).QuoteChar := lQuoteChar;
    XmlAttribute(result).WSleft := lWSleft;
    XmlAttribute(result).innerWSleft := linnerWSleft;
    XmlAttribute(result).innerWSright := linnerWSright;
    XmlAttribute(result).WSright := lWSright;
  end;
  //Tokenizer.Next;
end;

method XmlParser.ReadElement(aParent: XmlElement; aIndent: String):XmlElement;
begin
  var WS := "";
  Expected(XmlTokenKind.TagOpen);
  result := new XmlElement withParent(aParent) Indent(aIndent);
  if aIndent <> nil then
    aIndent := aIndent + FormatOptions.Indentation;
  result.StartLine := Tokenizer.Row;
  result.StartColumn := Tokenizer.Column;
  Tokenizer.Next;
  Expected(XmlTokenKind.ElementName);
  result.LocalName := Tokenizer.Value;
  Tokenizer.Next;
  Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.Whitespace);
  if Tokenizer.Token <> XmlTokenKind.Whitespace then
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd)
  else begin
    if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace) then WS := Tokenizer.Value;
    Tokenizer.Next;
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.ElementName);
  end;
  while (Tokenizer.Token = XmlTokenKind.ElementName) do begin
    var lXmlNode := ReadAttribute(result, WS, aIndent);
    WS := "";
    if lXmlNode.NodeType = XmlNodeType.Namespace then result.AddNamespace(XmlNamespace(lXmlNode))
      else result.AddAttribute(XmlAttribute(lXmlNode));
    Expected(XmlTokenKind.TagClose, XmlTokenKind.EmptyElementEnd, XmlTokenKind.ElementName);
  end;
  var lFormat := false;
  if (Tokenizer.Token = XmlTokenKind.TagClose) or (Tokenizer.Token = XmlTokenKind.EmptyElementEnd) then begin
    //check prefix for LocalName
    var lNamespace: XmlNamespace := nil;
    if result.LocalName.IndexOf(':')>0 then begin
      var lPrefix := result.LocalName.Substring(0, result.LocalName.IndexOf(':'));
      lNamespace := coalesce(result.Namespace[lPrefix], GetNamespaceForPrefix(lPrefix, aParent));
      if (lNamespace = nil) then raise new XmlException("Unknown prefix '"+lPrefix+":'", result.StartLine, (result.StartColumn+1));
      result.Namespace := lNamespace;
      result.LocalName := result.LocalName.Substring(result.LocalName.IndexOf(':')+1, result.LocalName.Length-result.LocalName.IndexOf(':')-1);
    end;
    //check prefix for attributes
    for each lAttribute in result.Attributes do begin
      if lAttribute.LocalName.IndexOf(':') >0 then begin
        var lPrefix := lAttribute.LocalName.Substring(0, lAttribute.LocalName.IndexOf(':'));
        lNamespace := coalesce(result.Namespace[lPrefix] , GetNamespaceForPrefix(lPrefix, aParent));
        if lNamespace = nil then raise new XmlException("Unknown prefix '"+lPrefix+":'", lAttribute.StartLine, lAttribute.StartColumn);
        lAttribute.Namespace := lNamespace;
        lAttribute.LocalName := lAttribute.LocalName.Substring(lAttribute.LocalName.IndexOf(':')+1, lAttribute.LocalName.Length-lAttribute.LocalName.IndexOf(':')-1);
      end;
    end;
    if (Tokenizer.Token = XmlTokenKind.TagClose) then begin
      if WS <> "" then result.LocalName := result.LocalName + WS;
      Tokenizer.Next;
      var WSValue: String := "";
      if (FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) and (FormatOptions.NewLineForElements) then
        lFormat := true;
      while (Tokenizer.Token <> XmlTokenKind.TagElementEnd) do begin
        Expected(XmlTokenKind.SymbolData, XmlTokenKind.Whitespace, XmlTokenKind.Comment, XmlTokenKind.CData, XmlTokenKind.ProcessingInstruction, XmlTokenKind.TagOpen, XmlTokenKind.TagElementEnd);
        if Tokenizer.Token = XmlTokenKind.TagOpen then begin
          if lFormat then begin result.AddNode(new XmlText(result, Value:=fLineBreak));result.AddNode(new XmlText(result, Value:=aIndent)); end;
          result.AddElement(ReadElement(result, aIndent));
          WSValue := "";
        end
        else begin
          if lFormat and (Tokenizer.Token not in [XmlTokenKind.Whitespace, XmlTokenKind.SymbolData]) then begin
            result.AddNode(new XmlText(result, Value := fLineBreak));// end;
            result.AddNode(new XmlText(result, Value:=aIndent));
          end;
          case Tokenizer.Token of
            XmlTokenKind.Whitespace: begin
              if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
                result.AddNode(new XmlText(result, Value := Tokenizer.Value));
                WSValue := "";
              end
              else
                if ((result.Nodes.Count > 0) and (result.Nodes[result.Nodes.Count-1].NodeType = XmlNodeType.Text) and (XmlText(result.Nodes[result.Nodes.Count-1]).Value.Trim <> "")) then begin
                  WSValue := Tokenizer.Value;
                  if WSValue.IndexOf(fLineBreak) > -1 then
                    WSValue := WSValue.Substring(0, WSValue.LastIndexOf(fLineBreak));
                  result.AddNode(new XmlText(result, Value := WSValue));
                  WSValue := "";
                end
                else WSValue := Tokenizer.Value;
            end;
            XmlTokenKind.SymbolData: begin
              if Tokenizer.Value.Trim <> "" then
                if (WSValue <>"") then begin
                  result.AddNode(new XmlText(result, Value := WSValue));
                end;
              var lParsedValue := ParseEntities(Tokenizer.Value);
              result.AddNode(new XmlText(result, Value := {Tokenizer.Value}lParsedValue, originalRawValue := Tokenizer.Value,
                StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column));//add node;
              WSValue := "";
            end;
            XmlTokenKind.Comment: begin
              result.AddNode(new XmlComment(result, Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column)) ;
              WSValue := "";
            end;
            XmlTokenKind.CData: begin
              result.AddNode(new XmlCData(result, Value := Tokenizer.Value, StartLine := Tokenizer.Row, StartColumn := Tokenizer.Column));
              WSValue := "";
            end;
            XmlTokenKind.ProcessingInstruction: begin
              result.AddNode(ReadProcessingInstruction(result));
              WSValue := "";
            end;
          end;
          Tokenizer.Next;
          var lCount := result.Nodes.Count-1;
          if (lCount > 0) and (result.Nodes[lCount].EndLine = 0) then
            result.Nodes[lCount].EndLine := Tokenizer.Row;
          if (lCount > 0) and (result.Nodes[lCount].EndColumn = 0) then
            result.Nodes[lCount].EndColumn := Tokenizer.Column-1;
        end;
      end;
      if Tokenizer.Token = XmlTokenKind.TagElementEnd then begin
        Tokenizer.Next;
        Expected(XmlTokenKind.ElementName);
        if (Tokenizer.Value.IndexOf(':') > 0) and ((result.Namespace = nil) or (result.Namespace.Prefix = nil) or
          (Tokenizer.Value <> result.Namespace.Prefix+':'+result.LocalName)) then
          raise new XmlException(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), Tokenizer.Row, Tokenizer.Column );
        if (Tokenizer.Value.IndexOf(':') <= 0) and (Tokenizer.Value <> result.LocalName) then
          raise new XmlException(String.Format("End tag '{0}' doesn't match start tag '{1}'", Tokenizer.Value, result.LocalName), Tokenizer.Row, Tokenizer.Column );

        if lFormat and (aIndent <> nil) and (result.Elements.Count >0) then begin
          result.AddNode(new XmlText(result, Value := fLineBreak));
          result.AddNode(new XmlText(result, Value := aIndent.Substring(0,aIndent.LastIndexOf(FormatOptions.Indentation))));
        end;
        if (result.IsEmpty) and (FormatOptions.EmptyTagSyle <> XmlTagStyle.PreferSingleTag) then
          result.AddNode(new XmlText(result,Value := ""));
        Tokenizer.Next;
        if (Tokenizer.Token = XmlTokenKind.Whitespace) then begin
          if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then
            result.EndTagName := result.LocalName+Tokenizer.Value;
            Tokenizer.Next;
        end;
        Expected(XmlTokenKind.TagClose);
        result.EndLine := Tokenizer.Row;
        result.EndColumn := Tokenizer.Column;
        if result.Parent = nil then exit(result);
        Tokenizer.Next;
      end;
    end
    else  if Tokenizer.Token = XmlTokenKind.EmptyElementEnd then begin
      result.EndLine := Tokenizer.Row;
      result.EndColumn := Tokenizer.Column+1;
      if (FormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then
        if (FormatOptions.EmptyTagSyle = XmlTagStyle.PreferOpenAndCloseTag) then
          result.AddNode(new XmlText(result,Value := ""))
        else if (FormatOptions.SpaceBeforeSlashInEmptyTags) then begin
        end;
      if result.Parent = nil then exit(result);
      Tokenizer.Next;
      if lFormat and (Tokenizer.Token not in [XmlTokenKind.Whitespace, XmlTokenKind.SymbolData]) then
        result.AddNode(new XmlText(result, Value:=fLineBreak));
    end;
  end;
end;

method XmlParser.GetNamespaceForPrefix(aPrefix:not nullable String; aParent: XmlElement): XmlNamespace;
begin
  var ParentElem := aParent;
  while (ParentElem <> nil) and (result = nil) do begin
    if ParentElem.Namespace[aPrefix] <> nil
    then result := ParentElem.Namespace[aPrefix]
    else ParentElem := XmlElement(ParentElem.Parent);
  end;
end;

method XmlParser.ReadProcessingInstruction(aParent: XmlElement):  XmlProcessingInstruction;
begin
  var WS := "";
  Expected(XmlTokenKind.ProcessingInstruction);
  result := new XmlProcessingInstruction(aParent);
  result.StartLine := Tokenizer.Row;
  result.StartColumn := Tokenizer.Column;
  Tokenizer.Next;
  Expected(XmlTokenKind.ElementName);
  result.Target := Tokenizer.Value;
  Tokenizer.Next;
  Expected(XmlTokenKind.Whitespace);
  if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
  Tokenizer.Next;

  Expected(XmlTokenKind.ElementName);
  while Tokenizer.Token = XmlTokenKind.ElementName do begin
    var lXmlAttr := XmlAttribute(ReadAttribute(nil, WS));
    result.Data := result.Data+lXmlAttr.ToString;//aXmlAttr.LocalName+'="'+aXmlAttr.Value;
    WS:="";
    //Tokenizer.Next;
  end;
  Expected(XmlTokenKind.DeclarationEnd);
  result.EndLine := Tokenizer.Row;
  result.EndColumn := Tokenizer.Column+1;
  //Tokenizer.Next;
end;

method XmlParser.ReadDocumentType: XmlDocumentType;
begin
  Expected(XmlTokenKind.DocumentType);
  result := new XmlDocumentType();
  result.StartLine := Tokenizer.Row;
  result.StartColumn := Tokenizer.Column;
  Tokenizer.Next;
  Expected(XmlTokenKind.Whitespace);
  var WS := "";
  if FormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveAllWhitespace then WS := Tokenizer.Value;
  Tokenizer.Next;
  Expected(XmlTokenKind.ElementName);
  result.Name := Tokenizer.Value;
  Tokenizer.Next;
  Expected(XmlTokenKind.Whitespace, XmlTokenKind.TagClose);
  if Tokenizer.Token = XmlTokenKind.Whitespace then Tokenizer.Next;
  Expected(XmlTokenKind.TagClose, XmlTokenKind.ElementName, XmlTokenKind.OpenSquareBracket);
  if Tokenizer.Token = XmlTokenKind.ElementName then begin
    if Tokenizer.Value = "SYSTEM" then begin
      Tokenizer.Next;
      Expected(XmlTokenKind.Whitespace);
      Tokenizer.Next;
      Expected(XmlTokenKind.AttributeValue);
      result.SystemId := Tokenizer.Value;
      Tokenizer.Next;
    end
    else if Tokenizer.Value = "PUBLIC" then begin
      Tokenizer.Next;
      Expected(XmlTokenKind.Whitespace);
      Tokenizer.Next;
      Expected(XmlTokenKind.AttributeValue);
      result.PublicId := Tokenizer.Value;
      Tokenizer.Next;
      Expected(XmlTokenKind.Whitespace);
      Tokenizer.Next;
      Expected(XmlTokenKind.AttributeValue);
      result.SystemId := Tokenizer.Value;
      Tokenizer.Next;
    end
    else raise new XmlException("SYSTEM, PUBLIC or square brackets expected", Tokenizer.Row, Tokenizer.Column);
    Expected(XmlTokenKind.Whitespace, XmlTokenKind.TagClose);
    if Tokenizer.Token = XmlTokenKind.Whitespace then Tokenizer.Next;
  end;
  if Tokenizer.Token = XmlTokenKind.OpenSquareBracket then begin
    //that's only for now, need to be parsed
    Tokenizer.Next;
    Expected(XmlTokenKind.ElementName);
    result.Declaration := Tokenizer.Value;
    Tokenizer.Next;
    Expected(XmlTokenKind.CloseSquareBracket, XmlTokenKind.Whitespace);
    if Tokenizer.Token = XmlTokenKind.Whitespace then begin
      Tokenizer.Next;
      Expected(XmlTokenKind.CloseSquareBracket);
    end;
    if Tokenizer.Token = XmlTokenKind.CloseSquareBracket then Tokenizer.Next;
    Expected(XmlTokenKind.TagClose, XmlTokenKind.Whitespace);
    if Tokenizer.Token = XmlTokenKind.Whitespace then Tokenizer.Next;
  end;
  Expected(XmlTokenKind.TagClose);
  result.EndLine := Tokenizer.Row;
  result.EndColumn := Tokenizer.Column;
end;

method XmlParser.ParseEntities(S: String): nullable String;
begin
  var i := 0;
  result := S;
  var len := length(result);
  while i < len do begin
    if result[i] = '&' then begin
      var lStart := i;
      var lEntity: String;
      inc(i);
      while i < length(result) do begin
        var ch := result[i];
        if ch = ';' then begin
          inc(i);
          lEntity := S.Substring(lStart, i-lStart);
          break;
        end
        else if ch in ['a'..'z','A'..'Z','0'..'9','#'] then begin
          inc(i);
        end
        else begin
          break;
        end;
      end;
      if assigned(lEntity) then begin
        var lResolvedEntity := ResolveEntity(lEntity);
        if assigned(lResolvedEntity) then begin
          result := result.Replace(lStart, length(lEntity), lResolvedEntity);
          var diff := (length(lEntity)-length(lResolvedEntity));
          i := i-diff;
          len := len-diff
        end;
      end;
    end
    else
      inc(i);
  end;
end;

method XmlParser.ResolveEntity(S: not nullable String): nullable String;
begin
  if S.StartsWith("&#x") then begin
    var lHex := S.Substring(3, length(S)-4);
    try
      var lValue := Convert.HexStringToInt32(lHex);
      result := chr(lValue);
    except
    end;
  end
  else if S.StartsWith("&#") then begin
    var lDec := S.Substring(2, length(S)-3);
    var lValue := Convert.TryToInt32(lDec);
    if assigned(lValue) then result := chr(lValue);
  end
  else case S of
    "&lt;": result := "<";
    "&gt;": result := ">";
    "&amp;": result := "&";
    "&apos;": result := "'";
    "&quot;": result := """";
  end;
end;

end.