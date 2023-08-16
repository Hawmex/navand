<div align="center">

<img
    alt="Navand"
    style="width: 100%"
    src="https://raw.githubusercontent.com/Hawmex/Hawmex/main/assets/banner.svg"
/>

---

[ [GitHub](https://github.com/Hawmex/navand) |
[Pub](https://pub.dev/packages/navand) |
[API Reference](https://pub.dev/documentation/navand) ]

---

</div>

Navand, meaning "a swift horse" in Persian, is a web framework in Dart that
lets developers create UIs with a widget model similar to Flutter. Navand apps
are compiled into JS and painted using HTML & CSS.

- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [Contributing to Navand](./CONTRIBUTING.md)
- [Changelog](./CHANGELOG.md)

## Get Started

### Install Navand's Command-Line Tool

To get started, install Navand's command-line tool first:

```
dart pub global activate navand
```

To learn more about Navand's command-line tool, run:

```
navand --help
```

### Set Up Your App

Head to the directory in which you want to set up your application and run:

```
navand create my_first_navand_app
```

**NOTE:** You should pass just the app name to `navand create`. Arguments like
`path/to/my_new_navand_app` are not supported.

### Serve Your App

After setting up your project is done, head to your app's directory:

```
cd my_first_navand_app
```

And serve it:

```
webdev serve
```

### Build Your App

To build your app, run:

```
webdev build
```

The output can be found in `build/`.

## Navand's Navigator

### Key Concepts

Navand has its own navigator that uses browser's History API. It has two main
entities:

- Routes: They are entities like typical routes and have a corresponding path
  in the URL. They are generally accessible in the application regardless of
  the users' actions.
- Modals: They are entities like dialogs, navigation drawers, bottom sheets,
  etc. that rely on users' actions or the flow of the application. They don't
  have a corresponding path in the URL because they must be prompted to the
  user in specific conditions and in response to their actions.

It also has the following concepts:

- Only a single instance of `Navigator` should be created in the app.
- Because modals should be accessible only through users' actions or the flow
  of the application, browser's forward button should disabled (in the same way
  that most modern native apps don't have one).
- When browser's back button is pressed or `Navigator.pop` is called, the
  latest modal, and if there are no modals left, the latest route should be
  popped.

### Examples

#### Defining Routes

```dart
Navigator(
  routes: [
    // Redirects are supported through `redirector`.
    Route(path: '', redirector: (final context, final state) => 'home'),
    Route(
      path: 'home',
      builder: (final context, final state) => const Text('Home'),
      // Routes can be nested.
      routes: [
        Route(
          path: 'notifications',
          builder: (final context, final state) => const Text('Notifications'),
          routes: [
            Route(
              // Routes can be defined as dynamic.
              path: ':id',
              builder: (final context, final state) =>
                  Text('Notification ID: ${state.params['id']}'),
            ),
          ],
        ),
      ],
    ),
    Route(
      path: 'about',
      builder: (final context, final state) => const Text('About'),
    ),
    Route(
      // Wildcards can be used in different cases like "Not Found" pages.
      path: '*',
      builder: (final context, final state) => const Text('Not Found'),
    ),
  ],
);
```

#### Navigating

```dart
// Popping the latest modal or the latest route.
Navigator.pop();

// Pushing a new route.
Navigator.pushRoute('/about');

// Replacing the current route.
Navigator.replaceRoute('/about');

// Pushing a new modal
Navigator.pushModal(
  onPop: () {
    // Closing the modal in the UI.
  },
);
```

## Navand's Animations

Navand's animations are very similar to CSS's and JavaScript's. They are
applied to widgets once the have mounted in the node tree.

### Examples

#### Simple Animations

```dart
// Animating a widget once it mounts.
const Text(
  'Hello World!',
  animation: Animation(
    keyframes: [
      Keyframe(offset: 0, style: Style({'color': 'red'})),
      Keyframe(offset: 0.5, style: Style({'color': 'green'})),
      Keyframe(offset: 1, style: Style({'color': 'blue'})),
    ],
    duration: Duration(milliseconds: 500),
    easing: Easing(0.4, 0, 0.2, 1),
  ),
);
```

#### Infinite Animations

```dart
const Text(
  'Hello World!',
  animation: Animation(
    keyframes: [
      Keyframe(offset: 0, style: Style({'color': 'red'})),
      Keyframe(offset: 0.5, style: Style({'color': 'green'})),
      Keyframe(offset: 1, style: Style({'color': 'blue'})),
    ],
    duration: Duration(milliseconds: 500),
    easing: Easing(0.4, 0, 0.2, 1),
    iterations: double.infinity,
  ),
);
```

#### Animations on Updates

```dart
// To animate the following widget every time `name` is updated,
// pass a key to it that serializes `name`.
Text(
  'Hello $name',
  key: name.toString(),
  animation: Animation(
    keyframes: [
      Keyframe(offset: 0, style: Style({'color': 'red'})),
      Keyframe(offset: 0.5, style: Style({'color': 'green'})),
      Keyframe(offset: 1, style: Style({'color': 'blue'})),
    ],
    duration: Duration(milliseconds: 500),
    easing: Easing(0.4, 0, 0.2, 1),
  ),
);
```

## Extending the API

Navand's API is extensible in many aspects. For example, you can easily create
your own widgets that paint specific HTML elements.

### Examples

#### Custom Heading

```dart
// Let's create an `H1` widget that paints an `<h1 />` element on the screen.

final class H1 extends PaintedWidget {
  final String value;

  const H1(
    this.value, {
    super.style,
    super.animation,
    super.onTap,
    super.onPointerDown,
    super.onPointerUp,
    super.onPointerEnter,
    super.onPointerLeave,
    super.onPointerMove,
    super.onPointerCancel,
    super.onPointerOver,
    super.onPointerOut,
    super.key,
    super.ref,
  });

  // Create a corresponding node.
  @override
  H1Node createNode() => H1Node(this);
}

final class H1Node extends ChildlessPaintedNode<Text, html.HeadingElement> {
  // Pass `html.HeadingElement.h1()` as its element.
  H1Node(super.widget) : super(element: html.HeadingElement.h1());

  @override
  void assembleElement() {
    super.assembleElement();

    // Set the text of the element to the widget's value.
    element.text = widget.value;
  }
}
```
