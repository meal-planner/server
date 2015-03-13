require 'faraday'
require 'json'
require_relative 'ingredient'

class Importer
  def initialize(api_key, update_existing: false, start_from: 0)
    @api = Faraday.new(:url => 'http://api.nal.usda.gov/usda/ndb/')
    @api_key = api_key
    @start_from = start_from
    @update_existing = update_existing
    @nutrient_map = {
        255 => :water,
        208 => :energy,
        203 => :protein,
        204 => :fat,
        606 => :fat_saturated,
        645 => :fat_monounsaturated,
        646 => :fat_polyunsaturated,
        605 => :fat_trans,
        601 => :cholesterol,
        205 => :carbohydrate,
        291 => :fiber,
        269 => :sugar,
        301 => :calcium,
        303 => :iron,
        304 => :magnesium,
        305 => :phosphorus,
        306 => :potassium,
        307 => :sodium,
        309 => :zinc,
        401 => :vitamin_c,
        320 => :vitamin_a_rae,
        318 => :vitamin_a_iu,
        404 => :thiamin,
        405 => :riboflavin,
        406 => :niacin,
        415 => :vitamin_b6,
        418 => :vitamin_b12,
        435 => :folate_dfe,
        323 => :vitamin_e,
        328 => :vitamin_d2_d3,
        324 => :vitamin_d,
        430 => :vitamin_k,
        262 => :caffeine,
    }
  end

  def import_all
    offset = @start_from
    per_page = 100
    finished = false
    until finished
      # @see http://ndb.nal.usda.gov/ndb/doc/apilist/API-LIST.md
      puts "Getting list with offset #{offset}."
      response = @api.get 'list', {:api_key => @api_key, :offset => offset, :max => per_page, :sort => 'n'}
      abort 'could not get API response.' unless response.success?

      list = JSON.parse(response.body)['list']
      list['item'].each { |food| import_food food['id'] }

      offset = offset + per_page
      finished = offset > list['total']
    end
  end

  def import_food(identifier)
    print "Importing food ID: #{identifier}..."
    search = Ingredient.search query: {match: {ndbno: identifier}}
    if search.size > 0
      return puts 'food already in storage, skipping.' unless @update_existing
      ingredient = search.first
    else
      ingredient = Ingredient.new
    end

    # @see http://ndb.nal.usda.gov/ndb/doc/apilist/API-FOOD-REPORT.md
    response = @api.get 'reports', {:api_key => @api_key, :ndbno => identifier, :type => 'f'}
    return puts 'could not get food nutrient report.' unless response.success?
    report = JSON.parse(response.body)['report']['food']
    ingredient[:ndbno] = identifier unless ingredient[:id]
    ingredient[:name] = report['name']
    ingredient[:group] = report['fg']
    ingredient[:nutrients] = convert_nutrients report['nutrients']
    ingredient.save
    puts 'done!'
  end

  def convert_nutrients(data)
    nutrients = {}
    data.each do |nutrient|
      nutrient_id = nutrient['nutrient_id'].to_i
      if @nutrient_map.has_key? nutrient_id
        nutrients[@nutrient_map[nutrient_id]] = {
            :group => nutrient['group'],
            :unit => nutrient['unit'],
            :value => nutrient['value'],
            :measures => nutrient['measures']
        }
      end
    end
    nutrients
  end
end

importer = Importer.new('cFgF6sRMTp8jmbE4zfJtuSFrtPnm4DYqnnOteXK6', start_from: 1600)
importer.import_all
