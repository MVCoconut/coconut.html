package coconut.html.macros;

#if macro
import haxe.macro.Type;
import tink.hxx.StringAt;
import tink.hxx.Tag;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using StringTools;
using tink.MacroApi;

class Generator extends tink.hxx.Generator {

  static final attrTypes = new Map<String, Map<String, Type>>();

  static function unwrap(e:Expr) 
    return if (e == null) null else switch e.expr {
      case EParenthesis(e) | ECheckType(e, _) | ECast(e, _): unwrap(e);
      default: e;
    }

  static function tUnwrap(e:TypedExpr)
    return switch e.expr {
      case TParenthesis(e) | TCast(e, _) | TMeta(_, e): tUnwrap(e);
      default: e;
    }

  override function childList(c:tink.hxx.Node.Children, ?t:Type):{expr:ExprDef, pos:Position} {
    return 
      if (t != null && t.toString() == 'coconut.html.Children' && c == null || c.value.length == 0) macro [];
      else super.childList(c, t);
  }

  override function invoke(name:StringAt, create:TagCreate, args:Array<Expr>, pos:Position):{expr:ExprDef, pos:Position} {

    var tagName = name.value;

    switch tink.domspec.Macro.tags[tagName] {
      case null:
      case tag: 

        switch Context.typeExpr(macro @:pos(name.pos) $i{name.value}).expr {
          case TField(_, FStatic(_.toString() => 'coconut.html.Html', _)):
          default: return super.invoke(name, create, args, pos);
        }

        switch unwrap(args[1]).expr {
          case EObjectDecl(fields):
            if (tagName == 'select' && Lambda.exists(fields, f -> f.field == 'value'))
              return super.invoke(name, create, args, pos);// the options need it at runtime, see coconut.html.Html.Select

            var dyn = [];
            var stat = [];

            // options must check the select they're in at runtime, see coconut.html.Html.OptionTag
            var isOption = tagName == 'option',
                value = macro null,
                selected = macro false,
                vars = [];

            var types = switch attrTypes[tagName] {
              case null: attrTypes[tagName] = [for (f in tag.attr.toType().sure().getFields().sure()) f.name => f.type];
              case v: v;
            }

            // non-constants are typed against the attribute's declared type, so that implicit casts apply (e.g. Map to ClassName)
            function typed(f:ObjectField)
              return switch [tUnwrap(Context.typeExpr(f.expr)), types[f.field]] {
                case [e = { expr: TConst(_) }, _] | [e, null]: e;
                case [_, t]:
                  var ct = t.toComplex();
                  tUnwrap(Context.typeExpr(macro @:pos(f.expr.pos) (${f.expr} : $ct)));
              }

            for (f in fields) switch typed(f) {
              case e if (isOption && f.field == 'selected'):
                selected = Context.storeTypedExpr(e);
              case e = { expr: TConst(c) }:
                if (isOption && f.field == 'value')
                  value = Context.storeTypedExpr(e);
                switch c {
                  case TInt(Std.string(_) => s)
                    | TFloat(s) | TString(_.htmlEscape(true) => s):
                    stat.push(' ${Setup.attrName(f.field)}="$s"');
                  case TBool(b):
                    if (b) 
                      stat.push(' ${Setup.attrName(f.field)}');
                  default:
                }
                
              case e:
                var v = Context.storeTypedExpr(e),
                    attr = ' ${Setup.attrName(f.field)}';

                if (isOption && f.field == 'value') {
                  vars.push(macro var __coco_optionValue = $v);
                  v = value = macro __coco_optionValue;
                }

                dyn.push(
                  switch Context.followWithAbstracts(e.t).toString() {
                    case 'Bool': macro if ($v) $v{attr} else '';
                    case 'Int' | 'Float':
                      attr += '="';
                      macro $v{attr} + $v + '"';
                    case 'String':
                      attr += '="';
                      macro $v{attr} + tink.HtmlString.escape($v) + '"';
                    case t: e.pos.error('Cannot handle ${t.toString()}'); 
                  }
                );
            }

            var start = '<${tagName}${stat.join('')}';

            var noArgs = switch unwrap(args[2]) {
              case null, macro null, macro []: true;
              default: false;
            }

            if (isOption) {
              var open = macro $v{start};
              for (a in dyn)
                open = macro $open + $a;
              var children = if (noArgs) macro null else args[2];
              vars.push(macro (new coconut.html.Html.OptionTag($open, $value, $selected, $children) : coconut.html.RenderResult));
              return macro $b{vars};
            }

            var end = 
              if (noArgs) 
                if (tag.kind == VOID) '>';
                else '></$tagName>';
              else '>';

            var open = 
              switch dyn {
                case []: 
                  macro $v{start + end};
                default: 
                  var e = macro $v{start};
                  for (a in dyn)
                    e = macro $e + $a;
                  macro $e + $v{end};
              }

            open = raw(open);

            if (noArgs)
              return open;
            else {
              var close = macro $v{'</$tagName>'};
              close = raw(close);
              
              return switch unwrap(args[2]) {
                case macro [$e]:
                  macro coconut.html.RenderResult.fragment({}, [$open, $e, $close]);
                case e: 
                  macro coconut.html.RenderResult.fragment({}, {
                    var __open = $open;
                    $e.prepend(__open).append($close);
                  });
              }
            }
          default:
        }
    }
    return super.invoke(name, create, args, pos);
  }

  static function raw(e)
    return macro coconut.html.RenderResult.raw(new tink.HtmlString($e));
}
#end