class RenameTypeToTypeOfPlace < ActiveRecord::Migration[5.1]
  def change
    rename_column :preferences, :type, :type_of_place
  end
end
