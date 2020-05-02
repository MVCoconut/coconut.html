package coconut.html;

class Renderer {
  static public function hxx(e)
    return coconut.html.macros.HXX.parse(e);

  static function render(markup)
    return macro @:pos(markup.pos) ${hxx(markup)}.getHtml();
}