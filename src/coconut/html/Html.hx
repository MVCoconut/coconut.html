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

  public function renderInto(_, buf:HtmlBuffer):Void {
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
  public inline function toString():Null<String>
    return
      #if js
        switch js.Lib.typeof(this) {
          case 'string': tink.HtmlString.escape(this);
          case 'boolean' if (this): '';
          case 'number': '' + (this:Float);
          default: null;
        }
      #else
        switch Type.typeof(this) {
          case TBool if (this): '';
          case TInt: '' + (this:Int);
          case TFloat: '' + (this:Float);
          case TClass(String): tink.HtmlString.escape(this);
          default: null;
        }
      #end
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

  public function renderInto(implicits, buf:HtmlBuffer):Void {
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
          c.renderInto(implicits, buf);
        buf.addRaw('</$tag>');
    }
  }
}
