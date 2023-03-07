class CreateCities < ActiveRecord::Migration[7.0]
  def change
    create_table :cities do |t|
      t.string :iata
      t.string :region
      t.string :country
      t.decimal :temperature
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :last_updated

      t.timestamps
    end
  end
end
