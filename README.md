wishywishy
==========

Social wishlist. This was developed as part of a course, but since we didn't continue with the project, now we open source it because it can be a nice example of a Sinatra REST API.

## Set up

Install [MongoDB](http://docs.mongodb.org/manual/installation/)

```
$ git clone https://github.com/miguelfrde/wishywishy.git
$ bundle install
```

## Run

First make sure that `mongod` is running on localhost.

Then (recommended):

```
$ rake
```

Other options:

- `rake serve`
- `rerun foreman start`
- `rackup config.ru`
- `rerun rackup config.ru`
- `foreman start`

## Testing

- `rake spec` runs specs using a local MongoDB instance

- `rake spec:remote` runs specs using a remote MongoDB instance. Useful to test on production: `heroku run rake spec:remote`
