require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    { first_name: 'John', last_name: 'Doe', email: 'john@example.com',
      password: 'password123', password_confirmation: 'password123' }
  end

  it 'is valid with valid attributes' do
    user = User.new(valid_attributes)
    expect(user).to be_valid
  end

  it 'is not valid without a first_name' do
    user = User.new(valid_attributes.merge(first_name: nil))
    expect(user).to_not be_valid
  end

  it 'is not valid without a last_name' do
    user = User.new(valid_attributes.merge(last_name: nil))
    expect(user).to_not be_valid
  end

  it 'is not valid without an email' do
    user = User.new(valid_attributes.merge(email: nil))
    expect(user).to_not be_valid
  end

  it 'is not valid with a duplicate email' do
    User.create!(valid_attributes)
    user = User.new(valid_attributes.merge(first_name: 'Jane'))
    expect(user).to_not be_valid
  end

  it 'returns full_name as first and last name' do
    user = User.new(first_name: 'John', last_name: 'Doe')
    expect(user.full_name).to eq('John Doe')
  end

  it 'calculates age from date_of_birth' do
    user = User.new(date_of_birth: 30.years.ago.to_date)
    expect(user.age).to eq(30)
  end

  it 'returns nil age when date_of_birth is blank' do
    user = User.new
    expect(user.age).to be_nil
  end

  it 'validates gender inclusion' do
    user = User.new(valid_attributes.merge(gender: 'invalid'))
    expect(user).to_not be_valid
  end

  it 'validates mbti inclusion' do
    user = User.new(valid_attributes.merge(mbti: 'XXXX'))
    expect(user).to_not be_valid
    user.mbti = 'INTJ'
    expect(user).to be_valid
  end

  it 'validates bio length' do
    user = User.new(valid_attributes.merge(bio: 'x' * 501))
    expect(user).to_not be_valid
  end
end
