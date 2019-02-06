class AddMinorAgeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :minor, :boolean, default: false
  end
end
