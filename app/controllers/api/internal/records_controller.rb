# frozen_string_literal: true

module Api
  module Internal
    class RecordsController < Api::Internal::ApplicationController
      permits :episode_id, :comment, :shared_twitter, :shared_facebook, :rating

      before_action :authenticate_user!, only: %i(create)

      def create(record, page_category)
        episode = Episode.published.find(record[:episode_id])
        record = episode.records.new do |c|
          c.comment = record[:comment]
          c.shared_twitter = record[:shared_twitter]
          c.shared_facebook = record[:shared_facebook]
          c.rating = record[:rating]
        end
        keen_client.page_category = page_category
        service = NewRecordService.new(current_user, record, keen_client)

        if service.save
          head 201
        else
          @record = service.record
          render status: 400, json: { message: @record.errors.full_messages.first }
        end
      end

      def user_heatmap(username, start_date, end_date)
        start_date = Time.parse(start_date)
        end_date = Time.parse(end_date)
        user = User.find_by(username: username)
        @days = user.records.between_times(start_date, end_date).
          group_by_day(:created_at).count.
          map { |date, val| [date.to_time.to_i, val] }.
          to_h
      end
    end
  end
end