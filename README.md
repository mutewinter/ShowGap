ShowGap
=======

**Filling the gap between podcast hosts and their listeners.**

_I started this project a year ago as a replacement for
[Showbot](http://showbot.5by5.tv/). I ended up falling out of love with the
idea of supporting it. I am not planning to continue development. The code is
MIT licensed, have fun._

[![][img8s]][img8]
[![][img2s]][img2]
[![][img5s]][img5]
[![][img1s]][img1]
[![][img4s]][img4]
[![][img6s]][img6]
[![][img7s]][img7]
[![][img3s]][img3]

## Woah, what's all this now?

ShowGap is a web application. Rails runs the server, which is just a JSON API.
The client is entirely written with [Backbone](http://backbonejs.org/).

## Features

* Customizable discussions (e.g. disable downvoting, only allow link replies)
* Subdomains for each show
* Multiple episodes per show with air date and time
* Multiple user roles (admin, host, and listener)
* Twitter authentication
* Backbone.js so it's super fast
* Rails [jBuilder](https://github.com/rails/jbuilder)-based API
* Server provisioning script using
  [Teleport](https://github.com/gurgeous/teleport)
* Server deployment script using [Mina](https://github.com/nadarei/mina)

## Technologies

* [Backbone](http://backbonejs.org/)
* [Rails](http://rubyonrails.org/)
* [CanCan](https://github.com/ryanb/cancan)
* [Twitter Boostrap](http://twitter.github.com/bootstrap/)
* [Underscore](http://underscorejs.org/)
* [Handlebars](http://handlebarsjs.com/)
* [Sugar.js](http://sugarjs.com/)
* [Kalendae](https://github.com/ChiperSoft/Kalendae)
* [jQuery Waypoints](http://imakewebthings.com/jquery-waypoints/)
* [URI.js](http://medialize.github.com/URI.js/)
* [Backbone Relational](https://github.com/PaulUithol/Backbone-relational/)
* [Bootstrap Wysihtml5](http://jhollingworth.github.com/bootstrap-wysihtml5/)
* [Backbone Forms](https://github.com/powmedia/backbone-forms)

## How do I Set it Up?

_You must have Ruby 2.0 installed. I suggest using [RVM](https://rvm.io/)._

1. `bundle`
1. `rake db:create db:migrate db:seed`
1. [Make an App](https://dev.twitter.com/apps) on Twitter
1. `mv config/application.yml.example config/application.yml`
1. Edit `config/application.yml` and add your Twitter consumer keys
1. `rails s`
1. Open [`localhost:3000`](http://localhost:3000).

**Becoming an Admin**

1. Click **Log in**.
1. Log in with Twitter
1. `rails c`
1. `User.last.update_attribute :role, 'admin'`
1. Refresh and your account can now create new shows!

## Deploying & Provisioning

Deploying and Provisioning of ShowGap servers is entirely automated.

**Deploying**

Simply run `mina deploy`.

**Provisioning**

Simply run `teleport user@server`.

## License

MIT

[img1]: http://i.imgur.com/ZCu1yRF.jpg
[img1s]: http://i.imgur.com/ZCu1yRFs.jpg
[img2]: http://i.imgur.com/oyEkval.jpg
[img2s]: http://i.imgur.com/oyEkvals.jpg
[img3]: http://i.imgur.com/uTtkY7w.jpg
[img3s]: http://i.imgur.com/uTtkY7ws.jpg
[img4]: http://i.imgur.com/itJYpBZ.jpg
[img4s]: http://i.imgur.com/itJYpBZs.jpg
[img5]: http://i.imgur.com/N3plj4w.jpg
[img5s]: http://i.imgur.com/N3plj4ws.jpg
[img6]: http://i.imgur.com/g1xOtv3.jpg
[img6s]: http://i.imgur.com/g1xOtv3s.jpg
[img7]: http://i.imgur.com/lBA3S3X.jpg
[img7s]: http://i.imgur.com/lBA3S3Xs.jpg
[img8]: http://i.imgur.com/Nqu2InM.jpg
[img8s]: http://i.imgur.com/Nqu2InMs.jpg
