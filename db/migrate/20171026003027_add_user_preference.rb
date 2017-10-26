class AddUserPreference < ActiveRecord::Migration[5.1]
  def change
    create_table :preferences_users, id: false do |t|
      t.belongs_to :preference, index: true
      t.belongs_to :user, index: true
    end
  end
end
