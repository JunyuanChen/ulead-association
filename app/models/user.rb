class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_many :articles, dependent: :destroy
  has_many :approvals, class_name: 'Article', foreign_key: :approver_id, dependent: :nullify
  enum permission: %i[unapproved member reviewer admin developer]

  def update_permission!(permission)
    raise TypeError, "`#{permission}' is not a valid permission." unless
      permission.is_a?(Symbol) || permission.is_a?(String)

    # This is necessary because `has_secure_password' made it impossible to use #update.
    ActiveRecord::Base.connection.exec_update('UPDATE `users` SET `permission` = ?, `updated_at` = ? WHERE `id` = ?',
                                              'Permission Update',
                                              [[nil, User.permissions[permission]],
                                               [nil, Time.now],
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
