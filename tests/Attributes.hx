import coconut.ui.*;
import coconut.ui.Html.*;

// split by topic, because neko limits the stack of a single function
class Attributes {
  static public function run(check:Check) {
    names(check);
    custom(check);
    booleans(check);
    numbers(check);
    escaping(check);
    misc(check);
  }

  static function names(check:Check) {
    var cls = 'dyn', yes = true, no = false;

    check.html('<div class="a" title="t">x</div>', Renderer.render('<div class="a" title="t">x</div>'));
    check.html('<div class="dyn">x</div>', Renderer.render('<div class=${cls}>x</div>'));
    check.html('<div class="a">x</div>', Renderer.render('<div class=${["a" => yes, "c" => no]}>x</div>'));

    check.html('<label for="i">l</label>', Renderer.render('<label htmlFor="i">l</label>'));
    check.html('<label for="dyn">l</label>', Renderer.render('<label htmlFor=${cls}>l</label>'));

    check.html('<input value="x">', Renderer.render('<input defaultValue="x" />'));
    check.html('<input value="dyn">', Renderer.render('<input defaultValue=${cls} />'));

    check.html('<div style="color: red">x</div>', Renderer.render('<div style="color: red">x</div>'));
  }

  static function custom(check:Check) {
    var text = 'some label';
    check.html(
      '<div data-foo="1" aria-label="some label">x</div>',
      Renderer.render('<div data-foo="1" aria-label=${text}>x</div>')
    );
  }

  static function booleans(check:Check) {
    var yes = true, no = false;
    check.html('<input disabled>', Renderer.render('<input disabled />'));
    check.html('<input disabled>', Renderer.render('<input disabled=${yes} />'));
    check.html('<input>', Renderer.render('<input disabled=${no} />'));
    check.html('<input>', Renderer.render('<input disabled={false} />'));
  }

  static function numbers(check:Check) {
    var three = 3;
    check.html('<input tabindex="3" maxlength="10">', Renderer.render('<input tabIndex=${three} maxLength={10} />'));
  }

  static function escaping(check:Check) {
    var nasty = '"<&>\'';
    check.html(
      '<div title="&quot;&lt;&amp;&gt;&#039;">&lt;b&gt;</div>',
      Renderer.render('<div title=${nasty}>${"<b>"}</div>')
    );
    check.html('<div title="&quot;&lt;&amp;&gt;&#039;">x</div>', Renderer.render('<div title={\'"<&>\\\'\'}>x</div>'));
  }

  static function misc(check:Check) {
    check.html('<button type="button">b</button>', Renderer.render('<button type="button" onclick=${trace("clicked")}>b</button>'));
    check.html('<p>a<br>b</p>', Renderer.render('<p>a<br/>b</p>'));
  }
}
