import 'dart:js' as js;

const _script = r'''
let currentIndex = history.state?.index ?? 0;
let preventingForward = false;

if (!history.state || !("index" in history.state)) {
  history.replaceState(
    { index: currentIndex, state: history.state },
    document.title
  );
}

const getState = Object.getOwnPropertyDescriptor(
  History.prototype,
  "state"
).get;

const { pushState, replaceState } = history;

const onPopstate = () => {
  const state = getState.call(history);

  if (!state) {
    replaceState.call(history, { index: currentIndex + 1 }, document.title);
  }

  const index = state ? state.index : currentIndex + 1;

  if (index > currentIndex) {
    preventingForward = true;

    history.back();
  } else if (preventingForward) {
    preventingForward = false;
  } else {
    window.dispatchEvent(new Event("__navand-navigator-back__"));
  }

  currentIndex = index;
};

const modifyStateFunction = (func, n) => {
  return (state, ...args) => {
    func.call(history, { index: currentIndex + n, state }, ...args);

    currentIndex += n;
  };
};

const modifyStateGetter = (object) => {
  const { get } = Object.getOwnPropertyDescriptor(object.prototype, "state");

  Object.defineProperty(object.prototype, "state", {
    configurable: true,
    enumerable: true,
    set: undefined,
    get() {
      return get.call(this).state;
    },
  });
};

modifyStateGetter(History);
modifyStateGetter(PopStateEvent);

history.pushState = modifyStateFunction(pushState, 1);
history.replaceState = modifyStateFunction(replaceState, 0);

window.addEventListener("popstate", onPopstate);
''';

void addBackEventScript() => js.context.callMethod('eval', [_script]);
