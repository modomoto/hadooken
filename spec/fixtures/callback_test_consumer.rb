class CallbackTestConsumer < Hadooken::Consumer

  before_consume -> { run_with_test_1 }
  before_consume -> { self.class.before_with_callback }
  before_consume -> { run_with_test_2 }, only: :test_2
  before_consume -> { run_with_test_3 }, only: :test_1
  before_consume -> { run_with_test_4 }, except: :test_2
  before_consume -> { run_with_test_5 }, except: :test_1
  after_consume -> { run_with_test_6 }
  after_consume -> { self.class.after_with_callback }
  after_consume -> { run_with_test_7 }, only: :test_2
  after_consume -> { run_with_test_8 }, only: :test_1
  after_consume -> { run_with_test_9 }, except: :test_2
  after_consume -> { run_with_test_10 }, except: :test_1

  def self.before_with_callback; end

  def self.before_with_action; end

  def self.after_with_callback; end

  def self.after_with_action; end

  def test_1
    run_with_test_1
    self.class.before_with_action
    self.class.after_with_action
  end

  def test_2
    run_with_test_2
  end

  def test_3
    run_with_test_3
  end

  private
    def after(arg); end

    def run_with_test_1; end

    def run_with_test_2; end

    def run_with_test_3; end

    def run_with_test_4; end

    def run_with_test_5; end

    def run_with_test_6; end

    def run_with_test_7; end

    def run_with_test_8; end

    def run_with_test_9; end

    def run_with_test_10; end

end
