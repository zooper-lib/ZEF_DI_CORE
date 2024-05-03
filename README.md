# zef_di_core

A dart library which provides abstractions for dependency injection and a default implementation.

This project is the continuation of [zef_di_abstractions](https://pub.dev/packages/zef_di_abstractions) and [zef_di_inglue](https://pub.dev/packages/zef_di_inglue). If you are still using those, you should upgrade to this successor.

## Features

- **Framework Agnostic**: Designed to be a flexible wrapper, this package can be used with any Dependency Injection (DI) framework, offering a unified interface for service registration and resolution.
- **Multiple Service Resolution**: Supports resolving multiple services registered under the same interface, enhancing the flexibility of service retrieval in complex applications.
- **Custom Adapter Integration**: Enables users to integrate any external DI framework by writing custom adapters, ensuring compatibility and extending functionality according to project needs.
- **Unlimited Parameters**: Different to other DI frameworks we offer the ability to pass any number of arguments when resolving a dependency.
- **Code generation**: Automatic dependency registration and resolution.

## Definitions

### **Singleton**

Singletons are instances which are held in memory and being reused everytime the dependency is resolved. This makes them very fast, but memory consuming.
Keep in mind that when you destroy the object by hand (or via an external package) the reference still exists inside the DI framework, but will throw an Exception.

#### **Transient**

A Transient registration is like registering a function which gets called every time we request an object. This way the memory usage is minimal as no instance is cached, but we instantiate the object every time we request it, which can result in performance issues.

#### **Lazy**

Lazies are a combination of Singleton and Transients. You will register a factory which will be called the first time you resolve the type and then the instance will be stored in memory. This way you will always get the same instance.

## Getting Started

### Initialization and Usage

We are fans of the "Builder" pattern, so that's the way how you initialize the ServiceLocator. Inside your `main()` function, call it like so: 

```dart
void main() {
  ServiceLocatorBuilder()
    .build();

  // Your application logic here
}
```

And you are good to go. Since the ServiceLocator is a Singleton, you are able to access it all over your application with `ServiceLocator.instance`, or shorthand `ServiceLocator.I`.

### Singletons

#### Simple registration

To register a `Singleton` you directly pass an instance of the object you want to have registered:

```dart
ServiceLocator.I.registerSingleton(MyService());
```

And to resolve that instance you call the `resolve()` method:

```dart
final MyService myService = ServiceLocator.I.resolve<MyService>();
```

---

**NOTE**

You can register the same instance multiple times if you have set this in `ServiceLocatorConfig`. This is turned on by default.
The method `resolve()` will then return the first registered instance by default, but you can also get the last registered with:

```dart
final MyService myService = ServiceLocator.I.resolve<MyService>(resolveFirst: false);
```

The same principle applies to the following registration option

---

#### Registering with a factory

You can also register a `Singleton` with a factory:

```dart
ServiceLocator.I.registerSingletonFactory<MyService>(
  (args) => MyService(),
);
```

This way you have more control over the instance creation.
Note that the factory will only be called once, and directly after the registration.

#### Named registration

You can pass a name with your registration.

```dart
ServiceLocator.I.registerSingleton(MyService(), name: 'One');
ServiceLocator.I.registerSingleton(MyService(), name: 'Two');
```

This way you can resolve different instances with ease:

```dart
final MyService myService = ServiceLocator.I.resolve<MyService>(name: 'one'); // Will return the instance with name `one`
final MyService myService = ServiceLocator.I.resolve<MyService>(name: 'two'); // Will return the instance with name `two`
```

#### Keyed registration

The same principle as named registrations, but with a different property

#### Environmental registration

The same principle as named registrations, but with a different property. Mostly used to define your instances under different environments like "dev", "test", "prod", ...

### Transient registration

#### Simple registration

```dart
ServiceLocator.I.registerTransient<MyService>(
        (args) => MyService(),
      );
```

And to resolve, you do the same as with the `Singleton` resolution:

```dart
final MyService myService = ServiceLocator.I.resolve<MyService>();
```

#### Resolving with parameters

One feature for `Transient` factories is, that you can pass arguments to resolve the instance.
First you need to tell the framework how to resolve the factory:

```dart
ServiceLocator.I.registerTransient<UserService>(
  (Map<String, dynamic> args) => UserService(
    id: args['theUserId'] as UserId, // This is how your parameter will be provided
    username: args['theUsername'], // You dont need to tell the type
    password: args['thePassword'] as String, // But you must pass all the needed parameters
  ),
);
```

The `args` parameter is a Map of arguments you will pass when trying to resolve a factory:

```dart
final UserService userService =
  ServiceLocator.I.resolve<UserService>(
    args: {
      'theUserId': UserId('1'),
      'theUsername': 'HansZimmer123',
      'thePassword': 'blafoo1!',
    },
  );
```

If you don't pass a required argument, a `TypeError` will be thrown.

### Lazy Registration

```dart
ServiceLocator.I.registerLazy<MyLazyService>(
  Lazy<MyLazyService>(() => MyLazyService()),
);
```

To resolve a `Lazy` registered service, you use the same resolve method:

```dart
final MyLazyService myLazyService = ServiceLocator.I.resolve<MyLazyService>();
```

## Implementing a Custom Adapter

This package comes with a built-in adapter which should mostly work for your needs, but you can still develop you own one to have the full control. Here's a conceptual example to guide you:

```dart
class MyDIAdapter extends ServiceLocatorAdapter {
  // Implement the adapter methods using your chosen DI framework
}
```

## Code generation

If you want to use the code generator, please refer to [this package here](https://pub.dev/zef_di_abstractions_generator).

## Customization and Extensibility

Our package's design encourages customization and extensibility. By creating adapters for your chosen DI frameworks, you can leverage our wrapper's features while utilizing the specific functionalities and optimizations of those frameworks.

## Contributing

Contributions are welcome! Please read our contributing guidelines and code of conduct before submitting pull requests or issues. Also every annotation or idea to improve is warmly appreciated.
