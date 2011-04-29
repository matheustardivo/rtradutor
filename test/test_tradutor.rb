$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'test_helper'

class TestTradutor < Test::Unit::TestCase
  
  def setup
    @tradutor = Tradutor.new
  end
  
  def test_translate_to_pt
    assert_equal("testing", 
      @tradutor.translate({
        :q => "testando", 
        :source => "pt", 
        :target => "en"}).downcase)
        
    assert_equal("testing the translator", 
      @tradutor.translate({
        :q => "testando o tradutor", 
        :source => "pt", 
        :target => "en"}).downcase)
  end
end
