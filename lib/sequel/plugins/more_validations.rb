# frozen_string_literal: true

require "sequel"
require "sequel/model"

# Additional validations for Sequel models.
# See README or InstanceMethods for more info.
module Sequel::Plugins::MoreValidations
  VERSION = "1.0.0"

  module InstanceMethods
    # Ensures that only one of the passed columns is not null
    def validates_mutually_exclusive(*cols)
      set_cols = cols.find_all { |col| !self[col].nil? }

      self.errors.add(set_cols.first, "is mutually exclusive with other set columns #{set_cols[1..].join(', ')}") if
        set_cols.length > 1
    end

    # Ensures that at least one of the passed columns is not null
    def validates_at_least_one_of(*cols)
      self.errors.add(cols.first, "must be set if all of #{cols[1..].join(', ')} are null") unless
        cols.any? { |col| !self[col].nil? }
    end

    # Ensures that one and only one of the passed columns is not null
    def validates_exactly_one_of(*cols)
      self.validates_at_least_one_of(*cols)
      self.validates_mutually_exclusive(*cols)
    end

    # Ensures the value in the column is an IPAddr or can be parsed as one.
    def validates_ip_address(col)
      return if self[col].respond_to?(:ipv4?)
      begin
        IPAddr.new(self[col])
      rescue IPAddr::Error
        self.errors.add(col, "is not a valid INET address")
      end
    end

    # Ensure the value in the column is non-nil, non-empty, and the start is before the end.
    def validates_pgrange(col)
      val = self[col]
      if val.nil?
        self.errors.add(col, "cannot be nil")
        return
      end
      return if val.end > val.begin
      if val.end == val.begin
        self.errors.add(col, "cannot be empty")
        return
      end
      self.errors.add(col, "lower bound must be less than upper bound")
    end
  end
end
