require 'spec_helper'

describe Icalendar::Recurrence::Schedule do
  describe "#transform_byday_to_hash" do
    it "returns an array of days when no monthly interval is set" do
      byday = ["MO", "WE", "FR"]
      schedule = Schedule.new(nil)
      expect(schedule.transform_byday_to_hash(byday)).to eq([:monday, :wednesday, :friday])
    end

    it "returns hash with day of week and interval" do
      byday = ["1SA"]
      schedule = Schedule.new(nil);
      expect(schedule.transform_byday_to_hash(byday)).to eq({saturday: [1]})
    end
  end

  describe "#convert_day_code_to_symbol" do
    it "returns symbol given day code" do
      day_code = "MO"
      schedule = Schedule.new(nil)
      expect(schedule.convert_day_code_to_symbol(day_code)).to eq :monday
    end
  end

  describe "#occurrences_between" do
    let(:example_occurrence) do
      daily_event = example_event :daily
      schedule = Schedule.new(daily_event)
      schedule.occurrences_between(Date.parse("2014-02-01"), Date.parse("2014-03-01")).first
    end

    it "returns object that responds to start_time and end_time" do
      expect(example_occurrence).to respond_to :start_time
      expect(example_occurrence).to respond_to :end_time
    end

    context "timezoned event" do
      let(:example_occurrence) do
        timezoned_event = example_event :first_saturday_of_month
        schedule = Schedule.new(timezoned_event)
        example_occurrence = schedule.occurrences_between(Date.parse("2014-02-01"), Date.parse("2014-03-01")).first
      end

      it "#occurrences_between return object that responds to #start_time and #end_time (timezoned example)" do
        expect(example_occurrence).to respond_to :start_time
        expect(example_occurrence).to respond_to :end_time
      end
    end
  end

  describe "#parse_ical_byday" do
    let(:schedule) { Schedule.new(nil) }

    it "returns a hash of data" do
      expect(schedule.parse_ical_byday("1SA")).to eq({day_code: "SA", position: 1})
      expect(schedule.parse_ical_byday("MO")).to eq({day_code: "MO", position: 0})
    end
  end

  describe "#convert_rrule_to_ice_cube_recurrence_rule" do
    let(:schedule) { Schedule.new(nil) }
    let(:ice_cube_rule) { schedule.convert_rrule_to_ice_cube_recurrence_rule(rrule) }

    context "hour, minute, second, month_of_year, and day_of_year specified" do
      let(:rrule) { Icalendar::Values::Recur.new("FREQ=DAILY;BYHOUR=1;BYMINUTE=2;BYSECOND=3;BYMONTH=4,5;BYYEARDAY=6")}

      it "adds hour, minute, second, and day_of_year to ice_cube rule" do
        expect(ice_cube_rule).to eq IceCube::Rule.daily.hour_of_day(1).minute_of_hour(2).second_of_minute(3).month_of_year(4,5).day_of_year(6)
      end
    end

    context "week_start specified" do
      let(:rrule) { Icalendar::Values::Recur.new("FREQ=WEEKLY;WKST=TU") }

      it "adds week start to ice_cube rule" do
        expect(ice_cube_rule.week_start).to eq :tuesday
      end
    end

    context "invalid rrule specified" do
      let(:rrule) { Icalendar::Values::Recur.new("COUNT:3")}
      it "it returns error" do
        expect(ice_cube_rule.week_start).to raise_error(ArgumentError)
      end
    end

  end
end