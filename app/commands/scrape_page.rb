# frozen_string_literal: true

class ScrapePage
  prepend SimpleCommand

  attr_reader :url

  def initialize(url:, fields:)
    @url = url
    @fields = fields
  end

  def call
    html = Rails.cache.fetch(url, expires_in: 12.hours) do
      URI.open(url).read
    end
    doc = Nokogiri::HTML(html)

    build_data(doc)
  end

  private

  attr_reader :fields

  def build_data(doc)
    result = {}
    build_regular(doc, result)
    build_meta(doc, result) if fields["meta"].is_a?(Array)
    result
  end

  # 1. Handle regular fields
  def build_regular(doc, result)
    fields.reject { |key, _| key == "meta" }.each do |key, selector|
      element = doc.at_css(selector)
      result[key] = element ? element.text.strip : nil
    end
  end

  # 2. Handle meta fields
  def build_meta(doc, result)
    result["meta"] = {}
    fields["meta"].each do |meta_name|
      meta_tag = doc.at("meta[name='#{meta_name}']")
      result["meta"][meta_name] = meta_tag ? meta_tag["content"] : nil
    end
  end
end
