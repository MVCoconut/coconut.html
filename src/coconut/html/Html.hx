package coconut.html;

import haxe.DynamicAccess;
import coconut.html.RenderResult;
import tink.HtmlString;

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

@:transitive
abstract AttrValue(Dynamic) from Int from String from Bool from Float {
  public inline function toString():Null<String>
    return
      #if js
        switch js.Lib.typeof(this) {
          case 'string': HtmlString.escape(this);
          case 'boolean' if (this): '';
          case 'number': '' + (this:Float);
          default: null;
        }
      #else
        switch Type.typeof(this) {
          case TBool if (this): '';
          case TInt: '' + (this:Int);
          case TFloat: '' + (this:Float);
          case TClass(String): HtmlString.escape(this);
          default: null;
        }
      #end
}

private class Tag implements RenderResultObject {
  final tag:String;
  final isVoid:Bool;
  final attr:DynamicAccess<AttrValue>;
  final children:Children;

  public function new(tag, isVoid, attr, ?children) {
    this.tag = tag;
    this.isVoid = isVoid;
    this.attr = attr;
    this.children = children;
  }

  public function renderInto(implicits, buf:HtmlBuffer):Void {
    buf.addRaw('<$tag');

    if (attr != null)
      for (key => val in attr)
        renderAttr(buf, key, val);

    buf.addRaw('>');

    if (isVoid) return;

    renderChildren(implicits, buf);
    buf.addRaw('</$tag>');
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
  The generator only folds selects without a value into plain markup, and options never (see OptionTag).
**/
private class Select extends Tag {

  override function renderAttr(buf:HtmlBuffer, key:String, val:AttrValue)
    if (key != 'value') super.renderAttr(buf, key, val);

  override function renderChildren(implicits, buf:HtmlBuffer) {
    var prev = SelectValue.current;
    SelectValue.current = switch get('value') {
      case null: null;
      case value: new SelectValue(value, get('multiple') == true);
    }
    super.renderChildren(implicits, buf);
    SelectValue.current = prev;
  }
}

@:noCompletion class SelectValue {

  static public var current:Null<SelectValue>;

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
  override public function renderInto(implicits, buf:HtmlBuffer) {
    var open = new HtmlBuffer();
    open.addRaw('<option');
    if (attr != null)
      for (key => val in attr)
        if (key != 'selected')
          renderAttr(open, key, val);
    OptionTag.render(implicits, buf, open.toString(), get('value'), get('selected') == true, children);
  }
}

/**
  An `<option>` with all attributes but `selected` already rendered into `open`.
**/
@:noCompletion class OptionTag implements RenderResultObject {

  final open:String;
  final value:Null<String>;
  final selected:Bool;
  final children:Null<Children>;

  public function new(open, value, selected, children) {
    this.open = open;
    this.value = value;
    this.selected = selected;
    this.children = children;
  }

  public function renderInto(implicits, buf:HtmlBuffer)
    render(implicits, buf, open, value, selected, children);

  static public function render(implicits, buf:HtmlBuffer, open:String, value:Null<String>, selected:Bool, children:Null<Children>) {

    inline function renderChildren(buf:HtmlBuffer)
      if (children != null)
        for (c in children)
          c.renderInto(implicits, buf);

    switch SelectValue.current {
      case null:
      case select:
        if (value == null) {
          var content = new HtmlBuffer();
          renderChildren(content);
          var content = content.toString();
          // the option's text, like the DOM's HTMLOptionElement.value
          selected = select.selects(~/[ \t\n\x0C\r]+/g.replace(content, ' ').trim().htmlUnescape());
          buf.addRaw(open + (if (selected) ' selected>' else '>') + content + '</option>');
          return;
        }
        selected = select.selects(value);
    }

    buf.addRaw(open + (if (selected) ' selected>' else '>'));
    renderChildren(buf);
    buf.addRaw('</option>');
  }
}
