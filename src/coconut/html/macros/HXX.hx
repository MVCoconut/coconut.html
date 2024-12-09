package coconut.html.macros;

#if macro
import coconut.ui.macros.Helpers;

using tink.MacroApi;

class HXX {
  static final generator = new tink.hxx.Generator();

  static public function parse(e)
    return Helpers.parse(e, generator, 'coconut.html.RenderResult.fragment').as(macro : coconut.html.RenderResult);
}
#end