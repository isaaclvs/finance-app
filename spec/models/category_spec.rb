require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user) { create(:user) }
  
  describe "business validation" do
    it "validates color format" do
      valid_category = build(:category, user: user, color: "#FF5733")
      invalid_category = build(:category, user: user, color: "invalid")
      
      expect(valid_category).to be_valid
      expect(invalid_category).not_to be_valid
    end
    
    it "accepts valid hex colors" do
      colors = ["#FF5733", "#000000", "#FFFFFF", "#123ABC"]
      
      colors.each do |color|
        category = build(:category, user: user, color: color)
        expect(category).to be_valid, "#{color} should be valid"
      end
    end
  end
  
  describe "useful scopes" do
    before do
      create(:category, user: user, name: "Z Category")
      create(:category, user: user, name: "A Category")
      create(:category, user: user, name: "M Category")
    end
    
    describe ".ordered" do
      it "returns categories ordered by name" do
        categories = Category.ordered
        expect(categories.map(&:name)).to eq(["A Category", "M Category", "Z Category"])
      end
    end
  end
  
  describe "constants" do
    it "has DEFAULT_COLORS" do
      expect(Category::DEFAULT_COLORS).to be_a(Hash)
      expect(Category::DEFAULT_COLORS).not_to be_empty
      expect(Category::DEFAULT_COLORS.values.first).to match(/\A#[0-9A-Fa-f]{6}\z/)
    end
  end
end