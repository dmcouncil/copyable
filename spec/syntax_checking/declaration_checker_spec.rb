require_relative '../helper/copyable_spec_helper'

describe Copyable::DeclarationChecker do

  it 'should throw an error if there are no declarations' do
    block = Proc.new {}
    expect { subject.verify!(block) }.to raise_error(Copyable::DeclarationError)
  end

  it 'should not throw an error if all required declarations are present' do
    block = Proc.new do
      disable_all_callbacks_and_observers_except_validate
      columns
      associations
    end
    expect { subject.verify!(block) }.to_not raise_error
  end

  it 'should not throw an error if all declarations are present' do
    block = Proc.new do
      disable_all_callbacks_and_observers_except_validate
      columns
      associations
      after_copy
    end
    expect { subject.verify!(block) }.to_not raise_error
  end

  it 'should throw an error if an unknown declaration is present' do
    block = Proc.new do
      disable_all_callbacks_and_observers_except_validate
      columns
      unknown
      associations
      after_copy
    end
    expect { subject.verify!(block) }.to raise_error(Copyable::DeclarationError)
  end

  it 'should throw an error if a required declaration is missing' do
    block = Proc.new do
      columns
      associations
    end
    expect { subject.verify!(block) }.to raise_error(Copyable::DeclarationError)
    block = Proc.new do
      disable_all_callbacks_and_observers_except_validate
      associations
    end
    expect { subject.verify!(block) }.to raise_error(Copyable::DeclarationError)
    block = Proc.new do
      disable_all_callbacks_and_observers_except_validate
      columns
    end
    expect { subject.verify!(block) }.to raise_error(Copyable::DeclarationError)
  end

end
