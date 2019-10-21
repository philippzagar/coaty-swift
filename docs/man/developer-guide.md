---
layout: default
title: CoatySwift Documentation
---

# CoatySwift Developer Guide

This document covers everything a Swift developer needs to know about using the
CoatySwift framework to implement collaborative IoT applications targeting iOS,
iPadOS, and macOS. We assume you know nothing about CoatySwift before reading
this guide.

> __NOTE__:
>
> We would like to note that more information about the internals and
> basics of the __Coaty__ framework can be found in [Coaty Communication
> Protocol](https://coatyio.github.io/coaty-js/man/communication-protocol/). The
> [Coaty JS Developer
> Guide](https://coatyio.github.io/coaty-js/man/developer-guide/), even though
> written for TypeScript, shares many similarities with CoatySwift and we
> recommend checking out this guide as well if you would like to dig deeper, as
> it is documented in a more detailed way and provides more extensive features.

## Table of Contents

- [Getting Started](#getting-started)
- [Necessary Background Knowledge](#necessary-background-knowledge)
- [Coaty(Swift) Terminology](#coatyswift-terminology)
- [Setup Instructions and Requirements](#setup-instructions-and-requirements)
  - [mDNS Broker Discovery Support](#mdns-broker-discovery-support)
- [Communication Patterns](#communication-patterns)
  - [Publish an Advertise (one-way event)](#publish-an-advertise-one-way-event)
  - [Observe Advertises (one-way event)](#observe-advertises-one-way-event)
  - [Publish a Discover event and Observe Resolve events (two-way event)](#publish-a-discover-event-and-observe-resolve-events-two-way-event)
  - [Observe a Discover event (two-way event)](#observe-a-discover-event-two-way-event)
- [Bootstrapping a Coaty Container](#bootstrapping-a-coaty-container)
- [Creating Controllers](#creating-controllers)
- [Object Family and Custom Data Types](#object-family-and-custom-data-types)
- [FAQ](#faq)
  - [Interacting with CoatyControllers](#interacting-with-coatycontrollers)
  - [Managing Subscriptions](#managing-subscriptions)
  - [Terminology](#terminology)
- [Additional resources](#additional-resources)

## Getting Started

If you want a short, concise look into CoatySwift, feel free to check out the
[CoatySwift Tutorial](https://coatyio.github.io/coaty-swift/tutorial/index.html)
with a step-by-step guide on how to set up a basic CoatySwift application. The
source code of this tutorial can be found in the
[Example](https://github.com/coatyio/coaty-swift/tree/master/Example) Xcode
folder of the CoatySwift repo. Just clone the repo, run `pod install` on the
Example folder and open the new  `xcworkspace` in Xcode.

You can find additional examples in the `swift` sections of the
[coaty-examples](https://github.com/coatyio/coaty-examples) repo on GitHub. You
will find three Xcode projects there: the `Hello World`, `Switch Light` and
`Dynamic` project. They are interoperable with the corresponding Coaty JS
examples and intended to be used along with them. Note that `Hello World` and
`Switch Light` are the blueprint examples for how to design CoatySwift
applications. The `Dynamic` example shows how dynamic components provide a less
static and less type safe version of CoatySwift to deal with Coaty object types
that are not yet known at compile time. This feature is currently experimental.

## Necessary Background Knowledge

In order to be able to use CoatySwift the way it is intended to, we assume you
are familiar with the following programming concepts:

- [ReactiveX](http://reactivex.io/) - Describes the basics on how incoming
  asynchronous messages are handled in the CoatySwift framework. In particular,
  CoatySwift is using [RxSwift](https://github.com/ReactiveX/RxSwift), the Swift
  version of ReactiveX.

## Coaty(Swift) Terminology

- In Coaty, every application component that communicates with other application
  components by use of Coaty communication flows is called an __agent__. So
  simply speaking, we consider an iOS or a macOS application to host an agent.

- Every agent holds a __container__. A container basically defines entry and
  exit points for a Coaty agent and provides lifecycle management for its
  controllers.

- Every container has 1...n __controllers__. A controller encapsulates business
  logic, and most importantly, all access methods related to any form of
  communication flow with other agents that you will be using in your
  application will be called from inside a controller. Each controller should
  encapsulate a single dedicated functionality. ___These controllers are in no
  way related to Apple's UIViewControllers!___

- Every container holds exactly one __communication manager__. A communication
  manager lets you publish and subscribe to communication events, basically
  handling all types of communication flow between Coaty agents.

- Every container has a __configuration__: Defines options for the container, as
  well as the controllers. There are many options available. You can check out
  example configs in the sections below, or the configs found in the `Example`
  folder in the CoatySwift Xcode project.

> __TL;DR Terminology__
>
> - Every iOS/iPadOS/macOS app hosts a Coaty __agent__
> - Every Coaty agent holds one __container__
> - Every container has
>   - 1...n __controllers__
>   - 1 __configuration__
>   - 1 __communication manager__

## Setup Instructions and Requirements

- To build and run Coaty agents with the CoatySwift technology stack you need
  [XCode](https://developer.apple.com/xcode/) 10.2 or higher.

- __Set up an MQTT Broker__: Communication flows between Coaty agents are build
  on top of the [MQTT](http://mqtt.org) publish-subscribe messaging protocol -
  so remember to set up and have an MQTT Broker running. We recommend checking
  out one of the following brokers:
  - [Coaty
    Broker](https://coatyio.github.io/coaty-js/man/developer-guide/#coaty-broker-for-development)
    (development broker provided by [Coaty
    JS](https://github.com/coatyio/coaty-js))
  - [Mosquitto](https://mosquitto.org/)
  - [HiveMQ](https://www.hivemq.com/)
  - [VerneMQ](https://vernemq.com/)

- __Integrate CoatySwift in your project__: CoatySwift is available through
  [CocoaPods](https://cocoapods.org). To install it, simply add the following
  line to your Podfile, and run `pod install` or `pod update` afterwards:

```ruby
pod 'CoatySwift'
```

### mDNS Broker Discovery Support

CoatySwift gives you the possibility to discover broker services dynamically via
mDNS. You will need an mDNS-supporting broker for this, which you can find
[here](https://coatyio.github.io/coaty-js/man/developer-guide/#coaty-broker-for-development).
For the client, add the following lines to your `Configuration` object:

```swift
// - IMPORTANT:
// shouldTryMDNSDiscovery has to bet set to `true`,
// while shouldAutoStart has to be set to `false`.
let mqttClientOptions = MQTTClientOptions(host: brokerIp,
                                          port: UInt16(brokerPort),
                                          enableSSL: enableSSL,
                                          shouldTryMDNSDiscovery: true)

config.communication = CommunicationOptions(mqttClientOptions: mqttClientOptions,
                                            shouldAutoStart: false)
```

> __NOTE__:
>
> Even if you discover the broker via mDNS, you are still required to specify a
> fallback host address and corresponding port.

## Communication Patterns

Citing the [Coaty Protocol
Documentation](https://coatyio.github.io/coaty-js/man/communication-protocol/#events-and-event-patterns):

The framework uses a minimum set of predefined events and event patterns to
discover, distribute, and share object information in a decentralized
application:

- __Advertise an object__: Broadcast an object to parties interested in objects
  of a specific core or object type.

- __Deadvertise an object by its unique ID__: Notify subscribers when capability
  is no longer available; for abnormal disconnection of a party, last will
  concept can be implemented by sending this event.

- __Channel Broadcast__ objects to parties interested in any kind of objects
  delivered through a channel with a specific channel identifier.

- __Discover - Resolve__: Discover an object and/or related objects by external
  ID, internal ID, or object type, and receive responses by Resolve events.

- __Query - Retrieve__: Query objects by specifying selection and ordering
  criteria, receive responses by Retrieve events.

- __Update - Complete__: Request or suggest an object update and receive
  accomplishments by Complete events.

- __Call - Return__: Request execution of a remote operation and receive results
  by Return events.

> __NOTE__:
>
> Although Coaty itself also specifices __IoValue__ and __Associate__ events,
> these are **not** included in the CoatySwift versions and therefore are left
> out of the documentation.

We differentiate between __one-way__ and __two-way__ events. Advertise,
Deadvertise and Channel are one-way events. Discover-Resolve, Query-Retrieve,
Update-Complete and Call-Return are two-way events.

We also differentiate between __publishing__ events or __observing__ them. When
publishing an event, simply put, you send a message over the broker. When
observing (or subscribing to) an event, you sign up to receive messages over the
broker.

In the following examples, we will show you how you can publish and observe
one-way events as well as two-way events.

### Publish an Advertise (one-way event)

Note that this procedure is much the same as publishing Deadvertise and Channel
events.

```swift
// Create the object.
let myExampleObject = CoatyObject(coreType: .CoatyObject,
                                  objectType: "com.mydomain.iot.ExampleObject",
                                  objectId: .init(),
                                  name: "My amazing example object")

// Create an event by using the event factory.
let event = self.eventFactory.AdvertiseEvent.with(object: myExampleObject)

// Publish the event by using the communication manager.
try? self.communicationManager.publishAdvertise(event)
```

### Observe Advertises (one-way event)

Note that this procedure is much the same as observing Deadvertise and Channel
events.

```swift
try? self.communicationManager
    .observeAdvertise(withCoreType: .Task)
    .subscribe(onNext: { (advertiseEvent) in
        let task = advertiseEvent.data.object as Task

        // Do something with this task...
        print(task.creatorId)

    })
    .disposed(by: disposeBag)
```

### Publish a Discover event and Observe Resolve events (two-way event)

Note that this procedure is much the same as for Query-Retrieve,
Update-Complete, and Call-Return events.

```swift
let discoverEvent = self.eventFactory.DiscoverEvent
    .with(externalId: "an-external-id")

try? self.communicationManager
    .publishDiscover(discoverEvent)
    .subscribe(onNext: { (resolveEvent) in
        // Do something with your resolve event.
        print(resolveEvent.data.object)

    })
    .disposed(by: disposeBag)
```

### Observe a Discover event (two-way event)

Note that this procedure is much the same as for Query-Retrieve,
Update-Complete, and Call-Return events.

```swift
try? self.communicationManager
    .observeDiscover()
    .filter { (discoverEvent) -> Bool in
        return discoverEvent.data.isDiscoveringExternalId()
    }
    .subscribe(onNext: { (discoverEvent)
        let externalId = discoverEvent.data.externalId

        // Search for an object with the given external Id...
        let resolveObject = CoatyObject(coreType: .CoreType,
            objectType: "com.mydomain.iot.ResolveExample",
            objectId: .init(),
            name: "My resolve example object")
        resolveObject.externalId = externalId

        let event = self.eventFactory.ResolveEvent.with(object: resolveObject)
        discoverEvent.resolve(resolveEvent: event)

    })
    .disposed(by: disposeBag)
```

## Bootstrapping a Coaty Container

In order to get your Coaty application running, you will have to set up the
Coaty container and all its corresponding controllers, as well as data-related
classes such as object families. We will provide a step by step explanation of
how you can create a container with an exemplary controller.

> __NOTE__:
>
>Unfortunately there is no sequential way (where everything compiles after each
>step) to set up a container until you added all of the required components. It
>is probably the easiest to add an empty `ObjectFamily` and at least one
>`Controller` before you start to resolve your `Container`. We suggest taking a
>look at the `Hello World` example to see how the final result looks like.

We suggest setting up the main structure of the container as part of the
`AppDelegate.swift`.

1. Make sure to import CoatySwift in the top.

```swift
import CoatySwift
```

2. Create a global variable `coatyContainer`. This will hold a reference to our
   Coaty container. It is needed because otherwise all of our references go out
   of scope. For example, in this case, the MQTT connection is simply
   terminated.

```swift
// ...
import CoatySwift

/// Save a reference of your container in the app delegate to
/// make sure it stays alive during the entire life-time of the app.
var coatyContainer: Container<ExampleObjectFamily>?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
// ...
```

3. We will now go on to instantiate our controllers. Here, we assume that you
   have already created an `ExampleController` as well as an
   `ExampleObjectFamily`. Feel free to read up on controllers and object
   families in this [section](#object-family-and-custom-data-types). The key note of
   this step is to indicate which key maps to which controller, in order to be
   able to access these controllers later after the container has been
   bootstrapped.  

```swift
// Here, you define which controllers you want to use for your application.
// Note that the keys (such as "ExampleController")
// do NOT have to have the exact name of their controller class. Feel free to give
// them any names you want. The _mapping_ is the important thing, so which name
// maps to what controller class.
let components = Components(controllers: [
    "ExampleController": ExampleController<ExampleObjectFamily>.self
])
```

4. The next step is to specify a configuration for your container. Below we have
   added an example configuration which should be appropriate for most Coaty
   beginner projects. Note the `MQTTClientOptions` in particular: Here, you pass in
   your broker address, port and SSL option.

```swift
/// This method creates an exemplary Coaty configuration.
/// You can use it as a basis for your application.
private func createExampleConfiguration() -> Configuration? {
    return try? .build { config in

        // This part defines common options shared by all container components,
        // including e.g. an associated user or associated device.
        config.common = CommonOptions()

        // Adjusts the logging level of CoatySwift messages, which is especially
        // helpful when you want to debug applications.
        config.common?.logLevel = .info

        // You can also add extra information to your configuration in the form of a
        // [String: String] dictionary.
        config.common?.extra = ["ContainerVersion": "0.0.1"]

        // Define the communication-related options, such as the IP address of your broker and
        // the port it exposes. Also, make sure to immediately connect with the broker,
        // indicated by `shouldAutoStart: true`.
        let mqttClientOptions = MQTTClientOptions(host: brokerIp,
                                          port: UInt16(brokerPort))
        config.communication = CommunicationOptions(mqttClientOptions: mqttClientOptions,
                                                    shouldAutoStart: true)

        // The communicationManager will advertise its identity upon connection to the
        // MQTT broker.
        config.communication?.shouldAdvertiseIdentity = true
    }
}

//...

/// And then, simply call it when you need it in order to integrate it
/// into your container configuration.
guard let configuration = createExampleConfiguration() else {
    print("Invalid configuration! Please check your options.")
    return
}

//...
```

5. Lastly, the only thing you need to do is to resolve everything and assign the
   variable we previously defined, namely, `coatyContainer`,  with the return
   value of `container.resolve(…)`. Below code shows the last step in
   boostrapping a Coaty container:

```swift
// Pass in the previously defined components, configuration and, most importantly, the
// ObjectFamily (in this case, `ExampleObjectFamily`). Then, call Container.resolve(...),
// save it into our global variable, and you're done!
coatyContainer = Container.resolve(components: components,
                                   configuration: configuration,
                                   objectFamily: ExampleObjectFamily.self)
```

> __TL;DR Container Bootstrapping__
>
>1. Create a global variable that holds a reference to the `coatyContainer`.
>2. Specify all controllers that you want to use.
>3. Create an appropriate configuration.
>4. Simply call `container.resolve(…)` and assign its return value to the
>   `coatyContainer` global variable from step 1.

## Creating Controllers

As previously mentioned, Coaty controllers are the components encapsulating
business logic in your application. Below we will show you how you can build
your own Coaty container and add networking functionality in order to
communicate with other Coaty agents.

Each controller provides __lifecycle methods__ that are called by the framework,
shown here:

```swift
class ExampleController<Family: ObjectFamily>: Controller<Family> {

    override func onInit() {
        // Perform additional setup.
    }

    override func onContainerResolved(container: Container<Family>) {
        // Gives you a reference to the container as soon as all components have been resolved.
        // Useful if you need to hold a reference to another controller.
    }

    override func onCommunicationManagerStarting() {
        // Here you can setup your subscriptions or start publishing some events.
    }

    override func onCommunicationManagerStopping() {
        // Teardown of subscriptions when the communication manager goes offline.
    }

    override func onDispose() {
        // Teardown when the container is disposed.
    }
}
```

Of course you can also additional functionality, such as new methods or
variables, references, and so on. A very simplified ExampleViewController could
look like this:

```swift
class ExampleController<Family: ObjectFamily>: Controller<Family> {

    override func onCommunicationManagerStarting() {
        print("[ExampleController] - onCommunicationManagerStarting()")
    }
}
```

In the next steps, you could add publish and subscribe handler, as previously
mentioned in this [section](#communication-patterns).

## Object Family and Custom Data Types

To use custom objects or datatypes with Coaty you may extend the preexisting
core types. Use standard Swift classes that extend the base implementation, e.g.
define your custom object that inherits from `CoatyObject` as in the following
example:

```swift
// ...

final class ExampleObject: CoatyObject {

    let myValue: String

    init(myValue: String) {
        self.myValue = myValue
        super.init(coreType: .CoatyObject,
                   objectType: ExampleObjectFamily.exampleObject.rawValue,
                   objectId: .init(),
                   name: "ExampleObject Name :)")
    }

    // MARK: Codable methods.

    enum CodingKeys: String, CodingKey {
        case myValue
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        myValue = try container.decode(String.self, forKey: .myValue)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        let container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(myValue, forKey: .myValue)
    }

}
```

> __NOTE:__
>
>You need to implement the conformance to the `Codable` protocol for your custom
>objects. Also, make sure to call the super implementations for the
>`init(from:)`initializer as well as the `encode(to:)` method.
>
>If you need to encode / decode a property value of a custom Coaty object type
>that can be any valid JSON data, and you don't know the JSON structure in
>advance, declare the property type as `AnyCodable`. Using this type, you can
>encode or decode mixed-type values in dictionaries and other collections that
>require `Encodable` or `Decodable` conformance.

To let the framework know about the new custom type you need to define a so
called `ObjectFamily`. The `ObjectFamily` provides a mapping from a type name
that is encoded by the `objectType` attribute of each `CoatyObject` to a Swift
class that is used to instantiate an actual Swift object from the JSON
representation that is being sent over the wire. A minimal `ObjectFamily` for
the `ExampleObject` that was defined above looks like this:

```swift
enum ExampleObjectFamily: String, ObjectFamily {
    case exampleObject = "io.coaty.hello-coaty.example-object"

    func getType() -> AnyObject.Type {
        switch self {
        case .exampleObject:
            return ExampleObject.self
        }
    }
}
```

The `ObjectFamily` is one of the parameters that are required for the
configuration of your CoatySwift application. After setting an `ObjectFamily`
during the bootstrapping of a container you will have full type safety and do
not need to worry about manual unmarshalling.

If you wish to see a more elaborate example for an ObjectFamily, please see the
base `CoatyObjectFamily` in the CoatySwift framework.

> __TL;DR Custom Data Types__
>
>1. Create a new Swift object that inherits from `CoatyObject` or another core
>   type.
>2. Implement conformance to the
>   [Codable](https://developer.apple.com/documentation/swift/codable) protocol.
>   Make sure to call the super implementations of the initializer and the
>   encode method.
>3. Create one `ObjectFamily` per CoatySwift application. Add your object type
>   to the enum and assign the correct Swift type.

## FAQ

### Interacting with CoatyControllers

A best practice to pass information from `CoatyControllers` to
`UIViewControllers` or other application components can be achieved by
implementing the delegate pattern. Assuming you configured your container and
made it available globally in your application via a variable named
`coatyContainer` you can load a controller to set a delegate as follows:

```swift
import CoatySwift

class ViewController: UIViewController {

    private var controller: ExampleController<ExampleObjectFamily>?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.controller = coatyContainer?.getController(name: "ExampleController")

        // Set the ViewController as the delegate.
        self.controller?.delegate = self

        // Call methods of the controller.
        self.controller?.publishExample()
    }

    // ...
}
```

### Managing Subscriptions

There are two ways how to manage subscriptions:

1. You can start and stop the Communication Manager manually by calling
   `communicationManager.startClient()` and `communicationManager.endClient()`.
   Remember that your previous subscriptions will become inactive if you call
   `communicationManager.endClient()`. It is therefore recommended to set up all
   the subscriptions anew in the `.onCommunicationManagerStarting()` methods in
   each controller.

2. Subscriptions can be disposed manually as well. You can do this by manually
   calling `.dispose()` on an active subscription.

### Terminology

It is important to remember that a CoatySwift `Controller` has nothing to do
with the regular `UIViewController`, and likewise, the `container` variable used
in the `decode` and `encode` methods is not related in any way to the Coaty
`Container` object.

## Additional resources

We would like to point you to additional resources if you want to dig deeper
into CoatySwift and Coaty itself.

- [Tutorial](https://coatyio.github.io/coaty-swift/tutorial/index.html) - shows
  how to set up a minimal CoatySwift app.
- [API Documentation](https://coatyio.github.io/coaty-swift/swiftdoc/index.html) - the
  source code documentation of public types and members of the CoatySwift framework.
- [Design Rationale](https://coatyio.github.io/coaty-swift/man/design-rationale/) - in case
  you want to know why certain things have been implemented in a particular way
  in the CoatySwift implementation.
- [Xcode Quick Help](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/SymbolDocumentation.html) - when
  you are directly writing the code and wondering what a certain function
  does.

The following resources are part of Coaty JS, but the CoatySwift API aims to be
as close as possible to the reference implementation. Therefore, we suggest
checking out these resources as well:

- [In a Nutshell](https://coaty.io/nutshell)
- [Communication Protocol](https://coatyio.github.io/coaty-js/man/communication-protocol/)
- [Coaty JS Developer Guide](https://coatyio.github.io/coaty-js/man/developer-guide/)
- [Coaty JS Project](https://github.com/coatyio/coaty-js)
- [Coaty Examples](https://github.com/coatyio/coaty-examples)