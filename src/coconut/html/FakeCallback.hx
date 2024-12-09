package coconut.html;

@:fromHxx(
  transform = coconut.html.FakeCallback.create(_)
)
abstract FakeCallback(Dynamic) {
  macro static public function create(e);
}