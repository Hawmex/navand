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

**NOTE:**

You should pass just the app name to `navand create`. Arguments like
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
    Route(path: '', redirector: (final context, final state) => 'home'),
    Route(
      path: 'home',
      builder: (final context, final state) => const Text('Home'),
      routes: [
        Route(
          path: 'notifications',
          builder: (final context, final state) => const Text('Notifications'),
        ),
      ],
    ),
    Route(
      path: 'about',
      builder: (final context, final state) => const Text('About'),
    ),
    Route(
      path: '*',
      builder: (final context, final state) => const Text('Not Found'),
    ),
  ],
);
```

#### Navigating

```dart
// Popping the latest modal or the latest route
Navigator.pop();

// Pushing a new route
Navigator.pushRoute('/about');

// Replacing the current route
Navigator.replaceRoute('/about');

// Pushing a new modal
Navigator.pushModal(
  onPop: () {
    // Closing the modal in the UI.
  },
);
```

## Animations

Navand's animations are very similar to CSS's and JavaScript's. They are
applied to widgets once the have mounted in the node tree.

### Example

```dart
// Animating a widget after it mounts
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

// Infinite animations
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
