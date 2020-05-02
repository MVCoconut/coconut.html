package coconut.html.macros;

#if macro
import coconut.ui.macros.*;
import tink.domspec.Macro.tags;
import haxe.macro.Context;
import haxe.macro.Expr;
import tink.hxx.*;

using tink.MacroApi;

class Setup {

  static function addTags() {
    tink.hxx.Helpers.setCustomTransformer('coconut.html.FakeCallback', {
      reduceType: t -> t,
      postprocessor: PUntyped(e -> macro @:pos(e.pos) null),
    });

    var ret = Context.getBuildFields();

    var events = switch Context.getType('tink.domspec.EventsStructure') {
      case TType(_, params):
        'tink.domspec.EventsStructure'.asComplexType([for (t in params) TPType(macro : coconut.html.FakeCallback)]);
      default:
        throw 'assert';
    }

    for (name in tags.keys()) {
      var tag = tags[name];

      ret.push({
        name: name,
        pos: tag.pos,
        access: [AStatic, APublic, AInline],
        kind: FFun({
          // var et = tag.domCt;
          var args = [
            {
              name: 'hxxMeta',
              type: macro : HxxMeta<Dynamic>,
              opt: false
            },
            {
              name: 'attr',
              type: [
                tag.attr,
                macro : $events,
                macro : {
                  @:hxxCustomAttributes(~/^(data-|aria-)/)
                  @:optional var attributes(default, never):Dynamic<String>;
                },
              ].intersect().sure(),
              opt: false
            }
          ];
          var callArgs = [macro $v{name}, macro cast attr];
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
            expr: macro return new Tag($a{callArgs}),//VNode.native($a{callArgs}),
            ret: macro : coconut.html.RenderResult
          }
        })
      });

    }

    return ret;
  }
}
#end