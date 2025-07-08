require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:transactions).dependent(:restrict_with_error) }
  end
  
  describe 'validations' do
    subject { build(:category) }
    
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:color) }
    it { should validate_uniqueness_of(:name).scoped_to(:user_id).with_message("has already been taken for this user") }
    
    it 'validates color format' do
      category = build(:category, color: 'invalid')
      expect(category).not_to be_valid
      expect(category.errors[:color]).to include("must be a valid hex color (e.g. #FF5733)")
    end
    
    it 'accepts valid hex colors' do
      valid_colors = ['#FF5733', '#ff5733', '#123ABC']
      valid_colors.each do |color|
        category = build(:category, color: color)
        expect(category).to be_valid
      end
    end
  end
  
  describe 'scopes' do
    describe '.ordered' do
      it 'returns categories ordered by name' do
        user = create(:user)
        category_b = create(:category, name: 'B Category', user: user)
        category_a = create(:category, name: 'A Category', user: user)
        category_c = create(:category, name: 'C Category', user: user)
        
        expect(user.categories.ordered).to eq([category_a, category_b, category_c])
      end
    end
  end
  
  describe 'constants' do
    it 'has DEFAULT_COLORS' do
      expect(Category::DEFAULT_COLORS).to be_a(Hash)
      expect(Category::DEFAULT_COLORS).to include('Salary', 'Food', 'Transport')
    end
  end
end
