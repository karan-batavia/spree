require 'spec_helper'

RSpec.describe Spree::Admin::PageBlocksController, type: :controller do
  stub_authorization!
  render_views

  let(:page) { create(:page, :preview) }
  let(:theme) { create(:theme, :preview) }

  before do
    page.update!(pageable: theme.parent)

    session[:page_preview_id] = page.id
    session[:theme_preview_id] = theme.id
  end

  describe '#destroy' do
    let(:page_section) { create(:featured_taxon, pageable: page) }
    let!(:page_block) { create(:page_block, :buttons, section: page_section) }

    it 'destroys the page block' do
      delete :destroy, params: { id: page_block.id, page_section_id: page_section.id }, format: :turbo_stream

      expect(page_block.reload).to be_deleted
    end
  end

  describe '#move_higher' do
    let(:page_section) { create(:featured_taxon) }
    let!(:another_page_block) { create(:page_block, :buttons, section: page_section, position: 1) }
    let!(:page_block) { create(:page_block, :buttons, section: page_section, position: 2) }

    it 'moves the page block higher' do
      put :move_higher, params: { id: page_block.id, page_section_id: page_section.id }, format: :turbo_stream

      expect(page_block.reload.position).to eq 1
    end
  end

  describe '#move_lower' do
    let(:page_section) { create(:featured_taxon) }
    let!(:page_block) { create(:page_block, :buttons, section: page_section, position: 1) }
    let!(:another_page_block) { create(:page_block, :buttons, section: page_section, position: 2) }

    it 'moves the page block lower' do
      put :move_lower, params: { id: page_block.id, page_section_id: page_section.id }, format: :turbo_stream

      expect(page_block.reload.position).to eq 2
    end
  end

  describe '#create' do
    let(:page_section) { create(:featured_taxon) }

    it 'creates page block of the given type' do
      create_req = lambda {
        post :create, params: { page_block: { type: 'Spree::PageBlocks::Buttons' }, page_section_id: page_section.id }, format: :turbo_stream
      }

      expect(&create_req).to change(Spree::PageBlock, :count).by(1)

      expect(page_section.page_blocks.last.type).to eq 'Spree::PageBlocks::Buttons'
    end
  end
end
