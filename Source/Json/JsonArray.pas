﻿namespace RemObjects.Elements.RTL;

interface

type
  JsonArray = public class (JsonNode, ISequence<JsonNode>)
  private
    fItems: List<JsonNode>;
    method GetItem(&Index: Integer): not nullable JsonNode;
    method SetItem(&Index: Integer; Value: not nullable JsonNode);

  public
    constructor;
    constructor(aItems: List<JsonNode>);

    method &Add(Value: not nullable JsonNode);
    method Insert(&Index: Integer; Value: not nullable JsonNode);
    method Clear;
    method &RemoveAt(&Index: Integer);

    method ToStrings: not nullable sequence of String;
    method ToStringList: not nullable List<String>;

    method ToJson: String; override;

    {$IF COOPER}
    method &iterator: java.util.&Iterator<JsonNode>;
    {$ELSEIF ECHOES}
    method GetNonGenericEnumerator: System.Collections.IEnumerator; implements System.Collections.IEnumerable.GetEnumerator;
    method GetEnumerator: System.Collections.Generic.IEnumerator<JsonNode>;
    {$ELSEIF ISLAND}
    method GetNonGenericEnumerator(): IEnumerator; implements IEnumerable.GetEnumerator;
    method GetEnumerator(): IEnumerator<JsonNode>;
    {$ELSEIF TOFFEE}
    {$HIDE CPW8}
    method countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^JsonNode) count(len: NSUInteger): NSUInteger;
    {$SHOW CPW8}
    {$ENDIF}

    class method Load(JsonString: String): not nullable JsonArray;

    property Count: Integer read fItems.Count; override;
    property Item[&Index: Integer]: not nullable JsonNode read GetItem write SetItem; default; override;
  end;

implementation

constructor JsonArray;
begin
  fItems := new List<JsonNode>();
end;

constructor JsonArray(aItems: List<JsonNode>);
begin
  fItems := aItems;
end;

method JsonArray.GetItem(&Index: Integer): not nullable JsonNode;
begin
  exit fItems[&Index];
end;

method JsonArray.SetItem(&Index: Integer; Value: not nullable JsonNode);
begin
  ArgumentNullException.RaiseIfNil(Value, "Value");
  fItems[&Index] := Value;
end;

method JsonArray.Add(Value: not nullable JsonNode);
begin
  fItems.Add(Value);
end;

method JsonArray.Insert(&Index: Integer; Value: not nullable JsonNode);
begin
  fItems.Insert(&Index, Value);
end;

method JsonArray.Clear;
begin
  fItems.RemoveAll;
end;

method JsonArray.RemoveAt(&Index: Integer);
begin
  fItems.RemoveAt(&Index);
end;

class method JsonArray.Load(JsonString: String): not nullable JsonArray;
begin
  var Serializer := new JsonDeserializer(JsonString);
  var lValue := Serializer.Deserialize;

  if not (lValue is JsonArray) then
    raise new InvalidOperationException("String does not contains valid Json array");

  result := lValue as JsonArray;
end;

method JsonArray.ToJson: String;
begin
  var Serializer := new JsonSerializer(self);
  exit Serializer.Serialize;
end;

{$IF COOPER}
method JsonArray.&iterator: java.util.Iterator<JsonNode>;
begin
  exit Iterable<JsonNode>(fItems).iterator;
end;
{$ELSEIF ECHOES}
method JsonArray.GetNonGenericEnumerator: System.Collections.IEnumerator;
begin
  exit GetEnumerator;
end;

method JsonArray.GetEnumerator: System.Collections.Generic.IEnumerator<JsonNode>;
begin
  exit System.Collections.Generic.IEnumerable<JsonNode>(fItems).GetEnumerator;
end;
{$ELSEIF ISLAND}
method JsonArray.GetNonGenericEnumerator: IEnumerator;
begin
  exit GetEnumerator;
end;

method JsonArray.GetEnumerator: IEnumerator<JsonNode>;
begin
  exit IEnumerable<JsonNode>(fItems).GetEnumerator;
end;
{$ELSEIF TOFFEE}
method JsonArray.countByEnumeratingWithState(aState: ^NSFastEnumerationState) objects(stackbuf: ^JsonNode) count(len: NSUInteger): NSUInteger;
begin
  exit NSArray(fItems).countByEnumeratingWithState(aState) objects(^id(stackbuf)) count(len);
end;
{$ENDIF}

method JsonArray.ToStrings: not nullable sequence of String;
begin
  result := self.Where(i -> i is JsonStringValue).Select(i -> i.StringValue) as not nullable;
end;

method JsonArray.ToStringList: not nullable List<String>;
begin
  result := ToStrings().ToList() as not nullable;
end;

end.