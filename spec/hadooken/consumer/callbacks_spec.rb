require 'spec_helper'

describe Hadooken::Consumer::Callbacks do

  describe 'before_consume' do
    context 'when callback is assigned without conditional' do
      it 'runs the callback before running consumer action' do
        expect_any_instance_of(CallbackTestConsumer).to receive(:run_with_test_1).twice

        CallbackTestConsumer.consume({}, { name: 'test_1' })
      end

      it 'runs the callback and the action itself in correct order' do
        expect(CallbackTestConsumer).to receive(:before_with_callback).ordered
        expect(CallbackTestConsumer).to receive(:before_with_action).ordered

        CallbackTestConsumer.consume({}, { name: 'test_1' })
      end
    end

    context 'when callback is assigned with :only conditional' do
      context 'when the consumer action in the list of conditional' do
        it 'runs the callback before running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).to receive(:run_with_test_2).twice

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end

      context 'when the consumer action is not in the list of conditional' do
        it 'does not run the callback before running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).not_to receive(:run_with_test_3)

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end
    end

    context 'when callback is assigned with :except conditional' do
      context 'when the consumer action in the list of conditional' do
        it 'does not run the callback before running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).not_to receive(:run_with_test_4)

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end

      context 'when the consumer action is not in the list of conditional' do
        it 'runs the callback before running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).to receive(:run_with_test_5)

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end
    end
  end

  describe 'after_consume' do
    context 'when callback is assigned without conditional' do
      it 'runs the callback after running consumer action' do
        expect_any_instance_of(CallbackTestConsumer).to receive(:run_with_test_1).twice

        CallbackTestConsumer.consume({}, { name: 'test_1' })
      end

      it 'runs the callback and the action itself in correct order' do
        expect(CallbackTestConsumer).to receive(:after_with_action).ordered
        expect(CallbackTestConsumer).to receive(:after_with_callback).ordered

        CallbackTestConsumer.consume({}, { name: 'test_1' })
      end
    end

    context 'when callback is assigned with :only conditional' do
      context 'when the consumer action in the list of conditional' do
        it 'runs the callback after running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).to receive(:run_with_test_7).once

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end

      context 'when the consumer action is not in the list of conditional' do
        it 'does not run the callback after running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).not_to receive(:run_with_test_8)

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end
    end

    context 'when callback is assigned with :except conditional' do
      context 'when the consumer action in the list of conditional' do
        it 'does not run the callback after running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).not_to receive(:run_with_test_9)

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end

      context 'when the consumer action is not in the list of conditional' do
        it 'runs the callback after running consumer action' do
          expect_any_instance_of(CallbackTestConsumer).to receive(:run_with_test_10)

          CallbackTestConsumer.consume({}, { name: 'test_2' })
        end
      end
    end
  end

end
