package coconut.html;

import haxe.macro.Expr;
using tink.MacroApi;

class View {
  static function hxx(_, e)
    return coconut.html.macros.HXX.parse(e);

  static function build()
    return
      coconut.ui.macros.ViewBuilder.autoBuild({
        renders: macro : coconut.html.RenderResult,
        afterBuild: ctx -> {

          var c = ctx.target;

          c.getConstructor().onGenerate(f -> {
            f.args.unshift({
              name: 'hxxMeta',
              type: macro : coconut.html.HxxMeta
            });
          });

          for (l in ctx.lifeCycle) {
            var fn = l.getFunction().sure();
            fn.expr = switch fn.ret {
              case macro : Void: macro @:pos(l.pos) {};
              default: macro @:pos(l.pos) return null;
            }
          }

          for (ref in ctx.refs) {
            c.removeMember(ref.field);
            c.removeMember(ref.setter);
            var name = ref.field.name;
            c.addMembers(macro class {
              var $name:Dynamic;
            });
          }

          for (f in c)
            if (f.extractMeta(':clientside').isSuccess())
              c.removeMember(f);
        }
      });
}