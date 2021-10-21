---
title: "TMDB Movie App"
image: "/images/tmdb_movies.png"
codeGistUrl: "https://raw.githubusercontent.com/bimsina/Matinee-Flutter/master/lib/main.dart"
codeUrl: "https://github.com/bimsina/Matinee-Flutter"
demoUrl: "https://bimsina.github.io/Matinee-Flutter/#/"
categories: ["full-app"]
packages:
  [
    "https://pub.dev/packages/http",
    "https://pub.dev/packages/shared_preferences",
    "https://pub.dev/packages/provider",
    "https://pub.dev/packages/carousel_slider",
  ]
---

## Movies App made in Flutter with api data from TMDB

This is an app that displays you details of movies that you can search for or browse.

## Features

- Fetch api data from TMDB asynchronously.
- Dynamic Theming using Provider
- Search Functionality

- Video Demo: "https://youtu.be/5_bDIUYLWzg"

<table>
<tr>
<td>
  <a href ="https://play.google.com/store/apps/details?id=com.bimsina.movies"><img src ="https://play.google.com/intl/en/badges/images/generic/en_badge_web_generic.png" ></a>
</td>
</tr>
</table>

### Screenshots

<table style={border:"none"}><tr>
<td><img src="https://user-images.githubusercontent.com/29589003/58170605-93aba280-7cb3-11e9-8733-dff46d1e86c7.png" alt="Screenshot 2" /></td>
<td><img src="https://user-images.githubusercontent.com/29589003/58170608-93aba280-7cb3-11e9-933f-395501d7a5a0.png" alt="Screenshot 1" /></td>

<td><img src="https://user-images.githubusercontent.com/29589003/58170610-94443900-7cb3-11e9-946f-79587eaa1043.png" alt="Screenshot 3" /></td>
<td><img src="https://user-images.githubusercontent.com/29589003/58170611-94443900-7cb3-11e9-8f01-ce5fe83bb93e.png" alt="Screenshot 1""/></td>

<td><img src="https://user-images.githubusercontent.com/29589003/58170612-94dccf80-7cb3-11e9-8955-ce6bba8b36dd.png" alt="Screenshot 2" /></td>
<td><img src="https://user-images.githubusercontent.com/29589003/58170613-94dccf80-7cb3-11e9-9182-a08922ae7139.png" alt="Screenshot 3"/></td>

</tr>

</table>

## To run this app

- Obtain api key from <a href ="https://www.themoviedb.org/">TMDB</a>.
- Replace YOUR_API_KEY in api_constants.dart with your api key.
- Run the app with <b>flutter run --release</b>
