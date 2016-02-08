require_relative '../helper/copyable_spec_helper'

describe Copyable::ColumnChecker do

  it 'should not throw an error if all columns are present' do
    block = Proc.new do
      columns({
        name:       :copy,
        kind:       :copy,
        birth_year: :copy,
      })
    end
    column_checker = Copyable::ColumnChecker.new(CopyablePet)
    expect { column_checker.verify!(block) }.to_not raise_error
  end

  it 'should throw an error if columns are empty' do
    block = Proc.new do
      columns({})
    end
    column_checker = Copyable::ColumnChecker.new(CopyablePet)
    expect { column_checker.verify!(block) }.to raise_error(Copyable::ColumnError)
  end

  it 'should throw an error if a column is missing' do
    block = Proc.new do
      columns({
        name:       :copy,
        birth_year: :copy,
      })
    end
    column_checker = Copyable::ColumnChecker.new(CopyablePet)
    expect { column_checker.verify!(block) }.to raise_error(Copyable::ColumnError)
  end

  it 'should throw an error if an unrecognized column is present' do
    block = Proc.new do
      columns({
        name:       :copy,
        kind:       :copy,
        intruder:   :copy,
        birth_year: :copy,
      })
    end
    column_checker = Copyable::ColumnChecker.new(CopyablePet)
    expect { column_checker.verify!(block) }.to raise_error(Copyable::ColumnError)
  end

end
