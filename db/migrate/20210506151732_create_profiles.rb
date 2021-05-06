class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.string :username
      t.string :email
      t.string :bio
      t.string :avatar_url
      t.string :facebook
      t.belongs_to :author, null: false, foreign_key: true

      t.timestamps
    end
  end
end
