require 'rspec'
require_relative '../../meal_planner'

describe 'Ingredient Model' do
  context 'creating new model' do
    it 'creates model from object' do
      json = {
          ndbno: 'foo',
          name: 'foo name',
          group: 'foo group',
          generic: true,
          measures: [
              {
                  qty: 100,
                  eqv: 200,
                  label: 'baz label',
                  invalid_attr: 'should be filtered out',
                  nutrients: {
                      energy: 200,
                      fat: '100.0'
                  }
              }
          ]
      }

      ingredient = Ingredient.new json

      expect(ingredient.name).to eq json[:name]
      expect(ingredient.group).to eq json[:group]
      expect(ingredient.generic).to eq json[:generic]
      expect(ingredient.measures.length).to eq 1
      expect(ingredient.measures[0].qty).to eq json[:measures][0][:qty]
      expect(ingredient.measures[0].eqv).to eq json[:measures][0][:eqv]
      expect(ingredient.measures[0].label).to eq json[:measures][0][:label]
      expect(ingredient.measures[0].nutrients[:energy]).to eq json[:measures][0][:nutrients][:energy]
      expect(ingredient.measures[0].nutrients[:fat]).to eq 100
    end
  end
end