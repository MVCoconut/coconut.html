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

  static public function raw(s):RenderResult // for some reason @:from here won't work
    return new Plain(s);

  @:from static inline function ofText(s:String):RenderResult
    return raw(s);

  @:from static function ofInt(i:Int):RenderResult
    return raw(Std.string(i));

  static public inline function fragment(attr:{}, children:Children):RenderResult
    return new Fragment(children);
}

interface RenderResultObject {
  function renderInto(buffer:HtmlBuffer):Void;
}

private class Plain implements RenderResultObject {

  final plain:tink.HtmlString;

  public function new(plain)
    this.plain = plain;

  public function renderInto(buffer:HtmlBuffer)
    buffer.add(plain);
}

private class Fragment implements RenderResultObject {
  final parts:Children;

  public function new(parts)
    this.parts = parts;

  public function renderInto(buffer:HtmlBuffer)
    for (p in parts) p.renderInto(buffer);
}