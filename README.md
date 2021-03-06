<img src="https://raw.github.com/espresso/enginery/master/logo.png" align="right">

# Enginery

### Fine-Tuned App Builder for [Espresso Framework](https://github.com/espresso/espresso)

<p>
<a href="https://travis-ci.org/espresso/enginery">
<img src="https://travis-ci.org/espresso/enginery.png"></a>
</p>

## Install

```bash
$ gem install enginery
```

\+ `$ rbenv rehash` if you are using `rbenv`

## Quick start

Create new application in `./App/` folder:

```bash
$ enginery g App
```

Create new application in current folder:

```bash
$ enginery g
```

Generate Controllers:

```bash
$ enginery g:c Foo
# generate multiple controllers at once ...
$ enginery g:c Foo Bar Baz
```

Generate Routes for `Foo` controller:

```bash
$ enginery g:r Foo a
# generate multiple routes at once ...
$ enginery g:r Foo a b c
```

Generate Models:

```bash
$ enginery g:m Foo
# generate multiple models at once ...
$ enginery g:m Foo Bar Baz
```

Generate Specs:

```bash
$ enginery g:s SomeController some_action
```

Generate Migrations:

```bash
$ enginery m migrationName model:ModelName column:some_column
```

List Migrations:

```bash
$ enginery m:l
```

Run Migrations:

```bash
$ enginery m:up migrationID
$ enginery m:down migrationID
```

## Application structure

```bash
- base/
  | - models/
  | - views/
  | - controllers/
  | - helpers/
  | - specs/
  | - migrations/
  | - boot.rb
  | - config.rb
  ` - database.rb

- config/
  | - config.yml
  ` - database.yml

- public/
  | - assets/
      | - app.css
      ` - app.js

- tmp/

- var/
  | - db/
  | - log/
  ` - pid/

- Rakefile
- Gemfile
- app.rb
- config.ru
```


# Tutorial

