package coconut.html;

import haxe.DynamicAccess;
import coconut.html.RenderResult;

@:build(coconut.html.macros.Setup.addTags())
class Html {
}

abstract AttrValue(Dynamic) from Int from String from Bool from Float {
  public inline function toString():Null<String> {
    return switch Type.typeof(this) {
      case TBool if (this): '';
      case TInt: '' + (this:Int);
      case TFloat: '' + (this:Float);
      case TClass(String): tink.HtmlString.escape(this);
      default: null;
    }
  }
}

private class Tag implements RenderResultObject {
  final tag:String;
  final attr:DynamicAccess<AttrValue>;
  final children:Children;

  public function new(tag, attr, ?children) {
    this.tag = tag;
    this.attr = attr;
    this.children = children;
  }

  public function renderInto(buf:HtmlBuffer):Void {
    buf.addRaw('<$tag');

    if (attr != null)
      for (key => val in attr) {
        key = switch key {
          case 'className': 'class';
          case 'htmlFor': 'for';
          case 'styleCss': 'style';
          default: key.toLowerCase();
        }

        switch val.toString() {
          case null:
          case '': buf.addRaw(' $key');
          case v: buf.addRaw(' $key="$v"');
        }
      }

    switch children {
      case null:
        buf.addRaw('/>');
      default:
        buf.addRaw('>');
        for (c in children)
          c.renderInto(buf);
        buf.addRaw('</$tag>');
    }
  }
}
