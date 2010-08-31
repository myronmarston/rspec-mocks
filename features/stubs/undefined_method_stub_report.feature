@wip
Feature: Undefined method stub report

  As an RSpec mocks user
  I want an undefined method stub report
  So that I'm aware of potential false positive specs

  Scenario: Invoking an undefined method stub
    Given a file named "undefined_method_stub_spec.rb" with:
      """
      RSpec.configure do |c|
        c.mock_with :rspec
      end

      describe String do
        it 'uses an undefined method stub' do
          str = "foo"
          str.stub(:revrse).and_return('oof')
          str.revrse.should == 'oof'
        end
      end
      """
    When I run "rspec undefined_method_stub_spec.rb"
    Then the output should contain "1 example, 0 failures"
    Then the output should contain:
      """
      One or more of your stubs are on objects that do not respond to the stubbed methods:

        ################################################
        Spec: String uses an undefined method stub # undefined_method_stub_spec.rb:6
          - stub: String#revrse # undefined_method_stub_spec.rb:8
          - invoked at undefined_method_stub_spec.rb:9
        ################################################
      """

