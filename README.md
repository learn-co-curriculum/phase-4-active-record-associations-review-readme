# Active Record Associations Review

## Learning Goals

- Understand how the foreign key is used to connect between two tables
- Create one-to-many and many-to-many relationships
- Use `has_many` and `belongs_to` Active Record macros

## Introduction

Active Record associations are an iconic Rails feature. They allow developers to
work with complex networks of related models without having to write a single
line of SQL &mdash; as long as all of the names line up!

To code along, run:

```sh
bundle install
rails db:migrate db:seed
```

You can use `rails console` to test out the code from these examples.

## Foreign Keys

It all starts in the database. **Foreign keys** are columns that refer to the
primary key of another table. Conventionally, foreign keys in Active Record are
comprised of the name of the model you're referencing, and `_id`. So for example
if the foreign key was for a `authors` table it would be `author_id`.

We can visualize in the relationship between two tables using foreign keys in an
Entity Relationship Diagram (ERD):

![one-to-many](https://raw.githubusercontent.com/learn-co-curriculum/phase-4-active-record-associations-review-readme/master/posts-authors.png)

Like any other column, foreign keys are accessible through instance methods of
the same name. For example, a schema for the above ERD would look like this:

```rb
create_table "authors", force: :cascade do |t|
  t.string "name"
end

create_table "posts", force: :cascade do |t|
  t.string "title"
  t.text "content"
  t.integer "author_id", null: false
end
```

And in Active Record, this mean you could find a post's author with the
following Active Record query:

```ruby
Author.find(post.author_id)
```

Which is equivalent to the SQL:

```sql
SELECT * FROM authors WHERE id = #{post.author_id}
```

And you could lookup an author's posts like this:

```ruby
Post.where("author_id = ?", author.id)
```

Which is equivalent to the SQL:

```sql
SELECT * FROM posts WHERE author_id = #{author.id}
```

This is all great, but Rails is always looking for ways to save us keystrokes.

## One-To-Many Relationships

By using Active Record's macro-style association class methods, we can add some
convenient instance methods to our models.

The most common relationship is **one-to-many**. Active Record gives us the
`has_many` and `belongs_to` macros for creating instance methods to access data
across models in a **one-to-many** relationship.

### belongs_to

Each `Post` is associated with **one** `Author`.

```ruby
class Post < ApplicationRecord
  belongs_to :author
end
```

We now have access to some new instance methods, like `author`. This will return
the actual `Author` object that is attached to that `post`.

```ruby
post.author_id = 5
post.author #=> #<Author id=5>
```

### has_many

In the opposite direction, each `Author` might be associated with zero, one, or
many `Post` objects. We haven't changed the schema of the `authors` table at
all; Active Record is just going to use `posts.author_id` to do all of the
lookups.

```ruby
class Author < ApplicationRecord
  has_many :posts
end
```

Now we can look up an author's posts just as easily:

```ruby
author.posts #=> [#<Post id=3>, #<Post id=8>]
```

Remember, Active Record uses its [Inflector][api_inflector] to switch between the singular and plural forms of your models.

<table border="1" cellpadding="4" cellspacing="0">
  <tr>
    <th>Name</th>
    <th>Data</th>
  </tr>

  <tr>
    <td>Model</td>
    <td>`Author`</td>
  </tr>
  <tr>
    <td>Foreign Key</td>
    <td>`author_id`</td>
  </tr>
  <tr>
    <td>`belongs_to`</td>
    <td>`:author`</td>
  </tr>
  <tr>
    <td>`has_many`</td>
    <td>`:authors`</td>
  </tr>
</table>

Like many other Active Record class methods, the symbol you pass determines the
name of the instance method that will be defined. So `belongs_to :author` will
give you a `post.author` instance method, and `has_many :posts` will give you
`author.posts`.

## Convenience Builders

### Building a new item in a collection

If you want to add a new post for an author, you might start this way:

```ruby
new_post = Post.create(author_id: author.id, title: "Web Development for Cats")
```

But the association macros save the day again, allowing this instead:

```ruby
new_post = author.posts.create(title: "Web Development for Cats")
```

This will return a create a new `Post` object with the `author_id` already set
for you! We use this one as much as possible because it's just easier.

`author.posts.create` will create a new instance and persist it to the database.
You can also use `author.posts.build` to generate a new instance without
persisting.

### Setting a singular association

The setup process is a little bit less intuitive for singular associations.
Remember, a post `belongs_to` an author. The verbose way of creating this
association would be like so:

```ruby
post.author = Author.new(name: "Leeroy Jenkins")
```

In the previous section, `author.posts` always exists, even if it's an empty
array. Here, `post.author` is `nil` until the author is defined, so Active
Record can't give us something like `post.author.create`. Instead, it prepends
the attribute with `build_` or `create_`. The `create_` option will persist to
the database for you.

```ruby
new_author = post.create_author(name: "Leeroy Jenkins")
```

Remember, if you used the `build_` option, you'll need to persist your new `author` with `#save`.

These methods are also documented in the [Rails Associations Guide][guides_associations].

### Collection Convenience

If you add an existing object to a collection association, Active Record will
conveniently take care of setting the foreign key for you:

```ruby
author = Author.find_by(name: "Leeroy Jenkins")
author.posts
#=> []
post = Post.new(title: "Web Development for Cats")
post.author
#=> nil
author.posts << post
post.author
#=> #<Author @name="Leeroy Jenkins">
```

## One-to-One Relationships

A **one-to-one** relationship is probably the least common type of relationship
you'll find.

One case where you might reach for a **one-to-one** relationship is for creating
a separate `Profile` model with data related to an `Author`. Profiles can get
pretty complex, so in large applications it can be a good idea to give them
their own model. In this case:

- Every author would have one, and only one, profile.
- Every profile would have one, and only one, author.

Here's an example of what that ERD would look like:

![one-to-one diagram](https://raw.githubusercontent.com/learn-co-curriculum/phase-4-active-record-associations-review-readme/master/profiles-authors.png)

`belongs_to` makes another appearance in this relationship, but instead of
`has_many` the other model is declared with `has_one`:

```rb
class Author < ApplicationRecord
  has_one :profile
end

class Profile < ApplicationRecord
  belongs_to :author
end
```

If you're not sure which model should be declared with which macro, it's usually
a safe bet to put `belongs_to` on whichever model has the foreign key column in
its database table.

## Many-to-Many Relationships and Join Tables

Each author has many posts, each post has one author.

The universe is in balance. We're programmers, so this really disturbs us. Let's
shake things up and think about tags.

- **One-to-one** doesn't work because a post can have multiple tags.
- **One-to-many** doesn't work because a tag can appear on multiple posts.

Because there is no "owner" model in this relationship, there's also no right
place to put the foreign key column.

<table border="1" cellpadding="4" cellspacing="0">
  <tr>
    <th>`tag_id`</th>
    <th>`post_id`</th>
  </tr>

  <tr>
    <td>1</td>
    <td>1</td>
  </tr>
  <tr>
    <td>2</td>
    <td>1</td>
  </tr>
  <tr>
    <td>1</td>
    <td>5</td>
  </tr>
</table>

This join table depicts two tags (1 and 2) and two posts (1 and 5). Post 1 has
both tags, while Post 5 has only one.

We need a new table that sits between `posts` and `tags`:

![many-to-many diagram](https://raw.githubusercontent.com/learn-co-curriculum/phase-4-active-record-associations-review-readme/master/posts-post_tags-tags.png)

### has_many :through

To work with the join table, both our `Post` and `Tag` models will have a
`has_many` association with the `post_tags` table. We also still need to
associate `Post` and `Tag` themselves. Ideally, we'd like to be able to call a
`@my_post.tags` method, right? That's where `has_many :through` comes in.

To do this requires a bit of focus. But you can do it! First of all, let's add
the `has_many :post_tags` line to our `Post` and `Tag` models:

```ruby
class Post < ApplicationRecord
  has_many :post_tags
end

class PostTag < ApplicationRecord
  belongs_to :post
  belongs_to :tag
end

class Tag < ApplicationRecord
  has_many :post_tags
end
```

So now we can run code like `post.post_tags` to get all the join entries. This
is kinda sorta what we want. What we really want is to be able to call
`post.tags`, so we need one more `has_many` relationship to complete the link
between tags and posts: `has_many :through`. Essentially, our `Post` model has
many `tags` _through_ the `post_tags` table, and vice versa. Let's write that
out:

```ruby
class Post < ApplicationRecord
  has_many :post_tags
  has_many :tags, through: :post_tags
end

class PostsTag < ApplicationRecord
  belongs_to :post
  belongs_to :tag
end

class Tag < ApplicationRecord
  has_many :post_tags
  has_many :posts, through: :post_tags
end
```

Great, we've unlocked our `post.tags` and `@tag.posts` methods!

## Conclusion

For every relationship, there is a foreign key somewhere. Foreign keys
correspond to the `belongs_to` macro on the model.

**One-to-one** and **many-to-one** relationships only require a single foreign
key, which is stored in the 'subordinate' or 'owned' model. The other model can
access data in the associated table via a `has_one` or `has_many` method,
respectively.

**Many-to-many** relationships require a join table containing a foreign key for
both models. The models need to use the `has_many :through` method to access
data from the related table via the join table.

You can see the entire [list of class methods][api_associations_class_methods]
in the Rails API docs.

## Resources

- [Active Record Association Basics](http://guides.rubyonrails.org/association_basics.html)
- [Entity Relationship Diagram Generator](https://dbdiagram.io/d)

[guides_associations]: http://guides.rubyonrails.org/association_basics.html
[guides_has_many_through]: http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association
[api_associations_class_methods]: http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
[api_inflector]: http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html
