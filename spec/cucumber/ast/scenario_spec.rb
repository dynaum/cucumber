require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/step_mother'
require 'cucumber/ast'

module Cucumber
  module Ast
    describe Scenario do
      before do
        @step_mother = Object.new
        @step_mother.extend(StepMom)
        $x = $y = nil
        @step_mother.Before do
          $x = 3
        end
        @step_mother.Given /y is (\d+)/ do |n|
          $y = n.to_i
        end
        @visitor = Visitor.new(@step_mother)
      end

      it "should execute Before blocks before steps" do
        scenario = Scenario.new(
          comment=Comment.new(""), 
          tags=Tags.new([]), 
          keyword="", 
          name="", 
          steps=[
            Step.new(7, "Given", "y is 5")
          ])
        @visitor.visit_feature_element(scenario)
        $x.should == 3
        $y.should == 5
      end

      it "should skip steps when previous is not passed" do
        scenario = Scenario.new(
          comment=Comment.new(""),
          tags=Tags.new([]), 
          keyword="", 
          name="", 
          steps=[
            Step.new(7, "Given", "this is missing"),
            Step.new(8, "Given", "y is 5")
          ])
        @visitor.visit_feature_element(scenario)

        $x.should == 3
        $y.should == nil
      end

      it "should be at exact line" do
        s = Scenario.new(comment=Comment.new(""), 
          tags=Tags.new([]), keyword="", name="", steps=[])

        s.line = 45
        s.should be_at_line(45)
      end

      it "should be at line if step is" do
        s = Scenario.new(
          comment=Comment.new(""), 
          tags=Tags.new([]), 
          keyword="", 
          name="", 
          steps=[
            Step.new(46, "Given", ""),
            Step.new(47, "Given", ""),
            Step.new(48, "Given", ""),
          ]
        )

        s.line = 45
        s.should be_at_line(47)
        s.should_not be_at_line(49)
      end
    end
  end
end
