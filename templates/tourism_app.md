---
title: "Travel App"
image: "/images/tourism.png"
codeGistUrl: "https://raw.githubusercontent.com/bimsina/visit_nepal/master/lib/main.dart"
codeUrl: "https://github.com/bimsina/visit_nepal"
demoUrl: "https://bimsina.github.io/visit_nepal/#/"
categories: ["full-app"]
packages:
  [
    "https://pub.dev/packages/shared_preferences",
    "https://pub.dev/packages/carousel_slider",
    "https://pub.dev/packages/graphql_flutter",
    "https://pub.dev/packages/http",
    "https://pub.dev/packages/url_launcher",
    "https://pub.dev/packages/shimmer",
    "https://pub.dev/packages/provider",
  ]
---

## Visit Nepal - Tourism app made with Flutter and Django

This is an app that gives you information about all the things that make Nepal breathtaking.<br>

### Features

- Fetch data from a [GraphQl Server]("https://tourism-nepal.herokuapp.com/")
- Data collected via web-scraping with Python.
- Navigate to a specific location via Google Maps
- Dynamic Theming using Provider
- Beautiful UI

### Backend Devs

- [Animesh Timsina]("https://github.com/AnimeshTimsina")
- [Lakshya pandit]("https://github.com/panditlakshya")

<table>
<tr>
<td>
<a href ="https://play.google.com/store/apps/details?id=com.bimsina.visit_nepal"><img src ="https://play.google.com/intl/en/badges/images/generic/en_badge_web_generic.png" ></a>

</td>
</tr>
</table>

### To run this app

- Obtain api key from [OpenWeatherMap]("https://openweathermap.org/api")
- Replace apiString in utils/constants.dart with your api key.
- Run the app with <b>flutter run --release</b>

### Screenshots

<table style={border:"none"}><tr>
<td><img src="https://user-images.githubusercontent.com/29589003/60561720-50ddef80-9d74-11e9-9407-69d8fd28e144.png" alt="Screenshot 1"/></td>
<td><img src="https://user-images.githubusercontent.com/29589003/60561720-50ddef80-9d74-11e9-9407-69d8fd28e144.png" alt="Screenshot 3"/></td>
<td><img src="https://user-images.githubusercontent.com/29589003/60561927-23de0c80-9d75-11e9-82c4-11486f429028.png" alt="Screenshot 2"/></td>
</tr>
<tr>
<td><img src="https://user-images.githubusercontent.com/29589003/60561660-0b212700-9d74-11e9-9360-e14ffbb1e29d.png" alt="Screenshot 1"/></td>
<td><img src="https://user-images.githubusercontent.com/29589003/60561296-c47efd00-9d72-11e9-9a7f-b1316e1e2ca9.png" alt="Screenshot 1"/></td>
<td><img src="https://user-images.githubusercontent.com/29589003/60561303-c779ed80-9d72-11e9-8e20-0bc413e3db5b.png" alt="Screenshot 1"/></td>
</tr>
</table>