[Projects](https://github.com/espresso/enginery#projects) |
[Controllers](https://github.com/espresso/enginery#controllers) |
[Routes](https://github.com/espresso/enginery#routes) |
[Specs](https://github.com/espresso/enginery#specs) |
[Views](https://github.com/espresso/enginery#views) |
[Models](https://github.com/espresso/enginery#models) |
[Migrations](https://github.com/espresso/enginery#migrations)

## Projects

To generate a project simply type:

```bash
$ enginery g:p App
```

This will create `./App` folder with a ready-to-use application inside.

To generate a new application in current folder simply omit application name, "App" in our case:

```bash
$ enginery g:p
```

Also, when generating applications, unit name can be omitted:

```bash
$ enginery g
```

### Setups

Generated application will use `ERB` engine and wont be set to use any `ORM`.

To generate a project that will use a custom engine, use `engine` option followed by a semicolon and the full, case sensitive, name of desired engine:

```bash
$ enginery g engine:Slim
```

This will update your `Gemfile` by adding `slim` gem and also will update `config.yml` by adding `engine: :Slim`.


Option name can be shortened down to first letter:

```bash
$ enginery g e:Slim
```

If your project will use any `ORM`, use `orm` option followed by a semicolon and the name of desired `ORM`:

```bash
$ enginery g orm:ActiveRecord
```

**Worth to note** - `ORM` name are case insensitive and can be shortened to first letter(s):

project using ActiveRecord:
```bash
$ enginery g orm:ar
# or just
$ enginery g o:ar
```

project using DataMapper:
```bash
$ enginery g orm:dm
# or just
$ enginery g o:dm
```

project using Sequel:
```bash
$ enginery g orm:sequel
# or just
$ enginery g o:sq
```

Enginery also allow to specify [format](https://github.com/espresso/espresso/blob/master/docs/Routing.md#format) to be used by all controllers / actions.

Ex: to make all actions to serve URLs ending in `.html`, use `format:html`:

```bash
$ enginery g format:html
```

And of course as per other options, `format` can be shortened to first letter too:

```bash
$ enginery g f:html
```

And of course you can pass multiple options:

```bash
$ enginery g o:ar e:Slim f:html
```

**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**


## Controllers

As simple as:

```bash
$ enginery g:c Foo
```

This will create "base/controllers/foo/" folder and "base/controllers/foo_controller.rb" file.

The file will contain controller's setups and the folder will contain controller's actions.

### Map

By default the controller will be mapped to its underscored name, that's it, "Foo" to "/foo", "FooBar" to "/foo_bar", "Foo::Bar" to "/foo/bar" etc.

To generate a controller mapped to a custom location, use the `route` option:

```bash
$ enginery g:c Foo route:bar
# or just
$ enginery g:c Foo r:bar
```

### Setups

When generating a controller without any setups, it will use project-wide ones(passed at project generation), if any.

To generate a controller with custom setups, pass them as options:

```bash
$ enginery g:c Foo e:Haml
```

This will create a controller that will use `Haml` engine.

Another option is [format](https://github.com/espresso/espresso/blob/master/docs/Routing.md#format):

```bash
$ enginery g:c Foo f:html
```

### Multiple

When you need to generate multiple controllers at once just pass their names separated by a space:

```bash
$ enginery g:c A B C
```

This will generate 3 controllers without any setups.

Any passed setups will apply to all generated controllers:

```bash
$ enginery g:c A B C e:Haml
```

### Namespaces

When you need a namespaced controller, pass its name as is:

```bash
$ enginery g:c Foo::Bar
```

This will generate `Foo` module with `Bar` controller inside:

```ruby
module Foo
  class Bar < E
    # ...
  end
end
``` 

**Worth to note** that `Bar` controller will be mapped to "/foo/bar" URL.<br>
To map it to another location, use `route` option as shown above.

**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**


## Routes

As simple as:

```bash
$ enginery g:route Foo bar
# or just
$ enginery g:r Foo bar
```

where `Foo` is the controller name and `bar` is the route.

This will create "base/controllers/foo/bar.rb" and "base/views/foo/bar.erb" files.

### Mapping

You can provide the URL rather than the action name - it will be automatically converted into action name according to effective [path rules](https://github.com/espresso/espresso/blob/master/docs/Routing.md#action-mapping):

```bash
$ enginery g:r Forum posts/latest
```

This will create "base/controllers/forum/posts__latest.rb" file with `posts__latest` action inside and the "base/views/forum/posts__latest.erb" template file.

See [more details on actions mapping](https://github.com/espresso/espresso/blob/master/docs/Routing.md#action-mapping).

### Setups

Setups provided at route generation will be effective only on generated route:

```bash
# generate Foo controller
$ enginery g:c Foo e:Haml

# generate Foo#bar route
$ enginery g:r Foo bar

# generate Foo#baz route
$ enginery g:r Foo baz e:Slim
```

`Foo#bar` action will use `Haml` engine, as per controller setup.<br>
`Foo#baz` action will use `Slim` engine instead, as per route setup.


### Multiple

To generate multiple routes at once just pass their names separated by spaces:

```bash
$ enginery g:r Foo a b c
```

this will create 3 routes and 3 views.

**Worth to note** that any provided setups will apply on all and only generated actions.

**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**

## Specs

Specs are generated simultaneously with routes.

It makes sense to generate a spec manually only if it was accidentally lost/damaged.

**Note** - Enginery uses [Specular](https://github.com/slivu/specular) to build/run specs. Feel free to contribute by adding support for other testing frameworks.

To generate a spec use `spec`(or just `s`) notation followed by controller name and the route to be tested:

```bash
$ enginery g:s Foo bar
# where Foo is the controller and bar is the route.
```
This will create `base/specs/foo/` with  `bar_spec.rb` file inside.

To generate multiple specs pass route names separated by a space:

```bash
$ enginery g:s Foo a b c
```
This will generate `specs/foo/a_spec.rb`, `specs/foo/b_spec.rb` and `specs/foo/c_spec.rb` files.

To run a spec use `$ rake test:Foo#bar`, where `Foo` is the controller name and `bar` is the tested route.

To run all specs for `Foo` controller use `$ rake test:Foo`

To run all specs for all controllers use `$ rake test` or just `$ rake`


If the controller is under some namespace, pass the full name, do not worry about `::`, `rake` will take care:

```bash
$ rake test:Forum::Posts
$ rake test:Forum::Posts#read
```

To see all available specs use `$ rake -D`

**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**

## Views

View generator are triggered every time you generate a route, so it make sense to use it only to create a template that was accidentally damaged/lost.

Invocation:

```bash
$ enginery g:v Foo bar
```
where `Foo` is the controller name and `bar` is the action to generate view for.

This will create "base/views/foo/bar.[ext]" template, if it does not exists.

[ext] depending on effective template engine.

If template already exists, the generator will simply touch it, without modifying the name/content in any way.


**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**

## Models

Supported ORMs: `ActiveRecord`, `DataMapper`, `Sequel`

```bash
$ enginery g:model Foo
# or just 
$ enginery g:m Foo
```
this will create "base/models/foo.rb" file.

File content will depend on setups passed at project generation:

If we generate a project like this:
```bash
$ enginery g orm:ActiveRecord
```

the:
```bash
$ enginery g:m Foo
```

will result in:

```ruby
class Foo < ActiveRecord::Base

end
```

And if the project are generated like this:
```bash
$ enginery g orm:DataMapper
```

the:
```bash
$ enginery g:m Foo
```

will result in:

```ruby
class Foo
  include DataMapper::Resource

  property :id, Serial
end
```

To generate a model on a project without default `ORM`, use `orm` option at model generation:


```bash
$ enginery g:m Foo orm:ActiveRecord
# or just
$ enginery g:m Foo orm:ar
# or even
$ enginery g:m Foo o:ar
```

will result in:

```ruby
class Foo < ActiveRecord::Base

end
```
and will update your Gemfile by adding corresponding gems, unless they are already there.

### Multiple

Generating multiple models at once:

```bash
$ enginery g:m A B C
# or just for readability
$ enginery g:models A B C
```

**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**


## Migrations

Supported ORMs: `ActiveRecord`, `DataMapper`, `Sequel`

Initial migration for any model are auto-generated alongside with model:

```bash
$ enginery g:m Page
```
this will generate `Page` model as well a migration that will create model's table when performed up and drop it when performed down.

Migrations will reside in `base/migrations/` folder. The file for `Page` model created above will be named **1.[timestamp].initializing-Page-model.rb**

Now you can edit it by adding columns you need created alongside with table. You should add them inside `up` method or block, depending on used ORM.

If you do not want to edit the file manually, you can automatize this step as well by providing columns at model generation:

```bash
$ enginery g:m Page column:name column:about:text
```
now the "up" section will contain instructions to create the table and 2 columns.<br>
Note: if type omitted, String will be used.

When your migration are ready, run it using its serial number.

Serial number usually are printed when migration are generated.

You can also find it by listing available migrations:

```bash
$ enginery m:list
# or just
$ enginery m:l
```
this will display something like:

```bash
                    ---=---
                     1 : initializing-Page-model
            created at : [timestamp]
        last performed : [none|timestamp]
                    ---=---
```
where "1" is the serial number and "initializing-Page-model" is the name.

Run migration up:

```bash
enginery m:up 1
```

Run migration down:

```bash
enginery m:down 1
```

### Adding columns

To add some column to an existing model simply add new migration that will do this.

To generate a migration use the `m` notation followed by migration name, model and column(s):

```bash
$ enginery m add-email model:Person column:email
```
this will output something like:

```bash
--- Person model - generating "add-email" migration ---

  Serial Number: 2
```

Run migration up:

```bash
enginery m:up 2
```
this will alter table by adding "email" column of "string" type.


Run migration down:

```bash
enginery m:down 2
```
this will drop "email" column.


### Updating Columns

To modify some column type use `update_column` option followed by column name and new type:

```bash
enginery m update-email model:Person update_column:email:text
```
this will output something like:

```bash
--- Person model - generating "update-email" migration ---

  Serial Number: 3
```

Run migration up:

```bash
enginery m:up 3
```
this will alter table by setting "email" type to "text".

Run migration down:

```bash
enginery m:down 3
```
this will alter table by reverting "email" type to "string".


### Renaming Columns

To rename some column type use `rename_column` option followed by current column name and new name:

```bash
enginery m rename-name model:Person rename_column:name:first_name
```
this will output something like:

```bash
--- Person model - generating "update-name" migration ---

  Serial Number: 4
```

Running migration up will rename "name" column to "first_name":
```bash
enginery m:up 4
```

Running migration down will rename "first_name" back to "name":
```bash
enginery m:down 4
```


### Running Migrations

**Important Note:** `Enginery` using migrations granulation rather than migrations versioning.

This mean you can run any migration at any time without implicitly calling other migrations, giving you the full, fine-grained control over your migrations.

`Enginery` will keep track of migrations already performed and wont run same migration twice(unless `force` option used).

You are free to choose what migration(s) to run in multiple ways.

Most obvious one is to provide the serial number of a single migration:

```bash
$ enginery m:[up|down] 1
```

When you need to run multiple migrations pass serial numbers separated by spaces:

```bash
$ enginery m:[up|down] 1 4 6
```
this will run only 1st, 4th and 6th migrations.

When you need to run N to M migrations, use N-M notation:

```bash
$ enginery m:[up|down] 2-6
```
this will run 2nd to 6th migrations inclusive.


**Important Note:** `Enginery` will automatically set the running order depending on performed direction - ascending on "up" and descending on "down".

```bash
$ enginery m:up 4 2 6
```
performing order: 2 4 6


```bash
$ enginery m:down 4 2 6
```
performing order: 6 4 2


```bash
$ enginery m:up 1-4
```
performing order: 1 2 3 4


```bash
$ enginery m:down 1-4
```
performing order: 4 3 2 1


To list available migrations use `$ enginery m:list` or just `$ enginery m:l`


### Force Running

`Enginery` will keep track of migrations already performed and wont run same migration twice.

However, sometimes you may need to run it anyway due to manual schema modification etc.

In such non-standard cases you can use `force` option:

```bash
$ enginery m:up:force 1
```

### DataMapper Notes

`Enginery` migrations will only update database schema.

You'll have to manually update your models by adding/updating/removing properties.

As a workaround you can use [dm-is-reflective](https://github.com/godfat/dm-is-reflective) plugin that will create mappings between database columns and model's properties.

Also, with DataMapper ORM you have extra `rake` tasks "for free", like `dm:auto_migrate`, `dm:auto_upgrade`, `dm:auto_migrate:ModelName`, `dm:auto_upgrade:ModelName`

Use `$ rake -D` to list all tasks.

A note on renaming columns: as of 'dm-migrations' 1.2.0 renaming columns are broken for MySQL adapter. 1.3.0 have it fixed but it is not yet released.


**[ [contents &uarr;](https://github.com/espresso/enginery#tutorial) ]**

## Contributing

  - Fork Enginery repository
  - optionally create a new branch
  - make your changes
  - submit a pull request

<hr>

<p>
  Issues/Bugs:
  <a href="https://github.com/espresso/enginery/issues">
    github.com/espresso/enginery/issues</a>
</p>
<p>
  Mailing List: <a href="https://groups.google.com/forum/?fromgroups#!forum/espresso-framework">
  groups.google.com/.../espresso-framework</a>
</p>
<p>
  IRC channel: #espressorb on irc.freenode.net
</p>

### Author - [Silviu Rusu](https://github.com/slivu).  License - [MIT](https://github.com/espresso/espresso/blob/master/LICENSE).

