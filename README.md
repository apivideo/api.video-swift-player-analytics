<!--<documentation_excluded>-->
[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video)
&nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-swift-player-analytics?style=social)](https://github.com/apivideo/api.video-swift-player-analytics)
&nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/.github/blob/main/assets/apivideo_banner.png)
<h1 align="center">api.video Swift player analytics</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast
video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in
your app.

## Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
    - [Installation](#installation)
    - [Code sample](#code-sample)
- [Documentation](#documentation)
- [FAQ](#faq)

<!--</documentation_excluded>-->
<!--<documentation_only>
---
title: api.video Swift player analytics
meta:
  description: The official api.video Swift player analytics library for api.video. [api.video](https://api.video/) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.
---

</documentation_only>-->

## Project description

This library send player events from the player to api.video.

## Getting started

### Installation

#### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
  dependencies: [
        .package(url: "https://github.com/apivideo/api.video-swift-player-analytics.git", from: "2.0.0"),
    ],
```

#### CocoaPods

Add the following line to your `Podfile`:

```ruby
pod 'ApiVideoPlayerAnalytics', '~> 2.0.0
```

Then, run `pod install`.

### Code sample

Create a `ApiVideoAnalyticsAVPlayer` instance.

```swift
import ApiVideoPlayerAnalytics

let player = ApiVideoAnalyticsAVPlayer(url: "URL of the HLS manifest") // HLS manifest from api.video. Example: https://vod.api.video/vod/YOUR_VIDEO_ID/hls/manifest.m3u8
```

Then, use it like a regular `AVPlayer`.

```swift
player.play()
```

For a custom domain collector, use:

```swift
let player = ApiVideoAnalyticsAVPlayer(url: "URL of the HLS manifest", collectorUrl: "https://collector.mycustomdomain.com") // Register the player analytics listener so it sends player events to api.video.
```

## Documentation

// TODO

## Sample application

Open `ApiVideoPlayerAnalytics.xcodeproj`.

Replace the default media ID in `Examples/iOS/ViewController.swift` with your own.

```swift
let url = Utils.inferManifestURL(mediaId: "vi77Dgk0F8eLwaFOtC5870yn") // replace `vi77Dgk0F8eLwaFOtC5870yn` with your own media ID
```

Then, run the `Example iOS` target.

## FAQ

If you have any questions, ask us in the [community](https://community.api.video) or
use [issues](https://github.com/apivideo/api.video-swift-player-analytics/issues).
