###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class BeaconSerializer < BaseSerializer
      attributes :id, :name, :proximity_id, :location, :zone, :vendor, :protocol, :unique_id, :config

      def zone
        S2sApi::V1::ZoneWithoutBeaconsSerializer.new(object.zone, root: false).as_json if object.zone
      end

      def proximity_id
        object.proximity_id.to_s
      end

      def location
        {
          lat: object.lat,
          lng: object.lng,
          floor: object.floor,
          address: object.location
        }
      end

      def unique_id
        wrap_beacon.uuid if controller
      end

      def config
        {
          data: object.config.attributes,
          config_updated_at: object.beacon_config.updated_at,
          beacon_updated_at: object.beacon_config.beacon_updated_at
        }
      end

      private

      def wrap_beacon
        case object.vendor
        when 'Kontakt' then KontaktIoBeacon.new(object, current_admin)
        else WrappedBeacon.new(object, current_admin)
        end
      end

      def current_admin
        @current_admin ||= controller.send(:current_admin).object
      end

      def controller
        @controller ||= @serialization_options.fetch(:controller, nil)
      end
    end
  end
end
