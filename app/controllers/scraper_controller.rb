# frozen_string_literal: true

class ScraperController < ApplicationController
  def fetch_data
    url = params[:url]
    fields = params[:fields]

    unless url.present? && fields.present?
      return render json: { error: "Missing 'url' or 'fields'" }, status: 400
    end

    command = ::ScrapePage.call(url: url, fields: fields)

    render json: command.result
  rescue => e
    render json: { error: e.message }, status: 500
  end
end
