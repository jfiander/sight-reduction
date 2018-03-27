class CreateLocs < ActiveRecord::Migration[5.0]
  def change
    create_table :locs do |t|
      t.string :lha
      t.string :dec
      t.string :ho
      t.string :lat
      t.string :lon
      t.decimal :dec_lha, precision: 8, scale: 5
      t.decimal :dec_dec, precision: 8, scale: 5
      t.decimal :dec_ho, precision: 8, scale: 5
      t.decimal :dec_lat, precision: 8, scale: 5
      t.decimal :dec_lon, precision: 8, scale: 5

      t.timestamps
    end
  end
end
