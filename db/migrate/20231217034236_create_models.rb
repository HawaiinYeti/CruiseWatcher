class CreateModels < ActiveRecord::Migration[7.1]
  def change
    create_table :ports do |t|
      t.string :name
      t.string :code
      t.string :region

      t.timestamps
    end

    create_table :ships do |t|
      t.string :name
      t.string :ship_class
      t.string :ship_code
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    create_table :cruises do |t|
      t.references :ship, null: false, foreign_key: true
      t.string :cruise_code
      t.string :name

      t.timestamps
    end

    create_table :sailings do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :sailing_code
      t.boolean :active, default: true, null: false
      t.references :ship, null: false, foreign_key: true
      t.references :cruise, null: false, foreign_key: true

      t.timestamps
    end

    create_table :rooms do |t|
      t.string :name
      t.string :room_class
      t.references :sailing, null: false, foreign_key: true
      t.decimal :price, default: 0, null: false

      t.timestamps
    end

    create_table :room_pricings do |t|
      t.datetime :timestamp
      t.references :room, null: false, foreign_key: true
      t.references :sailing, null: false, foreign_key: true
      t.decimal :price, default: 0, null: false

      t.timestamps
    end

    create_table :room_features do |t|
      t.string :feature_name
      t.text :regex_matchers, default: [].to_yaml, null: false

      t.timestamps
    end

    create_table :room_feature_memberships do |t|
      t.references :room, null: false, foreign_key: true
      t.references :room_feature, null: false, foreign_key: true

      t.timestamps
    end

    create_table :port_cruise_memberships do |t|
      t.references :port, null: false, foreign_key: true
      t.references :cruise, null: false, foreign_key: true

      t.timestamps
    end
  end
end
