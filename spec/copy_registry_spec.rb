require_relative 'helper/copyable_spec_helper'

describe Copyable::CopyRegistry do
  before(:all) do
    DummyModelPerson = Struct.new(:id, :name)
    DummyModelPlace = Struct.new(:id, :name)
  end

  before(:each) do
    Copyable::CopyRegistry.clear
    @bob = DummyModelPerson.new(10, "Bob")
    @new_bob = DummyModelPerson.new(11, "Copy of Bob")
    @fred = DummyModelPerson.new(15, "Fred")
    @new_fred = DummyModelPerson.new(16, "Copy of Fred")
    @winnipeg = DummyModelPlace.new(89, "Winnipeg")
    @new_winnipeg = DummyModelPlace.new(90, "Copy of Winnipeg")
    @yellowknife = DummyModelPlace.new(10, "Yellowknife")
    @new_yellowknife = DummyModelPlace.new(11, "Copy of Yellowknife")
  end

  it 'should know whether a model has already been copied' do
    registry = Copyable::CopyRegistry
    registry.register(@bob, @new_bob)
    registry.register(@fred, @new_fred)
    registry.register(@yellowknife, @new_yellowknife)
    # using record option
    expect(registry.already_copied?(record: @bob)).to be_truthy
    expect(registry.already_copied?(record: @fred)).to be_truthy
    expect(registry.already_copied?(record: @winnipeg)).to be_falsey
    expect(registry.already_copied?(record: @yellowknife)).to be_truthy
    # using id and class options
    expect(registry.already_copied?(id: 10, class: DummyModelPerson)).to be_truthy
    expect(registry.already_copied?(id: 15, class: DummyModelPerson)).to be_truthy
    expect(registry.already_copied?(id: 89, class: DummyModelPlace)).to be_falsey
    expect(registry.already_copied?(id: 10, class: DummyModelPlace)).to be_truthy
  end

  it 'should provide the copy of a model that has already been copied' do
    registry = Copyable::CopyRegistry
    registry.register(@bob, @new_bob)
    registry.register(@fred, @new_fred)
    registry.register(@winnipeg, @new_winnipeg)
    registry.register(@yellowknife, @new_yellowknife)
    # using record option
    expect(registry.fetch_copy(record: @bob)).to eq(@new_bob)
    expect(registry.fetch_copy(record: @fred)).to eq(@new_fred)
    expect(registry.fetch_copy(record: @winnipeg)).to eq(@new_winnipeg)
    expect(registry.fetch_copy(record: @yellowknife)).to eq(@new_yellowknife)
    # using id and class options
    expect(registry.fetch_copy(id: 10, class: DummyModelPerson)).to eq(@new_bob)
    expect(registry.fetch_copy(id: 15, class: DummyModelPerson)).to eq(@new_fred)
    expect(registry.fetch_copy(id: 89, class: DummyModelPlace)).to eq(@new_winnipeg)
    expect(registry.fetch_copy(id: 10, class: DummyModelPlace)).to eq(@new_yellowknife)
  end
end
