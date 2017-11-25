class CreatePlaces < ActiveRecord::Migration[5.1]
  def change
    create_table :places do |t|
      t.string :google_id
      t.string :name
      t.string :vicinity
      t.string :icon
      t.string :location

      t.timestamps
    end
  end

  create_table :places_preferences, id: false do |t|
    t.belongs_to :place, index: true
    t.belongs_to :preference, index: true
  end
end
