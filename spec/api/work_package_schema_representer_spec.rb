#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe ::API::V3::WorkPackages::Schema::WorkPackageSchemaRepresenter do
  let(:custom_field) { FactoryGirl.build(:custom_field) }
  let(:work_package) { FactoryGirl.build(:work_package) }
  let(:current_user) {
    FactoryGirl.build(:user, member_in_project: work_package.project)
  }
  let(:schema) {
    ::API::V3::WorkPackages::Schema::WorkPackageSchema.new(work_package: work_package)
  }
  let(:representer) { described_class.create(schema, current_user: current_user) }

  before do
    allow(schema.project).to receive(:backlogs_enabled?).and_return(true)
    allow(work_package.type).to receive(:backlogs_type?).and_return(true)
  end

  describe 'storyPoints' do
    subject { representer.to_json }

    it_behaves_like 'has basic schema properties' do
      let(:path) { 'storyPoints' }
      let(:type) { 'Integer' }
      let(:name) { I18n.t('activerecord.attributes.work_package.story_points') }
      let(:required) { false }
      let(:writable) { true }
    end

    context 'backlogs disabled' do
      before do
        allow(schema.project).to receive(:backlogs_enabled?).and_return(false)
      end

      it 'does not show story points' do
        is_expected.to_not have_json_path('storyPoints')
      end
    end

    context 'not a backlogs type' do
      before do
        allow(schema.type).to receive(:backlogs_type?).and_return(false)
      end

      it 'does not show story points' do
        is_expected.to_not have_json_path('storyPoints')
      end
    end
  end

  describe 'remainingTime' do
    subject { representer.to_json }

    before do
      allow(schema).to receive(:remaining_time_writable?).and_return(true)
    end

    it_behaves_like 'has basic schema properties' do
      let(:path) { 'remainingTime' }
      let(:type) { 'Duration' }
      let(:name) { I18n.t('activerecord.attributes.work_package.remaining_hours') }
      let(:required) { false }
      let(:writable) { true }
    end

    context 'backlogs disabled' do
      before do
        allow(schema.project).to receive(:backlogs_enabled?).and_return(false)
      end

      it 'does not show the remaining time' do
        is_expected.to_not have_json_path('remainingTime')
      end
    end

    context 'not a backlogs type' do
      before do
        allow(schema.type).to receive(:backlogs_type?).and_return(false)
      end

      it 'does not show the remaining time' do
        is_expected.to_not have_json_path('remainingTime')
      end
    end

    context 'remainingTime not writable' do
      before do
        allow(schema).to receive(:remaining_time_writable?).and_return(false)
      end

      it_behaves_like 'has basic schema properties' do
        let(:path) { 'remainingTime' }
        let(:type) { 'Duration' }
        let(:name) { I18n.t('activerecord.attributes.work_package.remaining_hours') }
        let(:required) { false }
        let(:writable) { false }
      end
    end
  end
end
