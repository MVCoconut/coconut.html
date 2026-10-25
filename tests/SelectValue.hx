import coconut.ui.*;
import coconut.ui.Html.*;
import tink.pure.List;

class SelectValue {
  static public function run() {
    var failures = [];

    function check(expected:String, actual:String)
      if (actual != expected)
        failures.push('expected $expected\n     got $actual');

    check(
      '<select name="s"><option value="a">A</option><option value="b" selected>B</option><option value="c">C</option></select>',
      Renderer.render('
        <select name="s" value="b">
          <option value="a" selected>A</option>
          <option value="b">B</option>
          <option value="c">C</option>
        </select>
      ')
    );

    check(
      '<select multiple><option value="a" selected>A</option><option value="b">B</option><option selected>c</option><option>d</option></select>',
      Renderer.render('
        <select multiple value=${['a', 'c']}>
          <option value="a">A</option>
          <option value="b" selected>B</option>
          <Options values=${['c', 'd']} />
        </select>
      ')
    );

    check(
      '<select><option>a</option><option selected>b</option><option>b</option></select><option>b</option>',
      Renderer.render('
        <>
          <select value="b">
            <Options values=${['a', 'b', 'b']} />
          </select>
          <option>b</option>
        </>
      ')
    );

    check(
      '<select><option>a</option><option selected>b</option></select>',
      Renderer.render('
        <select>
          <option>a</option>
          <option selected>b</option>
        </select>
      ')
    );

    check(
      '<select><option selected>Tom &amp; Jerry</option></select>',
      Renderer.render('
        <select value="Tom & Jerry">
          <option>
            Tom &amp; Jerry
          </option>
        </select>
      ')
    );

    var v = 'b & c', yes = true;
    check(
      '<select title="x"><option title="o" value="a">a</option><option title="o" value="b &amp; c" selected>bc</option></select>',
      Renderer.render('
        <select title="x" value=${v}>
          <option title="o" value="a" selected=${yes}>a</option>
          <option title="o" value=${v}>bc</option>
        </select>
      ')
    );

    check(
      '<select title="x"><option value="a" selected>a</option><option value="b &amp; c">bc</option></select>',
      Renderer.render('
        <select title="x">
          <option value="a" selected=${yes}>a</option>
          <option value=${v} selected=${!yes}>bc</option>
        </select>
      ')
    );

    return failures;
  }
}

class Options extends View {
  @:attribute var values:List<String>;
  function render() '
    <>
      <for ${v in values}>
        <option>${v}</option>
      </for>
    </>
  ';
}
