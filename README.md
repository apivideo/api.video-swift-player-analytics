# api.video-ios-player-analytics
[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video) &nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-ios-player-analytics?style=social)](https://github.com/apivideo/api.video-ios-player-analytics) &nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/API_OAS_file/blob/master/apivideo_banner.png)
<h1 align="center">api.video iOS player analytics module</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.

# Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
    - [Installation](#installation)
        - [Swift Package Manager](#swift-package-manager)
- [Sample application](#sample-application)
- [Documentation](#documentation)
    - [Options](#options)
    - [PlayerAnalytics API](#playeranalytics-api)
        - [`play()`](#play)
        - [`resume()`](#resume)
        - [`ready()`](#ready)
        - [`end()`](#end)
        - [`seek(from: Float, to: Float)`](#seekfrom-float-to-float)
        - [`pause()`](#pause)
        - [`destroy()`](#destroy)
        - [`currentTime`](#currenttime)
    - [API documentation](#api-documentation)


# Project description
iOS library to manually call the api.video analytics collector.

This is useful if you are using a video player for which we do not yet provide a ready-to-use monitoring module.

# Getting started

## Installation
### Swift Package Manager
```swift
 https://github.com/apivideo/api.video-ios-player-analytics.swift
```

# Sample application

A demo application demonstrates how to use player analytics library. See [`/example`](https://github.com/apivideo/api.video-ios-player-analytics/tree/main/Example) folder.

# Documentation

## Options

The analytics module constructor takes a `Options` parameter that contains the following options:

|         Option name | Mandatory | Type                                            | Description                                                                                                  |
| ------------------: | --------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
|            mediaUrl | **yes**   | String                                          | url of the media (eg. `https://cdn.api.video/vod/vi5oDagRVJBSKHxSiPux5rYD/hls/manifest.m3u8`)                |
|           videoInfo | **yes**   | VideoInfo                                       | information containing analytics collector url, video type (vod or live) and video id                        |
|            metadata | no        | ```[[String:String]]```                       | object containing [metadata](https://api.video/blog/tutorials/dynamic-metadata)                              |
| onSessionIdReceived | no        | ```((String) -> ())?```            | callback called once the session id has been received                                                        |
|              onPing | no        | ```((PlaybackPingMessage) -> ())?``` | callback called before sending the ping message                                                              |

Options instantiation is made with either mediaUrl or videoInfo.

Once the module is instantiated, the following methods have to be called to monitor the playback events.

## PlayerAnalytics API

#### `play(){(isDone, error) in

}`
> method to call when the video starts playing for the first time (in the case of a resume after paused, use `resume()`)

#### `resume(){(isDone, error) in

}`
> method to call when the video playback is resumed after a pause

#### `ready(){(isDone, error) in

}`
> method to call once the player is ready to play the media

#### `end(){(isDone, error) in

}`
> method to call when the video is ended

#### `seek(from: Float, to: Float){(isDone, error) in

}`
> method to call when a seek event occurs, the `from` and `to` parameters are mandatory and should contains the seek start & end times in seconds

#### `pause(){(isDone, error) in

}`
> method to call when the video is paused

#### `destroy(){(isDone, error) in

}`
> method to call when the video player is disposed (eg. when the use closes the navigation tab)

#### `currentTime`
> field to call each time the playback time changes (it should be called often, the accuracy of the collected data depends on it)


