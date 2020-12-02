# ulead-association
This is the software that powers https://www.ulead-association.org/

# First time server setup
```sh
export RAILS_ENV=production
bundle install --without development test
rails credentials:edit
rails db:schema:load
rails assets:precompile
rails server -d
```

# Development setup
```sh
bundle install
yarn install
rails server
```

# DB seeding
To create one user for each permission level, run the following in the rails console.
```ruby
User.permissions.each do |permission, _id|
    User.create! username: permission,
                 password: '123456',
                 password_confirmation: '123456',
                 permission: permission
end
```

With `faker` gem one can easily generate nonsense articles and tags with `Faker::Lorem`.

# Architecture
The site consists three basic building blocks (for now) - articles, tags and users.

An article has an author, an approver and a boolean status `hidden`. When an article
is created, its `approver` defaults to `nil`, indicating that the article is not yet
approved. The `hidden` attributes defaults to `false`.

Users can create, edit and delete articles if they have adequate permission. There
are 5 permission levels - `:unapproved`, `:member`, `:reviewer`, `:admin` and
`:developer`. On a user's profile page, all articles authored by the user will be listed.

- guest users can only view approved articles and tags.  
- `:unapproved` users cannot sign in at all, and thus they are the same as guest users.  
- `:member` can create new articles and new tags, and can view their own user profile
and change their password. They can view their own articles regardless if its hidden
or approved. They are able to edit their own articles that are not approved or hidden.  
- `:reviewer` can in addition approve articles, and can edit any articles that are not
hidden. They can see who authored an article, and, if the article is approved, who
approved it. They also have access to a user index and the profile page of all users.  
- `:admin` can view and edit hidden articles. They can view and change the permission
level of all users (and thus can approve new users). They can also reset the password
of any user.  
- `:developer` has a few extra tools. They can view and delete the resources (images, etc.)
uploaded to the server. In addition, they can create and delete dynamic routing rules,
rules that bind a path to an article.

Tags have a name and a description. Each article can have many tags, and each tags
can have many articles. They are associated by `HABTM` relation.

Any other pages and features on the website, such as `/about_us` page and homepage,
is achieved with articles and dynamic routing rules. Since one can use Markdown and HTML
markup in an article, most, if not all, static pages can be implemented in this way,
without the need of re-deploying everything.
