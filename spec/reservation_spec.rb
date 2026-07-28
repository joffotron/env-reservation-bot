require 'spec_helper'
require 'logger'
require_relative '../lib/reservation'

RSpec.describe Reservation do
  User = Struct.new(:name, :timezone)
  let(:user) { User.new('Alvin Z', 'Australia/Melbourne') }
  let(:reservation) { Reservation.new(user: user) }

  def stub_time
    frozen_time = Time.parse('2000-01-01 13:30:00 UTC')
    frozen_date = Date.parse('2000-01-01')

    allow(Time).to receive(:now).and_return(frozen_time)
    allow(DateTime).to receive(:now).and_return(frozen_time.to_datetime)
    allow(Date).to receive(:today).and_return(frozen_date)
    allow(Date).to receive(:tomorrow).and_return(frozen_date + 1)
  end

  before do
    stub_time
  end

  describe '#parse_message!' do
    before { reservation.parse_message!(message) }

    context 'parses environment and "now" start time' do
      let(:message) { '@reservebot staging-nz now' }

      it do
        expect(reservation.environment).to eq('staging-nz')
        expect(reservation.start_time).to eq(Time.parse('2000-01-01 13:30:00 UTC'))
        expect(reservation.end_time).to be_nil
        expect(reservation.comment).to eq(nil)
        expect(reservation.repo).to eq(nil)
      end
    end

    context 'parses environment, start time, and duration' do
      let(:message) { '@reservebot staging-nz now 2h' }

      it do
        expect(reservation.environment).to eq('staging-nz')
        expect(reservation.start_time).to eq(Time.parse('2000-01-01 13:30:00 UTC'))
        expect(reservation.end_time).to eq(Time.parse('2000-01-01 15:30:00 UTC'))
        expect(reservation.comment).to eq('')
        expect(reservation.repo).to eq(nil)
      end
    end

    context 'parses environment, start time (plural), and duration' do
      let(:message) { '@reservebot demo-au now 3hrs' }

      it do
        expect(reservation.environment).to eq('demo-au')
        expect(reservation.start_time).to eq(Time.parse('2000-01-01 13:30:00 UTC'))
        expect(reservation.end_time).to eq(Time.parse('2000-01-01 16:30:00 UTC'))
        expect(reservation.comment).to eq('')
        expect(reservation.repo).to eq(nil)
      end
    end

    context 'parses environment, start time, duration, and comment' do
      let(:message) { '@reservebot demo-au now 1h testing new feature' }

      it do
        expect(reservation.environment).to eq('demo-au')
        expect(reservation.start_time).to eq(Time.parse('2000-01-01 13:30:00 UTC'))
        expect(reservation.end_time).to eq(Time.parse('2000-01-01 14:30:00 UTC'))
        expect(reservation.comment).to eq('testing new feature')
        expect(reservation.repo).to eq(nil)
      end
    end

    context 'parses optional repo with no comment' do
      let(:message) { '@reservebot staging-nz now 1h --repo okkaz' }

      it do
        expect(reservation.environment).to eq('staging-nz')
        expect(reservation.start_time).to eq(Time.parse('2000-01-01 13:30:00 UTC'))
        expect(reservation.end_time).to eq(Time.parse('2000-01-01 14:30:00 UTC'))
        expect(reservation.comment).to eq('')
        expect(reservation.repo).to eq('okkaz')
      end
    end

    context 'parses optional repo' do
      let(:message) { '@reservebot demo-au now 1h testing new feature --repo okkaz' }

      it do
        expect(reservation.environment).to eq('demo-au')
        expect(reservation.start_time).to eq(Time.parse('2000-01-01 13:30:00 UTC'))
        expect(reservation.end_time).to eq(Time.parse('2000-01-01 14:30:00 UTC'))
        expect(reservation.comment).to eq('testing new feature')
        expect(reservation.repo).to eq('okkaz')
      end
    end

    context 'parses free' do
      let(:message) { '@reservebot staging-nz free' }

      it do
        expect(reservation.environment).to eq('staging-nz')
        expect(reservation.start_time).to be_nil
        expect(reservation.end_time).to be_nil
        expect(reservation.comment).to eq('free')
        expect(reservation.repo).to eq(nil)
      end
    end
  end
end
