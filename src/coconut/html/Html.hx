package coconut.html;

import haxe.DynamicAccess;
import coconut.html.RenderResult;
using StringTools;

@:build(coconut.html.macros.Setup.addTags())
class Html {
  static public function raw(hxxMeta:HxxMeta, attr:HtmlFragmentAttr)
    return new HtmlFragment(attr);
}

private class HtmlFragment implements RenderResultObject {

  final attr:HtmlFragmentAttr;
  public function new(attr)
    this.attr = attr;

  public function renderInto(buf:HtmlBuffer):Void {
    var tag = switch attr.tag {
      case null: 'div';
      case v: v;
    }

    buf.addRaw('<$tag');

    buf.addRaw(switch attr.className {
      case null: '>';
      case v: ' class="${(v:String).htmlEscape()}">';
    });

    buf.addRaw(attr.content + '</$tag>');
  }
}

private typedef HtmlFragmentAttr = { content:String, ?className:tink.domspec.ClassName, ?tag:String };

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
          case 'htmlFor': 'html';
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