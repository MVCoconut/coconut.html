package ;

import coconut.ui.*;
import coconut.ui.Html.*;

class RunTests {

  static function main() {

    travix.Logger.exit(
      try {
        trace(Renderer.render('<Bar />'));
        travix.Logger.println('... works');
        var check = new Check();
        Attributes.run(check);
        SelectValue.run(check);
        switch check.failures {
          case []:
            travix.Logger.println('attributes and select values work');
            0;
          case failures:
            for (f in failures)
              travix.Logger.println(f);
            500;
        }
      }
      catch (e:Dynamic) {
        travix.Logger.println(Std.string(e));
        500;
      }
    ); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }

}

class Foo extends View {
  @:implicit var beep:Beep;
  @:attribute var foo:Int;
  function render() '<div><raw content="<b>so</b> bold" /></div>';
}

@:default(Beep.INST)
class Beep {
  static public final INST = new Beep();
  public function new() {}
}

class Bar extends View {
  function render() '<Foo foo={42} />';
}