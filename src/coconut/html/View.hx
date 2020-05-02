package coconut.html;

@:build(coconut.html.View.init())
class View extends ViewBase {
  macro function hxx(e);
}

class ViewBase implements RenderResult.RenderResultObject {

  var o:tink.state.Observable<RenderResult>;

  public function new(o, _, _, _)
    this.o = o;

  public function renderInto(buffer:HtmlBuffer):Void
    o.value.renderInto(buffer);

}