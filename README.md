# @elm-land/movies
> An implementation of the [TasteJS Movies](https://tastejs.com/movies) learning app, powered by [the TMDB API](https://www.themoviedb.org/), with a design inspired by the [Nuxt Movies example](https://github.com/nuxt/movies).


## Introduction

The goal of this repository is to show you how to use [Elm Land](https://elm.land) to build a web application. If you're new to Elm Land or learning web development, we recommend you join [the community Discord](https://join.elm.land)!

<!-- ![Screenshot](./docs/screenshot.jpg) -->

__Disclaimer:__ This product uses [the TMDB API](https://www.themoviedb.org/) but is not endorsed or certified by TMDB.

<!-- ![The TMDB logo](https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bafe5dcb6f8a62a4c6bc55cd9ba82bb2cd95f6c.svg) -->

## Running the app locally

Here's how you can run this web application locally on your own machine.

1. Be sure to install [Node.js v18.15.0+](https://nodejs.org/)
1. Copy the `.env.example` file to `.env`, and provide your [personal TMDB API token](https://developers.themoviedb.org/3/getting-started/introduction). Here's a quick example:

    ```sh
    # https://developers.themoviedb.org/3/getting-started/introduction
    TMDB_API_TOKEN="eyJhbGciOiJIU9......94_1RbDIf3kQ1vgB-I4"
    ```

1. Run the Elm Land server:
    ```
    npx elm-land server
    ```

1. Visit `http://localhost:1234` in your web browser!

## Special thanks

- [TasteJS](https://tastejs.com/movies) - For providing a resource for folks to learn how to build web apps
- [Nuxt Community](https://github.com/nuxt/movies) - For sharing a beautiful, responsive design to get inspiration from
- [TMDB](https://www.themoviedb.org/) - For your awesome API, and great developer documentation