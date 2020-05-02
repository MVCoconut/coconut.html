package coconut.html.macros;

#if macro
import coconut.ui.macros.Helpers;
import tink.hxx.*;

using tink.MacroApi;

class HXX {
  static final generator = new Generator(Tag.extractAllFrom(macro coconut.html.Html));

  static public function parse(e)
    return Helpers.parse(e, generator, 'coconut.html.RenderResult.fragment').as(macro : coconut.html.RenderResult);
}
#end