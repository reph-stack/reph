# Reph

[About RePh](https://medium.com/@chvanikoff/reph-react-phoenix-app-scaffolding-made-easy-346cddc76838)

Reph is an acronym for **RE**act + **PH**oenix stack. This library provides `reph.new` installer as an archive. It aims to replace `phx.new` for new projects, based on React/Phoenix stack, scaffolding.

Some of the batteries included:
- Webpack 2 pre-installed and set up
- React and required dependencies pre-installed and set up
- Less-compiler pre-installed and set up
- SSR (Server-side rendering) set up
- React-router set up to work with SSR
- Websocket connection

Syntax of the `reph.new` command is the same as of `phx.new`, except for flags `--no-brunch`, `--no-html`, `--dev`, `--ecto` which are not supported.

To install, run:

    mix archive.install github reph-stack/reph

To build and install locally:
 
    $ MIX_ENV=prod mix archive.build
    $ mix archive.install

Once installed, you can scaffold an application in a following way, for example:

    mix reph.new myapp --database=mysql --module=APP

