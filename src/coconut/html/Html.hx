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
      for (key => val in attr)
        renderAttr(buf, key, val);

    switch children {
      case null:
        buf.addRaw('/>');
      default:
        buf.addRaw('>');
        renderChildren(implicits, buf);
        buf.addRaw('</$tag>');
    }
  }

  function renderAttr(buf:HtmlBuffer, key:String, val:AttrValue) {
    key = Html.attrName(key);

    switch val.toString() {
      case null:
      case '': buf.addRaw(' $key');
      case v: buf.addRaw(' $key="$v"');
    }
  }

  function renderChildren(implicits, buf:HtmlBuffer)
    for (c in children)
      c.renderInto(implicits, buf);

  function get(name:String):Dynamic
    return if (attr == null) null else attr[name];
}

/**
  Supports `value` on `<select>` as React does: the options rendered within get `selected` if their value matches.
**/
private class Select extends Tag {

  static public var current(default, null):Null<SelectValue>;

  override function renderAttr(buf:HtmlBuffer, key:String, val:AttrValue)
    if (key != 'value') super.renderAttr(buf, key, val);

  override function renderChildren(implicits, buf:HtmlBuffer) {
    var prev = current;
    current = switch get('value') {
      case null: null;
      case value: new SelectValue(value, get('multiple') == true);
    }
    super.renderChildren(implicits, buf);
    current = prev;
  }
}

private class SelectValue {
  final values:Array<String>;
  final multiple:Bool;
  var matched = false;

  public function new(value:Dynamic, multiple:Bool) {
    this.multiple = multiple || Std.isOfType(value, Array);
    this.values = if (Std.isOfType(value, Array)) value else [value];
  }

  public function selects(value:String) {
    if ((matched && !multiple) || !values.contains(value))
      return false;
    return matched = true;
  }
}

private class Option extends Tag {
  override public function renderInto(implicits, buf:HtmlBuffer)
    switch Select.current {
      case null:
        super.renderInto(implicits, buf);
      case select:
        var content = new HtmlBuffer();
        if (children != null)
          renderChildren(implicits, content);
        var content = content.toString();

        var selected = select.selects(switch get('value') {
          case null: ~/[ \t\n\x0C\r]+/g.replace(content, ' ').trim().htmlUnescape();// like the DOM's HTMLOptionElement.value
          case value: value;
        });

        buf.addRaw('<option');

        if (attr != null)
          for (key => val in attr)
            if (key != 'selected')
              renderAttr(buf, key, val);

        if (selected)
          buf.addRaw(' selected');

        buf.addRaw('>$content</option>');
    }
}
