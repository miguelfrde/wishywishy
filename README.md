wishywishy
==========

Social wishlist

## Set up

Install [MongoDB](http://docs.mongodb.org/manual/installation/)

```
$ git clone https://github.com/miguelfrde/wishywishy.git
$ bundle install
```

## Run

First make sure that `mongod` is running.

Then (recommended):

```
$ rerun foreman start
```

Other options:

- `rackup config.ru`
- `rerun rackup config.ru`
- `foreman start`
