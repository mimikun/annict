# frozen_string_literal: true

module V3
  class TracksController < V3::ApplicationController
    before_action :authenticate_user!

    def show
    end
  end
end
