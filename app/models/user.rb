class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_many :articles, dependent: :destroy
  enum permission: %i[unapproved member reviewer admin developer]

  def update_permission!(permission)
    # This is necessary because `has_secure_password' made it impossible to use #update.
    permission = User.permissions[permission] unless permission.is_a?(Integer)
    ActiveRecord::Base.connection.exec_update('UPDATE `users` SET `permission` = ? WHERE `id` = ?',
                                              'Permission Update',
                                              [[nil, permission],
                                               [nil, id]])
    reload
  end

  def permission?(required)
    required = User.permissions[required] unless required.is_a?(Integer)
    User.permissions[permission] >= required
  end

  def can_view?(article)
    return true if article.author == self

    if article.hidden?
      permission? :admin
    elsif !article.approved?
      permission? :reviewer
    else
      true
    end
  end

  def can_edit?(article)
    if article.hidden?
      permission? :admin
    elsif article.approved?
      permission? :reviewer
    else
      article.author == self || permission?(:reviewer)
    end
  end
end
