class EmailPreference < ActiveRecord::Base
  belongs_to :user
  belongs_to :system_email

  validates :user, presence: true
  validates :token, presence: true

  before_validation :ensure_token

  def self.email_list
    [
      { slug: 'new_version', description: 'New cookbook version' },
      { slug: 'deleted', description: 'Cookbook deleted' },
      { slug: 'deprecated', description: 'Cookbook deprecated' }
    ]
  end

  def self.default_set_for_user(user)
    email_list.each do |slug, description|
      EmailPreference.create(
        user: user,
        slug: slug,
        description: description
      )
    end
  end

  def to_param
    token
  end

  private

  #
  # This ensures there's a token present when a request is created.
  #
  def ensure_token
    self.token = SecureRandom.hex if token.blank?
  end
end
