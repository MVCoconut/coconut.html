import coconut.ui.*;
import coconut.Ui.hxx;

import js.html.*;

class Playground {

  static function main() {
    trace(Renderer.hxx('<HelloView />').getHtml());
  }
}

class HelloSubView extends View {
  function render() '
    <div onclick=${trace("yeah!")}>
      <svg viewBox="0 0 105 93" xmlns="http://www.w3.org/2000/svg">
        <path d="M66,0h39v93zM38,0h-38v93zM52,35l25,58h-16l-8-18h-18z" fill="#ED1C24" />
      </svg>
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