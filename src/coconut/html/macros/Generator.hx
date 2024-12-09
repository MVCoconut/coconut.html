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
            var dyn = [];
            var stat = [];

            for (f in fields) switch tUnwrap(Context.typeExpr(f.expr)) {
              case { expr: TConst(c) }:
                switch c {
                  case TInt(Std.string(_) => s)
                    | TFloat(s) | TString(_.htmlEscape() => s):
                    stat.push(' ${f.field}="$s"');
                  case TBool(b):
                    if (b) 
                      stat.push(' ${f.field}');
                  default:
                }
                
              case e:
                var v = Context.storeTypedExpr(e),
                    attr = ' ${f.field}';

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