package coconut.html;

import haxe.macro.Expr;
using tink.MacroApi;

class View {
  static function hxx(_, e)
    return coconut.html.macros.HXX.parse(e);

  static function init()
    return
      coconut.ui.macros.ViewBuilder.init(macro : coconut.html.RenderResult, function (c) {
        // trace(TAnonymous(c.target.export()).toString());
      });
}