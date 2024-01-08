class SyncDataJob < ApplicationJob
  queue_as :default

  def perform
    client = RcClient.new
    cruises = client.get_sailings(Ship.where(active: true).pluck(:ship_code))

    Parallel.each(cruises, in_threads: 2) do |cruise|
      cruise_client = RcClient.new

      ship = Ship.find_or_create_by(
        ship_code: cruise[:masterSailing][:itinerary][:ship][:code]
      )

      cruise_obj = ship.cruises.find_or_create_by(
        cruise_code: cruise[:masterSailing][:itinerary][:code]
      )
      cruise_obj.update(
        name: cruise[:masterSailing][:itinerary][:name]
      )

      ports = cruise[:masterSailing][:itinerary][:days].
              select { |x| x[:type] == 'PORT' }
      port_objs = ports.map do |day|
        port = Port.find_or_create_by(
          code: day[:ports].first[:port][:code]
        )
        port.update(
          name: day[:ports].first[:port][:name],
          region: day[:ports].first[:port][:region],
        )
        port
      end
      cruise_obj.ports = port_objs.uniq

      sailings = cruise[:sailings].map do |sailing|
        sailing_obj = Sailing.find_or_create_by(
          sailing_code: sailing[:id]
        )

        sailing_obj.update(
          ship_id: ship.id,
          cruise_id: cruise_obj.id,
          start_date: sailing[:startDate].in_time_zone,
          end_date: sailing[:endDate].in_time_zone,
          active: true
        )
        sailing_obj
      end
      cruise_obj.sailings.
        where.not(sailing_code: sailings.pluck(:sailing_code)).
        update(active: false)

      sailings.each do |sailing|
        rooms = cruise_client.get_rooms(sailing)

        rooms.each do |room|
          room_obj = sailing.rooms.find_or_create_by(
            name: room[:title],
            room_class: room[:cabinClass]
          )
          room_obj.update(
            price: room[:priceLockup][:totalPriceNbr]
          )
        end
      end
    end

    true
  end
end
