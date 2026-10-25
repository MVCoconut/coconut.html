package coconut.html.macros;

#if macro
import coconut.ui.macros.*;
import tink.domspec.Macro.tags;
import haxe.macro.Context;
import haxe.macro.Expr;
import tink.hxx.*;

using tink.MacroApi;

class Setup {

  static function perform() {
  }

  static inline var NAMELESS = '';

  static var attrNames:Map<String, String>;

  /**
    The name an attribute is rendered with: as declared with `@:html` in tink_domspec, otherwise lower cased.
  **/
  static public function attrName(field:String):String {
    if (attrNames == null) {
      attrNames = ['styleCss' => 'style'];
      for (tag in tags)
        for (f in tag.attr.toType().sure().getFields().sure())
          switch f.meta.extract(':html') {
            case [{ params: [{ expr: EConst(CString(html)) }] }]: attrNames[f.name] = html;
            default:
          }
    }
    return switch attrNames[field] {
      case null: field.toLowerCase();
      case v: v;
    }
  }

  static function addTags() {

    var ret = Context.getBuildFields();

    var events = switch Context.getType('tink.domspec.EventsStructure') {
      case TType(_, params):
        'tink.domspec.EventsStructure'.asComplexType([for (t in params) TPType(macro : coconut.html.FakeCallback)]);
      default:
        throw 'assert';
    }

    for (name => tag in tags) {

      ret.push({
        name: name,
        pos: tag.pos,
        access: [AStatic, APublic, AInline],
        kind: FFun({
          var args = [
            {
              name: 'hxxMeta',
              type: macro : HxxMeta,
              opt: false
            },
            {
              name: 'attr',
              type: [
                tag.attr,
                macro : $events,
                macro : {
                  @:hxxCustomAttributes(~/^(data-|aria-)/)
                  @:optional var $NAMELESS(default, never):coconut.html.Html.AttrValue;
                  @:hxx('style') @:optional var styleCss:String;
                },
              ].concat(switch name {
                case 'select': [macro : {
                  @:optional var value(default, never):haxe.extern.EitherType<String, Array<String>>;
                }];
                default: [];
              }).intersect().sure(),
              opt: false
            }
          ];
          var callArgs = [macro $v{name}, macro $v{tag.kind == VOID}, macro cast attr];
          if (tag.kind != VOID) {
            args.push({
              name: 'children',
              type: macro : coconut.html.Children,
              opt: true
            });
            callArgs.push(macro children);
          }
          {
            args: args,
            expr: {
              var cls = (switch name {
                case 'select': 'Select';
                case 'option': 'Option';
                default: 'Tag';
              }).asTypePath();
              macro return new $cls($a{callArgs});
            },
            ret: macro : coconut.html.RenderResult
          }
        })
      });

    }

    attrName('');

    ret.push({
      name: 'attrName',
      pos: Context.currentPos(),
      access: [AStatic, APublic],
      kind: FFun({
        args: [{ name: 'field', type: macro : String }],
        ret: macro : String,
        expr: macro return ${ESwitch(
          macro field,
          [for (field => html in attrNames) { values: [macro $v{field}], expr: macro $v{html} }],
          macro field.toLowerCase()
        ).at()},
      })
    });

    return ret;
  }
}
#end