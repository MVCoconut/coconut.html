package coconut.html;

class View {
  static function hxx(_, e)
    return coconut.html.macros.HXX.parse(e);

  static function init()
    return
      coconut.ui.macros.ViewBuilder.init(macro : coconut.html.RenderResult, function () {

      });
}