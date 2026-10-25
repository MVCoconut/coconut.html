import coconut.ui.*;
import tink.pure.List;

class SelectValue {
  static public function run(check:Check) {
    check.html(
      '<select name="s"><option value="a">A</option><option value="b" selected>B</option><option value="c">C</option></select>',
      Renderer.render('
        <select name="s" value="b">
          <option value="a" selected>A</option>
          <option value="b">B</option>
          <option value="c">C</option>
        </select>
      ')
    );

    check.html(
      '<select multiple><option value="a" selected>A</option><option value="b">B</option><option selected>c</option><option>d</option></select>',
      Renderer.render('
        <select multiple value=${['a', 'c']}>
          <option value="a">A</option>
          <option value="b" selected>B</option>
          <Options values=${['c', 'd']} />
        </select>
      ')
    );

    check.html(
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

    check.html(
      '<select><option>a</option><option selected>b</option></select>',
      Renderer.render('
        <select>
          <option>a</option>
          <option selected>b</option>
        </select>
      ')
    );

    check.html(
      '<select><option selected>Tom &amp; Jerry</option></select>',
      Renderer.render('
        <select value="Tom & Jerry">
          <option>
            Tom &amp; Jerry
          </option>
        </select>
      ')
    );
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
