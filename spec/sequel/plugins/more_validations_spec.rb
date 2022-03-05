# frozen_string_literal: true

require "sequel"
require "sequel/plugins/more_validations"

RSpec.describe Sequel::Plugins::MoreValidations, :db do
  before(:each) do
    @db = Sequel.sqlite
  end
  after(:each) do
    @db.disconnect
  end

  let(:table_name) { :more_validations_test }

  let(:subclass) do
    @db.create_table(:more_validations_test) do
      text :first_name
      text :last_name
      inet :ip
      tstzrange :pgrange
    end
    mc = Class.new(Sequel::Model(@db[:more_validations_test]))
    mc.plugin(:more_validations)
    mc
  end

  let(:instance) { subclass.new }

  context "mutually exclusive" do
    it "can validate fields as mutually exclusive" do
      instance.first_name = "boom"
      instance.last_name = "co"

      instance.validates_mutually_exclusive(:first_name, :last_name)

      expect(instance.errors).to include(:first_name)
      expect(instance.errors[:first_name].first).to match(/mutually exclusive/)
    end

    it "does not add errors if only one mutually exclusive field is set" do
      instance.first_name = "boom"
      instance.last_name = nil

      expect do
        instance.validates_mutually_exclusive(:first_name, :last_name)
      end.to_not(change do
        instance.errors.count
      end)
    end
  end

  context "at least one of" do
    it "validates that at least one column is set" do
      instance.validates_at_least_one_of(:first_name, :last_name)

      expect(instance.errors).to include(:first_name)
      expect(instance.errors[:first_name].first).to match(/must be set/)
    end

    it "passes validation if one of the passed columns is set" do
      instance.last_name = "co"

      expect do
        instance.validates_at_least_one_of(:first_name, :last_name)
      end.to_not(change do
        instance.errors.count
      end)
    end
  end

  context "exactly one of" do
    it "validates that at least one column is set" do
      instance.validates_exactly_one_of(:first_name, :last_name)

      expect(instance.errors).to include(:first_name)
      expect(instance.errors[:first_name].first).to match(/must be set/)
    end

    it "validates that no more than one column is set" do
      instance.first_name = "boom"
      instance.last_name = "co"

      instance.validates_exactly_one_of(:first_name, :last_name)

      expect(instance.errors).to include(:first_name)
      expect(instance.errors[:first_name].first).to match(/mutually exclusive/)
    end

    it "passes validation if only one of the columns is set" do
      instance.first_name = "boom"
      instance.last_name = nil

      expect do
        instance.validates_exactly_one_of(:first_name, :last_name)
      end.to_not(change do
        instance.errors.count
      end)
    end
  end

  context "ip address" do
    let(:valid_ip) { "192.168.16.72" }
    let(:invalid_ip) { "284.111.0.1" }

    it "validates that the peer IP address is a valid INET address" do
      instance.ip = invalid_ip

      instance.validates_ip_address(:ip)

      expect(instance.errors).to include(:ip)
      expect(instance.errors[:ip].first).to match(/is not a valid INET address/i)
    end

    it "does not add errors if the IP address is a valid INET address" do
      instance.ip = valid_ip

      expect do
        instance.validates_ip_address(:ip)
      end.to_not(change do
        instance.errors.count
      end)
    end

    it "does not add errors if the IP address is already of type IPAddr" do
      instance.ip = IPAddr.new(valid_ip)

      expect do
        instance.validates_ip_address(:ip)
      end.to_not(change do
        instance.errors.count
      end)
    end
  end

  context "pgrange" do
    let(:now) { Time.now }
    let(:day) { 60 * 60 * 24 }
    let(:valid_period) { (1 - day)..(2 + (2 * day)) }
    let(:empty_period) { now..now }
    let(:backwards_period) { (2 + (2 * day))..(1 - day) }

    it "a range is valid if it goes forward and is not empty" do
      instance.pgrange = valid_period
      instance.validates_pgrange(:pgrange)
      expect(instance.errors).to be_empty
    end

    it "is invalid if empty" do
      instance.pgrange = empty_period
      instance.validates_pgrange(:pgrange)
      expect(instance.errors[:pgrange].first).to match(/cannot be empty/)
    end

    it "is invalid if backwards" do
      instance.pgrange = backwards_period
      instance.validates_pgrange(:pgrange)
      expect(instance.errors[:pgrange].first).to match(/lower bound must be less than upper bound/)
    end
  end
end
