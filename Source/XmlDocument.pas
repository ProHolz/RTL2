﻿namespace RemObjects.Elements.RTL;

interface

type
  XmlDocument = public class
    constructor;
    constructor (aRoot : not nullable XmlElement);
  assembly
    fXmlParser: XmlParser;
    fFormatOptions: XmlFormattingOptions;
    fLineBreak: String;
  private
    fNodes: List<XmlNode> := new List<XmlNode>;
    fRoot: /*not nullable*/ XmlElement;
    fDefaultVersion := "1.0";

    method GetNodes: ImmutableList<XmlNode>;
    method GetRoot: not nullable XmlElement;
    method SetRoot(aRoot: not nullable XmlElement);

  public
    class method FromFile(aFileName: not nullable File): not nullable XmlDocument;
    class method FromUrl(aUrl: not nullable Url): not nullable XmlDocument;
    class method FromString(aString: not nullable String): not nullable XmlDocument;
    class method FromBinary(aBinary: not nullable Binary): not nullable XmlDocument;
    class method WithRootElement(aElement: not nullable XmlElement): not nullable XmlDocument;
    class method WithRootElement(aName: not nullable String): not nullable XmlDocument;

    class method TryFromFile(aFileName: not nullable File): nullable XmlDocument;
    class method TryFromUrl(aUrl: not nullable Url): nullable XmlDocument;
    class method TryFromString(aString: not nullable String): nullable XmlDocument;
    class method TryFromBinary(aBinary: not nullable Binary): nullable XmlDocument;

    [ToString]
    method ToString(): String; override;
    method ToString(aFormatOptions: XmlFormattingOptions): String;
    method ToString(aSaveFormatted: Boolean; aFormatOptions: XmlFormattingOptions): String;

    method SaveToFile(aFileName: not nullable File);
    method SaveToFile(aFileName: not nullable File; aFormatOptions: XmlFormattingOptions);


    property Nodes: ImmutableList<XmlNode> read GetNodes;
    property Root: not nullable XmlElement read GetRoot write SetRoot;

    property Version : String;
    property Encoding : String;
    property Standalone : String;
    method AddNode(aNode: not nullable XmlNode);
  end;

  XmlNodeType = public enum(
    Element,
    Attribute,
    Comment,
    CData,
    &Namespace,
    Text,
    ProcessingInstruction,
    DocumentType
    );

  XmlNode = public class
  unit
    fDocument: weak nullable XmlDocument;
    fParent: weak nullable XmlNode;
    fNodeType: XmlNodeType;
    Indent: String;

    method SetDocument(aDoc: XmlDocument);
    method GetNodeType : XmlNodeType;
    constructor withParent(aParent: XmlNode := nil);
  protected
    method CharIsWhitespace(C: String): Boolean;
    method ConvertEntity(S: String; C: nullable Char): String;
  public
    constructor; empty;
    property Parent: nullable XmlNode read fParent;
    property Document: nullable XmlDocument read coalesce(Parent:Document, fDocument) write SetDocument;
    property NodeType: XmlNodeType read GetNodeType;
    property StartLine: Integer;
    property StartColumn: Integer;
    property EndLine: Integer;
    property EndColumn: Integer;
    [ToString]
    method ToString(): String; override;
    method ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aPreserveExactStringsForUnchnagedValues: Boolean := false): String;
  end;

  XmlElement = public class(XmlNode)
  private
    fLocalName : String;
    fAttributes: List<XmlAttribute> := new List<XmlAttribute>;
    fElements: List<XmlElement> := new List<XmlElement>;
    fNodes: List<XmlNode> := new List<XmlNode>;
    fNamespace : XmlNamespace;
    fNamespaces: List<XmlNamespace> := new List<XmlNamespace>;
    fDefaultNamespace: XmlNamespace;

    method GetNamespace: XmlNamespace;
    method SetNamespace(aNamespace: XmlNamespace);
    method GetLocalName: not nullable String;
    method SetLocalName(aValue: not nullable String);
    //method GetValue: nullable String;
    method SetValue(aValue: nullable String);
    method GetAttributes: not nullable sequence of XmlAttribute;
    method GetAttribute(aName: not nullable String): nullable XmlAttribute;
    method GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
    method GetNodes: ImmutableList<XmlNode>;
    method GetElements: not nullable sequence of XmlElement;
    method GetNamespace(aUrl: Url): nullable XmlNamespace;
    method GetNamespace(aPrefix: String): nullable XmlNamespace;
    method GetNamespaces: not nullable sequence of XmlNamespace;
    method GetDefaultNamespace: XmlNamespace;

  assembly
    fIsEmpty: Boolean := true;
    constructor withParent(aParent: XmlNode := nil);
    constructor withParent(aParent: XmlNode) Indent(aIndent: String := "");

  public
    constructor withName(aLocalName: not nullable String);
    constructor withName(aLocalName: not nullable String) Value(aValue: not nullable String);

    property &Namespace: XmlNamespace read GetNamespace write SetNamespace;
    property DefinedNamespaces: not nullable sequence of XmlNamespace read GetNamespaces;
    property DefaultNamespace: XmlNamespace read  GetDefaultNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: nullable String read GetValue(true) write SetValue;
    property IsEmpty: Boolean read fIsEmpty;
    property EndTagName: String;

    property Attributes: not nullable sequence of XmlAttribute read GetAttributes;
    property Attribute[aName: not nullable String]: nullable XmlAttribute read GetAttribute;
    property Attribute[aName: not nullable String; aNamespace: nullable XmlNamespace]: nullable XmlAttribute read GetAttribute;
    property Elements: not nullable sequence of XmlElement read GetElements;
    property Nodes: ImmutableList<XmlNode> read GetNodes;
    property &Namespace[aUrl: Url]: nullable XmlNamespace read GetNamespace;
    property &Namespace[aPrefix: String]: nullable XmlNamespace read GetNamespace;

    method GetValue (aWithNested: Boolean): nullable String;
    method ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
    method FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;

    method AddAttribute(aAttribute: not nullable XmlAttribute);
    method SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
    method RemoveAttribute(aAttribute: not nullable XmlAttribute);
    method RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;

    method AddElement(aElement: not nullable XmlElement);
    method AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
    method AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
    method AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
    method AddElements(aElements: not nullable sequence of XmlElement);
    method RemoveElement(aElement: not nullable XmlElement);
    method RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
    method RemoveAllElements;

    method ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);

    method AddNode(aNode: not nullable XmlNode);
    //method MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
    method AddNamespace(aNamespace: not nullable XmlNamespace);
    method AddNamespace(aPrefix: nullable String; aUrl: not nullable Url): XmlNamespace;
    method RemoveNamespace(aNamespace: not nullable XmlNamespace);
    method RemoveNamespace(aPrefix: not nullable String);
    [ToString]
    method ToString(): String; override;
    method ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aPreserveExactStringsForUnchnagedValues: Boolean := false): String;
  end;

  XmlAttribute = public class(XmlNode)
  assembly
    WSleft, WSright: String;
    innerWSleft, innerWSright: String;
    QuoteChar: Char := '"';
    originalRawValue: String;
  private
    fLocalName: String;
    fValue: String;
    fNamespace:XmlNamespace;
    method GetNamespace: XmlNamespace;
    method SetNamespace(aNamespace: not nullable XmlNamespace);
    method GetLocalName: not nullable String;
    method GetValue: not nullable String;
    method SetLocalName(aValue: not nullable String);
    method SetValue(aValue: not nullable String);
  public
    constructor withParent(aParent: XmlNode := nil);
    constructor (aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
    property &Namespace: XmlNamespace read GetNamespace write SetNamespace;
    property LocalName: not nullable String read GetLocalName write SetLocalName;
    property Value: not nullable String read GetValue write SetValue;
    [ToString]
    method ToString(): String; override;
    method ToString(aFormatInsideTags: Boolean; aPreserveExactStringsForUnchnagedValues: Boolean := false): String;
  end;

  XmlComment = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Value: String;
  end;

  XmlCData = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Value: String;
  end;

  XmlNamespace = public class(XmlNode)
  private
    method GetPrefix: String;
    method SetPrefix(aPrefix: String);
    fPrefix: String;
  assembly
    WSleft, WSright: String;
    innerWSleft, innerWSright: String;
    QuoteChar: Char := '"';
    constructor withParent(aParent: XmlNode := nil);
  public
    constructor(aPrefix: String; aUrl: not nullable Url);
    property Prefix: String read GetPrefix write SetPrefix;
    property Url: Url;
    [ToString]
    method ToString(): String; override;
    method ToString(aFormatInsideTags: Boolean): String;

  end;

  XmlProcessingInstruction = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Target: String;
    property Data: String;
  end;

  XmlText = public class(XmlNode)
  private
    fValue: String;
    method GetValue: String;
    method SetValue(aValue: String);
  assembly
    originalRawValue: String;
  public
    constructor (aParent: XmlNode := nil);
    property Value: String read GetValue write SetValue;
  end;

  XmlDocumentType = public class(XmlNode)
  public
    constructor (aParent: XmlNode := nil);
    property Name: String;
    property SystemId: String;
    property PublicId: String;
    property Declaration: String;
  end;

implementation

{ XmlDocument }

constructor XmlDocument();
begin
end;

constructor XmlDocument(aRoot: not nullable XmlElement);
begin
  fRoot := aRoot;
  fRoot.Document := self;
  AddNode(fRoot);
end;

class method XmlDocument.FromFile(aFileName: not nullable File): not nullable XmlDocument;
begin
  if not aFileName.Exists then
    raise new FileNotFoundException(aFileName);
  var XmlStr:String := aFileName.ReadText();
  var lXmlParser := new XmlParser(XmlStr);
  result := lXmlParser.Parse();
  result.fXmlParser := lXmlParser;
end;

class method XmlDocument.TryFromFile(aFileName: not nullable File): nullable XmlDocument;
begin
  if aFileName.Exists then begin
    try
      result := FromFile(aFileName);
    except
      on E: XmlException do;
    end;
  end;
end;

class method XmlDocument.FromUrl(aUrl: not nullable Url): not nullable XmlDocument;
begin
  if aUrl.IsFileUrl and aUrl.FilePath.FileExists then
    result := FromFile(aUrl.FilePath)
  {$IF NOT ISLAND}
  //77333: Toffee: "in" operator is broken for mapped strings
  //else if aUrl.Scheme in ["http", "https"] then
  else if (aUrl.Scheme = "http") or (aUrl.Scheme = "https") then
    result := Http.GetXml(new HttpRequest(aUrl))
  {$ENDIF}
  else
    raise new XmlException(String.Format("Cannot load XML from URL '{0}'.", aUrl.ToAbsoluteString()));
end;

class method XmlDocument.TryFromUrl(aUrl: not nullable Url): nullable XmlDocument;
begin
  if aUrl.IsFileUrl and aUrl.FilePath.FileExists then
    result := TryFromFile(aUrl.FilePath)
  {$IF NOT ISLAND}
  else if aUrl.Scheme in ["http", "https"] then try
    result := Http.GetXml(new HttpRequest(aUrl));
  except
    on E: XmlException do;
    on E: HttpException do;
  end;
  {$ENDIF}
end;

class method XmlDocument.FromString(aString: not nullable String): not nullable XmlDocument;
begin
  var lXmlParser := new XmlParser(aString);
  result := lXmlParser.Parse();
  result.fXmlParser := lXmlParser;
end;

class method XmlDocument.TryFromString(aString: not nullable String): nullable XmlDocument;
begin
  try
    result := FromString(aString);
  except
    on XmlException do
      exit nil;
  end;
end;

class method XmlDocument.FromBinary(aBinary: not nullable Binary): not nullable XmlDocument;
begin
  result := XmlDocument.FromString(new String(aBinary.ToArray));
end;

class method XmlDocument.TryFromBinary(aBinary: not nullable Binary): nullable XmlDocument;
begin
  result := XmlDocument.TryFromString(new String(aBinary.ToArray));
end;

class method XmlDocument.WithRootElement(aElement: not nullable XmlElement): not nullable XmlDocument;
begin
  result := new XmlDocument(aElement);
end;

class method XmlDocument.WithRootElement(aName: not nullable String): not nullable XmlDocument;
begin
  result := new XmlDocument(new XmlElement withName(aName));
end;

method XmlDocument.ToString(): String;
begin
  result := ToString(false, new XmlFormattingOptions());
end;

method XmlDocument.ToString(aFormatOptions: XmlFormattingOptions): String;
begin
  result := ToString(true, aFormatOptions);
end;

method XmlDocument.ToString(aSaveFormatted: Boolean; aFormatOptions: XmlFormattingOptions): String;
begin
  fFormatOptions := aFormatOptions;
  fLineBreak := aFormatOptions.NewLineString;
  if (fLineBreak = nil) and (fXmlParser <> nil) then fLineBreak := fXmlParser.fLineBreak;
  var lPreserveExactStringsForUnchnagedValues := aFormatOptions.PreserveExactStringsForUnchnagedValues;
  result:="";
  var lFormatInsideTags := false;
  if Version <> nil then result := '<?xml version="'+Version+'"';
  if (Encoding <> nil) then begin
    if result = "" then result := '<?xml version="'+fDefaultVersion+'"';
    result := result + ' encoding="'+Encoding+'"';
  end;
  if Standalone <> nil then begin
    if result = "" then result := '<?xml version="'+fDefaultVersion+'"';
    result := result + ' standalone="'+Standalone+'"';
  end;
  if result <> "" then result := result + "?>";
  if not(aSaveFormatted) or
    (aSaveFormatted and
      (fXmlParser <> nil) and
      (
        (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveWhitespaceAroundText) or
        (
          (fXmlParser.FormatOptions.WhitespaceStyle = aFormatOptions.WhitespaceStyle) and
          (fXmlParser.FormatOptions.NewLineForElements = aFormatOptions.NewLineForElements) and
          (fXmlParser.FormatOptions.Indentation = aFormatOptions.Indentation) and
          (fXmlParser.FormatOptions.NewLineSymbol = aFormatOptions.NewLineSymbol)
        )
      )
     ) then begin
    if aSaveFormatted and (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then begin
      aSaveFormatted := false;
      lFormatInsideTags := true;
    end;
    for each aNode in fNodes do
      result := result+aNode.ToString(aSaveFormatted, lFormatInsideTags, lPreserveExactStringsForUnchnagedValues);
  end
  else begin
    if (aFormatOptions.WhitespaceStyle <> XmlWhitespaceStyle.PreserveAllWhitespace) then lFormatInsideTags := true;
    if (Version <> nil) or (Encoding <> nil) or (Standalone <> nil) and aFormatOptions.NewLineForElements then result := result + fLineBreak;
      for each aNode in fNodes do
        if (aNode.NodeType <> XmlNodeType.Text) or (XmlText(aNode).Value.Trim <> "") then
          result := result+aNode.ToString(aSaveFormatted, lFormatInsideTags, lPreserveExactStringsForUnchnagedValues)+fLineBreak;
      if not aFormatOptions.WriteNewLineAtEnd then
        result := result.TrimEnd();
  end;
end;

method XmlDocument.SaveToFile(aFileName: not nullable File);
begin
  if Encoding = nil then Encoding := "utf-8";
  File.WriteText(aFileName.FullPath, self.ToString(false, new XmlFormattingOptions), RemObjects.Elements.RTL.Encoding.GetEncoding(Encoding));
end;

method XmlDocument.SaveToFile(aFileName: not nullable File; aFormatOptions: XmlFormattingOptions);
begin
  var lStringValue := self.ToString(true, aFormatOptions);
  var lEncoding := coalesce(if assigned(Encoding) then RemObjects.Elements.RTL.Encoding.GetEncoding(Encoding), RemObjects.Elements.RTL.Encoding.UTF8);
  var lBytes := lEncoding.GetBytes(lStringValue) includeBOM(aFormatOptions.WriteBOM);
  File.WriteBytes(aFileName.FullPath, lBytes);
end;


method XmlDocument.AddNode(aNode: not nullable XmlNode);
begin
  aNode.Document := self;
  fNodes.Add(aNode);
end;

method XmlDocument.GetRoot: not nullable XmlElement;
begin
  result := fRoot as not nullable;
end;

method XmlDocument.SetRoot(aRoot: not nullable XmlElement);
begin
  if fRoot <> nil then fNodes.Remove(fRoot);
  fRoot := aRoot;
  AddNode(aRoot);
end;

method XmlDocument.GetNodes: ImmutableList<XmlNode>;
begin
  {var aNodes: List<XmlNode> := new List<XmlNode>;
  for each aNode in fNodes do begin
    if (aNode.NodeType <> XmlNodeType.Text) or (XmlText(aNode).Value.Trim <> "") then
      aNodes.Add(aNode);
  end;
  result := aNodes as not nullable;}
  result := fNodes;
end;

constructor XmlNode withParent(aParent: XmlNode);
begin
  fParent := aParent;
end;

method XmlNode.SetDocument(aDoc: XmlDocument);
begin
  fDocument := aDoc;
end;

method XmlNode.GetNodeType: XmlNodeType;
begin
  result := fNodeType;
end;

method XmlNode.ToString: String;
begin
  result := ToString(false, false, false);
end;

method XmlNode.ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aPreserveExactStringsForUnchnagedValues: Boolean): String;
begin
  result := "";
  case NodeType of
    XmlNodeType.Text: begin
      if (XmlText(self).originalRawValue <> nil) and aPreserveExactStringsForUnchnagedValues then result := XmlText(self).originalRawValue
      else result := ConvertEntity(XmlText(self).Value, nil);
    end;
    XmlNodeType.Comment: begin
      result := "<!--"+XmlComment(self).Value+"-->";
    end;
    XmlNodeType.CData: result := "<![CDATA["+XmlCData(self).Value+"]]>";
    XmlNodeType.ProcessingInstruction: begin
      result := "<?"+XmlProcessingInstruction(self).Target;
      var str := XmlProcessingInstruction(self).Data;
      if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
        result := result + " ";
      result := result + str+"?>";
    end;
    XmlNodeType.Element: result := XmlElement(self).ToString(aSaveFormatted, aFormatInsideTags, aPreserveExactStringsForUnchnagedValues);
    XmlNodeType.DocumentType: begin
      result := "<!DOCTYPE ";
      if XmlDocumentType(self).Name <> nil then result := result + XmlDocumentType(self).Name;
      if XmlDocumentType(self).PublicId <> nil then begin
        result := result + " PUBLIC "+ XmlDocumentType(self).PublicId + " "+XmlDocumentType(self).SystemId;

      end
      else if XmlDocumentType(self).SystemId <> nil then
        result := result + " SYSTEM "+XmlDocumentType(self).SystemId;
      if XmlDocumentType(self).Declaration <> nil then
        result := result + " ["+XmlDocumentType(self).Declaration+"]";
      result := result + ">";
    end;
  end;
end;

method XmlNode.CharIsWhitespace(C: String): Boolean;
begin
   exit (C = ' ') or (C = #13) or (C = #10) or (C = #9);
end;

method XmlNode.ConvertEntity(S: String; C: nullable Char): String;
begin
  result := S.Replace('&',"&amp;");
  result := result.Replace('>',"&gt;");
  result := result.Replace('<',"&lt;");
  if (C = '''') then result := result.Replace('''',"&apos");
  if (C = '"') then result := result.Replace('"',"&quot;");
end;

{ XmlElement }

constructor XmlElement withParent(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Element;
end;

constructor XmlElement withParent(aParent: XmlNode) Indent(aIndent: String);
begin
  inherited constructor withParent(aParent);
  Indent := aIndent;
  fNodeType := XmlNodeType.Element;
end;

constructor XmlElement withName(aLocalName: not nullable String);
begin
  constructor withParent(nil);
  fLocalName := aLocalName;
end;

constructor XmlElement withName(aLocalName: not nullable String) Value(aValue: not nullable String);
begin
  constructor withParent(nil);
  fLocalName := aLocalName;
  Value := aValue;
end;


method XmlElement.ElementsWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  if aNamespace = nil then
    result := Elements.Where(c -> (c.LocalName = aLocalName)) as not nullable
  else
    result := Elements.Where(c -> (c.LocalName = aLocalName) and (c.Namespace = aNamespace)) as not nullable
end;

method XmlElement.ElementsWithNamespace(aNamespace: nullable XmlNamespace := nil): not nullable sequence of XmlElement;
begin
  result := Elements.Where(c -> c.Namespace = aNamespace) as not nullable;
end;

method XmlElement.FirstElementWithName(aLocalName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlElement;
begin
  if assigned(aNamespace) then begin
    for each e in fElements do
      if (e.LocalName = aLocalName) and (e.Namespace = aNamespace) then
        exit e;
  end
  else begin
    for each e in fElements do
      if e.LocalName = aLocalName then
        exit e;

    var lBracePos := aLocalName.IndexOf('{');
    if (lBracePos = 0) then begin
      var lClosingBracePos := aLocalName.IndexOf('}');
      if lClosingBracePos > lBracePos then begin
        aNamespace := &Namespace[Url.UrlWithString(aLocalName.Substring(1, lClosingBracePos-1))];
        if assigned(aNamespace) then
          result := FirstElementWithName(aLocalName.Substring(lClosingBracePos+1, aLocalName.Length-lClosingBracePos-1), aNamespace);
      end;
    end
    else begin
      var lPrefixPos := aLocalName.IndexOf(':');
      if (lPrefixPos > 0) then begin
        var lNamespaceString := aLocalName.Substring(0, lPrefixPos);
        aNamespace := &Namespace[lNamespaceString];
        if assigned(aNamespace) then
          result := FirstElementWithName(aLocalName.Substring(lPrefixPos+1, aLocalName.Length-lPrefixPos-1), aNamespace);
      end;
    end;
  end;
end;

method XmlElement.AddAttribute(aAttribute: not nullable XmlAttribute);
begin
  fAttributes.Add(aAttribute);
end;

method XmlElement.SetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: not nullable String);
begin
  if assigned(Attributes) then begin
    var lAttribute := GetAttributes.Where(a -> a.LocalName = aName).FirstOrDefault();
    if assigned(lAttribute) then lAttribute.Value := aValue
    else fAttributes.Add(new XmlAttribute(aName, aNamespace, aValue));
  end
  else begin
    fAttributes.Add( new XmlAttribute(aName, aNamespace, aValue));
  end;
end;

method XmlElement.RemoveAttribute(aAttribute: not nullable XmlAttribute);
begin
  fAttributes.Remove(aAttribute);
end;

method XmlElement.RemoveAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace := nil): nullable XmlAttribute;
begin
  var lAttribute := Attributes.Where(a -> (a.LocalName = aName) and (a.Namespace = aNamespace)).FirstOrDefault;
  if assigned(lAttribute) then
    fAttributes.Remove(lAttribute);
end;

method XmlElement.AddElement(aElement: not nullable XmlElement);
begin
  aElement.fParent := self;
  if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then begin
    if fNodes.Count > 0 then begin
      var LastNodePos := fNodes.Count-1;
      if XmlText(fNodes.Item[LastNodePos]):Value = aElement.fParent.Indent then begin
        fNodes.Insert(LastNodePos,new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
        fNodes.Insert(LastNodePos+1,aElement);
        fNodes.Insert(LastNodePos+2 ,new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
      end;
     end
     else begin
        fNodes.Add(new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
        fNodes.Add(aElement);
        fNodes.Add(new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
     end;
  end
  else fNodes.Add(aElement);
  fElements.Add(aElement);
  fIsEmpty := false;
end;

method XmlElement.AddElements(aElements: not nullable sequence of XmlElement);
begin
  for each e in aElements do
    AddElement(e);
end;

method XmlElement.AddElement(aElement: not nullable XmlElement) atIndex(aIndex: Integer);
begin
  if (fNodes.Count = 0)  and (aIndex = 0) then AddElement(aElement)
  else begin
    fElements.Insert(aIndex, aElement);
    var lFormat := false;
    if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then
      lFormat := true;
    var i,j: Integer;
    for i:=0 to fNodes.Count-1 do begin
      if fNodes.Item[i].NodeType = XmlNodeType.Element then begin
        if aIndex = j then break;
        inc(j);
      end;
    end;
    if lFormat and (fNodes.Item[i-1].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[i-1]).Value.StartsWith(aElement.fParent.Indent)) then begin
      fNodes.Insert(i-1,new XmlText(self, Value := aElement.fParent.Indent+ aElement.Document.fXmlParser.FormatOptions.Indentation));
      fNodes.Insert(i,aElement);
      fNodes.Insert(i+1 ,new XmlText(self, Value := aElement.Document.fXmlParser.fLineBreak));
    end
    else fNodes.Insert(i,aElement);
  end;
  fIsEmpty := false;
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil): not nullable XmlElement;
begin
  result := new XmlElement withParent(self);
  result.Namespace := aNamespace;
  result.LocalName := aName;
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result);
end;

method XmlElement.AddElement(aName: not nullable String; aNamespace: nullable XmlNamespace := nil; aValue: nullable String := nil) atIndex(aIndex: Integer): not nullable XmlElement;
begin
  result := new XmlElement withParent(self);
  result.Namespace := aNamespace;
  result.LocalName := aName;
  if length(aValue) > 0 then
    result.Value := aValue;
  AddElement(result) atIndex(aIndex);
end;

method XmlElement.RemoveElement(aElement: not nullable XmlElement);
begin
  fElements.Remove(aElement);
  if (self.Indent <> nil) and (aElement.Document <> nil) and (aElement.Document.fXmlParser <> nil) then begin
    var i := 0;
    var found := false;
    while (i < fNodes.Count) and not(found) do begin
      if fNodes.Item[i] = aElement then found := true;
      inc(i);
    end;
    i:= i-1;
    if found and (i > 0) and (i < fNodes.Count-1)  and
      (fNodes.Item[i-1].NodeType = XmlNodeType.Text) and  (XmlText(fNodes.Item[i-1]).Value.StartsWith(self.Document.fXmlParser.FormatOptions.Indentation) and
      (fNodes.Item[i+1].NodeType = XmlNodeType.Text) and (XmlText(fNodes.Item[i+1]).Value.EndsWith(#10))) then begin
       fNodes.RemoveAt(i-1);
       fNodes.RemoveAt(i-1);
       fNodes.RemoveAt(i-1);
    end
    else fNodes.Remove(aElement);
  end
  else fNodes.Remove(aElement);
  if fNodes.count = 0 then fIsEmpty := true;
  aElement.fParent := nil;
end;

method XmlElement.RemoveElementsWithName(aName: not nullable String; aNamespace: nullable XmlNamespace := nil);
begin
  for each e in ElementsWithName(aName, aNamespace).ToList() do
    RemoveElement(e);
end;

method XmlElement.RemoveAllElements;
begin
  for each e in Elements.ToList() do
    RemoveElement(e);
end;

method XmlElement.ReplaceElement(aExistingElement: not nullable XmlElement) withElement(aNewElement: not nullable XmlElement);
begin
  var i := 0;
  for each elem in Elements do
    if elem.Equals(aExistingElement) then begin
      fElements.ReplaceAt(i, aNewElement);
      break;
    end
    else inc(i) ;
  var j := i;
  for j:=i to Nodes.Count-1 do begin
     if fNodes.Item[j].Equals(aExistingElement) then begin
       fNodes.ReplaceAt(j, aNewElement);
       break;
     end;
  end;
end;

{method XmlElement.MoveElement(aExistingElement: not nullable XmlElement) toIndex(aIndex: Integer);
begin
end;}

method XmlElement.GetNodes: ImmutableList<XmlNode>;
begin
  {var aNodes: List<XmlNode> := new List<XmlNode>;
  for each aNode in fNodes do begin
    if (aNode.NodeType <> XmlNodeType.Text) or (XmlText(aNode).Value.Trim <> "") then
      aNodes.Add(aNode);
  end;
  result := aNodes as not nullable;}
  result := fNodes;
end;

method XmlElement.AddNode(aNode: not nullable XmlNode);
begin
  fIsEmpty := false;
  if (aNode.NodeType = XmlNodeType.Text) and (XmlText(aNode).Value = "") then exit;
  fNodes.Add(aNode);
end;

method XmlElement.GetLocalName: not nullable String;
begin
  //result := fLocalName as not nullable;
  result := fLocalName.Trim as not nullable;
end;

method XmlElement.SetLocalName(aValue: not nullable String);
begin
  fLocalName := aValue;
end;

method XmlElement.GetNamespace: nullable XmlNamespace;
begin
  result := fNamespace;
  result := coalesce(fNamespace, fDefaultNamespace);
  if (result = nil) and (self.Parent <> nil) then result := XmlElement(self.Parent).DefaultNamespace;
end;

method XmlElement.SetNamespace(aNamespace: XmlNamespace);
begin
  fNamespace := aNamespace;
end;

method XmlElement.GetDefaultNamespace: XmlNamespace;
begin
  if Parent = nil then result := fDefaultNamespace
  else result := coalesce(fDefaultNamespace, XmlElement(Parent).DefaultNamespace);
end;

{method XmlElement.GetValue: nullable String;
begin
  result := "";
  for each lNode in Nodes do begin
    if result <> "" then result := result+" ";
    if lNode.NodeType = XmlNodeType.Text then result := result+XmlText(lNode).Value
    else if lNode.NodeType = XmlNodeType.Element then result := result+XmlElement(lNode).GetValue;
  end;
end;}

method XmlElement.GetValue(aWithNested: Boolean): nullable String;
begin
  result := "";
  for each lNode in Nodes do begin

    if (lNode.NodeType = XmlNodeType.Text) and (XmlText(lNode).Value.Trim <> "") then begin
        if result <> "" then result := result+" ";
        result := result+XmlText(lNode).Value.Trim
    end
    else if lNode.NodeType = XmlNodeType.Element then
      if aWithNested then begin
        if result <> "" then result := result+" ";
          result := result+XmlElement(lNode).GetValue(true);
      end
  end
end;
method XmlElement.SetValue(aValue: nullable String);
begin
  fNodes.RemoveAll;
  AddNode(new XmlText(self, Value := aValue));
end;

method XmlElement.GetAttributes: not nullable sequence of XmlAttribute;
begin
  result := fAttributes as not nullable;
end;

method XmlElement.GetAttribute(aName: not nullable String): nullable XmlAttribute;
begin
  result := Attributes.Where(a -> a.LocalName = aName).FirstOrDefault;
end;

method XmlElement.GetAttribute(aName: not nullable String; aNamespace: nullable XmlNamespace): nullable XmlAttribute;
begin
  result := Attributes.Where(a -> (a.LocalName = aName) and (a.Namespace = aNamespace)).FirstOrDefault;
end;

method XmlElement.GetElements: not nullable sequence of XmlElement;
begin
  result := fElements as not nullable;
end;

method XmlElement.GetNamespaces: not nullable sequence of XmlNamespace;
begin
  result := fNamespaces as not nullable;
end;

method XmlElement.GetNamespace(aUrl: Url): nullable XmlNamespace;
begin
  result := DefinedNamespaces.Where(a -> a.Url = aUrl).FirstOrDefault;
end;

method XmlElement.GetNamespace(aPrefix: String): nullable XmlNamespace;
begin
  result := DefinedNamespaces.Where(a -> a.Prefix = aPrefix).FirstOrDefault;
end;

method XmlElement.AddNamespace(aNamespace: not nullable XmlNamespace);
begin
  if GetNamespace(aNamespace.Prefix) = nil then begin
    fNamespaces.Add(aNamespace);
    if (aNamespace.Prefix = nil) or (aNamespace.Prefix = "") then fDefaultNamespace := aNamespace;
  end
  else if aNamespace.Prefix=nil then raise new Exception("Duplicate namespace xmlns")
    else  raise new Exception("Duplicate namespace xmlns:"+aNamespace.Prefix);
end;

method XmlElement.AddNamespace(aPrefix: nullable String; aUrl: not nullable Url): XmlNamespace;
begin
  result := new XmlNamespace(aPrefix, aUrl);
  AddNamespace(result);
end;

method XmlElement.RemoveNamespace(aNamespace: not nullable XmlNamespace);
begin
  fNamespaces.Remove(aNamespace);
end;

method XmlElement.RemoveNamespace(aPrefix: not nullable String);
begin
  var lNamespace := DefinedNamespaces.Where(a -> a.Prefix = aPrefix).FirstOrDefault;
  fNamespaces.Remove(lNamespace);
end;

method xmlElement.ToString(): String;
begin
  result := ToString(false, false, false);
end;

method XmlElement.ToString(aSaveFormatted: Boolean; aFormatInsideTags: Boolean; aPreserveExactStringsForUnchnagedValues: Boolean): String;
begin
  var str: String;
  result := "<";
  if (&Namespace <> nil) and (&Namespace.Prefix<>"") and (&Namespace.Prefix <> nil) then
    result := result+&Namespace.Prefix+":";
  result := result + fLocalName;
  for each defNS in DefinedNamespaces do begin
    str := "";
    if not(aFormatInsideTags) and (defNS.WSleft <> nil) then str := defNS.WSleft;
    str := str +defNS.ToString(aFormatInsideTags);
    if not(aFormatInsideTags) and (defNS.WSright <> nil) then str := str + defNS.WSright;
    if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
      result := result+" ";
    result := result+str;
  end;
  for each attr in Attributes do begin
    str := "";
    if not(aFormatInsideTags) and (attr.WSleft <> nil) then str := attr.WSleft;
    str := str + attr.ToString(aFormatInsideTags, aPreserveExactStringsForUnchnagedValues);
    if not (aFormatInsideTags) and (attr.WSright <> nil) then str := str + attr.WSright;
    if not(CharIsWhitespace(result[result.Length-1])) and not(CharIsWhitespace(str[0])) then
      result := result+" ";
    result := result+str;

  end;
  if IsEmpty then begin
    if (Document <> nil) then begin
      if (aFormatInsideTags) then begin
        if (Document.fFormatOptions.EmptyTagSyle <> XmlTagStyle.PreferOpenAndCloseTag) and Document.fFormatOptions.SpaceBeforeSlashInEmptyTags and
          not (CharIsWhitespace(result[result.Length-1])) then
          result := result + " ";
        result := result + "/>"
      end
      else begin
        if (Document.fXmlParser <> nil) and (Document.fXmlParser.FormatOptions.SpaceBeforeSlashInEmptyTags) and
          not (CharIsWhitespace(result[result.Length-1])) then
          result := result+ " ";
        result := result +"/>";
      end;

    end;
  end;
  if fNodes.count > 0 then result := result +">";
  /********/
  var lFormat := false;
  var indent : String := "";
  if aSaveFormatted and (Document.fFormatOptions.WhitespaceStyle = XmlWhitespaceStyle.PreserveWhitespaceAroundText) then begin
    if Document.fFormatOptions.NewLineForElements  then lFormat := true;
    var i := 0;
    if lFormat  and (fNodes.count > 0) then begin
      var n := fNodes[0];
      while n.Parent<>nil do begin
        indent := indent+Document.fFormatOptions.Indentation;
        n := n.Parent;
      end;
    end;

    for each aNode in fNodes do begin
      if (aNode.NodeType = XmlNodeType.Text) then
        if (XmlText(aNode).Value.Trim <> "") then begin
          if (i > 0) and (fNodes[i-1].NodeType = XmlNodeType.Text) and (XmlText(fNodes[i-1]).Value.Trim = "") then
            result := result + fNodes[i-1].ToString(aSaveFormatted, aFormatInsideTags, aPreserveExactStringsForUnchnagedValues);
          result := result+ aNode.ToString(aSaveFormatted, aFormatInsideTags, aPreserveExactStringsForUnchnagedValues);
          if (i < fNodes.Count-1) and (fNodes[i+1].NodeType = XmlNodeType.Text) and (XmlText(fNodes[i+1]).Value.Trim = "") then begin
            str := fNodes[i+1].ToString(aSaveFormatted, aFormatInsideTags, aPreserveExactStringsForUnchnagedValues);
            if str.IndexOf(Document.fLineBreak) > -1 then
              str := str.Substring(0, str.LastIndexOf(Document.fLineBreak));
            result := result + str;
          end;
        end;
      if (aNode.NodeType <> XmlNodeType.Text) then
        if lFormat then
          result := result + Document.fLineBreak + indent + aNode.ToString(aSaveFormatted, aFormatInsideTags)
        else result := result + aNode.tostring(aSaveFormatted, aFormatInsideTags);
      inc(i);
    end;
  end
  /******/
  else
    for each aNode in fNodes do
      result := result + aNode.ToString(aSaveFormatted, aFormatInsideTags, aPreserveExactStringsForUnchnagedValues);
  if IsEmpty = false then begin
    if (fNodes.Count = 0) and (aFormatInsideTags) and (Document.fFormatOptions.EmptyTagSyle = XmlTagStyle.PreferSingleTag) then
      if Document.fFormatOptions.SpaceBeforeSlashInEmptyTags and not (CharIsWhitespace(result[result.Length-1])) then
        result := result + " />"
      else
        result := result+"/>"
    else begin
      if fNodes.Count = 0 then result := result + ">";
      if lFormat and (Elements.Count > 0) then begin
        result := result +Document.fLineBreak;
        if Indent.LastIndexOf(Document.fFormatOptions.Indentation) > -1 then result := result+Indent.Substring(0, Indent.LastIndexOf(Document.fFormatOptions.Indentation));
      end;
      result := result+"</";
      if (&Namespace <> nil) and (&Namespace.Prefix <> "") and (&Namespace.Prefix <> nil) then
        result := result+&Namespace.Prefix+':';
      if EndTagName <> nil then result := result+ EndTagName+">"
      else result := result + LocalName+">";
    end;
  end;
end;

{ XmlAttribute }

constructor XmlAttribute withParent(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Attribute;
end;

constructor XmlAttribute(aLocalName: not nullable String; aNamespace: nullable XmlNamespace; aValue: not nullable String);
begin
  fLocalName := aLocalName;
  fNamespace := aNamespace;
  inherited constructor;
  setValue(aValue);
  fNodeType := XmlNodeType.Attribute;
end;

method XmlAttribute.GetLocalName: not nullable String;
begin
  //result := fLocalName as not nullable;
  /*if fLocalName.IndexOf("=") > -1 then begin
    result := fLocalName.Substring(0, fLocalName.IndexOf("="));
  end;*/
  result := fLocalName.Trim as not nullable;
end;

method XmlAttribute.GetNamespace: XmlNamespace;
begin
  result := fNamespace;
end;

method XmlAttribute.SetNamespace(aNamespace: not nullable XmlNamespace);
begin
  fNamespace := aNamespace;
end;

method XmlAttribute.GetValue: not nullable String;
begin
  result := fValue as not nullable;
end;

method XmlAttribute.SetLocalName(aValue: not nullable String);
begin
  fLocalName := aValue;
end;

method XmlAttribute.SetValue(aValue: not nullable String);
begin
  originalRawValue := nil;
  fValue := aValue;
end;

method XmlAttribute.ToString(): String;
begin
  result := ToString(false);
end;

method XmlAttribute.ToString(aFormatInsideTags: Boolean; aPreserveExactStringsForUnchnagedValues: Boolean): String;
begin
  result := "";
  if (Document <> nil) and aFormatInsideTags and Document.fFormatOptions.NewLineForAttributes then begin
    var indent :="";
    var lNode: XmlNode;
    lNode:=Parent;
    while lNode <> nil do begin
      indent := indent + Document.fFormatOptions.Indentation;
      lNode := lNode.Parent;
    end;
    result := result + Document.fLineBreak+indent;
  end;
  if &Namespace<>nil then result := result+&Namespace.Prefix+":";
  result := result + LocalName;
  if not(aFormatInsideTags) and (innerWSleft <> nil) then result := result + innerWSleft;
  result := result + "=";
  if not(aFormatInsideTags) and (innerWSright <> nil) then result := result + innerWSright;
  result := result + QuoteChar;
  if (originalRawValue <> nil) and (aPreserveExactStringsForUnchnagedValues) then result := result + originalRawValue
  else result := result + ConvertEntity(Value, QuoteChar);
  result := result+QuoteChar;
end;

{ XmlNamespace}
constructor XmlNamespace withParent(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Namespace;
end;

constructor XmlNamespace(aPrefix: String; aUrl: not nullable Url);
begin
  inherited constructor;
  Prefix := aPrefix;
  Url := aUrl;
  fNodeType := XmlNodeType.Namespace;
end;

method XmlNamespace.GetPrefix: String;
begin
  if fPrefix = nil then exit nil
  else exit fPrefix.Trim;
end;

method XmlNamespace.SetPrefix(aPrefix: String);
begin
  fPrefix := aPrefix;
end;


method XmlNamespace.ToString(): String;
begin
  result := ToString(false);
end;

method XmlNamespace.ToString(aFormatInsideTags: Boolean): String;
begin
  result := "";
  if (Document <> nil) and aFormatInsideTags and Document.fFormatOptions.NewLineForAttributes then begin
    var indent :="";
    var lNode: XmlNode := Parent;
    while lNode <> nil do begin
      indent := indent + Document.fFormatOptions.Indentation;
      lNode := lNode.Parent;
    end;
    result := result + Document.fLineBreak+Indent;
  end;
  result := result+"xmlns";
  if (Prefix <> "") and (Prefix <> nil) then result := result+':'+Prefix;
  if not(aFormatInsideTags) and (innerWSleft <> nil) then result := result + innerWSleft;
  result := result + "=";
  if not(aFormatInsideTags) and (innerWSright <> nil) then result := result + innerWSright;
  result := result +QuoteChar+ Url.ToString+QuoteChar;
end;

{XmlComment}
constructor XmlComment(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Comment;
end;

{XmlCData}
constructor XmlCData(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.CData;
end;

{XmlText}

constructor XmlText(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.Text;
end;

method XmlText.GetValue: String;
begin
  result := fValue;
end;

method XmlText.SetValue(aValue: String);
begin
  originalRawValue := nil;
  fValue := aValue;
end;

{XmlProcessingInstructions}

constructor XmlProcessingInstruction(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.ProcessingInstruction;
end;

constructor XmlDocumentType(aParent: XmlNode);
begin
  inherited constructor withParent(aParent);
  fNodeType := XmlNodeType.DocumentType;
end;

end.