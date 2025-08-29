# SwiftDotenv

[![CI](https://github.com/thebarndog/swift-dotenv/workflows/CI/badge.svg)](https://github.com/pointfreeco/swift-composable-architecture/actions?query=workflow%3ACI)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fthebarndog%2Fswift-dotenv%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/thebarndog/swift-dotenv)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fthebarndog%2Fswift-dotenv%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/thebarndog/swift-dotenv)

A one-stop shop for working with environment values in a Swift program. 

## Overview

`SwiftDotenv` is a small and compact Swift scripting library that allows you to load and save `.env` files at runtime and query for those values as well as system provided environemntal values via `ProcessInfo`. It's a single abstraction for dealing with environment variables at runtime in a local configuration file that doesn't get committed to version control, rather than hardcoding strings into your app or framework.

**IMPORTANT**: Please note that storing secrets or other sensitive information in the `.env` file does not necessarily make your app secure. For more information, see [this great article from NSHipster](https://nshipster.com/secrets/).

### What is a `.env` file?

`.env` files are used, most often in server-side applications, to inject environment variables into an application during active development. They can contain api keys, secrets, and other sensitive information and therefore **should not be committed to version control**. An environment file should only exist locally on a development machine; on a continuous integration system like TravisCI or CircleCI, environment variables are added via the respective UI in lieu of a `.env` file.

### When should I use this library?

`SwiftDotenv` is primarily meant for _scripting use-cases only_, not within applications. This is because in order to access the `.env` file from your application, it would have to be included and bundled with your application which defeats the purpose of keeping them separate to start with. You can however still use `Dotenv` as a Swiftier way of interacting with the system environment variables which will just proxy to `processInfo.environment`. 

## Installation

`SwiftDotenv` supports Swift Package Manager and can be added by adding this entry to your `Package.swift` manifest file:

```swift
.package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.0.0")
```

You can also use solutions such as [`swift-sh`](https://github.com/mxcl/swift-sh) for a less cumbersome scripting setup.

## Usage

```swift
import SwiftDotenv

// load in environment variables
try Dotenv.configure()

// access values
print(Dotenv.apiSecret)
```

### `Dotenv`

To configure the environment with values from your environment file, call `Dotenv.configure(atPath:overwrite:)`:

```swift
try Dotenv.configure()
```

It can optionally be provided with a path:

```swift
try Dotenv.configure(atPath: ".custom-env")
```

and the ability to not overwrite currently existing environment variables:

```swift
try Dotenv.configure(overwrite: false)
```

To read values:

```swift
let key = Dotenv.apiKey // using dynamic member lookup
let key = Dotenv["API_KEY"] // using regular subscripting
```

To set new values:

```swift
Dotenv.apiKey = .string("some-secret")
Dotenv["API_KEY"] = .string("some-secret")

// set a value and turn off overwriting 
Dotenv.set(value: "false", forKey: "DEBUG_MODE", overwrite: false)
```

The `Dotenv` structure can also be given a custom delimeter, file manager, and process info:

```swift
Dotenv.delimeter = "-" // default is "="
Dotenv.processInfo = ProcessInfo() // default is `ProcessInfo.processInfo`
Dotenv.fileManager = FileManager() // default is `FileManager.default`
```

### Contributing

If you find a bug, have an idea for a feature request, or want to help out, please open an issue describing your problem or a pull request with your feature. Please follow the [Code of Conduct](.github/CodeOfConduct.md) at all times.

Made with Swift and ❤️.
