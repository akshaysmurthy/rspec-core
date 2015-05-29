require 'rspec/core/profiler'

RSpec.describe 'RSpec::Core::Profiler' do
  let(:profiler) { RSpec::Core::Profiler.new }

  it 'has starts with an empty hash of example_groups' do
    expect(profiler.example_groups).to be_empty.and be_a Hash
  end

  context 'when hooked into the reporter' do
    include FormatterSupport

    let(:id) { 42 }
    let(:description ) { "My Group" }
    let(:now) { ::Time.now }

    before do
      allow(::RSpec::Core::Time).to receive(:now) { now }
    end

    def group
      @group ||=
        begin
          group = super
          allow(group).to receive_messages(:id => id, :top_level_description => description)
          group
        end
    end

    describe '#example_group_started' do
      it 'records example groups start time and description via id' do
        expect {
          profiler.example_group_started group_notification group
        }.to change { profiler.example_groups[id] }.to include(
          :start => now, :description => description
        )
      end
    end

    describe '#example_group_finished' do
      before do
        profiler.example_group_started group_notification group
        allow(::RSpec::Core::Time).to receive(:now) { now + 1 }
      end

      it 'records example groups total time and description via id' do
        expect {
          profiler.example_group_finished group_notification group
        }.to change { profiler.example_groups[id] }.to include(
          :total_time => 1.0
        )
      end
    end

    describe '#example_started' do
      let(:example) { new_example }
      before do
        allow(example).to receive(:example_group) { group }
        allow(group).to receive(:parent_groups) { [group] }
        profiler.example_group_started group_notification group
      end

      it 'increments the count of examples for its parent group' do
        expect {
          profiler.example_started example_notification example
        }.to change { profiler.example_groups[id][:count] }.by 1
      end
    end
  end
end
