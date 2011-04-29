require 'net/http'
require 'json'
require 'config'

class Tradutor
  
  attr_reader :languages
  
  QUERY_STRING = "/language/translate/v2?key=[google_key]&q=[query]&source=[language_source]&target=[language_target]";
  LANGUAGES_QUERY_STRING = "/language/translate/v2/languages?key=[google_key]";
  GOOGLE_APIS_URL = 'https://www.googleapis.com';
  
  QUERY_KEYS = {
    :key => '[google_key]', 
    :query => '[query]', 
    :source => '[language_source]', 
    :target => '[language_target]'
  }
  
  def initialize(google_key = GOOGLE_TRANSLATE_KEY)
    QUERY_STRING.sub!(QUERY_KEYS[:key], google_key)
    LANGUAGES_QUERY_STRING.sub!(QUERY_KEYS[:key], google_key)
    prepare_connection
    
    @languages = fetch_languages
  end
  
  def translate(opts = {})
    query_string = prepare_query_string(opts[:q], opts[:source], opts[:target])
    
    request = Net::HTTP::Get.new(query_string)
    json = @http.request(request).body

    obj = JSON.parse(json)
    obj["data"]["translations"].first["translatedText"]
  end
  
  def validate_languages(source, target)
    raise "Invalid source language" unless language_valid?(source)
    raise "Invalid target language" unless language_valid?(target)
  end
  
  private
  
  def prepare_connection
    url = URI.parse(GOOGLE_APIS_URL)
    @http = Net::HTTP.new(url.host, url.port)
    @http.use_ssl = true if url.scheme == 'https'
  end
  
  def fetch_languages
    request = Net::HTTP::Get.new(LANGUAGES_QUERY_STRING)
    json = @http.request(request).body
    
    languages = []
    obj = JSON.parse(json)
    obj["data"]["languages"].each { |lang| languages << lang["language"] }
    
    languages
  end
  
  def prepare_query_string(query, source, target)
    validate_languages(source, target)
    
    query_string = QUERY_STRING.dup
    query_string.sub!(QUERY_KEYS[:query], URI.escape(query))
    query_string.sub!(QUERY_KEYS[:source], source)
    query_string.sub!(QUERY_KEYS[:target], target)
    
    query_string
  end
  
  def language_valid?(lang)
    @languages.include?(lang)
  end
end
