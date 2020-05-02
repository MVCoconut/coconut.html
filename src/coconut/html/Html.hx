package coconut.html;

import haxe.DynamicAccess;
import coconut.html.RenderResult;

@:build(coconut.html.macros.Setup.addTags())
class Html {
}

private class Tag implements RenderResultObject {
  final tag:String;
  final attr:DynamicAccess<Dynamic>;
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
          default: key.toLowerCase();
        }
        switch Type.typeof(val) {
          case TBool: if (val) buf.addRaw(' $key');
          case TInt: buf.addRaw(' $key="${(val:Int)}"');
          case TClass(String):
            buf.addRaw(' $key="${tink.HtmlString.escape(val)}"');
          default:
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
private typedef HxxMeta<T> = {
  @:optional var key(default, never):Key;
  @:optional var ref(default, never):coconut.ui.Ref<T>;
}