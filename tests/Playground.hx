import coconut.ui.*;
import coconut.html.Html.*;

class Playground {

  static function main() {
    // trace(Renderer.renderDocument('<html><head data-foo="5" data-bar={Math.random() > 5}><script></script><script /><meta charset="utf-8"/><title>Test</title></head><body><HelloView /></body></html>'));
    haxe.Timer.measure(() -> for (i in 0...100000) Renderer.renderDocument('<html><head data-foo="5" data-bar={Math.random() > 5}><script></script><script /><meta charset="utf-8"/><title>Test</title></head><body><HelloView /></body></html>'));
  }
}

class HelloSubView extends View {
  inline function input(a:{ maxLength: Int}) return null;
  function render() '
    <div onclick=${trace("yeah!")} data-foo-bar="123">
      <svg viewBox="0 0 ${105} 93" xmlns="http://www.w3.org/2000/svg">
        <path d="M66,0h39v93zM38,0h-38v93zM52,35l25,58h-16l-8-18h-18z" fill="#ED1C24" />
      </svg>
      <input maxLength=${Std.random(123)} />
    </div>
  ';
}

class HelloView extends View {
  @:ref var sub:HelloSubView;

  function render() '<HelloSubView ref=$sub />';

  override function viewDidMount()
    trace("HelloView afterMounting", sub);

  override function viewDidUpdate()
    trace("HelloView afterPatching", sub);
}