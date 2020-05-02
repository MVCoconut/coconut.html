package coconut.html;

@:pure
abstract RenderResult(RenderResultObject) to RenderResultObject from RenderResultObject {

  inline function new(n) this = n;

  public inline function renderInto(buf)
    if (this != null) this.renderInto(buf);

  public inline function getHtml()
    return new tink.HtmlString(switch this {
      case null: '';
      case v:
        var buf = new HtmlBuffer();
        this.renderInto(buf);
        buf.toString();
    });

  @:from static inline function ofText(s:String):RenderResult
    return new Text(s);

  @:from static function ofInt(i:Int):RenderResult
    return ofText(Std.string(i));
}

interface RenderResultObject {
  function renderInto(buffer:HtmlBuffer):Void;
}

private class Text implements RenderResultObject {

  final text:String;

  public function new(text)
    this.text = text;

  public function renderInto(buffer:HtmlBuffer)
    buffer.add(text);
}