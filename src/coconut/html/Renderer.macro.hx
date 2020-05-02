package coconut.html;

class Renderer {
  static public function hxx(e)
    return coconut.html.macros.HXX.parse(e);

  static function mount(target, markup)
    return coconut.ui.macros.Helpers.mount(macro coconut.html.Renderer.mountInto, target, markup, hxx);
}